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
mkLib "delib" (
  delib:
  {
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
      declareFunctionArgs
      callDenixModule
      compileModule
      ;

    attrset = delib._callLib ./attrset.nix;
    inherit (delib.attrset) getAttrByStrPath setAttrByStrPath hasAttrs;

    options = delib._callLib ./options.nix;
  }
  # After implementing https://github.com/NixOS/nix/issues/4090 it will be possible to use `// delib.options` (to inherit all)
  // (import ./options.nix) { inherit lib delib; }
)
