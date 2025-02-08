{
  delib,
  lib,
  apply,
  myconfigName,
  ...
}: {
  module = {
    name,
    feature ? null,
    options ? {},
    myconfig ? {},
    nixos ? {},
    home ? {},
  }: {
    imports = [
      ({config, ...}: let
        cfg = delib.attrset.getAttrByStrPath name config.${myconfigName} {};

        wrap = x:
          if builtins.typeOf x == "lambda"
          then
            x {
              inherit name cfg featured;
              myconfig = config.${myconfigName};
            }
          else x;

        defaults = {
          ifEnabled ? {},
          ifDisabled ? {},
          ifFeatured ? {},
          always ? {},
        }: {inherit ifEnabled ifDisabled ifFeatured always;};
        _myconfig = defaults myconfig;
        _nixos = defaults nixos;
        _home = defaults home;

        enabled = delib.attrset.getAttrByStrPath "enable" cfg false;
        disabled = !(delib.attrset.getAttrByStrPath "enable" cfg true);
        featured = enabled && lib.lists.elem feature (delib.attrset.getAttrByStrPath "features" cfg [ ]);
      in {
        options.${myconfigName} = wrap options;

        imports = [
          (apply.all (wrap _myconfig.always) (wrap _nixos.always) (wrap _home.always))
          (lib.mkIf enabled (apply.all (wrap _myconfig.ifEnabled) (wrap _nixos.ifEnabled) (wrap _home.ifEnabled)))
          (lib.mkIf disabled (apply.all (wrap _myconfig.ifDisabled) (wrap _nixos.ifDisabled) (wrap _home.ifDisabled)))
          (lib.mkIf featured (apply.all (wrap _myconfig.ifFeatured) (wrap _nixos.ifFeatured) (wrap _home.ifFeatured)))
        ];
      })
    ];
  };
}
