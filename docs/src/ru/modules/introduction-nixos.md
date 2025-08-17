# Введение в модули NixOS {#introduction-nixos}
Модуль NixOS - это файл, содержащий Nix-выражение с определенной структурой. В нем указаны опции (options) и значения для этих опций (config). Например, файл `/etc/nixos/configuration.nix` тоже является модулем.

Модули Home Manager и Nix-Darwin устроены аналогично, но они могут работать не только в NixOS, но и на других системах.

Это не подробный гайд по Nix-модулям, поэтому рекомендуется прочитать статью [NixOS Wiki о модулях](https://nixos.wiki/wiki/NixOS_modules).

## Структура {#structure}
Структура модуля NixOS:
```nix
{
  imports = [
    # Пути к остальным модулям или Nix-выражения.
  ];

  options = {
    # Декларация опций.
  };

  config = {
    # Присвоение ранее созданным опциям значений.
    # Например, networking.hostName = "denix";
  };

  # Однако обычно значения опциям присваиваются не в config, а тут.
  # Например, networking.hostName = "denix";
}
```

### Функция {#structure-function}
Модуль также может быть функцией (lambda), которая возвращает attribute set:

```nix
{lib, ...} @ args: {
  # Формально это config._module.args.hostname
  _module.args.hostname = lib.concatStrings ["de" "nix"];

  imports = [
    {hostname, config, ...}: {
      config = lib.mkIf config.customOption.enable {
        networking.hostName = hostname;
      };
    }
  ];
}
```

### Импортирование
`imports` - это список из относительных и абсолютных путей, а также из [функций](#structure-function) и attribute set:

```nix
{
  imports = [
    ./pureModule.nix
    /etc/nixos/impureModule.nix
    {pkgs, ...}: {
      # ...
    }
  ];
}
```

### Опции Nixpkgs
Опции обычно указываются через `lib.mkOption`:

```nix
optionName = lib.mkOption {
  # ...
};
```

`lib.mkOption` принимает attribute set. Некоторые атрибуты:

- `type`: тип значения этой опции, например, `lib.types.listOf lib.types.port`.
- `default`: значение по умолчанию для этой опции.
- `example`: пример значения для этой опции, используется для документации.
- `description`: описание этой опции, также используется для документации.
- `readOnly`: может ли опция быть изменена после декларирования.

Более подробно о опциях Nixpkgs можно узнать в [NixOS Wiki](https://nixos.wiki/wiki/Declaration).

### Опции Denix
В Denix используется другой подход к опциям, хотя можно использовать оба метода одновременно.

Пример модуля с опциями в Denix:

```nix
{delib, ...}:
delib.module {
  name = "coolmodule";

  options.coolmodule = with delib; {
    # boolOption <default>
    enable = boolOption false;
    # noDefault (listOf <type> <default>)
    ports = noDefault (listOfOption port null);
    # allowNull (strOption <default>)
    email = allowNull (strOption null);
  };
}
```

Более подробно о опциях Denix можно узнать в разделе [Опции](/ru/options/introduction).

## Создание своих модулей (опций) {#creating-own-modules}
Декларирование своих опций - отличная практика, если вы хотите включать и отключать части кода. Это может понадобиться, если у вас несколько хостов (машин) с одной конфигурацией, и, например, машине `foo` не нужна программа, которая используется на машине `bar`.

Пример NixOS-модуля для простой настройки git:

```nix
{lib, config, ...}: {
  options.myconfig.programs.git = {
    enable = lib.mkEnableOption "git" // {default = true;};
  };

  config = lib.mkIf config.myconfig.programs.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;

      config = {
        init.defaultBranch = "master";
      };
    };
  };
}
```

То же самое, но с использованием Denix:

```nix
{delib, ...}:
delib.module {
  name = "programs.git";

  options = delib.singleEnableOption true;

  nixos.ifEnabled.programs.git = {
    enable = true;
    lfs.enable = true;

    config = {
      init.defaultBranch = "master";
    };
  };
}
```
