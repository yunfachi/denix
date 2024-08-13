{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: {
    lib = import ./lib {
      inherit (nixpkgs) lib;
      inherit home-manager;
      inherit nixpkgs;
    };

    templates = {
      minimal = {
        description = ''
          Minimal configuration with hosts, rices, constants, home manager, and user config.
          It is not recommended to use if this is your first time or if you haven't read or don't plan to read the documentation.
        '';
        path = ./templates/minimal;
      };
    };
  };
}
