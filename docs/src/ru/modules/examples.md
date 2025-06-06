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

## Home Manager {#home-manager}
С [константами](#constants):
```nix
{delib, pkgs, ...}:
delib.module {
  name = "home";

  home.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    home = {
      inherit username;
      # Если вам не нужен Nix-Darwin или вы используете только его,
      # можете оставить здесь строку вместо условия.
      homeDirectory =
        if pkgs.stdenv.isDarwin
        then "/Users/${username}"
        else "/home/${username}";
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

  # Если вы не используете NixOS, можете полностью удалить этот блок.
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

  # Если вы не используете Nix-Darwin, можете полностью удалить этот блок.
  darwin.always = {myconfig, ...}: let
    inherit (myconfig.constants) username;
  in {
    users.users.${username} = {
      name = username;
      home = "/Users/${username}";
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
{delib, pkgs, ...}:
delib.module {
  name = "programs.alejandra";

  options = delib.singleEnableOption true;

  home.ifEnabled.home.packages = [pkgs.alejandra];
}
```
