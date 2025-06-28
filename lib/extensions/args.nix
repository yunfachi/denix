{delib, ...}:
delib.extension {
  name = "args";
  description = "More convenient way to configure `_module.args` via `myconfig`";
  maintainers = with delib.maintainers; [yunfachi];

  config.path = "args";

  modules = config: [
    (
      {delib, ...}:
        delib.module {
          name = config.path;

          options = with delib;
            setAttrByStrPath config.path {
              shared = attrsLegacyOption {};
              nixos = attrsLegacyOption {};
              home = attrsLegacyOption {};
              darwin = attrsLegacyOption {};
            };

          nixos.always = {cfg, ...}: {
            imports = [
              {_module.args = cfg.shared;}
              {_module.args = cfg.nixos;}
            ];
          };
          home.always = {cfg, ...}: {
            imports = [
              {_module.args = cfg.shared;}
              {_module.args = cfg.home;}
            ];
          };
          darwin.always = {cfg, ...}: {
            imports = [
              {_module.args = cfg.shared;}
              {_module.args = cfg.darwin;}
            ];
          };
        }
    )
  ];
}
