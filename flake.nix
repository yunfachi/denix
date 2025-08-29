{
  description = "Nix library for creating scalable NixOS, Home Manager, and Nix-Darwin configurations with modules, hosts, and rices.";

  inputs = {
    #nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-lib.url = "github:yunfachi/nixpkgs/patch-2?dir=lib";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
    };

    /**
      The reason for separating nixpkgs and nixpkgs-lib is that nixpkgs, home-manager,
      and nix-darwin are inputs used exclusively for creating the system configuration
      (e.g., lib.nixosSystem, ...). nixpkgs is an input, which implies user overrides
      to their own channel, while nixpkgs-lib is a library used by Denix, and it should
      not be overridden by the user without a special reason.
    */
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:yunfachi/nixpkgs/patch-2";
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
