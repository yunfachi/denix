{
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}: let
  inherit
    (lib.fix (delib: import ./fixed-points.nix {inherit delib lib;}))
    makeRecursivelyExtensible
    ;
in
  makeRecursivelyExtensible (
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

        attrset = _callLib ./attrset.nix;
        inherit (delib.attrset) getAttrByStrPath setAttrByStrPath hasAttrs;

        inherit (_callLib ./configurations) configurations;

        inherit
          (_callLib ./fixed-points.nix)
          fix
          fixWithUnfix
          recursivelyExtends
          recursivelyComposeExtensions
          recursivelyComposeManyExtensions
          makeRecursivelyExtensible
          makeRecursivelyExtensibleWithCustomName
          ;

        inherit (_callLib ./maintainers.nix) maintainers;

        options = _callLib ./options.nix;

        inherit
          (_callLib ./extension.nix)
          extension
          extensions
          callExtension
          callExtensions
          withExtensions
          mergeExtensions
          ;

        inherit (_callLib ./umport.nix) umport;
      }
      // (import ./options.nix {inherit delib lib;})
    # After implementing https://github.com/NixOS/nix/issues/4090 it will be possible to use `// callLib` (to inherit all)
  )
