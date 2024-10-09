# Примеры {#examples}

## Минимально рекомендуемый модуль хостов: {#minimally-recommended}
Пример минимальной конфигурации модуля хостов, который является базовой точкой для всех дальнейших настроек:

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

## С опцией `type` {#type-option}
Опция `type` **очень** полезна для задания значений по умолчанию в своих модулях. Например, опция `enable = boolOption host.isDesktop` может использоваться для какой-нибудь GUI программы. Это упрощает управление конфигурациями в зависимости от типа устройства.

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

## С опцией `displays` {#displays-option}
Эта опция может быть полезна для настройки мониторов, однако её можно реализовать как отдельный модуль.

```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {config, ...}: {
      options =
        hostSubmoduleOptions
        // {
          displays = listOfOption (submodule {
            options = {
              enable = boolOption true;
              touchscreen = boolOption false;

              # e.g. DP-1, HDMI-A-1
              name = noDefault (strOption null);
              primary = boolOption (builtins.length config.displays == 1);
              refreshRate = intOption 60;

              width = intOption 1920;
              height = intOption 1080;
              x = intOption 0;
              y = intOption 0;
            };
          }) [];
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

## Краткая версия {#short-version}
Использование `delib.hostNamesAssertions` настоятельно рекомендуется, но можно обойтись и без него:

```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host.options = hostSubmoduleOptions;
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };
}
```
