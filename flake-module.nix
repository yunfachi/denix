self:
{
  lib,
  delib,
  config,
  options,
  inputs,
  extendModules,
  ...
}:
let
  cfg = config.denixSettings;
in
{
  config._module.args.delib = self.lib;

  options = with delib; {
    denixSettings = {
      denixConfigurationExtraArgs = attrsOption { };
      passInputs = boolOption true;
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
    denix = modules.denixConfigurationSubmoduleOption (
      cfg.denixConfigurationExtraArgs
      // lib.optionalAttrs cfg.passInputs {
        extraInputs = cfg.denixConfigurationExtraArgs.extraInputs or { } // inputs;
      }
    );
  };

  config.flake = lib.mkMerge (
    (lib.optional cfg.generateModules (
      config.denixConfiguration.genModules (
        {
          configurationExtendModules =
            _configuration: modules:
            (extendModules { modules = [ { config.denix.imports = modules; } ]; }).config.denixConfiguration;
        }
        // cfg.generateSystemsArgs
      )
    ))
    ++ (lib.optional cfg.generateSystems (
      config.denixConfiguration.genSystems (
        {
          configurationExtendModules =
            _configuration: modules:
            (extendModules { modules = [ { config.denix.imports = modules; } ]; }).config.denixConfiguration;
        }
        // cfg.generateSystemsArgs
      )
    ))
  );
}
