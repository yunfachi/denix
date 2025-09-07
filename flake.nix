{
  description = "Nix library for creating scalable NixOS, Home Manager, and Nix-Darwin configurations with modules, hosts, and rices.";

  inputs = {
    #nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-lib.url = "github:yunfachi/nixpkgs/patch-2?dir=lib";
    #git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.url = "github:yunfachi/git-hooks.nix";

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
      git-hooks,
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
