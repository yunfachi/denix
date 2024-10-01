# Структура {#structure}

## Аргументы функции {#function-arguments}
- `name`: строка, представляющая имя хоста.
- `homeManagerSystem`: строка, используемая в атрибуте `pkgs` функции `home-manager.lib.homeManagerConfiguration`, которая используется в функции [`delib.configurations`](/ru/configurations/introduction) в виде `homeManagerNixpkgs.legacyPackages.${homeManagerSystem}`.
- `myconfig`: устанавливает её значение в `config.${myconfigName}`, если `config.${myconfigName}.host` соответствует текущему хосту.
- `nixos`: устанавливает её значение в `config`, если `isHomeManager` равен `false` и `config.${myconfigName}.host` соответствует текущему хосту.
- `home`: устанавливает её значение в `config`, если `isHomeManager` равен `true` и `config.${myconfigName}.host` соответствует текущему хосту. В противном случае, если `config.${myconfigName}.host` соответствует текущему хосту, устанавливает её значение в `config.home-manager.users.${homeManagerUser}`.
- `shared.myconfig`: устанавливает её значение в `config.${myconfigName}` для всех хостов.
- `shared.nixos`: устанавливает её значение в `config`, если `isHomeManager` равен `false`. В противном случае, не выполняется.
- `shared.home`: устанавливает её значение в `config`, если `isHomeManager` равен `true`. В противном случае, устанавливает в `config.home-manager.users.${homeManagerUser}`.

## Передаваемые аргументы {#passed-arguments}
Список аргументов, которые передаются в `?(shared.)[myconfig|nixos|home]`, если их тип - `lambda`:

- `name`: тот же `name`, что и в аргументах `delib.host`.
- `myconfig`: равен `config.${myConfigName}`.
- `cfg`: равен `config.${myConfigName}.hosts.${delib.host :: name}`.

## Псевдокод {#pseudocode}
```nix
delib.host {
  name = "";

  # homeManagerNixpkgs.legacyPackages.${homeManagerSystem}
  homeManagerSystem = "x86_64-linux";

  # если config.${myconfigName}.host == name
  # то {config.${myConfigName} = ...;}
  # иначе {}
  myconfig = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.host == name
  # то {config = ...;}
  # иначе {}
  nixos = {name, cfg, myconfig, ...}: {};

  # если config.${myconfigName}.host == name, то
  #   если isHomeManager
  #   то {config = ...;}
  #   иначе {config.home-manager.users.${homeManagerUser} = ...;}
  # иначе {}
  home = {name, cfg, myconfig, ...}: {};

  # config.${myConfigName} = ...
  shared.myconfig = {name, cfg, myconfig, ...}: {};

  # config = ...
  shared.nixos = {name, cfg, myconfig, ...}: {};

  # если isHomeManager
  # то {}
  # иначе {config = ...;}
  shared.home = {name, cfg, myconfig, ...}: {};
}
```
