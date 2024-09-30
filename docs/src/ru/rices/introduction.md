# Введение в райсы Denix {#introduction}
Райс (rice) - это attribute set, возвращаемый функцией [`delib.rice`](/ru/rices/structure), который включает или отключает определенные конфигурации в зависимости от значения опции `${myconfigName}.rice`. Также он передает входящий attribute set в функцию `delib.rice` в опцию `${myconfigName}.rice.${delib.rice :: name}`.

Термин "райс" в жаргоне обозначает настройки системы, которые чаще всего связаны с внешним видом. В контексте Denix райс представляет собой конфигурацию, которую можно применить **к любому** хосту, и она будет работать корректно.

При этом райсы не являются обязательными - если вы не хотите их использовать, просто не добавляйте опции `${myconfigName}.rices` и `${myconfigName}.rice`, а также не вызывайте функцию `delib.rice`.

## Наследование {#inheritance}
Райс может наследовать все конфигурации другого райса через атрибут `inherits`. Кроме того, можно установить `inheritanceOnly = true;`, чтобы скрыть райс от генерации в [`delib.system`](/TODO), оставив его только для наследования.

Пример трех райсов, где первые два наследуют все конфигурации райса "rounded":

```nix
delib.rice {
  name = "black";
  inherits = ["rounded"];
  myconfig.colorscheme = "black";
}
```

```nix
delib.rice {
  name = "light";
  inherits = ["rounded"];
  myconfig.colorscheme = "light";
}
```

```nix
delib.rice {
  name = "rounded";
  inheritanceOnly = true;
  myconfig.hyprland.rounding = "6";
}
```

## Опции {#options}
Для работы райсов ваша конфигурация должна включать опции `${myconfigName}.rice` и `${myconfigName}.rices`, которые **вы задаете самостоятельно** в одном из модулей.

Пример минимальной рекомендуемой конфигурации для райсов:

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

Другие примеры можно найти в разделе [Примеры](/ru/rices/examples). 
