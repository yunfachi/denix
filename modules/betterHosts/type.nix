{
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.betterHosts.type;
in
with delib;
{
  options.betterHosts.type = {
    enable = boolOption true;
    generateIsType = boolOption true;
    types = listOfOption str [
      "desktop"
      "server"
    ];
  };

  config.extraHostSubmodules = lib.mkIf cfg.enable (
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
    }
  );
}
