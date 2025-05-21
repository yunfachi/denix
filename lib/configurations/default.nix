{
  delib,
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}: let
  configurations = {
    myconfigName ? "myconfig",
    denixLibName ? "delib",
    homeManagerNixpkgs ? nixpkgs,
    homeManagerUser,
    moduleSystem ? null, # TODO: remove the default value once the deprecated isHomeManager is removed
    isHomeManager ? null, # TODO: DEPRECATED since 2025/05/05
    paths ? [],
    exclude ? [],
    recursive ? true,
    specialArgs ? {},
    extraModules ? [],
    mkConfigurationsSystemExtraModule ? {nixpkgs.hostPlatform = "x86_64-linux";}, # just a plug; FIXME
  } @ topArgs:
    (
      if topArgs ? isHomeManager
      then builtins.trace "'delib.configurations :: isHomeManager' is deprecated, use 'delib.configurations :: moduleSystem' with values \"nixos\", \"home\", or \"darwin\" instead."
      else _: _
    ) (let
      moduleSystem =
        topArgs.moduleSystem
        or (
          if isHomeManager == null
          then builtins.abort "Please specify 'delib.configurations :: moduleSystem'. Valid values are \"nixos\", \"home\", or \"darwin\"."
          else
            (
              if isHomeManager
              then "home"
              else "nixos"
            )
        );

      files = delib.umport {inherit paths exclude recursive;};

      mkApply = moduleSystem: import ./apply.nix {inherit lib homeManagerUser moduleSystem myconfigName;};
      mkDenixLib = {
        config,
        moduleSystem,
        currentHostName ? null,
      }:
        delib.extend (delib: _: let
          apply = mkApply moduleSystem;
          callLib = file: import file {inherit delib lib apply config myconfigName currentHostName;};
        in
          {
            # not really needed
            # inherit apply;
          }
          // callLib ./host.nix
          // callLib ./module.nix
          // callLib ./rice.nix);

      mkSystem = {
        moduleSystem,
        homeManagerSystem,
        currentHostName,
        internalExtraModules ? (moduleSystem_: []),
      }: let
        nixosSystem = lib.nixosSystem {
          specialArgs =
            specialArgs
            // {
              ${denixLibName} = mkDenixLib {
                config = nixosSystem.config;
                moduleSystem = "nixos";
                inherit currentHostName;
              };
            };
          modules = (internalExtraModules "nixos") ++ extraModules ++ files ++ [home-manager.nixosModules.home-manager];
        };
        homeSystem = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs =
            specialArgs
            // {
              ${denixLibName} = mkDenixLib {
                # FIXME: nixosSystem is used, not homeSystem, because homeManagerConfiguration causes infinite recursion (maybe I should create an issue in home-manager?)
                config = nixosSystem.config; # darwinSystem.config ?
                moduleSystem = "home";
                inherit currentHostName;
              };
            };
          pkgs = homeManagerNixpkgs.legacyPackages.${homeManagerSystem};
          modules = (internalExtraModules "home") ++ extraModules ++ files;
        };
        darwinSystem = nix-darwin.lib.darwinSystem {
          specialArgs =
            specialArgs
            // {
              ${denixLibName} = mkDenixLib {
                config = darwinSystem.config;
                moduleSystem = "darwin";
                inherit currentHostName;
              };
            };
          # FIXME: is this really necessary?
          # pkgs = ...;
          modules = (internalExtraModules "darwin") ++ extraModules ++ files ++ [home-manager.darwinModules.home-manager];
        };
      in
        {
          nixos = nixosSystem;
          home = homeSystem;
          darwin = darwinSystem;
        }
        .${
          moduleSystem
        };

      inherit
        ({rices = {};}
          // (mkSystem {
            # TODO: maybe add moduleSystem = "empty", which "apply" would skip entirely*?
            moduleSystem = "nixos";
            homeManagerSystem = "x86_64-linux"; # just a plug; FIXME
            currentHostName = null;
            internalExtraModules = _: [mkConfigurationsSystemExtraModule];
          })
          .config
          .${
            myconfigName
          })
        hosts
        rices
        ;

      mkHost = {
        host,
        rice ? null,
      }: let
        myconfig = system.config.${myconfigName};

        system = mkSystem {
          inherit moduleSystem;
          inherit (host) homeManagerSystem;
          currentHostName = host.name;
          internalExtraModules = moduleSystem: let
            apply = mkApply moduleSystem;
          in
            [
              ({options, ...}: {config.${myconfigName} = {inherit host;} // lib.optionalAttrs (options.${myconfigName} ? rice) {inherit rice;};})
            ]
            ++ (lib.optionals (rice != null) (apply.listOfEverything rice.myconfig rice.nixos rice.home rice.darwin))
            ++ builtins.concatMap (riceName: (apply.listOfEverything rices.${riceName}.myconfig rices.${riceName}.nixos rices.${riceName}.home) rices.${riceName}.darwin) (rice.inherits or []);
        };
      in
        system;

      configurations = let
        mkHostAttrs = riceName: rice: hostName: host:
          lib.optionalAttrs (!rice.inheritanceOnly or false) {
            "${lib.optionalString (moduleSystem == "home") "${homeManagerUser}@"}${hostName}${lib.optionalString (riceName != null) "-${riceName}"}" = mkHost {
              inherit host;
              rice =
                if rice == null
                then
                  (
                    if (host.rice or null) == null
                    then null
                    else rices.${host.rice}
                  )
                else rice;
            };
          };
      in
        lib.concatMapAttrs (mkHostAttrs null null) hosts
        // lib.concatMapAttrs (riceName: rice: lib.concatMapAttrs (mkHostAttrs riceName rice) hosts) rices;
    in
      configurations);
in
  configurations
