{
  lib,
  apply,
  config,
  myconfigName,
  ...
}: let
  getAttrByStrPath = strPath: attrset: default:
    lib.attrByPath (lib.splitString "." strPath) default attrset;
in {
  module = {
    name,
    options ? {},
    myconfig ? {},
    nixos ? {},
    home ? {},
  }: let
    cfg = getAttrByStrPath name config.${myconfigName} {};

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

    enabled = getAttrByStrPath "enable" cfg false;
    disabled = !(getAttrByStrPath "enable" cfg true);
  in {
    options.${myconfigName} = wrap options;

    imports = [
      (apply.myconfig (wrap _myconfig.always))
      (apply.nixos (wrap _nixos.always))
      (apply.home (wrap _home.always))
      (lib.mkIf enabled (apply.myconfig (wrap _myconfig.ifEnabled)))
      (lib.mkIf enabled (apply.nixos (wrap _nixos.ifEnabled)))
      (lib.mkIf enabled (apply.home (wrap _home.ifEnabled)))
      (lib.mkIf disabled (apply.myconfig (wrap _myconfig.ifDisabled)))
      (lib.mkIf disabled (apply.nixos (wrap _nixos.ifDisabled)))
      (lib.mkIf disabled (apply.home (wrap _home.ifDisabled)))
    ];
  };
}
