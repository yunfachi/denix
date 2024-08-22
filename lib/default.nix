{
  lib,
  home-manager,
  nixpkgs,
  ...
}: let
  inherit (import ./umport.nix {inherit lib;}) umport;

  attrset = import ./attrset.nix {inherit lib;};
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
    extraModules ? [],
    mkConfigurationsSystemExtraModule ? {nixpkgs.hostPlatform = "x86_64-linux";}, # just a plug; FIXME
  } @ topArgs: let
    files = umport {inherit paths exclude recursive;};

    mkApply = isHomeManager: import ./apply.nix {inherit lib homeManagerUser isHomeManager myconfigName;};
    mkDenixLib = {
      config,
      isHomeManager,
    }: let
      apply = mkApply isHomeManager;

      host = import ./host.nix {inherit lib apply config myconfigName options;};
      module = import ./module.nix {inherit lib apply attrset config myconfigName;};
      options = import ./options.nix {inherit lib attrset;};
      rice = import ./rice.nix {inherit lib myconfigName options;};
    in
      host // module // options // rice;

    mkSystem = {
      isHomeManager,
      homeManagerSystem,
      internalExtraModules ? (apply: []),
    }: let
      nixosSystem = let
        apply = mkApply false;
      in
        lib.nixosSystem {
          specialArgs =
            specialArgs
            // {
              ${denixLibName} = mkDenixLib {
                config = nixosSystem.config;
                isHomeManager = false;
              };
            };
          modules = (internalExtraModules apply) ++ extraModules ++ files ++ [home-manager.nixosModules.home-manager];
        };
      homeSystem = let
        apply = mkApply true;
      in
        home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs =
            specialArgs
            // {
              ${denixLibName} = mkDenixLib {
                # FIXME: nixosSystem is used, not homeSystem, because homeManagerConfiguration causes infinite recursion (maybe I should create an issue in home-manager?)
                config = nixosSystem.config;
                isHomeManager = true;
              };
            };
          pkgs = homeManagerNixpkgs.legacyPackages.${homeManagerSystem};
          modules = (internalExtraModules apply) ++ extraModules ++ files;
        };
    in
      if isHomeManager
      then homeSystem
      else nixosSystem;

    mkHost = {
      host,
      rice ? null,
    }: let
      myconfig = system.config.${myconfigName};

      wrap = name: cfg: x:
        if builtins.typeOf x == "lambda"
        then x {inherit name cfg myconfig;}
        else x;
      wrapHost = wrap host.name (myconfig.hosts.${host.name});

      system = mkSystem {
        inherit isHomeManager;
        inherit (host) homeManagerSystem;
        internalExtraModules = apply: [
          {config.${myconfigName} = {inherit rice host;};}
          (apply.all
            (wrapHost host.myconfig)
            (wrapHost host.nixos)
            (wrapHost host.home))
          (lib.optionalAttrs (rice != null) (let
            wrapRice = wrap rice.name (myconfig.rices.${rice.name});
          in
            apply.all
            (wrapRice rice.myconfig)
            (wrapRice rice.nixos)
            (wrapRice rice.home)))
        ];
      };
    in
      system;

    mkConfigurations = let
      system = mkSystem {
        isHomeManager = false;
        homeManagerSystem = "x86_64-linux"; # just a plug; FIXME
        internalExtraModules = _: [mkConfigurationsSystemExtraModule];
      };

      inherit (system.config.${myconfigName}) hosts rices;
    in
      (builtins.mapAttrs (_: host:
        mkHost {
          inherit host;
          rice =
            if host.rice == null
            then null
            else rices.${host.rice};
        })
      hosts)
      // (lib.concatMapAttrs (riceName: rice:
        lib.attrsets.mapAttrs' (hostName: host: {
          name = "${hostName}-${riceName}";
          value = mkHost {inherit host rice;};
        })
        hosts)
      rices);
  in
    mkConfigurations;
}
