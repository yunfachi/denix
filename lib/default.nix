{
  lib,
  home-manager,
  nixpkgs,
  ...
}: let
  inherit (import ./umport.nix {inherit lib;}) umport;
in {
  configurations = {
    myconfigName ? "myconfig",
    denixLibName ? "delib",
    homeManagerNixpkgs ? nixpkgs,
    homeManagerUser,
    isHomeManager,
    paths ? [],
    exclude ? [],
    recursive ? true,
    specialArgs ? {},
  }: let
    files = umport {inherit paths exclude recursive;};
    apply = import ./apply.nix {inherit lib homeManagerUser isHomeManager myconfigName;};
    attrset = import ./attrset.nix {inherit lib;};

    denixLib = config: isHomeManager: let
      apply = import ./apply.nix {inherit lib homeManagerUser isHomeManager myconfigName;};

      host = import ./host.nix {inherit lib apply config myconfigName options;};
      module = import ./module.nix {inherit lib apply attrset config myconfigName;};
      options = import ./options.nix {inherit lib attrset;};
      rice = import ./rice.nix {inherit lib myconfigName options;};
    in
      host // module // options // rice;

    system = extraModule: homeManagerSystem: isHomeManager: let
      nixosSystem = lib.nixosSystem {
        specialArgs = specialArgs // {${denixLibName} = denixLib config isHomeManager;};
        modules =
          [
            home-manager.nixosModules.home-manager
            extraModule
          ]
          ++ files;
      };
      homeSystem = home-manager.lib.homeManagerConfiguration {
        pkgs = homeManagerNixpkgs.legacyPackages.${homeManagerSystem};
        extraSpecialArgs = specialArgs // {${denixLibName} = denixLib config isHomeManager;};
        modules = [extraModule] ++ files;
      };
    in
      if isHomeManager
      then homeSystem
      else nixosSystem;

    mkHost = host: rice:
      system {
        config.${myconfigName} = {inherit rice host;};

        imports =
          [
            (apply.myconfig host.myconfig)
            (apply.nixos host.nixos)
            (apply.home host.home)
          ]
          ++ (lib.optionals (rice != null) [
            (apply.myconfig rice.myconfig)
            (apply.nixos rice.nixos)
            (apply.home rice.home)
          ]);
      }
      host.homeManagerSystem
      isHomeManager;

    inherit ((system {} "useless" false)) config;
    inherit (config.${myconfigName}) hosts rices;
  in
    (lib.concatMapAttrs (riceName: rice:
      lib.attrsets.mapAttrs' (hostName: host: {
        name = "${hostName}-${riceName}";
        value = mkHost host rice;
      })
      hosts)
    rices)
    // (builtins.mapAttrs (_: host:
      mkHost host (
        if host.rice == null
        then null
        else rices.${host.rice}
      ))
    hosts);
}
