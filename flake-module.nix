self:
{
  lib,
  delib,
  config,
  options,
  ...
}:
{
  config._module.args.delib = self.lib;

  options = with delib; {
    denixSettings = {
      denixConfigurationExtraArgs = attrsOption { };
      generateSystems = boolOption true;
      generateSystemsArgs = attrsOption {
        forEachModuleSystem = true;
        forEachHost = true;
      };
      generateModules = boolOption true;
      generateModulesArgs = attrsOption {
        forEachModuleSystem = true;
        forEachHost = true;
      };
    };

    denixConfiguration = attrsOption options.denix.valueMeta.configuration;
    # denixConfiguration.config
    denix = modules.denixConfigurationSubmoduleOption config.denixSettings.denixConfigurationExtraArgs;
  };

  config.flake = lib.mkMerge (
    (lib.optional config.denixSettings.generateModules (
      config.denixConfiguration.genModules config.denixSettings.generateModulesArgs
    ))
    ++ (lib.optional config.denixSettings.generateSystems (
      config.denixConfiguration.genSystems config.denixSettings.generateSystemsArgs
    ))
  );
}
