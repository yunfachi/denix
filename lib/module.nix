{
  lib,
  apply,
  attrset,
  myconfigName,
  ...
}: {
  module = {
    name,
    options ? {},
    myconfig ? {},
    nixos ? {},
    home ? {},
  }: {
    imports = [
      ({config, ...}: let
        cfg = attrset.getAttrByStrPath name config.${myconfigName} {};

        wrap = x:
          if builtins.typeOf x == "lambda"
          then
            x {
              inherit name cfg;
              myconfig = config.${myconfigName};
            }
          else x;

        defaults = {
          ifEnabled ? {},
          ifDisabled ? {},
          always ? {},
        }: {inherit ifEnabled ifDisabled always;};
        _myconfig = defaults myconfig;
        _nixos = defaults nixos;
        _home = defaults home;

        enabled = attrset.getAttrByStrPath "enable" cfg false;
        disabled = !(attrset.getAttrByStrPath "enable" cfg true);
      in {
        options.${myconfigName} = wrap options;

        imports = [
          (apply.all (wrap _myconfig.always) (wrap _nixos.always) (wrap _home.always))
          (lib.mkIf enabled (apply.all (wrap _myconfig.ifEnabled) (wrap _nixos.ifEnabled) (wrap _home.ifEnabled)))
          (lib.mkIf disabled (apply.all (wrap _myconfig.ifDisabled) (wrap _nixos.ifDisabled) (wrap _home.ifDisabled)))
        ];
      })
    ];
  };
}
