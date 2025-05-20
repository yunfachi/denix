# Структура {#structure}
В этом разделе будут использованы переменные `myconfigName`, `moduleSystem` и `homeManagerUser`, поэтому рекомендуется предварительно ознакомиться с соответствующим подразделом: [Аргументы delib.configurations](/ru/configurations/structure#function-arguments).

## Аргументы функции {#function-arguments}
- `name`{#function-arguments-name}: строка. Рекомендуется, чтобы она совпадала с родительским путём опции `enable` модуля, например, `"programs.example"`, так как передаваемый аргумент `cfg` зависит именно от этого пути.
- `options`: attrset или lambda, которая возвращает attrset (см. [Опции](/ru/options/introduction)).
- `[myconfig|nixos|home|darwin].[ifEnabled|ifDisabled|always]`: attrset или lambda, которая возвращает attrset.
  - `myconfig.*`: устанавливает значения в `config.${myconfigName}`.
  - `nixos.*`: устанавливает значения в `config`, если `moduleSystem` равен `nixos`. В противном случае, ничего не делает.
  - `home.*`: устанавливает значения в `config`, если `moduleSystem` равен `home`. В противном случае, устанавливает в `config.home-manager.users.${homeManagerUser}`.
  - `darwin.*`: устанавливает значения в `config`, если `moduleSystem` равен `darwin`. В противном случае, ничего не делает.
  - `[myconfig|nixos|home|darwin].ifEnabled`: выполняется только если опция `cfg.enable` (см. [Передаваемые аргументы - cfg](#passed-arguments-cfg)) существует и равна `true`.
  - `[myconfig|nixos|home|darwin].ifDisabled`: выполняется только если опция `cfg.enable` существует и равна `false`.
  - `[myconfig|nixos|home|darwin].always`: выполняется всегда, даже если опция `cfg.enable` не существует.

## Передаваемые аргументы {#passed-arguments}
Список аргументов, которые передаются в `options` и `[myconfig|nixos|home|darwin].[ifEnabled|ifDisabled|always]`, если их тип - это `lambda`:
- `name`: тот же [name](#function-arguments-name) из аргументов `delib.module`.
- `myconfig`: равен `config.${myConfigName}`.
- `cfg`{#passed-arguments-cfg}: равен результату выражения `delib.getAttrByStrPath name config.${myConfigName} {}`, где `name` - это [аргумент](#function-arguments-name) `delib.module`, а `{}` - значение, которое возвращается, если атрибут не найден.

## Псевдокод {#pseudocode}
```nix
delib.module {
  name = "";

  # options.${myConfigName} = ...
  options = {name, cfg, myconfig, ...}: {};

  # config.${myConfigName} = ...
  myconfig.ifEnabled = {name, cfg, myconfig, ...}: {};
  myconfig.ifDisabled = {name, cfg, myconfig, ...}: {};
  myconfig.always = {name, cfg, myconfig, ...}: {};

  # если moduleSystem == "nixos"
  # то {config = ...;}
  # иначе {}
  nixos.ifEnabled = {name, cfg, myconfig, ...}: {};
  nixos.ifDisabled = {name, cfg, myconfig, ...}: {};
  nixos.always = {name, cfg, myconfig, ...}: {};

  # если moduleSystem == "home"
  # то {config = ...;}
  # иначе {config.home-manager.users.${homeManagerUser} = ...;}
  home.ifEnabled = {name, cfg, myconfig, ...}: {};
  home.ifDisabled = {name, cfg, myconfig, ...}: {};
  home.always = {name, cfg, myconfig, ...}: {};

  # если moduleSystem == "darwin"
  # то {config = ...;}
  # иначе {}
  darwin.ifEnabled = {name, cfg, myconfig, ...}: {};
  darwin.ifDisabled = {name, cfg, myconfig, ...}: {};
  darwin.always = {name, cfg, myconfig, ...}: {};
}
```
