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
        features = [];
        default = [];
        defaultByHostType = {};
      };

      displays = {
        enable = true;
        # TODO: hyprland = {enable = false; moduleSystem = "home";}; ...
      };
    };
  };

  libExtension = config: final: prev:
    with final; {
      generateHostType = {
        hostConfig,
        generateIsType ? config.hosts.type.generateIsType,
        types ? config.hosts.type.types,
      }:
        {
          type = noDefault (enumOption types null);
        }
        // lib.optionalAttrs generateIsType (
          builtins.listToAttrs (
            map (type: {
              name = let
                chars = lib.stringToCharacters type;
              in "is${lib.toUpper (lib.head chars) + lib.concatStrings (lib.tail chars)}";
              value = boolOption (hostConfig.type == type);
            })
            types
          )
        );

      generateHostFeatures = {
        hostConfig,
        generateIsFeatured ? config.hosts.features.generateIsFeatured,
        features ? config.hosts.features.features,
        default ? config.hosts.features.default,
        defaultByHostType ? config.hosts.features.defaultByHostType,
      }:
        {
          defaultFeatures = listOfOption (enum features) (
            default ++ (defaultByHostType.${hostConfig.type} or [])
          );
          features = listOfOption (enum features) [];
        }
        // lib.optionalAttrs generateIsFeatured (
          builtins.listToAttrs (
            map (feature: {
              name = "${feature}Featured";
              value = boolOption (builtins.elem feature (hostConfig.features ++ hostConfig.defaultFeatures));
            })
            features
          )
        );

      generateHostDisplays = {hostConfig}: {
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
        }) [];
      };
    };

  modules = config:
    lib.optionals config.hosts.enable [
      (
        {delib, ...}: let
          assertionsConfig = {myconfig, ...}: {
            assertions = delib.hostNamesAssertions myconfig.hosts;
          };
          assertionsModuleSystem =
            {
              nixos = "nixos";
              home-manager = "home";
              nix-darwin = "darwin";
            }
            .${
              config.hosts.assertions.moduleSystem
            } or config.hosts.assertions.moduleSystem;
        in
          delib.module (
            {
              name = "hosts";

              options = with delib; let
                host = {config, ...}: {
                  options =
                    hostSubmoduleOptions
                    // delib.generateHostType {hostConfig = config;}
                    // delib.generateHostFeatures {hostConfig = config;}
                    // delib.generateHostDisplays {hostConfig = config;};
                };
              in {
                host = hostOption host;
                hosts = hostsOption host;
              };

              myconfig.always = {myconfig, ...}:
                lib.optionalAttrs config.hosts.args.enable (
                  delib.setAttrByStrPath config.hosts.args.path {
                    shared = {inherit (myconfig) host hosts;};
                  }
                )
                // lib.optionalAttrs (assertionsModuleSystem == "myconfig") (
                  lib.optionalAttrs config.hosts.assertions.enable assertionsConfig
                );
            }
            // (lib.optionalAttrs (assertionsModuleSystem != "myconfig") {
              ${assertionsModuleSystem}.always =
                lib.optionalAttrs config.hosts.assertions.enable assertionsConfig;
            })
          )
      )
    ];
}
