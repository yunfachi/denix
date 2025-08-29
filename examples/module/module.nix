{ delib, ... }:
{
  modules."programs.module" = {
    options = with delib; {
      enable = boolOption true;
      test = intOption 0;
    };

    myconfig.ifEnabled = {
      programs.module.test = 213;
    };

    nixos.ifEnabled = {
      nixpkgs.hostPlatform = "x86_64-linux";
    };
  };
}
