{
  lib,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}:
lib.makeExtensible (
  delib: let
    callLib = file: import file {inherit delib lib nixpkgs home-manager nix-darwin;};
  in
    {
      configurations = callLib ./configurations;

      attrset = callLib ./attrset.nix;
      maintainers = callLib ./maintainers.nix;
      options = callLib ./options.nix;
      umport = callLib ./umport.nix;
    }
    // callLib ./options.nix
)
