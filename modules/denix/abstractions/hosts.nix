{
  delib,
  lib,
  config,
  ...
}:
let
  inherit (lib.strings) escapeNixIdentifier;

  mapItem =
    hostName: moduleSystemName: myconfigPrefix: pathSuffix: index: entry:
    let
      keyAttrs.key = "denix.hosts.${escapeNixIdentifier hostName}.${escapeNixIdentifier moduleSystemName}${pathSuffix}:${toString index}";
    in
    delib.processModuleAndGenerateDenixArgs (module: keyAttrs // module) entry (
      { config, options, ... }:
      {
        name = hostName;
        myconfig = delib.getAttrByStrPath config myconfigPrefix { };
        myoptions = delib.getAttrByStrPath options myconfigPrefix { };
      }
    );
in
{
  options = with delib; {
    settings.hosts = {
      extraSubmodules = modules.coercedListOfModulesOption;
      defaultModuleSystems = listOfOption (enum (builtins.attrNames config.moduleSystems)) [ ];
    };

    host = allowNull (
      coercedToOption (enum (builtins.attrNames config.hosts)) (
        hostName: if hostName == null then null else config.hosts.${hostName}
      ) (enum (builtins.attrValues config.hosts)) null
    );

    hosts = attrsOfOption (modules.denixAbstractionType {
      moduleSystems = config.moduleSystems;
      extraModules = [
        {
          options = {
            moduleSystems = listOfOption (enum (builtins.attrNames config.moduleSystems)) config.settings.hosts.defaultModuleSystems;
          };
        }
      ]
      ++ config.settings.hosts.extraSubmodules;
    }) { };
  };

  config.rawModules = lib.mapAttrs (
    moduleSystemName: moduleSystem:
    builtins.concatMap moduleSystem.applyConfigForModuleSystem (
      lib.concatLists (
        lib.mapAttrsToList (
          hostName: host:
          lib.imap1 (mapItem hostName moduleSystemName moduleSystem.myconfigPrefix
            ".always"
          ) host.${moduleSystemName}.always
          ++ lib.optionals (config.host.name or null == hostName) (
            lib.imap1 (mapItem hostName moduleSystemName moduleSystem.myconfigPrefix
              ".ifEnabled"
            ) host.${moduleSystemName}.ifEnabled
          )
          ++ lib.optionals (config.host.name or null != hostName) (
            lib.imap1 (mapItem hostName moduleSystemName moduleSystem.myconfigPrefix
              ".ifDisabled"
            ) host.${moduleSystemName}.ifDisabled
          )
        ) config.hosts
      )
    )
  ) config.moduleSystems;
}
