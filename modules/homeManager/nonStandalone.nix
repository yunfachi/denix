{
  delib,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.homeManager;

  usersConfig = {
    home-manager.users = lib.mapAttrs (user: moduleSystems: {
      imports = builtins.concatMap (moduleSystem: config.rawModules.${moduleSystem}) (
        lib.optionals (
          # FIXME: does not duplicate rawModules.home for the current user, but duplicates all modules of the current user for all other users.
          # Causes issues in a rather unusual use case: using `rawModules.nixos` or `rawModules.home` when `moduleSystem = "home"` (standalone Home Manager).
          config.moduleSystem.name != "home" && cfg.standalone.user != user
        ) moduleSystems
        ++ [ "home" ]
      );
    }) cfg.users;
  };
in
{
  options.homeManager = with delib; {
    nixos = {
      enable = boolOption (config.moduleSystems ? nixos);
      homeManagerModule = anythingOption inputs.home-manager.nixosModules.default;
    };

    darwin = {
      enable = boolOption (config.moduleSystems ? darwin);
      homeManagerModule = anythingOption inputs.home-manager.darwinModules.default;
    };
  };

  config.modules."home-manager" =
    lib.optionalAttrs cfg.nixos.enable {
      nixos.always = [
        cfg.nixos.homeManagerModule
        usersConfig
      ];
    }
    // lib.optionalAttrs cfg.darwin.enable {
      darwin.always = [
        cfg.darwin.homeManagerModule
        usersConfig
      ];
    };
}
