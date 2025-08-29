{ delib, lib, ... }:
let
  genOptions = f: lib.listToAttrs (map f (lib.attrsToList types));

  types = {
    inherit (lib.types)
      anything
      attrsOf
      bool
      coercedTo
      enum
      float
      int
      oneOf
      listOf
      number
      package
      path
      port
      singleLineStr
      str
      submodule
      submoduleWith
      lazyAttrsOf
      ;
    attrs = delib.options.attrsOf delib.options.anything;
    attrsLegacy = lib.types.attrs;
    lazyAttrs = delib.options.lazyAttrsOf delib.options.anything;
    # FIX https://github.com/NixOS/nixpkgs/issues/438933
    functionTo =
      elemType:
      lib.mkOptionType {
        name = "functionTo";
        description = "function that evaluates to a(n) ${
          lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
        }";
        descriptionClass = "composite";
        check = lib.isFunction;
        merge = loc: defs: {
          # An argument attribute has a default when it has a default in all definitions
          __functionArgs = lib.zipAttrsWith (_: lib.all (x: x)) (
            lib.map (fn: lib.functionArgs fn.value) defs
          );
          __functor =
            _: callerArgs:
            (lib.mergeDefinitions loc elemType (
              map (fn: {
                inherit (fn) file;
                value = fn.value callerArgs;
              }) defs
            )).mergedValue;
        };
        getSubOptions = prefix: elemType.getSubOptions prefix;
        getSubModules = elemType.getSubModules;
        substSubModules = m: delib.options.functionTo (elemType.substSubModules m);
        functor = lib.defaultFunctor "functionTo" // {
          type = payload: types.functionTo payload.elemType;
          payload.elemType = elemType;
          binOp =
            a: b:
            let
              merged = a.elemType.typeMerge b.elemType.functor;
            in
            if merged == null then null else { elemType = merged; };
        };
        nestedTypes.elemType = elemType;
      };
    function = delib.options.functionTo delib.options.anything;
    list = delib.options.listOf delib.options.anything;
    intBetween = lib.types.ints.between;
    null = lib.mkOptionType {
      name = "null";
      description = "null";
      descriptionClass = "noun";
      check = x: x == null;
      merge = lib.mergeEqualOption;
      emptyValue = {
        value = null;
      };
    };
  };

  functorForType = type: {
    __functor =
      option:
      if lib.isFunction type then
        typeArg: option // { type = type typeArg; } // functorForType (type typeArg)
      else
        default: option // { inherit default; };
  };

  typeOptions = genOptions (
    { name, value }:
    {
      name = "${name}Option";
      value =
        lib.mkOption {
          type = value;
        }
        // functorForType value;
    }
  );

  allowTypeOptions = genOptions (
    { name, value }:
    {
      name = "allow${
        lib.toUpper (builtins.substring 0 1 name) + (builtins.substring 1 (builtins.stringLength name) name)
      }";
      value =
        option:
        option
        // {
          type = lib.types.oneOf [
            value
            option.type
          ];
        };
    }
  );
in
types
// typeOptions
// allowTypeOptions
// {
  readOnly =
    option:
    option
    // {
      readOnly = true;
      __functor = self: readOnly: self // { inherit readOnly; };
    };
  internal =
    option:
    option
    // {
      internal = true;
      __functor = self: internal: self // { inherit internal; };
    };
  visible =
    option: visible:
    option
    // {
      inherit visible;
    };

  defaultText = option: defaultText: option // { inherit defaultText; };
  example = option: example: option // { inherit example; };
  description = option: description: option // { inherit description; };
  relatedPackages = option: relatedPackages: option // { inherit relatedPackages; };
  apply = option: apply: option // { inherit apply; };
}
