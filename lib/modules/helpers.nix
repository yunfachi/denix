{ delib, lib, ... }:
{
  processModule =
    f: m:
    if !lib.isFunction m then
      f m
    else if !lib.isFunction (delib.callWithMocks f) then
      delib.mirrorFunctionArgs m (args: f (m args))
    else
      delib.inheritFunctionArgs m (
        delib.mirrorFunctionArgs (delib.callWithMocks f) (args: f (m args) args)
      );

  processModuleAndGenerateDenixArgs =
    f: m: denixArgs:
    if !delib.isDenixArgs m then
      delib.processModule f m
    else
      delib.processModule f (
        if !lib.isFunction denixArgs then
          m denixArgs
        else if !lib.isFunction (delib.callWithMocks m) then
          delib.mirrorFunctionArgs denixArgs (args: m (denixArgs args))
        else
          delib.inheritFunctionArgs (delib.callWithMocks m) (
            delib.mirrorFunctionArgs denixArgs (args: m (denixArgs args) args)
          )
      );

  processModuleWithDenixArgs =
    f: m:
    delib.mirrorFunctionArgs m (delib.toDenixArgs (denixArgs: delib.processModule f (m denixArgs)));

  setDefaultModuleLocation = file: m: delib.processModule (module: { _file = file; } // module) m;

  setDefaultModuleLocationWithDenixArgs =
    file: m: delib.processModuleWithDenixArgs (module: { _file = file; } // module) m;

  addPrefixToModule =
    prefix: m:
    let
      type = m._type or "module";
      addPrefix = lib.setAttrByPath prefix;
    in
    if type == "module" && (m ? config || m ? options) then
      m
      // lib.optionalAttrs ((m.options or { }) != { }) {
        options = addPrefix m.options;
      }
      // lib.optionalAttrs ((m.config or { }) != { }) {
        config = addPrefix m.config;
      }
    else if type == "module" then
      let
        names = [
          "_class"
          "_file"
          "key"
          "disabledModules"
          "require"
          "imports"
          "freeformType"
        ];
      in
      delib.keepAttrs m names
      // lib.optionalAttrs (builtins.removeAttrs m names != { }) {
        config = addPrefix (builtins.removeAttrs m names);
      }
    else if type == "merge" then
      m
      // lib.optionalAttrs ((m.contents or [ ]) != [ ]) {
        contents = map (delib.modules.addPrefixToModule prefix) m.contents;
      }
    else if type == "if" || type == "override" then
      m
      // lib.optionalAttrs ((m.content or { }) != { }) {
        content = addPrefix m.content;
      }
    else
      throw "denix.lib.modules.addPrefixToModule: passed module does not look like a module.";
}
