# Примеры

## Константы {#constants} 
```nix
{delib, ...}:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = readOnly (strOption "sjohn");
    userfullname = readOnly (strOption "John Smith");
    useremail = readOnly (strOption "johnsmith@example.com");
  };
}
```

## Хосты {#hosts}
Без опции `type`:
```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {
      options = hostSubmoduleOptions;
    };
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.hostNamesAssertions myconfig.hosts;
  };
}
```
С опцией `type`:
```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {config, ...}: {
      options =
        hostSubmoduleOptions
        // {
          type = noDefault (enumOption ["desktop" "server"] null);

          isDesktop = boolOption (config.type == "desktop");
          isServer = boolOption (config.type == "server");
        };
    };
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.hostNamesAssertions myconfig.hosts;
  };
}
```

## Райсы {#rices}
```nix
{delib, ...}:
delib.module {
  name = "rices";

  options = with delib; let
    rice = {
      options = riceSubmoduleOptions;
    };
  in {
    rice = riceOption rice;
    rices = ricesOption rice;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.riceNamesAssertions myconfig.rices;
  };
}
```

## Home Manager {#home-manager}
С [константами](#constants):
```nix
{delib, ...}:
delib.module {
  name = "home";

  home.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";
    };
  };
}
```

## Пользователь {#user}
С [константами](#constants):
```nix
{delib, ...}:
delib.module {
  name = "user";

  nixos.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    users = {
      users.${username} = {
        isNormalUser = true;
        initialPassword = username;
        extraGroups = ["wheel"];
      };
    };
  };
}
```

## Git {#git}
С [константами](#constants):
```nix
{delib, ...}:
delib.module {
  name = "programs.git";

  options = with delib; {
    enable = boolOption true;
    enableLFS = boolOption true;
  };

  home.ifEnabled.programs.git = {myconfig, cfg, ...}: {
    enable = cfg.enable;
    lfs.enable = cfg.enableLFS;

    userName = myconfig.constants.username;
    userEmail = myconfig.constants.useremail;
  };
}
```

## Alejandra {#alejandra}
```nix
{delib, ...}:
delib.module {
  name = "programs.alejandra";

  options = delib.singleEnableOption true;

  home.ifEnabled.home.packages = [pkgs.alejandra];
}
```
