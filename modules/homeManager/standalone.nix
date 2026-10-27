{
  delib,
  lib,
  config,
  ...
}:
let
  hostCfg = config.host.standaloneHomeManager or null; # Hosts is optional.
  cfg = config.settings.homeManager;
in
{
  options = with delib; {
    homeManager.standalone = {
      system = allowNull (strOption (hostCfg.system or null));
      user = allowNull (strOption (hostCfg.user or null));

      defaultForEachUser = boolOption true;
    };
  };

  config = {
    settings.hosts.extraSubmodules = {
      options = with delib; {
        standaloneHomeManager = {
          system = allowNull (strOption null);
          user = allowNull (strOption null);

          users = listOfOption (enum (builtins.attrNames cfg.users)) (
            lib.optionals cfg.standalone.defaultForEachUser (builtins.attrNames cfg.users)
          );
        };
      };
    };
  };
}
