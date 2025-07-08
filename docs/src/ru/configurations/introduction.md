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
outputs = {denix, ...} @ inputs: let
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

## Использование нескольких каналов {#multiple-channels}
Для удобной работы с несколькими каналами в конфигурации функция `delib.configurations` принимает аргументы `nixpkgs`, `home-manager` и `nix-darwin`, которые используются в сгенерированных конфигурациях.

**По умолчанию эти аргументы указывать не требуется** - они равны соответствующим значениям из `inputs` флейка Denix. Эти значения можно также переопределить через `inputs.denix.inputs.<input>.follows`, однако такой способ больше подходит тем, кто использует только один канал.

Таким образом:
- `delib.configurations :: [nixpkgs, home-manager, nix-darwin]` - для тех, кому нужно несколько каналов.
- `inputs.denix.<nixpkgs|home-manager|nix-darwin>.follows` - для тех, кому достаточно одного канала.

Исходя из этого, возможны следующие варианты использования:

1. Переопределение `nixpkgs`, `home-manager` и `nix-darwin` через аргументы функции `delib.configurations` на каналы "stable" и "unstable" для `./hosts/stable` и `./hosts/unstable` соответственно. Обратите внимание, что реализация функции `mkConfigurations` в этом примере может быть произвольной - это лишь демонстрация подхода.
```nix
{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-darwin-unstable = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin-stable = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    denix.url = "github:yunfachi/denix";
  };

  outputs = {
    denix,
    nixpkgs-unstable,
    nixpkgs-stable,
    home-manager-unstable,
    home-manager-stable,
    nix-darwin-unstable,
    nix-darwin-stable,
    ...
  } @ inputs: let
    _mkConfigurations = nixpkgs: home-manager: nix-darwin: hosts: moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem nixpkgs home-manager nix-darwin;
        homeManagerUser = "sjohn";

        paths = [./modules ./rices] ++ hosts;

        specialArgs = {
          inherit inputs;
        };
      };

    mkConfigurations = moduleSystem:
      nixpkgs-unstable.lib.attrsets.mergeAttrsList
      (map (f: f moduleSystem) [
        (_mkConfigurations nixpkgs-stable home-manager-stable nix-darwin-stable [./hosts/stable])
        (_mkConfigurations nixpkgs-unstable home-manager-unstable nix-darwin-unstable [./hosts/unstable])
      ]);
  in {
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
    darwinConfigurations = mkConfigurations "darwin";
  };
}
```

2. Переопределение `nixpkgs`, `home-manager` и `nix-darwin` через `inputs.denix.inputs.<name>.follows`. Это рекомендуемый способ для тех, кто использует только один канал.
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-darwin.follows = "nix-darwin";
    };
  };

  outputs = {denix, ...} @ inputs: let
    mkConfigurations = moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem;
        homeManagerUser = "sjohn";

        paths = [./hosts ./modules ./rices];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
    darwinConfigurations = mkConfigurations "darwin";
  };
}
```

3. Не переопределять ничего. Также вариант для использования одного канала, но менее рекомендуемый.
```nix
{
  inputs = {
    denix.url = "github:yunfachi/denix";
  };

  outputs = {denix, ...} @ inputs: let
    mkConfigurations = moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem;
        homeManagerUser = "sjohn";

        paths = [./hosts ./modules ./rices];

        specialArgs = {
          inherit inputs;
        };
      };
  in {
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
    darwinConfigurations = mkConfigurations "darwin";
  };
}
```
