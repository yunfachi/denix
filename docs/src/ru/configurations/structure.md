# Структура {#structure}

## Аргументы функции {#function-arguments}
- `myconfigName` (string): категория для всех опций модулей Denix, хостов и райсов. По умолчанию `myconfig`; изменять не рекомендуется.
- `denixLibName` (string): имя библиотеки Denix в `specialArgs` (`{denixLibName, ...}: denixLibName.module { ... }`). По умолчанию `delib`; изменять не рекомендуется.
- `nixpkgs` (nixpkgs): используется для переопределения nixpkgs в вашей конфигурации, аналогично `inputs.denix.inputs.nixpkgs.follows`. По умолчанию `inputs.nixpkgs`.
- `home-manager` (home-manager): используется для переопределения home-manager в вашей конфигурации, аналогично `inputs.denix.inputs.home-manager.follows`. По умолчанию `inputs.home-manager`.
- `nix-darwin` (nix-darwin): используется для переопределения nix-darwin в вашей конфигурации, аналогично `inputs.denix.inputs.nix-darwin.follows`. По умолчанию `inputs.nix-darwin`.
- `homeManagerNixpkgs` (nixpkgs): используется в атрибуте `pkgs` функции `home-manager.lib.homeManagerConfiguration` в формате: `homeManagerNixpkgs.legacyPackages.${host :: homeManagerSystem}`. По умолчанию используется `nixpkgs` из аргументов этой функции.
- `homeManagerUser` (string): имя пользователя, используется в `home-manager.users.${homeManagerUser}` и для генерации списка конфигураций Home Manager.
- `moduleSystem` (`"nixos"`, `"home"` и `"darwin"`): указывает, для какой модульной системы должен быть создан список конфигураций - NixOS, Home Manager или Nix-Darwin.
- `paths` (listOf string): пути, которые будут импортированы; добавьте сюда хосты, райсы и модули. По умолчанию `[]`.
- `exclude` (listOf string): пути, которые будут исключены из импортирования. По умолчанию `[]`.
- `recursive` (boolean): определяет, следует ли рекурсивно искать пути для импортирования. По умолчанию `true`.
- `specialArgs` (attrset): `specialArgs`, которые будут переданы в `lib.nixosSystem`, `home-manager.lib.homeManagerConfiguration` и `nix-darwin.lib.darwinSystem`. По умолчанию `{}`.
- **EXPERIMENTAL** `extraModules` (list): по умолчанию `[]`.
- **EXPERIMENTAL** `mkConfigurationsSystemExtraModule` (attrset): модуль, используемый во внутренней конфигурации NixOS, который получает список хостов и райсов для генерации списка конфигураций. По умолчанию `{nixpkgs.hostPlatform = "x86_64-linux";}`.

## Псевдокод {#pseudocode}
```nix
delib.configurations rec {
  myconfigName = "myconfig";
  denixLibName = "delib";
  nixpkgs = inputs.nixpkgs;
  home-manager = inputs.home-manager;
  nix-darwin = inputs.nix-darwin;
  homeManagerNixpkgs = nixpkgs;
  homeManagerUser = "sjohn";
  moduleSystem = "nixos";
  paths = [./modules ./hosts ./rices];
  exclude = [./modules/deprecated];
  recursive = true;
  specialArgs = {
    inherit inputs;
  };
}
```
