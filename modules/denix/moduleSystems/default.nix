{
  delib,
  lib,
  config,
  ...
}:
let
  defaultMyconfigPrefix = config.myconfigPrefix;
  selectedModuleSystem = config.moduleSystem;
in
{
  # TODO: system-manager, nvf, nix on droid
  imports = [
    ./darwin.nix
    ./home.nix
    ./myconfig.nix
    ./nixos.nix
  ];

  options = with delib; {
    moduleSystem = allowNull (
      coercedToOption (enum (builtins.attrNames config.moduleSystems)) (
        moduleSystemName:
        if moduleSystemName == null then null else config.moduleSystems.${moduleSystemName}
      ) (enum (builtins.attrValues config.moduleSystems)) null
    );

    moduleSystems = lazyAttrsOfOption (submoduleWith {
      modules = [
        (
          { name, config, ... }:
          {
            options = {
              name = readOnly (strOption name);
              __toString = readOnly (functionToOption str (self: self.name));

              enable = boolOption false; # enable in gen modules

              myconfigPrefix = allowNull (strOption defaultMyconfigPrefix);

              flakeOutputs = {
                modules = allowNull (strOption "${config.name}Modules");
                systems = allowNull (strOption "${config.name}Configurations");
              };

              makeSystem = allowNull (functionOption null);

              applyConfigForModuleSystem = functionToOption list (
                value: lib.optional (selectedModuleSystem.name == config.name) value
              );

              processHosts = functionOption ({configuration, forEachHost, hosts, host, fn}: if forEachHost then lib.genAttrs hosts (fn configuration) else fn configuration host);
            };
          }
        )
      ];
    }) { };
  };
}
