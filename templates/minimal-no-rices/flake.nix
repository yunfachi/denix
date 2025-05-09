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
        homeManagerUser = "sjohn";

        paths = [./hosts ./modules];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
  };
}
