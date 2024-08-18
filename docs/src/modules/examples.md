# Examples

## Constants {#constants} 
```nix
delib.module {
  name = "constants";

  options = {
    constants = with delib; {
      username = readOnly (strOption "sjohn");
      userfullname = readOnly (strOption "John Smith");
      useremail = readOnly (strOption "johnsmith@example.com");
    };
  };
}
```

## Hosts {#hosts}
Without `type` option:
```nix
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
With `type` option:
```nix
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

## Rices {#rices}
```nix
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
With [constants](#constants):
```nix
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

## User {#user}
With [constants](#constants):
```nix
delib.module {
  name = "user";

  nixos.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    users = {
      groups.${username} = {};

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
With [constants](#constants):
```nix
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
delib.module {
  name = "programs.alejandra";

  options = delib.singleEnableOption true;

  home.ifEnabled.home.packages = [pkgs.alejandra];
}
```
