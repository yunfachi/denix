{
  delib,
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}:
{
  denixConfiguration =
    {
      modules ? [ ],
      specialArgs ? { },
    }:
    lib.evalModules {
      modules = [ ./config/denix.nix ] ++ modules;

      specialArgs = {
        inherit nixpkgs home-manager nix-darwin;
      }
      // lib.recursiveUpdate {
        inherit delib;
      } specialArgs;
    };

  callDenixModule =
    { module, myconfigPrefix }:
    { config, options, ... }:
    delib.fix (
      self:
      let
        modulePath = lib.optionalString (myconfigPrefix != null) "${myconfigPrefix}." + self.name;
      in
      module {
        inherit (self) name;
        cfg = delib.getAttrByStrPath config modulePath { };
        opt = delib.getAttrByStrPath options modulePath { };
      }
    );

  compileModule =
    {
      configuration,
      moduleSystem,
      myconfigPrefix ? configuration.config.moduleSystems.${moduleSystem}.myconfigPrefix,
      applyModuleSystemsConfig ?
        configuration.config.moduleSystems.${moduleSystem}.applyModuleSystemsConfig,
      applyOptions ? configuration.config.moduleSystems.${moduleSystem}.applyOptions,
      applyMyConfig ? configuration.config.moduleSystems.${moduleSystem}.applyMyConfig,
    }:
    (
      let
        allModules = lib.attrValues configuration.config.modules;
        allModuleSystems = lib.attrNames configuration.config.moduleSystems;
      in
      {
        imports = lib.concatMap (
          module:
          let
            fakeCalled = delib.callDenixModule { inherit module myconfigPrefix; } {
              config = { };
              options = { };
            };
            genModulesWithCalled =
              y:
              lib.genList (
                index:
                { config, options, ... }@args:
                let
                  called = delib.callDenixModule { inherit module myconfigPrefix; } args;
                in
                y index called
              );
          in
          genModulesWithCalled (
            index: called:
            applyOptions {
              inherit myconfigPrefix;
              moduleName = called.name;
              value = lib.elemAt called.options index;
            }
          ) (lib.length fakeCalled.options)
          ++ lib.concatMap (
            moduleSystem':
            genModulesWithCalled (
              index: called:
              applyModuleSystemsConfig {
                inherit myconfigPrefix;
                moduleSystem = moduleSystem';
                moduleName = called.name;
                value = lib.elemAt called.${moduleSystem'}.always index;
                type = "always";
              }
            ) (lib.length fakeCalled.${moduleSystem'}.always)
            ++ genModulesWithCalled (
              index: called:
              applyModuleSystemsConfig {
                inherit myconfigPrefix;
                moduleSystem = moduleSystem';
                moduleName = called.name;
                value = lib.elemAt called.${moduleSystem'}.ifEnabled index;
                type = "ifEnabled";
              }
            ) (lib.length fakeCalled.${moduleSystem'}.ifEnabled)
            ++ genModulesWithCalled (
              index: called:
              applyModuleSystemsConfig {
                inherit myconfigPrefix;
                moduleSystem = moduleSystem';
                moduleName = called.name;
                value = lib.elemAt called.${moduleSystem'}.ifDisabled index;
                type = "ifDisabled";
              }
            ) (lib.length fakeCalled.${moduleSystem'}.ifDisabled)
          ) allModuleSystems
        ) allModules;
      }
    );
}
