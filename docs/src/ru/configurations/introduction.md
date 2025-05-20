# Введение в конфигурации Denix (флейки) {#introduction}
Функция `delib.configurations` используется для создания списков `nixosConfigurations`, `homeConfigurations` и `darwinConfigurations` для флейков.

Помимо всех хостов, она также добавляет комбинации каждого хоста с каждым **не `inheritanceOnly`** райсом, что позволяет быстро переключаться между райсами без редактирования кода. Например, если у хоста "desktop" задан райс "light", то при выполнении следующей команды:

```sh
nixos-rebuild switch --flake .#desktop --use-remote-sudo
```

будет использован хост "desktop" с райсом "light". Однако, если необходимо быстро переключиться на другой райс, например, на "dark", можно выполнить следующую команду:

```sh
nixos-rebuild switch --flake .#desktop-dark --use-remote-sudo
```

В этом случае хост останется "desktop", но райс изменится на "dark".

Важно отметить, что при смене райса таким образом меняется только значение опции `${myConfigName}.rice`, при этом значение `${myconfigName}.hosts.${hostName}.rice` остаётся прежним.

## Принцип генерации списка конфигураций {#principle}
Список конфигураций генерируется по следующему принципу:

- `{hostName}` - где `hostName` - имя любого хоста.
- `{hostName}-{riceName}` - где `hostName` - имя любого хоста, а `riceName` - имя любого райса, у которого `inheritanceOnly` равно `false`.

Если `moduleSystem` из [аргументов функции](/ru/configurations/structure#function-arguments) равен `home`, то ко всем конфигурациям в списке добавляется префикс `{homeManagerUser}@`.

## Пример {#example}
Пример `outputs` флейка для `nixosConfigurations`, `homeConfigurations` и `darwinConfigurations`:

```nix
outputs = {denix, nixpkgs, ...} @ inputs: let
  mkConfigurations = moduleSystem:
    denix.lib.configurations rec {
      inherit moduleSystem;
      homeManagerUser = "sjohn";

      paths = [./hosts ./modules ./rices];

      specialArgs = {
        inherit inputs moduleSystem homeManagerUser;
      };
    };
in {
  nixosConfigurations = mkConfigurations "nixos";
  homeConfigurations = mkConfigurations "home";
  darwinConfigurations = mkConfigurations "darwin";
}
```
