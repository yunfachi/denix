{ delib, ... }:
{
  modules."programs.module" = {
    options = with delib; {
      enable = boolOption true;
      test = intOption 0;
      asd = intOption 1;
    };

    myconfig.always =
      { config, ... }:
      {
        #programs.module.test = config.myconfig.programs.module.asd;
      };

    #myconfig.ifEnabled.programs.module.test = 999;

    nixos.ifEnabled =
      { test, ... }:
      {
        #nixpkgs.hostPlatform = "x86_64-linux";
        _module.args.test = 123;
        myconfig.programs.module.test = test;
      };
  };

  hosts."keka" = {
    myconfig.ifDisabled = {
      programs.module.enable = false;
    };
  };
}
