# Структура {#structure}

## Аргументы функции {#function-arguments}
- `name`: строка, представляющая имя хоста.
- `useHomeManagerModule`: добавлять ли модуль Home Manager в конфигурации NixOS и Nix-Darwin этого хоста. По умолчанию `delib.configurations :: useHomeManagerModule`, который, в свою очередь, по умолчанию `true`.
- `homeManagerUser`: имя пользователя, используется в `home-manager.users.${homeManagerUser}` и для генерации списка конфигураций Home Manager. По умолчанию `delib.configurations :: homeManagerUser`.
- `homeManagerSystem`: строка, используемая в атрибуте `pkgs` функции `home-manager.lib.homeManagerConfiguration`, которая используется в функции [`delib.configurations`](/ru/configurations/introduction) в виде `homeManagerNixpkgs.legacyPackages.${homeManagerSystem}`.
- `myconfig`: устанавливает её значение в `config.${myconfigName}`, если `config.${myconfigName}.host` соответствует текущему хосту.
- `nixos`: устанавливает её значение в `config`, если `moduleSystem` равен `nixos` и `config.${myconfigName}.host` соответствует текущему хосту.
- `home`: устанавливает её значение в `config`, если `moduleSystem` равен `home` и `config.${myconfigName}.host` соответствует текущему хосту. В противном случае, если `config.${myconfigName}.host` соответствует текущему хосту, устанавливает её значение в `config.home-manager.users.${homeManagerUser}`.
- `darwin`: устанавливает её значение в `config`, если `moduleSystem` равен `darwin` и `config.${myconfigName}.host` соответствует текущему хосту.
- `shared.myconfig`: устанавливает её значение в `config.${myconfigName}` для всех хостов.
- `shared.nixos`: устанавливает её значение в `config`, если `moduleSystem` равен `nixos`. В противном случае, ничего не делает.
- `shared.home`: устанавливает её значение в `config`, если `moduleSystem` равен `home`. В противном случае, устанавливает в `config.home-manager.users.${homeManagerUser}`.
- `shared.darwin`: устанавливает её значение в `config`, если `moduleSystem` равен `darwin`. В противном случае, ничего не делает.

## Передаваемые аргументы {#passed-arguments}
Список аргументов, которые передаются в `?(shared.)[myconfig|nixos|home|darwin]`, если их тип - `lambda`:

- `name`: тот же `name`, что и в аргументах `delib.host`.
- `myconfig`: равен `config.${myConfigName}`.
- `cfg`: равен `config.${myConfigName}.hosts.${delib.host :: name}`.

## Псевдокод {#pseudocode}
```nix
delib.host {
  name = "";

  useHomeManagerModule = true;
  homeManagerUser = "sjohn";

  # homeManagerNixpkgs.legacyPackages.${homeManagerSystem}
  homeManagerSystem = "x86_64-linux";

  # если config.${myconfigName}.host == name
  # то {config.${myConfigName} = ...;}
  # иначе {}
  myconfig = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.host == name, то
  #   если moduleSystem == "nixos",
  #   то {config = ...;}
  #   иначе {}
  # иначе {}
  nixos = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.host == name, то
  #   если moduleSystem == "home"
  #   то {config = ...;}
  #   иначе {config.home-manager.users.${homeManagerUser} = ...;}
  # иначе {}
  home = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.host == name, то
  #   если moduleSystem == "darwin",
  #   то {config = ...;}
  #   иначе {}
  # иначе {}
  darwin = {name, cfg, myconfig, ...}: {};

  # config.${myConfigName} = ...
  shared.myconfig = {name, cfg, myconfig, ...}: {};

  # если moduleSystem == "nixos"
  # то {config = ...;}
  # иначе {}
  shared.nixos = {name, cfg, myconfig, ...}: {};

  # если moduleSystem == "home"
  # то {config = ...;}
  # иначе {config.home-manager.users.${homeManagerUser} = ...;}
  shared.home = {name, cfg, myconfig, ...}: {};

  # если moduleSystem == "darwin"
  # то {config = ...;}
  # иначе {}
  shared.darwin = {name, cfg, myconfig, ...}: {};
}
```
