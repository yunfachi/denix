{
  delib,
  lib,
  ...
}:
delib.extension {
  name = "base";

  config = final: prev: {
    rices = {
      enable = final.enableAll;
      inherit (final) args assertions;
    };
  };

  modules = config:
    lib.optionals config.rices.enable [
      (
        {delib, ...}: let
          assertionsConfig = {myconfig, ...}: {
            assertions = delib.riceNamesAssertions myconfig.rices;
          };
          assertionsModuleSystem =
            {
              nixos = "nixos";
              home-manager = "home";
              nix-darwin = "darwin";
            }
            .${
              config.rices.assertions.moduleSystem
            } or config.rices.assertions.moduleSystem;
        in
          delib.module (
            {
              name = "rices";

              options = with delib; let
                rice = {
                  options = riceSubmoduleOptions;
                };
              in {
                rice = riceOption rice;
                rices = ricesOption rice;
              };

              myconfig.always = {myconfig, ...}:
                lib.optionalAttrs config.rices.args.enable (
                  delib.setAttrByStrPath config.rices.args.path {
                    shared = {inherit (myconfig) rice rices;};
                  }
                )
                // lib.optionalAttrs (assertionsModuleSystem == "myconfig") (
                  lib.optionalAttrs config.rices.assertions.enable assertionsConfig
                );
            }
            // (lib.optionalAttrs (assertionsModuleSystem != "myconfig") {
              ${assertionsModuleSystem}.always =
                lib.optionalAttrs config.rices.assertions.enable assertionsConfig;
            })
          )
      )
    ];
}
