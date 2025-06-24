{
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}:
lib.makeExtensible (
  delib: let
    inherit (delib) _callLib;
  in
    {
      _callLib = file: import file delib._callLibArgs;

      _callLibArgs = {
        inherit
          delib
          lib
          nixpkgs
          home-manager
          nix-darwin
          ;
      };

      configurations = _callLib ./configurations;

      attrset = _callLib ./attrset.nix;
      inherit (delib.attrset) getAttrByStrPath setAttrByStrPath hasAttrs;
      maintainers = _callLib ./maintainers.nix;
      options = _callLib ./options.nix;
      inherit
        (_callLib ./extension.nix)
        extension
        callExtension
        callExtensions
        extensions
        mergeExtensions
        ;
      umport = _callLib ./umport.nix;
    }
    // (import ./options.nix {inherit delib lib;})
  # After implementing https://github.com/NixOS/nix/issues/4090 it will be possible to use `// callLib` (to inherit all)
)
