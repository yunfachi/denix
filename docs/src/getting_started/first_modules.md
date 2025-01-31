# First Modules {#first-modules}
In this section, we will create modules for some programs. To start, create the `programs` and `services` subdirectories in the `modules` directory.

Creating your own modules is almost the same as creating regular NixOS modules, so you can look for NixOS options [here](https://search.nixos.org/options?).

## Git {#git}
Let's assume you already have a constants module. Create a file `modules/programs/git.nix` with the following content:
```nix
{delib, ...}:
delib.module {
  name = "programs.git";

  options.programs.git = with delib; {
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

### Code Explanation:
- `enable` - an option to enable or disable the module entirely.
- `enableLFS` - an option to enable [Git Large File Storage](https://github.com/git-lfs/git-lfs).

## Hyprland {#hyprland}
Assume that your host has the options `type` and `isDesktop`. Create a subdirectory `hyprland` in the `modules/programs/` directory, and in it, create a file `default.nix` with the following content:
```nix
{delib, ...}:
delib.module {
  name = "programs.hyprland";

  options = {myconfig, ...} @ args: delib.singleEnableOption myconfig.host.isDesktop args;

  nixos.ifEnabled.programs.hyprland.enable = true;
  home.ifEnabled.wayland.windowManager.hyprland.enable = true;
}
```

Also, create a file `settings.nix` in this directory:
```nix
{delib, ...}:
delib.module {
  name = "programs.hyprland";

  home.ifEnabled.wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    general = {
      gaps_in = 5;
      gaps_out = 10;
    };
  };
}
```

And finally, the file `binds.nix`:
```nix
{delib, ...}:
delib.module {
  name = "programs.hyprland";

  home.ifEnabled.wayland.windowManager.hyprland.settings = {
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bind = [
      "$mod, q, killactive,"
      "CTRLALT, Delete, exit,"

      "$mod, Return, exec, kitty" # your terminal
    ];
  };
}
```

We have created a small configuration for Hyprland, which you can expand and add new options to as needed.
