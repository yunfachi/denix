{
  delib,
  lib,
  config,
  ...
}:
let
  inherit (lib.strings) escapeNixIdentifier;

  mapItem =
    moduleName: moduleSystemName: myconfigPrefix: pathSuffix: contentFn: index: entry:
    let
      myconfigPrefixWithDot = lib.optionalString (myconfigPrefix != null) "${myconfigPrefix}.";
      keyAttrs.key = "denix.modules.${escapeNixIdentifier moduleName}.${escapeNixIdentifier moduleSystemName}${pathSuffix}:${toString index}";
    in
    delib.processModuleAndGenerateDenixArgs
      (
        module:
        if !lib.isFunction (contentFn module) then
          keyAttrs // contentFn module
        else
          { config, ... }: keyAttrs // contentFn module config
      )
      entry
      (
        { config, options, ... }:
        {
          name = moduleName;
          myconfig = delib.getAttrByStrPath config myconfigPrefix { };
          myoptions = delib.getAttrByStrPath options myconfigPrefix { };
          cfg = delib.getAttrByStrPath config "${myconfigPrefixWithDot}${moduleName}" { };
          opt = delib.getAttrByStrPath options "${myconfigPrefixWithDot}${moduleName}" { };
        }
      );
in
{
  options = with delib; {
    settings.modules = {
      extraSubmodules = modules.coercedListOfModulesOption;
    };

    modules = attrsOfOption (modules.denixAbstractionType {
      moduleSystems = config.moduleSystems;
      withOptions = true;
      extraModules = config.settings.modules.extraSubmodules;
    }) { };
  };

  config.rawModules = lib.mapAttrs (
    moduleSystemName: moduleSystem:
    builtins.concatMap moduleSystem.applyConfigForModuleSystem (
      let
        myconfigPrefixWithDot = lib.optionalString (
          moduleSystem.myconfigPrefix != null
        ) "${moduleSystem.myconfigPrefix}.";
      in
      lib.concatLists (
        lib.mapAttrsToList (
          moduleName: module:
          let
            # TODO
            specialAttrs = x: delib.keepAttrs x [ "_file" ];
            nonSpecialAttrs = x: delib.removeAttrs x [ "_file" ];
          in
          let
            contentOptions =
              entry:
              (specialAttrs entry)
              // {
                options = delib.setAttrByStrPath (nonSpecialAttrs entry) moduleName;
              };
            contentAlways = entry: entry;
            contentIfEnabled =
              entry: config:
              (specialAttrs entry)
              // lib.mkIf (delib.getAttrByStrPath config "${myconfigPrefixWithDot}${moduleName}.enable" false) (
                nonSpecialAttrs entry
              );
            contentIfDisabled =
              entry: config:
              (specialAttrs entry)
              // lib.mkIf (!delib.getAttrByStrPath config "${myconfigPrefixWithDot}${moduleName}.enable" true) (
                nonSpecialAttrs entry
              );
          in
          # "options" is not a separate module system on its own, but an alias for the options of the myconfig module system.
          lib.optionals (moduleSystemName == "myconfig") (
            lib.imap1 (mapItem moduleName "options" moduleSystem.myconfigPrefix ""
              contentOptions
            ) module.options
          )
          ++ lib.imap1 (mapItem moduleName moduleSystemName moduleSystem.myconfigPrefix ".always"
            contentAlways
          ) module.${moduleSystemName}.always
          ++ lib.imap1 (mapItem moduleName moduleSystemName moduleSystem.myconfigPrefix ".ifEnabled"
            contentIfEnabled
          ) module.${moduleSystemName}.ifEnabled
          ++ lib.imap1 (mapItem moduleName moduleSystemName moduleSystem.myconfigPrefix ".ifDisabled"
            contentIfDisabled
          ) module.${moduleSystemName}.ifDisabled
        ) config.modules
      )
    )
  ) config.moduleSystems;
}
