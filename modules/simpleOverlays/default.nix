{
  lib,
  config,
  delib,
}:
let
  cfg = config.simpleOvelays;
in
{
  # maintainers = with maintainers; [ zonni ];

  options.simpleOvelays = {
    defaultTargets = delib.listOfOption delib.str [ "nixos" ];
    moduleNamePrefix = delib.strOption "overlays";
  };

  config._module.args.delib.overlayModule =
    {
      name,
      overlay ? null,
      overlays ? [ ],
      targets ? cfg.defaultTargets,
      withPrefix ? true,
      enabled ? true,
    }:
    let
      finalOverlays = overlays ++ (lib.optional (overlay != null) overlay);
    in
    {
      config.modules.${if withPrefix then "${cfg.moduleNamePrefix}.${name}" else name} = {
        options.enable = delib.boolOption enabled;
      }
      // lib.genAttrs targets (target: {
        ${target}.ifEnabled = {
          nixpkgs.overlays = finalOverlays;
        };
      });
    };
}
