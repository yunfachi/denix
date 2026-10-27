{
  delib,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.settings.homeManager;
in
{
  options.settings.homeManager = with delib; {
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
        { home-manager.sharedModules = config.rawModules.myconfig; }
      ];
    }
    // lib.optionalAttrs cfg.darwin.enable {
      darwin.always = [
        cfg.darwin.homeManagerModule
        { home-manager.sharedModules = config.rawModules.myconfig; }
      ];
    };
}
