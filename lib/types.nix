{ delib, lib, ... }:
{
  inherit (lib.types)
    # keep-sorted start case=no
    anything
    attrsOf
    bool
    coercedTo
    enum
    float
    int
    lazyAttrsOf
    listOf
    number
    oneOf
    package
    path
    port
    singleLineStr
    str
    submodule
    submoduleWith
    # keep-sorted end
    ;

  # keep-sorted start case=no block=yes newline_separated=yes
  attrs = delib.types.attrsOf delib.types.anything;

  attrsLegacy = lib.types.attrs;

  function = delib.types.functionTo delib.types.anything;

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
      substSubModules = m: delib.types.functionTo (elemType.substSubModules m);
      functor = lib.defaultFunctor "functionTo" // {
        type = payload: delib.types.functionTo payload.elemType;
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

  intBetween = lib.types.ints.between;

  lazyAttrs = delib.types.lazyAttrsOf delib.types.anything;

  list = delib.types.listOf delib.types.anything;

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
  # keep-sorted end
}
