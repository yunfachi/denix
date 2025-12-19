{ delib, lib, ... }:
{
  coercedListOfModules = lib.mkOptionType {
    name = "listOfModules";
    check = x: lib.isList x || lib.isAttrs x || lib.isFunction x || lib.path.check x;
    merge =
      loc: defs:
      lib.concatMap (
        def:
        map (delib.setDefaultModuleLocation def.file
          #"${def.file}, via option ${lib.showOption loc}"
        ) (lib.toList def.value)
      ) defs;
    emptyValue.value = [ ];
  };

  coercedListOfModulesWithDenixArgs = lib.mkOptionType {
    name = "listOfModulesWithDenixArgs";
    check = x: lib.isList x || lib.isAttrs x || lib.isFunction x || lib.path.check x;
    merge =
      loc: defs:
      lib.concatMap (
        def:
        map (
          (
            if delib.isDenixArgs def.value then
              delib.setDefaultModuleLocationWithDenixArgs
            else
              delib.setDefaultModuleLocation
          )
          def.file
          #"${def.file}, via option ${lib.showOption loc}"
        ) (lib.toList def.value)
      ) defs;
    emptyValue.value = [ ];
  };

  coercedListOfModulesOption = lib.mkOption {
    type = delib.modules.coercedListOfModules;
    default = [ ];
  };

  coercedListOfModulesWithDenixArgsOption = lib.mkOption {
    type = delib.modules.coercedListOfModulesWithDenixArgs;
    default = [ ];
  };

  denixAbstractionType =
    {
      moduleSystems,
      withOptions ? false,
      extraModules ? [ ],
    }:
    with delib;
    coercedTo (either (functionTo attrs) attrs)
      (module: {
        config =
          if !lib.isFunction module then
            module
          else
            let
              calledWithMocks = delib.callWithMocks module;

              definedModuleSystems = lib.intersectLists (builtins.attrNames calledWithMocks) (
                builtins.attrNames moduleSystems
              );

              eachToDenixArgs =
                fn:
                if builtins.isList (fn calledWithMocks) then
                  lib.imap0 (
                    index: value:
                    delib.toDenixArgs (
                      if delib.isDenixArgs (fn calledWithMocks) then
                        delib.inheritFunctionArgs (fn calledWithMocks) (
                          delib.mirrorFunctionArgs module (
                            denixArgs: (builtins.elemAt (fn (module denixArgs)) index) denixArgs
                          )
                        )
                      else
                        delib.mirrorFunctionArgs module (denixArgs: builtins.elemAt (fn (module denixArgs)) index)
                    )
                  ) (fn calledWithMocks)
                else
                  delib.toDenixArgs (
                    if delib.isDenixArgs (fn calledWithMocks) then
                      delib.inheritFunctionArgs (fn calledWithMocks) (
                        delib.mirrorFunctionArgs module (denixArgs: fn (module denixArgs) denixArgs)
                      )
                    else
                      delib.mirrorFunctionArgs module (denixArgs: fn (module denixArgs))
                  );

            in
            calledWithMocks
            // lib.genAttrs definedModuleSystems (
              moduleSystem:
              calledWithMocks.${moduleSystem}
              // lib.genAttrs (lib.intersectLists (builtins.attrNames calledWithMocks.${moduleSystem}) [
                "always"
                "ifEnabled"
                "ifDisabled"
              ]) (condition: eachToDenixArgs (x: x.${moduleSystem}.${condition}))
            )
            // lib.optionalAttrs (withOptions && calledWithMocks ? options) {
              options = eachToDenixArgs (x: x.options);
            };
      })
      (submoduleWith {
        modules = extraModules ++ [
          (
            { name, ... }:
            {
              options =
                builtins.mapAttrs (name: value: {
                  always = delib.modules.coercedListOfModulesWithDenixArgsOption;
                  ifEnabled = delib.modules.coercedListOfModulesWithDenixArgsOption;
                  ifDisabled = delib.modules.coercedListOfModulesWithDenixArgsOption;
                }) moduleSystems
                // lib.optionalAttrs withOptions {
                  options = delib.modules.coercedListOfModulesWithDenixArgsOption;
                }
                // {
                  name = readOnly (strOption name);
                  __toString = readOnly (functionToOption str (self: self.name));
                };
            }
          )
        ];
      });

  denixConfigurationSubmodule =
    {
      modules ? [ ],
      ...
    }@attrs:
    let
      noCheckForDocsModule = {
        # When generating documentation, our goal isn't to check anything.
        # Quite the opposite in fact. Generating docs is somewhat of a
        # challenge, evaluating modules in a *lacking* context. Anything
        # that makes the docs avoid an error is a win.
        config._module.check = lib.mkForce false;
        _file = "<built-in module that disables checks for the purpose of documentation generation>";
      };
      checkDefsForError =
        check: loc: defs:
        let
          invalidDefs = lib.filter (def: !check def.value) defs;
        in
        if invalidDefs != [ ] then
          { message = "Definition values: ${lib.options.showDefs invalidDefs}"; }
        else
          null;

      base = delib.denixConfiguration (
        attrs
        // {
          inherit modules;
        }
      );

      freeformType = base._module.freeformType;

      name = "denixConfiguration";

      check = {
        __functor = _self: x: lib.isAttrs x || lib.isFunction x || lib.path.check x;
        isV2MergeCoherent = true;
      };
    in
    lib.mkOptionType {
      inherit name;
      description =
        let
          docsEval = base.extendModules { modules = [ noCheckForDocsModule ]; };
        in
        if docsEval._module.freeformType ? description then
          "open ${name} of ${
            lib.types.optionDescriptionPhrase (
              class: class == "noun" || class == "composite"
            ) docsEval._module.freeformType
          }"
        else
          name;
      inherit check;
      merge = {
        __functor =
          self: loc: defs:
          (self.v2 { inherit loc defs; }).value;
        v2 =
          { loc, defs }:
          let
            configuration = base.extendModules {
              modules = map (
                { value, file }:
                {
                  _file = file;
                  imports = [ value ];
                }
              ) defs;
              prefix = loc;
            };
          in
          {
            headError = checkDefsForError check loc defs;
            value = configuration.config;
            valueMeta = { inherit configuration; };
          };
      };
      emptyValue = {
        value = { };
      };
      getSubOptions =
        prefix:
        let
          docsEval = (
            base.extendModules {
              inherit prefix;
              modules = [ noCheckForDocsModule ];
            }
          );
          # Intentionally shadow the freeformType from the possibly *checked*
          # configuration. See `noCheckForDocsModule` comment.
          inherit (docsEval._module) freeformType;
        in
        docsEval.options
        // lib.optionalAttrs (freeformType != null) {
          # Expose the sub options of the freeform type. Note that the option
          # discovery doesn't care about the attribute name used here, so this
          # is just to avoid conflicts with potential options from the submodule
          _freeformOptions = freeformType.getSubOptions prefix;
        };
      getSubModules = modules;
      substSubModules =
        m:
        delib.modules.denixConfigurationSubmodule (
          attrs
          // {
            modules = m;
          }
        );
      nestedTypes = lib.optionalAttrs (freeformType != null) {
        freeformType = freeformType;
      };
      functor = lib.defaultFunctor name // {
        type = delib.modules.denixConfigurationSubmodule;
        payload = attrs;
        binOp = lhs: rhs: throw "ты долбаеб";
      };
    };

  denixConfigurationSubmoduleOption =
    args:
    lib.mkOption {
      type = delib.modules.denixConfigurationSubmodule args;
    };
}
