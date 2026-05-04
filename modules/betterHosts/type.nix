{
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.settings.betterHosts.type;
in
with delib;
{
  options.settings.betterHosts.type = {
    enable = boolOption true;
    generateIsType = boolOption true;
    types = listOfOption str [
      "desktop"
      "server"
    ];
  };

  config = lib.mkIf cfg.enable {
    settings.hosts.extraSubmodules =
      { config, ... }:
      {
        options =
          delib.strictMergeAttrs
            {
              type = allowNull (enumOption cfg.types null);
            }
            (
              lib.optionalAttrs cfg.generateIsType (
                lib.genAttrs' cfg.types (type: {
                  name =
                    let
                      chars = lib.stringToCharacters type;
                    in
                    "is${lib.toUpper (lib.head chars) + lib.concatStrings (lib.tail chars)}";
                  value = boolOption (config.type == type);
                })
              )
            );
      };
  };
}
