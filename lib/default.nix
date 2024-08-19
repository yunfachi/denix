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
    internalSystemExtraModule ? {nixpkgs.hostPlatform = "x86_64-linux";}, # just a plug; FIXME
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

    mkHost = host: rice: let
      wrap = name: cfg: x:
        if builtins.typeOf x == "lambda"
        then
          x {
            inherit name cfg;
            myconfig = config.${myconfigName};
          }
        else x;
      wrapHost = wrap host.name (config.${myconfigName}.hosts.${host.name});
    in
      system {
        config.${myconfigName} = {inherit rice host;};

        imports =
          [
            (apply.myconfig (wrapHost host.myconfig))
            (apply.nixos (wrapHost host.nixos))
            (apply.home (wrapHost host.home))
          ]
          ++ (lib.optionals (rice != null) (let
            wrapRice = wrap rice.name (config.${myconfigName}.rices.${rice.name});
          in [
            (apply.myconfig (wrapRice rice.myconfig))
            (apply.nixos (wrapRice rice.nixos))
            (apply.home (wrapRice rice.home))
          ]));
      }
      host.homeManagerSystem
      isHomeManager;

    inherit ((system internalSystemExtraModule "useless" false)) config;
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
