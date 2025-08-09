{
  description = "Nix library for creating scalable NixOS, Home Manager, and Nix-Darwin configurations with modules, hosts, and rices.";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs-lib,
      pre-commit-hooks,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs-lib.lib.genAttrs supportedSystems;
    in
    {
      lib = import ./lib {
        inherit (nixpkgs-lib) lib;
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
        extensions-collection = {
          description = ''
            Flake for creating your own collection of Denix extensions.
          '';
          path = ./templates/extensions-collection;
        };
      };

      checks = forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks.nixfmt-rfc-style.enable = true;
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
