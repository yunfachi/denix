{
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.betterHosts.features;
in
with delib;
{
  options.betterHosts.features = {
    enable = boolOption true;
    generateIsFeatured = boolOption true;
    features = listOfOption str [ ];
    default = listOfOption str [ ];
    defaultByHostType = attrsOfOption (listOf str) { };
  };

  config.extraHostSubmodules = lib.mkIf cfg.enable (
    { config, ... }:
    {
      options =
        delib.strictMergeAttrs
          {
            features = listOfOption (enum cfg.features) [ ];
            defaultFeatures = listOfOption (enum cfg.features) (
              cfg.default ++ (if config.type or null != null then cfg.defaultByHostType.${config.type} or [ ] else [ ])
            );
          }
          (
            lib.optionalAttrs cfg.generateIsFeatured (
              lib.genAttrs' cfg.features (feature: {
                name = "${feature}Featured";
                value = boolOption (builtins.elem feature (config.features ++ config.defaultFeatures));
              })
            )
          );
    }
  );
}
