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

      displays = {
        enable = true;
        # TODO: hyprland = {enable = false; moduleSystem = "home";}; ...
      };

      extraSubmodules = [ ];
    };
  };

  libExtension =
    extensionConfig: final: prev: with final; {
      generateHostType =
        {
          hostConfig,
          generateIsType ? extensionConfig.hosts.type.generateIsType,
          types ? extensionConfig.hosts.type.types,
        }:
        {
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
              value = boolOption (hostConfig.type == type);
            }) types
          )
        );

      generateHostFeatures =
        {
          hostConfig,
          generateIsFeatured ? extensionConfig.hosts.features.generateIsFeatured,
          features ? extensionConfig.hosts.features.features,
          default ? extensionConfig.hosts.features.default,
          defaultByHostType ? extensionConfig.hosts.features.defaultByHostType,
        }:
        {
          defaultFeatures = listOfOption (enum features) (
            default ++ (defaultByHostType.${hostConfig.type} or [ ])
          );
          features = listOfOption (enum features) [ ];
        }
        // lib.optionalAttrs generateIsFeatured (
          builtins.listToAttrs (
            map (feature: {
              name = "${feature}Featured";
              value = boolOption (builtins.elem feature (hostConfig.features ++ hostConfig.defaultFeatures));
            }) features
          )
        );

      generateHostDisplays =
        { hostConfig }:
        {
          displays = listOfOption (submodule {
            options = {
              enable = boolOption true;

              name = noDefault (strOption null);
              primary = boolOption (builtins.length hostConfig.displays == 1);
              touchscreen = boolOption false;

              refreshRate = intOption 60;
              width = intOption 1920;
              height = intOption 1080;
              x = intOption 0;
              y = intOption 0;
            };
          }) [ ];
        };
    };

  modules =
    extensionConfig:
    lib.optionals extensionConfig.hosts.enable [
      (
        { delib, ... }:
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
                host =
                  lib.singleton (
                    { config, ... }:
                    {
                      options =
                        hostSubmoduleOptions
                        // delib.generateHostType { hostConfig = config; }
                        // delib.generateHostFeatures { hostConfig = config; }
                        // delib.generateHostDisplays { hostConfig = config; };
                    }
                  )
                  ++ extensionConfig.hosts.extraSubmodules;
              in
              {
                host = hostOption host;
                hosts = hostsOption host;
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
