{ delib, lib, ... }:
let
  mkWrapper' =
    field: obj:
    if lib.isFunction obj then
      {
        config.${field}.${(delib.callWithMocks obj).name} = delib.mirrorFunctionArgs obj (
          args: builtins.removeAttrs (obj args) [ "name" ]
        );
      }
    else
      {
        config.${field}.${obj.name} = builtins.removeAttrs obj [ "name" ];
      };

  mkWrapper =
    field: _obj:
    if lib.isString _obj then
      obj:
      mkWrapper' field (
        if lib.isFunction obj then
          delib.mirrorFunctionArgs obj (args: delib.strictMergeAttrs { name = _obj; } (obj args))
        else
          delib.strictMergeAttrs { name = _obj; } obj
      )
    else
      mkWrapper' field _obj;
in
{
  module = mkWrapper "modules";
  host = mkWrapper "hosts";
  moduleSystem = mkWrapper "moduleSystems";
  overlayModule =
    {
      name,
      overlay ? null,
      overlays ? [ ],
      targets ? null,
      withPrefix ? true,
      enabled ? true,
    }@args:
    {
      imports = [
        (
          { config, ... }:
          let
            finalOverlays = overlays ++ (lib.optional (overlay != null) overlay);
            cfg = config.simpleOvelays or (abort "import `denix.denixModules.simpleOverlays`");
            targets = args.targets or cfg.defaultTargets;
          in
          {
            config.modules.${if withPrefix then "${cfg.moduleNamePrefix}.${name}" else name} = {
              options.enable = delib.boolOption enabled;
            }
            // lib.genAttrs targets (_target: {
              ifEnabled = {
                nixpkgs.overlays = finalOverlays;
              };
            });
          }
        )
      ];
    };
}
