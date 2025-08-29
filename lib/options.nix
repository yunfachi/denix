{ delib, lib, ... }:
let
  genOptions = f: lib.listToAttrs (map f (lib.attrsToList delib.types));

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

  optionModifiers = {
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
  };
in
typeOptions // allowTypeOptions // optionModifiers
