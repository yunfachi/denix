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
- `cfg`{#passed-arguments-cfg}: по сути, значения (присвоенные) из конфигурации текущего модуля. Другими словами, равняется `config.${myConfigName}.${name}`, где `name` это [аргумент](#function-arguments-name) из `delib.module`, "раскрывающийся" (конвертируется в валидный путь как атрибут) при этом.
- `parent`: равняется модулю-"родителю" (набору атрибутов) `cfg`. Пример: `parent` это `config.${myConfigName}.programs`, если `cfg` это `config.${myConfigName}.programs.example`.

## Псевдокод {#pseudocode}
```nix
delib.module {
  name = "";

  # options.${myConfigName} = ...
  options = {name, cfg, parent, myconfig, ...}: {};

  # config.${myConfigName} = ...
  myconfig.ifEnabled = {name, cfg, parent, myconfig, ...}: {};
  myconfig.ifDisabled = {name, cfg, parent, myconfig, ...}: {};
  myconfig.always = {name, cfg, parent, myconfig, ...}: {};

  # если moduleSystem == "nixos"
  # то {config = ...;}
  # иначе {}
  nixos.ifEnabled = {name, cfg, parent, myconfig, ...}: {};
  nixos.ifDisabled = {name, cfg, parent, myconfig, ...}: {};
  nixos.always = {name, cfg, parent, myconfig, ...}: {};

  # если moduleSystem == "home"
  # то {config = ...;}
  # иначе {config.home-manager.users.${homeManagerUser} = ...;}
  home.ifEnabled = {name, cfg, parent, myconfig, ...}: {};
  home.ifDisabled = {name, cfg, parent, myconfig, ...}: {};
  home.always = {name, cfg, parent, myconfig, ...}: {};

  # если moduleSystem == "darwin"
  # то {config = ...;}
  # иначе {}
  darwin.ifEnabled = {name, cfg, parent, myconfig, ...}: {};
  darwin.ifDisabled = {name, cfg, parent, myconfig, ...}: {};
  darwin.always = {name, cfg, parent, myconfig, ...}: {};
}
```
