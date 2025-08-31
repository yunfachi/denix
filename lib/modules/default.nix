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
    let
      allModules = lib.attrValues configuration.config.modules;
      allModuleSystems = lib.attrValues configuration.config.moduleSystems;
    in
    { config, options, ... }@args:
    {
      imports = lib.concatMap (
        module:
        let
          moduleName = module.name;
        in
        applyOptions {
          inherit moduleName;
          inherit (module) options;
        }
        ++ applyMyConfig {
          inherit moduleName;
          inherit (module) myconfig;
        }
        ++ lib.concatMap (
          moduleSystem':
          applyModuleSystemsConfig {
            inherit moduleName;
            moduleSystem = moduleSystem'.name;
            module = module.${moduleSystem'.name};
          }
        ) allModuleSystems
      ) (map (module: delib.callDenixModule { inherit module myconfigPrefix; } args) allModules);
    };
}
