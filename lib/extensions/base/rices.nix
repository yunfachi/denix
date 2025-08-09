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

      extraSubmodules = [ ];
    };
  };

  modules =
    extensionConfig:
    lib.optionals extensionConfig.rices.enable [
      (
        { delib, ... }:
        let
          assertionsConfig =
            { myconfig, ... }:
            {
              assertions = delib.riceNamesAssertions myconfig.rices;
            };
          assertionsModuleSystem =
            {
              nixos = "nixos";
              home-manager = "home";
              nix-darwin = "darwin";
            }
            .${extensionConfig.rices.assertions.moduleSystem} or extensionConfig.rices.assertions.moduleSystem;
        in
        delib.module (
          {
            name = "rices";

            options =
              with delib;
              let
                rice =
                  lib.singleton {
                    options = riceSubmoduleOptions;
                  }
                  ++ extensionConfig.rices.extraSubmodules;
              in
              {
                rice = riceOption rice;
                rices = ricesOption rice;
              };

            myconfig.always =
              { myconfig, ... }:
              lib.optionalAttrs extensionConfig.rices.args.enable (
                delib.setAttrByStrPath extensionConfig.rices.args.path {
                  shared = { inherit (myconfig) rice rices; };
                }
              )
              // lib.optionalAttrs (assertionsModuleSystem == "myconfig") (
                lib.optionalAttrs extensionConfig.rices.assertions.enable assertionsConfig
              );
          }
          // (lib.optionalAttrs (assertionsModuleSystem != "myconfig") {
            ${assertionsModuleSystem}.always =
              lib.optionalAttrs extensionConfig.rices.assertions.enable assertionsConfig;
          })
        )
      )
    ];
}
