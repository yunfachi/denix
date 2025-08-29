{
  delib,
  lib,
  config,
  ...
}:
{
  imports = [
    ./abstractions/default.nix
    ./moduleSystems/default.nix
  ];

  options = with delib; {
    myconfigPrefix = allowNull (strOption "myconfig");

    rawModules = lib.mapAttrs (
      moduleSystemName: moduleSystem: modules.coercedListOfModulesOption
    ) config.moduleSystems;
  };
}
