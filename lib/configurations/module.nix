{
  delib,
  lib,
  apply,
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
        cfg = delib.attrset.getAttrByStrPath name config.${myconfigName} {};

        wrap = object:
          if builtins.typeOf object == "lambda"
          then
            object {
              inherit name cfg;
              myconfig = config.${myconfigName};
            }
          else object;

        defaults = {
          ifEnabled ? {},
          ifDisabled ? {},
          always ? {},
        }: {
          inherit ifEnabled ifDisabled always;
        };

        _myconfig = defaults myconfig;
        _nixos = defaults nixos;
        _home = defaults home;

        # If the `cfg.enable` option is missing, do not import ifEnabled or ifDisabled.
        enabled = delib.attrset.getAttrByStrPath "enable" cfg false;
        # Not `disabled = !enabled`, because it behaves differently when the 'enable' option is missing.
        disabled = !(delib.attrset.getAttrByStrPath "enable" cfg true);
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
