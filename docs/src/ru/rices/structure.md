# Структура {#structure}

## Аргументы функции {#function-arguments}
- `name`: строка, представляющая имя райса.
- `inherits`: список строк - имена райсов, чьи конфигурации будут унаследованы текущим райсом.
- `inheritanceOnly`: булевое значение (`true` или `false`), которое определяет, будет ли этот райс добавлен в [список систем, сгенерированный для каждого хоста и райса](/ru/configurations/introduction), или же он используется только для наследования.
- `myconfig`: устанавливает её значение в `config.${myconfigName}`, если `config.${myconfigName}.rice` соответствует текущему райсу.
- `nixos`: устанавливает её значение в `config`, если `moduleSystem` равен `nixos` и `config.${myconfigName}.rice` соответствует текущему райсу.
- `home`: устанавливает её значение в `config`, если `moduleSystem` равен `home` и `config.${myconfigName}.rice` соответствует текущему райсу. В противном случае, если `config.${myconfigName}.rice` соответствует текущему райсу, устанавливает её значение в `config.home-manager.users.${homeManagerUser}`.
- `darwin`: устанавливает её значение в `config`, если `moduleSystem` равен `darwin` и `config.${myconfigName}.rice` соответствует текущему райсу.

## Передаваемые аргументы {#passed-arguments}
Список аргументов, которые передаются в `[myconfig|nixos|home|darwin]`, если их тип - `lambda`:

- `name`: тот же `name`, что и в аргументах `delib.rice`.
- `myconfig`: равен `config.${myConfigName}`.
- `cfg`: равен `config.${myConfigName}.rices.${delib.rice :: name}`.

## Псевдокод {#pseudocode}
```nix
delib.rice {
  name = "";

  inherits = [];

  inheritanceOnly = [];

  # если config.${myconfigName}.rice == name
  # то {config.${myConfigName} = ...;}
  # иначе {}
  myconfig = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.rice == name, то
  #   если moduleSystem == "nixos"
  #   то {config = ...;}
  #   иначе {}
  # иначе {}
  nixos = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.rice == name, то
  #   если moduleSystem == "home"
  #   то {config = ...;}
  #   иначе {config.home-manager.users.${homeManagerUser} = ...;}
  # иначе {}
  home = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.rice == name, то
  #   если moduleSystem == "darwin"
  #   то {config = ...;}
  #   иначе {}
  # иначе {}
  darwin = {name, cfg, myconfig, ...}: {};
}
```
