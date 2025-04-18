{
  delib,
  lib,
  nixpkgs,
  home-manager,
  ...
}: let
  configurations = {
    myconfigName ? "myconfig",
    denixLibName ? "delib",
    homeManagerNixpkgs ? nixpkgs,
    homeManagerUser,
    isHomeManager,
    paths ? [],
    exclude ? [],
    recursive ? true,
    specialArgs ? {},
    extraModules ? [],
    mkConfigurationsSystemExtraModule ? {nixpkgs.hostPlatform = "x86_64-linux";}, # just a plug; FIXME
  } @ topArgs: let
    files = delib.umport {inherit paths exclude recursive;};

    mkApply = isHomeManager: import ./apply.nix {inherit lib homeManagerUser isHomeManager myconfigName;};
    mkDenixLib = {
      config,
      isHomeManager,
      currentHostName ? null,
    }:
      delib.extend (delib: _: let
        apply = mkApply isHomeManager;
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
      isHomeManager,
      homeManagerSystem,
      currentHostName,
      internalExtraModules ? (_: []),
    }: let
      nixosSystem = lib.nixosSystem {
        specialArgs =
          specialArgs
          // {
            ${denixLibName} = mkDenixLib {
              config = nixosSystem.config;
              isHomeManager = false;
              inherit currentHostName;
            };
          };
        modules = (internalExtraModules false) ++ extraModules ++ files ++ [home-manager.nixosModules.home-manager];
      };
      homeSystem = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs =
          specialArgs
          // {
            ${denixLibName} = mkDenixLib {
              # FIXME: nixosSystem is used, not homeSystem, because homeManagerConfiguration causes infinite recursion (maybe I should create an issue in home-manager?)
              config = nixosSystem.config;
              isHomeManager = true;
              inherit currentHostName;
            };
          };
        pkgs = homeManagerNixpkgs.legacyPackages.${homeManagerSystem};
        modules = (internalExtraModules true) ++ extraModules ++ files;
      };
    in
      if isHomeManager
      then homeSystem
      else nixosSystem;

    inherit
      ({rices = {};}
        // (mkSystem {
          isHomeManager = false;
          homeManagerSystem = "x86_64-linux"; # just a plug; FIXME
          currentHostName = null;
          internalExtraModules = _: [mkConfigurationsSystemExtraModule];
        })
        .config
        .${myconfigName})
      hosts
      rices
      ;

    mkHost = {
      host,
      rice ? null,
    }: let
      myconfig = system.config.${myconfigName};

      system = mkSystem {
        inherit isHomeManager;
        inherit (host) homeManagerSystem;
        currentHostName = host.name;
        internalExtraModules = _isHomeManager: let
          apply = mkApply _isHomeManager;
        in
          [
            ({options, ...}: {config.${myconfigName} = {inherit host;} // lib.optionalAttrs (options.${myconfigName} ? rice) {inherit rice;};})
          ]
          ++ (lib.optionalAttrs (rice != null) (apply.listOfEverything rice.myconfig rice.nixos rice.home))
          ++ builtins.concatMap (riceName: (apply.listOfEverything rices.${riceName}.myconfig rices.${riceName}.nixos rices.${riceName}.home)) (rice.inherits or []);
      };
    in
      system;

    configurations = let
      mkHostAttrs = riceName: rice: hostName: host:
        lib.optionalAttrs (!rice.inheritanceOnly or false) {
          "${lib.optionalString isHomeManager "${homeManagerUser}@"}${hostName}${lib.optionalString (riceName != null) "-${riceName}"}" = mkHost {
            inherit host;
            rice =
              if rice == null
              then
                (
                  if host.rice == null
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
    configurations;
in
  configurations
