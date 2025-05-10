{
  description = "Modular configuration of Home Manager and NixOS with Denix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    denix,
    nixpkgs,
    ...
  } @ inputs: let
    mkConfigurations = moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem;
        homeManagerUser = "sjohn"; #!!! REPLACEME

        paths = [./hosts ./modules ./rices];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    # If you're not using NixOS, Home Manager, or Darwin,
    # you can safely remove the corresponding lines below.
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
    darwinConfigurations = mkConfigurations "darwin";
  };
}
