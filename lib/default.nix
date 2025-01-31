{
  lib,
  nixpkgs,
  home-manager,
  ...
}:
lib.makeExtensible (
  delib: let
    callLib = file: import file {inherit delib lib nixpkgs home-manager;};
  in
    {
      configurations = callLib ./configurations;

      attrset = callLib ./attrset.nix;
      options = callLib ./options.nix;
      umport = callLib ./umport.nix;
    }
    // callLib ./options.nix
)
