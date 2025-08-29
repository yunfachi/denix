{ delib, lib, ... }:
{
  inherit (lib.types)
    # keep-sorted start case=no
    anything
    attrsOf
    bool
    coercedTo
    either
    enum
    float
    functionTo
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
    unspecified
    # keep-sorted end
    ;

  # keep-sorted start case=no block=yes newline_separated=yes
  attrs = delib.types.attrsOf delib.types.unspecified;

  attrsLegacy = lib.types.attrs;

  function = delib.types.functionTo delib.types.unspecified;

  intBetween =
    lowest: highest:
    assert lib.assertMsg (lowest <= highest) "intBetween: lowest must be smaller than highest";
    lib.types.addCheck delib.types.int (x: x >= lowest && x <= highest)
    // {
      name = "intBetween";
      description = "integer between ${toString lowest} and ${toString highest} (both inclusive)";
    };

  lazyAttrs = delib.types.lazyAttrsOf delib.types.unspecified;

  list = delib.types.listOf delib.types.unspecified;

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

  steppedInt =
    step:
    assert lib.assertMsg (builtins.isInt step) "steppedInt: step must be an integer";
    lib.types.addCheck delib.types.int (x: x == x / step * step)
    // {
      name = "steppedInt";
      description = "integer that is a multiple of ${step}";
    };

  steppedIntBetween =
    lowest: highest: step:
    assert lib.assertMsg (builtins.isInt step) "steppedIntBetween: step must be an integer";
    assert lib.assertMsg (lowest <= highest) "steppedIntBetween: lowest must be smaller than highest";
    lib.types.addCheck delib.types.int (x: x >= lowest && x <= highest && x == x / step * step)
    // {
      name = "steppedIntBetween";
      description = "integer between ${toString lowest} and ${toString highest} (inclusive) that is a multiple of ${step}";
    };
  # keep-sorted end
}
