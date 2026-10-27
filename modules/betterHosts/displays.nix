{
  delib,
  lib,
  config,
  ...
}:
let
  cfg = config.settings.betterHosts.displays;
in
with delib;
{
  options.settings.betterHosts.displays = {
    enable = boolOption true;
  };

  config = lib.mkIf cfg.enable {
    settings.hosts.extraSubmodules = {
      options = {
        displays = attrsOfOption (submodule (
          { name, ... }: {
            options = {
              enable = boolOption true;
              output = strOption name;
              width = intOption 1920;
              height = intOption 1080;
              refreshRate = intOption 60;
            };
          }
        )) { };
      };
    };
  };
}
