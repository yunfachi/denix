# Первые модули {#first-modules}
В этом разделе мы создадим модули для некоторых программ. Для начала создайте поддиректории `programs` и `services` в директории `modules`.

Создание своих модулей практически не отличается от создания обычных модулей NixOS, поэтому опции NixOS можно искать [здесь](https://search.nixos.org/options?).

## Git {#git}
Предположим, что у вас уже есть модуль констант. Создайте файл `modules/programs/git.nix` со следующим содержанием:
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

### Объяснение кода:
- `enable` - опция для включения и отключения модуля полностью.
- `enableLFS` - опция для включения [Git Large File Storage](https://github.com/git-lfs/git-lfs).

## Hyprland {#hyprland}
Предположим, что в вашем хосте есть опции `type` и `isDesktop`. Создайте поддиректорию `hyprland` в директории `modules/programs/`, а в ней - файл `default.nix` со следующим содержанием:
```nix
{delib, ...}:
delib.module {
  name = "programs.hyprland";

  options = {myconfig, ...} @ args: delib.singleEnableOption myconfig.host.isDesktop args;

  nixos.ifEnabled.programs.hyprland.enable = true;
  home.ifEnabled.wayland.windowManager.hyprland.enable = true;
}
```

Также в этой директории создайте файл `settings.nix`:
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

И последний файл `binds.nix`:
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

      "$mod, Return, exec, kitty" # ваш терминал
    ];
  };
}
```

Мы создали небольшую конфигурацию Hyprland, которую можно расширить и добавить новые опции.
