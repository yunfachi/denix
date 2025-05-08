# Введение в конфигурации Denix (флейки) {#introduction}
Функция `delib.configurations` используется для создания списков `nixosConfigurations` и `homeConfigurations` для флейков.

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

Если `isHomeManager` из [аргументов функции](/ru/configurations/structure#function-arguments) равен `true`, то ко всем конфигурациям в списке добавляется префикс` {homeManagerUser}@`.

## Пример {#example}
Пример `outputs` флейка для `nixosConfigurations` и `homeConfigurations`:

```nix
outputs = {denix, nixpkgs, ...} @ inputs: let
  mkConfigurations = isHomeManager:
    denix.lib.configurations rec {
      homeManagerUser = "sjohn";
      inherit isHomeManager;

      paths = [./hosts ./modules ./rices];

      specialArgs = {
        inherit inputs isHomeManager homeManagerUser;
      };
    };
in {
  nixosConfigurations = mkConfigurations false;
  homeConfigurations = mkConfigurations true;
}
```
