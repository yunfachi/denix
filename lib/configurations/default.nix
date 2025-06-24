{
  delib,
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
} @ args: let
  configurations = {
    # Denix
    myconfigName ? "myconfig",
    denixLibName ? "delib",
    moduleSystem ? null, # TODO: remove the default value once the deprecated isHomeManager is removed
    extensions ? [],
    # Umport
    paths ? [],
    exclude ? [],
    recursive ? true,
    # System
    specialArgs ? {},
    extraModules ? [],
    # Inputs
    nixpkgs ? args.nixpkgs,
    home-manager ? args.home-manager,
    nix-darwin ? args.nix-darwin,
    # Home Manager
    homeManagerNixpkgs ? nixpkgs,
    homeManagerUser ? null, # not default value!
    isHomeManager ? null, # TODO: DEPRECATED since 2025/05/05
    # Dev
    mkConfigurationsSystemExtraModule ? {
      nixpkgs.hostPlatform = "x86_64-linux";
    }, # just a plug; FIXME
  } @ topArgs:
    (
      if topArgs ? isHomeManager
      then builtins.trace "'delib.configurations :: isHomeManager' is deprecated, use 'delib.configurations :: moduleSystem' with values \"nixos\", \"home\", or \"darwin\" instead."
      else _: _
    )
    (
      let
        moduleSystem =
          topArgs.moduleSystem or (
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

        mkApply = moduleSystem: useHomeManagerModule:
          import ./apply.nix {
            inherit
              useHomeManagerModule
              homeManagerUser
              moduleSystem
              myconfigName
              ;
          };
        mkDenixLib = {
          config,
          moduleSystem,
          useHomeManagerModule,
          currentHostName ? null,
        }: let
          extendedDelib = delib.extend (
            final: prev: let
              apply = mkApply moduleSystem useHomeManagerModule;
              inherit (final) _callLib;
            in {
              _callLibArgs =
                prev._callLibArgs
                // {
                  inherit
                    apply
                    config
                    myconfigName
                    currentHostName
                    ;
                };

              inherit
                (_callLib ./host.nix)
                host
                hostSubmoduleOptions
                hostOption
                hostsOption
                hostNamesAssertions
                ;
              inherit (_callLib ./module.nix) module;
              inherit
                (_callLib ./rice.nix)
                rice
                riceSubmoduleOptions
                riceOption
                ricesOption
                riceNamesAssertions
                ;
            }
          );
        in
          lib.pipe extendedDelib (
            builtins.map (extension: lib: lib.extend extension.libExtension) extensions
          );

        mkSystem = {
          moduleSystem,
          useHomeManagerModule,
          homeManagerSystem,
          currentHostName,
          internalExtraModules ? (moduleSystem_: []),
        }:
          if !topArgs ? homeManagerUser && useHomeManagerModule
          then abort "Please specify 'delib.configurations :: useHomeManagerModule'. Valid values are true and false."
          else let
            extensionsModules = builtins.concatMap (extension: extension.modules) extensions;
            nixosSystem = nixpkgs.lib.nixosSystem {
              specialArgs =
                specialArgs
                // {
                  ${denixLibName} = mkDenixLib {
                    config = nixosSystem.config;
                    moduleSystem = "nixos";
                    inherit currentHostName useHomeManagerModule;
                  };
                  inherit useHomeManagerModule; # otherwise it's impossible to make config.home-manager optional when not useHomeManagerModule.
                };
              modules =
                (internalExtraModules "nixos")
                ++ extraModules
                ++ files
                ++ (lib.optionals useHomeManagerModule [home-manager.nixosModules.home-manager])
                ++ extensionsModules;
            };
            homeSystem = home-manager.lib.homeManagerConfiguration {
              extraSpecialArgs =
                specialArgs
                // {
                  ${denixLibName} = mkDenixLib {
                    config = homeSystem.config;
                    moduleSystem = "home";
                    inherit currentHostName useHomeManagerModule;
                  };
                  inherit useHomeManagerModule; # otherwise it's impossible to make config.home-manager optional when not useHomeManagerModule.
                };
              pkgs = homeManagerNixpkgs.legacyPackages.${homeManagerSystem};
              modules = (internalExtraModules "home") ++ extraModules ++ files ++ extensionsModules;
            };
            darwinSystem = nix-darwin.lib.darwinSystem {
              specialArgs =
                specialArgs
                // {
                  ${denixLibName} = mkDenixLib {
                    config = darwinSystem.config;
                    moduleSystem = "darwin";
                    inherit currentHostName useHomeManagerModule;
                  };
                  inherit useHomeManagerModule; # otherwise it's impossible to make config.home-manager optional when not useHomeManagerModule.
                };
              # FIXME: is this really necessary?
              # pkgs = ...;
              modules =
                (internalExtraModules "darwin")
                ++ extraModules
                ++ files
                ++ (lib.optionals useHomeManagerModule [home-manager.darwinModules.home-manager])
                ++ extensionsModules;
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
          (
            {
              rices = {};
            }
            // (mkSystem {
              # TODO: maybe add moduleSystem = "empty", which "apply" would skip entirely*?
              moduleSystem = "nixos";
              useHomeManagerModule = true; # FIXME
              homeManagerSystem = "x86_64-linux"; # just a plug; FIXME
              currentHostName = null;
              internalExtraModules = _: [mkConfigurationsSystemExtraModule];
            }).config.${
              myconfigName
            }
          )
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
            inherit (host) useHomeManagerModule homeManagerSystem;
            currentHostName = host.name;
            internalExtraModules = moduleSystem: let
              apply = mkApply moduleSystem host.useHomeManagerModule;
            in
              [
                (
                  {options, ...}: {
                    config.${myconfigName} =
                      {
                        inherit host;
                      }
                      // lib.optionalAttrs (options.${myconfigName} ? rice) {inherit rice;};
                  }
                )
              ]
              ++ (lib.optionals (rice != null) (
                apply.listOfEverything rice.myconfig rice.nixos rice.home rice.darwin
              ))
              ++ builtins.concatMap (
                riceName:
                  (apply.listOfEverything rices.${riceName}.myconfig rices.${riceName}.nixos rices.${riceName}.home)
                  rices.${riceName}.darwin
              ) (rice.inherits or []);
          };
        in
          system;

        configurations = let
          mkHostAttrs = riceName: rice: hostName: host:
            lib.optionalAttrs (!rice.inheritanceOnly or false) {
              "${lib.optionalString (moduleSystem == "home") "${homeManagerUser}@"}${hostName}${
                lib.optionalString (riceName != null) "-${riceName}"
              }" = mkHost {
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
        configurations
    );
in
  configurations
