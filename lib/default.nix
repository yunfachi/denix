{
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}:
let
  inherit (import ./toplevel/lib.nix { inherit lib; }) mkLib;
in
mkLib "delib" (delib: {
  _callLibArgs = {
    inherit nixpkgs home-manager nix-darwin;
  };

  fixedPoints = delib._callLib ./toplevel/fixed-points.nix;
  inherit (delib.fixedPoints)
    fix
    fixWithUnfix
    recursivelyExtends
    recursivelyComposeExtensions
    recursivelyComposeManyExtensions
    makeRecursivelyExtensible
    makeRecursivelyExtensibleWithCustomName
    ;

  inherit (delib._callLib ./toplevel/lib.nix) mkLib;

  modules = delib._callLib ./modules;
  inherit (delib.modules)
    denixConfiguration
    callDenixModule
    compileModule
    ;

  attrset = delib._callLib ./attrset.nix;
  inherit (delib.attrset) getAttrByStrPath setAttrByStrPath hasAttrs;

  options = delib._callLib ./options.nix;

  types = delib._callLib ./types.nix;

  # Generated inherits.
  # After implementing https://github.com/NixOS/nix/issues/4090 it will be possible to use `// delib.options` (to inherit all)

  #[[[cog
  #  import cog
  #  import subprocess
  #  import json
  #  import os
  #
  #  def nix_attr_names(attr):
  #    out = subprocess.run(
  #      ["nix", "eval", f".#lib.{attr}",
  #       "--apply", "builtins.attrNames",
  #       "--quiet", "--json", "--no-pretty"],
  #      capture_output=True, text=True, check=False
  #    ).stdout or os.environ[f"pre_evaled_{attr}"]
  #    return json.loads(out)
  #
  #  for group in ["options", "types"]:
  #    cog.outl(f"inherit (delib.{group})")
  #    for name in nix_attr_names(group):
  #      cog.outl(f"  {name}")
  #    cog.outl("  ;")
  #]]]
  inherit (delib.options)
    allowAnything
    allowAttrs
    allowAttrsLegacy
    allowAttrsOf
    allowBool
    allowCoercedTo
    allowEnum
    allowFloat
    allowFunction
    allowFunctionTo
    allowInt
    allowIntBetween
    allowLazyAttrs
    allowLazyAttrsOf
    allowList
    allowListOf
    allowNull
    allowNumber
    allowOneOf
    allowPackage
    allowPath
    allowPort
    allowSingleLineStr
    allowStr
    allowSubmodule
    allowSubmoduleWith
    anythingOption
    apply
    attrsLegacyOption
    attrsOfOption
    attrsOption
    boolOption
    coercedToOption
    defaultText
    description
    enumOption
    example
    floatOption
    functionOption
    functionToOption
    intBetweenOption
    intOption
    internal
    lazyAttrsOfOption
    lazyAttrsOption
    listOfOption
    listOption
    nullOption
    numberOption
    oneOfOption
    packageOption
    pathOption
    portOption
    readOnly
    relatedPackages
    singleLineStrOption
    strOption
    submoduleOption
    submoduleWithOption
    visible
    ;
  inherit (delib.types)
    anything
    attrs
    attrsLegacy
    attrsOf
    bool
    coercedTo
    enum
    float
    function
    functionTo
    int
    intBetween
    lazyAttrs
    lazyAttrsOf
    list
    listOf
    null
    number
    oneOf
    package
    path
    port
    singleLineStr
    str
    submodule
    submoduleWith
    ;
  #[[[end]]]
})
