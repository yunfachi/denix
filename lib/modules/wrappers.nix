{ delib, lib, ... }:
let
  mkWrapper =
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
in
{
  module = mkWrapper "modules";
  host = mkWrapper "hosts";
  moduleSystem = mkWrapper "moduleSystems";
}
