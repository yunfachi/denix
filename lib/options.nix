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
      functionTo
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
