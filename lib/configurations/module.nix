{
  delib,
  lib,
  apply,
  myconfigName,
  ...
}:
{
  module =
    {
      name,
      options ? { },
      myconfig ? { },
      nixos ? { },
      home ? { },
      darwin ? { },
    }:
    {
      imports = [
        (
          { config, ... }:
          let
            params = delib.attrset.mkModuleArgs {
              inherit name;
              myconfig = config.${myconfigName};
            };

            inherit (params) cfg;

            wrap = x: if builtins.typeOf x == "lambda" then x params else x;

            defaults =
              {
                ifEnabled ? { },
                ifDisabled ? { },
                always ? { },
              }:
              {
                inherit ifEnabled ifDisabled always;
              };

            _myconfig = defaults myconfig;
            _nixos = defaults nixos;
            _home = defaults home;
            _darwin = defaults darwin;

            # If the `cfg.enable` option is missing, do not import ifEnabled or ifDisabled.
            enabled = delib.attrset.getAttrByStrPath "enable" cfg false;
            # Not `disabled = !enabled`, because it behaves differently when the 'enable' option is missing.
            disabled = !(delib.attrset.getAttrByStrPath "enable" cfg true);
          in
          {
            options.${myconfigName} = wrap options;

            imports =
              (apply.listOfEverything (wrap _myconfig.always) (wrap _nixos.always) (wrap _home.always) (
                wrap _darwin.always
              ))
              ++ (apply.listOfEverything (lib.mkIf enabled (wrap _myconfig.ifEnabled)) (lib.mkIf enabled (
                wrap _nixos.ifEnabled
              )) (lib.mkIf enabled (wrap _home.ifEnabled)) (lib.mkIf enabled (wrap _darwin.ifEnabled)))
              ++ (apply.listOfEverything (lib.mkIf disabled (wrap _myconfig.ifDisabled)) (lib.mkIf disabled (
                wrap _nixos.ifDisabled
              )) (lib.mkIf disabled (wrap _home.ifDisabled)) (lib.mkIf disabled (wrap _darwin.ifDisabled)));
          }
        )
      ];
    };
}
