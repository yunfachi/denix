{
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.homeManager;
in
{
  options.homeManager.standalone = with delib; {
    system = allowNull (strOption null);
    user = allowNull (strOption null);

    defaultForEachUser = boolOption true;
  };

  config = {
    homeManager.standalone = {
      system = lib.mkIf (
        config.host.standaloneHomeManager.system or null != null
      ) config.host.standaloneHomeManager.system;
      user = lib.mkIf (
        config.host.standaloneHomeManager.user or null != null
      ) config.host.standaloneHomeManager.user;
    };

    extraHostSubmodules = {
      options.standaloneHomeManager = with delib; {
        system = allowNull (strOption null);
        user = allowNull (strOption null);

        users = listOfOption (enum (builtins.attrNames cfg.users)) (
          lib.optionals cfg.standalone.defaultForEachUser (builtins.attrNames cfg.users)
        );
      };
    };

    modules."home-manager".home.always =
      lib.optionals (config.moduleSystem.name == "home" && cfg.standalone.user != null)
        (
          builtins.concatMap (
            moduleSystem: config.rawModules.${moduleSystem}
          ) config.homeManager.users.${cfg.standalone.user}
        );
  };
}
