# Структура {#structure}

## Аргументы функции {#function-arguments}
- `myconfigName` (string): категория для всех опций модулей Denix, хостов и райсов. По умолчанию `myconfig`; изменять не рекомендуется.
- `denixLibName` (string): имя библиотеки Denix в `specialArgs` (`{denixLibName, ...}: denixLibName.module { ... }`). По умолчанию `delib`; изменять не рекомендуется.
- `homeManagerNixpkgs` (nixpkgs): используется в атрибуте `pkgs` функции `home-manager.lib.homeManagerConfiguration` в формате: `homeManagerNixpkgs.legacyPackages.${host :: homeManagerSystem}`. По умолчанию берется `nixpkgs` из флейка, поэтому если вы указали `inputs.denix.inputs.nixpkgs.follows = "nixpkgs";`, указывать `homeManagerNixpkgs` обычно не имеет смысла.
- `homeManagerUser` (string): имя пользователя, используется в `home-manager.users.${homeManagerUser}` и для генерации списка конфигураций Home Manager.
- `isHomeManager` (boolean): указывает, создавать ли список конфигураций для Home Manager или для NixOS.
- `paths` (listOf string): пути, которые будут импортированы; добавьте сюда хосты, райсы и модули. По умолчанию `[]`.
- `exclude` (listOf string): пути, которые будут исключены из импортирования. По умолчанию `[]`.
- `recursive` (boolean): определяет, следует ли рекурсивно искать пути для импортирования. По умолчанию `true`.
- `specialArgs` (attrset): `specialArgs`, которые будут переданы в `lib.nixosSystem` и `home-manager.lib.homeManagerConfiguration`. По умолчанию `{}`.
- **EXPERIMENTAL** `extraModules` (list): по умолчанию `[]`.
- **EXPERIMENTAL** `mkConfigurationsSystemExtraModule` (attrset): модуль, используемый во внутренней конфигурации NixOS, который получает список хостов и райсов для генерации списка конфигураций. По умолчанию `{nixpkgs.hostPlatform = "x86_64-linux";}`.

## Псевдокод {#pseudocode}
```nix
delib.configurations {
  myconfigName = "myconfig";
  denixLibName = "delib";
  homeManagerNixpkgs = inputs.nixpkgs;
  homeManagerUser = "";
  isHomeManager = true;
  paths = [./modules ./hosts ./rices];
  exclude = [./modules/deprecated];
  recursive = true;
  specialArgs = {
    inherit inputs;
    isHomeManager = true;
  };
}
```
