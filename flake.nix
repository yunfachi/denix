{
  description = "Nix library for creating scalable NixOS, Home Manager, and Nix-Darwin configurations with modules, hosts, and rices.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    pre-commit-hooks,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    lib = import ./lib {
      inherit (nixpkgs) lib;
      inherit home-manager nix-darwin nixpkgs;
    };

    templates = {
      minimal = {
        description = ''
          Minimal configuration with hosts, rices, constants, home manager, and user config.
          It is not recommended to use if this is your first time or if you haven't read or don't plan to read the documentation.
        '';
        path = ./templates/minimal;
      };
      minimal-no-rices = {
        description = ''
          Minimal configuration with hosts, constants, home manager, and user config.
          It is not recommended to use if this is your first time or if you haven't read or don't plan to read the documentation.
        '';
        path = ./templates/minimal-no-rices;
      };
    };

    checks = forAllSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks.alejandra.enable = true;
      };
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    });
  };
}
