{
  delib,
  lib,
  ...
}:
delib.extension {
  name = "base";

  config = final: prev: {
    hosts = {
      enable = final.enableAll;
      inherit (final) args assertions;

      type = {
        enable = true;
        generateIsType = true;
        types = [
          "desktop"
          "server"
        ];
      };

      features = {
        enable = true;
        generateIsFeatured = true;
        features = [ ];
        default = [ ];
        defaultByHostType = { };
      };

      system = {
        enable = true;
      };

      displays = {
        enable = true;
        # TODO: hyprland = {enable = false; moduleSystem = "home";}; ...
      };

      extraSubmodules = [ ];
    };
  };

  libExtension =
    extensionConfig: final: prev: with final; {
      generateHostTypeSubmodule =
        {
          generateIsType ? extensionConfig.hosts.type.generateIsType,
          types ? extensionConfig.hosts.type.types,
        }:
        { config, ... }:
        {
          options = {
            type = noDefault (enumOption types null);
          }
          // lib.optionalAttrs generateIsType (
            builtins.listToAttrs (
              map (type: {
                name =
                  let
                    chars = lib.stringToCharacters type;
                  in
                  "is${lib.toUpper (lib.head chars) + lib.concatStrings (lib.tail chars)}";
                value = boolOption (config.type == type);
              }) types
            )
          );
        };

      generateHostFeaturesSubmodule =
        {
          generateIsFeatured ? extensionConfig.hosts.features.generateIsFeatured,
          features ? extensionConfig.hosts.features.features,
          default ? extensionConfig.hosts.features.default,
          defaultByHostType ? extensionConfig.hosts.features.defaultByHostType,
        }:
        { config, ... }:
        {
          options = {
            defaultFeatures = listOfOption (enum features) (
              default ++ (defaultByHostType.${config.type} or [ ])
            );
            features = listOfOption (enum features) [ ];
          }
          // lib.optionalAttrs generateIsFeatured (
            builtins.listToAttrs (
              map (feature: {
                name = "${feature}Featured";
                value = boolOption (builtins.elem feature (config.features ++ config.defaultFeatures));
              }) features
            )
          );
        };

      generateHostDisplaysSubmodule =
        _:
        { config, ... }:
        {
          options.displays = listOfOption (submodule {
            options = {
              enable = boolOption true;

              name = noDefault (strOption null);
              primary = boolOption (builtins.length config.displays == 1);
              touchscreen = boolOption false;

              refreshRate = intOption 60;
              width = intOption 1920;
              height = intOption 1080;
              x = intOption 0;
              y = intOption 0;
            };
          }) [ ];
        };

      generateHostSystemSubmodule =
        _:
        { config, lib, ... }:
        {
          options.system = allowNull (strOption null);

          config.homeManagerSystem = lib.mkIf (config.system != null) config.system;
        };
    };

  modules =
    extensionConfig:
    lib.optionals extensionConfig.hosts.enable [
      (
        { delib, lib, ... }:
        let
          assertionsConfig =
            { myconfig, ... }:
            {
              assertions = delib.hostNamesAssertions myconfig.hosts;
            };
          assertionsModuleSystem =
            {
              nixos = "nixos";
              home-manager = "home";
              nix-darwin = "darwin";
            }
            .${extensionConfig.hosts.assertions.moduleSystem} or extensionConfig.hosts.assertions.moduleSystem;
        in
        delib.module (
          {
            name = "hosts";

            options =
              with delib;
              let
                host = [
                  { options = hostSubmoduleOptions; }
                ]
                ++ lib.optionals extensionConfig.hosts.type.enable [ (delib.generateHostTypeSubmodule { }) ]
                ++ lib.optionals extensionConfig.hosts.features.enable [ (delib.generateHostFeaturesSubmodule { }) ]
                ++ lib.optionals extensionConfig.hosts.displays.enable [ (delib.generateHostDisplaysSubmodule { }) ]
                ++ lib.optionals extensionConfig.hosts.system.enable [ (delib.generateHostSystemSubmodule { }) ]
                ++ extensionConfig.hosts.extraSubmodules;
              in
              {
                host = hostOption host;
                hosts = hostsOption host;
              };

            nixos.always =
              { myconfig, ... }:
              lib.optionalAttrs extensionConfig.hosts.system.enable {
                nixpkgs.hostPlatform = lib.mkIf (
                  delib._callLibArgs.currentHostName != null
                  && myconfig.hosts.${delib._callLibArgs.currentHostName}.system != null
                ) myconfig.hosts.${delib._callLibArgs.currentHostName}.system;
              };

            darwin.always =
              { myconfig, ... }:
              lib.optionalAttrs extensionConfig.hosts.system.enable {
                nixpkgs.hostPlatform = lib.mkIf (
                  delib._callLibArgs.currentHostName != null
                  && myconfig.hosts.${delib._callLibArgs.currentHostName}.system != null
                ) myconfig.hosts.${delib._callLibArgs.currentHostName}.system;
              };

            myconfig.always =
              { myconfig, ... }:
              lib.optionalAttrs extensionConfig.hosts.args.enable (
                delib.setAttrByStrPath extensionConfig.hosts.args.path {
                  shared = { inherit (myconfig) host hosts; };
                }
              )
              // lib.optionalAttrs (assertionsModuleSystem == "myconfig") (
                lib.optionalAttrs extensionConfig.hosts.assertions.enable assertionsConfig
              );
          }
          // (lib.optionalAttrs (assertionsModuleSystem != "myconfig") {
            ${assertionsModuleSystem}.always =
              lib.optionalAttrs extensionConfig.hosts.assertions.enable assertionsConfig;
          })
        )
      )
    ];
}
