{
  delib,
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}@args:
{
  configurations =
    {
      # Denix
      myconfigName ? "myconfig",
      denixLibName ? "delib",
      moduleSystem ? null, # TODO: remove the default value once the deprecated isHomeManager is removed
      extensions ? [ ],
      # Umport
      paths ? [ ],
      exclude ? [ ],
      recursive ? true,
      # System
      specialArgs ? { },
      extraModules ? [ ],
      # Inputs
      nixpkgs ? args.nixpkgs,
      home-manager ? args.home-manager,
      nix-darwin ? args.nix-darwin,
      # Home Manager
      homeManagerNixpkgs ? nixpkgs,
      homeManagerUser ? null, # not default value!
      useHomeManagerModule ? true,
      isHomeManager ? null, # TODO: DEPRECATED since 2025/05/05
      # Dev
      mkConfigurationsSystemExtraModule ?
        { config, ... }:
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          ${myconfigName}.host = builtins.elemAt (builtins.attrValues config.${myconfigName}.hosts) 0;
        }, # just a plug; FIXME
    }@topArgs:
    (
      if topArgs ? isHomeManager then
        builtins.trace "'delib.configurations :: isHomeManager' is deprecated, use 'delib.configurations :: moduleSystem' with values \"nixos\", \"home\", or \"darwin\" instead."
      else
        _: _
    )
      (
        let
          moduleSystem =
            topArgs.moduleSystem or (
              if isHomeManager == null then
                builtins.abort "Please specify 'delib.configurations :: moduleSystem'. Valid values are \"nixos\", \"home\", or \"darwin\"."
              else
                (if isHomeManager then "home" else "nixos")
            );

          files = delib.umport { inherit paths exclude recursive; };

          mkApply =
            moduleSystem: homeManagerUser: useHomeManagerModule:
            import ./apply.nix {
              inherit
                useHomeManagerModule
                homeManagerUser
                moduleSystem
                myconfigName
                ;
            };
          mkDenixLib =
            {
              config,
              moduleSystem,
              useHomeManagerModule,
              homeManagerUser,
              currentHostName ? null,
            }:
            let
              extendedDelib = delib.recursivelyExtend (
                final: prev:
                let
                  apply = mkApply moduleSystem homeManagerUser useHomeManagerModule;
                  inherit (final) _callLib;
                in
                {
                  _callLibArgs = prev._callLibArgs // {
                    inherit
                      apply
                      config
                      myconfigName
                      currentHostName
                      useHomeManagerModule
                      homeManagerUser
                      ;
                  };

                  inherit (_callLib ./host.nix)
                    host
                    hostSubmoduleOptions
                    hostOption
                    hostsOption
                    hostNamesAssertions
                    ;

                  inherit (_callLib ./module.nix) module;

                  inherit (_callLib ./rice.nix)
                    rice
                    riceSubmoduleOptions
                    riceOption
                    ricesOption
                    riceNamesAssertions
                    ;
                }
              );
            in
            extendedDelib.withExtensions extensions;

          mkSystem =
            {
              moduleSystem,
              useHomeManagerModule,
              homeManagerUser,
              homeManagerSystem,
              currentHostName,
              isInternal ? false,
              internalExtraModules ? (moduleSystem_: [ ]),
            }@args:
            if homeManagerUser == null && (useHomeManagerModule || moduleSystem == "home") then
              abort "Please specify 'delib.configurations :: homeManagerUser' or 'delib.host :: homeManagerUser'."
            else
              let
                useHomeManagerModule =
                  if isInternal then topArgs.useHomeManagerModule or true else args.useHomeManagerModule;
                homeManagerUser = if isInternal then topArgs.homeManagerUser or null else args.homeManagerUser;

                extensionsModules = builtins.concatMap (extension: extension.modules) extensions;
                nixosSystem = nixpkgs.lib.nixosSystem {
                  specialArgs = specialArgs // {
                    ${denixLibName} = mkDenixLib {
                      config = nixosSystem.config;
                      moduleSystem = "nixos";
                      inherit currentHostName useHomeManagerModule homeManagerUser;
                    };
                    inherit useHomeManagerModule homeManagerUser; # otherwise it's impossible to make config.home-manager optional when not useHomeManagerModule.
                  };
                  modules =
                    (internalExtraModules "nixos")
                    ++ extraModules
                    ++ files
                    ++ (lib.optionals useHomeManagerModule [ home-manager.nixosModules.home-manager ])
                    ++ extensionsModules;
                };
                homeSystem = home-manager.lib.homeManagerConfiguration {
                  extraSpecialArgs = specialArgs // {
                    ${denixLibName} = mkDenixLib {
                      config = homeSystem.config;
                      moduleSystem = "home";
                      inherit currentHostName useHomeManagerModule homeManagerUser;
                    };
                    inherit useHomeManagerModule homeManagerUser; # otherwise it's impossible to make config.home-manager optional when not useHomeManagerModule.
                  };
                  pkgs = homeManagerNixpkgs.legacyPackages.${homeManagerSystem};
                  modules = (internalExtraModules "home") ++ extraModules ++ files ++ extensionsModules;
                };
                darwinSystem = nix-darwin.lib.darwinSystem {
                  specialArgs = specialArgs // {
                    ${denixLibName} = mkDenixLib {
                      config = darwinSystem.config;
                      moduleSystem = "darwin";
                      inherit currentHostName useHomeManagerModule homeManagerUser;
                    };
                    inherit useHomeManagerModule homeManagerUser; # otherwise it's impossible to make config.home-manager optional when not useHomeManagerModule.
                  };
                  # FIXME: is this really necessary?
                  # pkgs = ...;
                  modules =
                    (internalExtraModules "darwin")
                    ++ extraModules
                    ++ files
                    ++ (lib.optionals useHomeManagerModule [ home-manager.darwinModules.home-manager ])
                    ++ extensionsModules;
                };
              in
              {
                nixos = nixosSystem;
                home = homeSystem;
                darwin = darwinSystem;
              }
              .${moduleSystem};

          inherit
            (
              {
                rices = { };
              }
              // (mkSystem {
                # TODO: maybe add moduleSystem = "empty", which "apply" would skip entirely*?
                moduleSystem = "nixos";
                useHomeManagerModule = topArgs.useHomeManagerModule; # FIXME
                homeManagerUser = "user";
                homeManagerSystem = "x86_64-linux"; # just a plug; FIXME
                currentHostName = null;
                isInternal = true;
                internalExtraModules = _: [ mkConfigurationsSystemExtraModule ];
              }).config.${myconfigName}
            )
            hosts
            rices
            ;

          mkHost =
            {
              host,
              rice ? null,
            }:
            let
              myconfig = system.config.${myconfigName};

              system = mkSystem {
                inherit moduleSystem;
                inherit (host) useHomeManagerModule homeManagerUser homeManagerSystem;
                currentHostName = host.name;
                internalExtraModules =
                  moduleSystem:
                  let
                    apply = mkApply moduleSystem host.homeManagerUser host.useHomeManagerModule;
                  in
                  [
                    (
                      { options, ... }:
                      {
                        config.${myconfigName} = {
                          inherit host;
                        }
                        // lib.optionalAttrs (options.${myconfigName} ? rice) { inherit rice; };
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
                  ) (rice.inherits or [ ]);
              };
            in
            system;

          configurations =
            let
              mkHostAttrs =
                riceName: rice: hostName: host:
                lib.optionalAttrs (!rice.inheritanceOnly or false) {
                  "${lib.optionalString (moduleSystem == "home") "${host.homeManagerUser}@"}${hostName}${
                    lib.optionalString (riceName != null) "-${riceName}"
                  }" =
                    mkHost {
                      inherit host;
                      rice =
                        if rice == null then (if (host.rice or null) == null then null else rices.${host.rice}) else rice;
                    };
                };
            in
            lib.concatMapAttrs (mkHostAttrs null null) hosts
            // lib.concatMapAttrs (riceName: rice: lib.concatMapAttrs (mkHostAttrs riceName rice) hosts) rices;
        in
        configurations
      );
}
