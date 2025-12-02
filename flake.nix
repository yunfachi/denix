{
  description = "Nix framework for creating scalable configurations, modules, and libraries.";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    git-hooks.url = "github:cachix/git-hooks.nix";
    systems.url = "github:nix-systems/default";

    /**
      The reason for separating nixpkgs and nixpkgs-lib is that nixpkgs, home-manager,
      and nix-darwin are inputs used exclusively for creating the system configuration
      (e.g., lib.nixosSystem, ...). nixpkgs is an input, which implies user overrides
      to their own channel, while nixpkgs-lib is a library used by Denix, and it should
      not be overridden by the user without a special reason.
    */
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
      nixpkgs,
      git-hooks,
      systems,
      ...
    }:
    let
      forAllSystems = nixpkgs-lib.lib.genAttrs (import systems);
    in
    {
      denixModules = {
        default = self.denixModules.denix;
        denix = ./modules/denix;

        betterHosts = ./modules/betterHosts;
        nixDarwin = ./modules/nixDarwin;
        homeManager = ./modules/homeManager;
      };

      lib = import ./lib {
        inherit (nixpkgs-lib) lib;
        inherit (self) inputs denixModules;
      };

      flakeModules.default = import ./flake-module.nix self;
      flakeModule = self.flakeModules.default;

      checks = forAllSystems (system: {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            keep-sorted = {
              enable = true;
              name = "keep-sorted";
              language = "system";
              entry = "${nixpkgs.legacyPackages.${system}.keep-sorted}/bin/keep-sorted";
            };
            cog = {
              enable = true;
              name = "cog";
              language = "system";
              entry = nixpkgs.lib.getExe (
                nixpkgs.legacyPackages.${system}.writeShellApplication {
                  name = "denix-cog";

                  runtimeInputs = with nixpkgs.legacyPackages.${system}; [
                    python313Packages.cogapp
                    nix
                  ];

                  text = ''
                    export pre_evaled_options='${builtins.toJSON (builtins.attrNames self.lib.options)}'
                    export pre_evaled_types='${builtins.toJSON (builtins.attrNames self.lib.types)}'
                    cog -r "$@"
                  '';
                }
              );
            };
          };
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
