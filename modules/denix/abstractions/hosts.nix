{
  delib,
  lib,
  config,
  ...
}:
let
  inherit (lib.strings) escapeNixIdentifier;

  mapItem =
    hostName: moduleSystemName: pathSuffix: index: entry:
    let
      keyAttrs.key = "denix.hosts.${escapeNixIdentifier hostName}.${escapeNixIdentifier moduleSystemName}${pathSuffix}:${toString index}";
    in
    delib.processModuleAndGenerateDenixArgs (module: keyAttrs // module) entry {
      name = hostName;
    };
in
{
  options = with delib; {
    host = allowNull (
      coercedToOption (enum (builtins.attrNames config.hosts)) (
        hostName: if hostName == null then null else config.hosts.${hostName}
      ) (enum (builtins.attrValues config.hosts)) null
    );

    extraHostSubmodules = modules.coercedListOfModulesOption;

    hosts = attrsOfOption (delib.modules.denixAbstractionType {
      moduleSystems = config.moduleSystems;
      extraModules = config.extraHostSubmodules;
    }) { };
  };

  config.rawModules = lib.mapAttrs (
    moduleSystemName: moduleSystem:
    lib.concatLists (
      lib.mapAttrsToList (
        hostName: host:
        lib.imap1 (mapItem hostName moduleSystemName ".always") host.${moduleSystemName}.always
        ++ lib.optionals (config.host.name or null == hostName) (
          lib.imap1 (mapItem hostName moduleSystemName ".ifEnabled") host.${moduleSystemName}.ifEnabled
        )
        ++ lib.optionals (config.host.name or null != hostName) (
          lib.imap1 (mapItem hostName moduleSystemName ".ifDisabled") host.${moduleSystemName}.ifDisabled
        )
      ) config.hosts
    )
  ) config.moduleSystems;
}
