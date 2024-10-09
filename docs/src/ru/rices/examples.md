# Примеры {#examples}

## Минимально рекомендуемый модуль райсов: {#minimally-recommended}
Пример минимальной конфигурации модуля райсов, который является базовой точкой для всех дальнейших настроек:

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

## Краткая версия {#short-version}
Использование `delib.riceNamesAssertions` настоятельно рекомендуется, но можно обойтись и без него:

```nix
{delib, ...}:
delib.module {
  name = "rices";

  options = with delib; let
    rice.options = riceSubmoduleOptions;
  in {
    rice = riceOption rice;
    rices = ricesOption rice;
  };
}
```
