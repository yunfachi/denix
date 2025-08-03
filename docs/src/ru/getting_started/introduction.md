# Введение {#introduction}
В этом разделе вы узнаете о том, что такое Denix, зачем он нужен и кому может быть полезен, а также о популярных практиках конфигурирования системы.

## Что такое Denix {#what-is-denix}
Denix - это библиотека для Nix, предназначенная для создания масштабируемых конфигураций [NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager) и [Nix-Darwin](https://github.com/nix-darwin/nix-darwin).

Она предоставляет функции, которые по определённому алгоритму преобразуют входные данные в модуль. Благодаря этому, если по какой-либо причине вам необходимо создать модуль без использования Denix, будет достаточно импортировать файл с ним, и всё будет работать.

Предоставленные функции, грубо говоря, делятся на пять категорий:
- Создание конфигураций для Flake ([NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager) или [Nix-Darwin](https://github.com/nix-darwin/nix-darwin))
- Опции - аналог типов и функций для создания опций из [Nixpkgs](https://github.com/NixOS/nixpkgs)
- [Модули](#modules)
- [Хосты](#hosts)
- [Райсы](#rices)

## Зачем и кому нужен Denix {#why-and-who-needs-denix}
Denix в первую очередь нужен для упрощения создания, редактирования и улучшения читаемости кода конфигураций. Он избавляет от необходимости создавать типичные выражения для создания своих модулей, хостов, райсов и т.д.

Если вы планируете расширять свою конфигурацию на несколько машин (хостов), хотите иметь различные настройки системы (райсы), которые можно изменить одной командой, и стремитесь писать легкочитаемый и красивый код, то вам стоит попробовать Denix. Если же вы создаёте небольшую конфигурацию для одной машины и не планируете её развивать, то Denix может оказаться избыточным.

Шаблоны конфигураций с использованием Denix можно найти в директории `templates` репозитория на GitHub: [github:yunfachi/denix?path=templates](https://github.com/yunfachi/denix/tree/master/templates).

## Модули {#modules}
Собственные модули - это, возможно, лучшая практика для создания масштабируемых конфигураций.

Модуль включает в себя опции (options), конфигурацию (config) и импорт других модулей (imports).
- `options = {};`: Похоже на декларацию переменных в программировании, но здесь это декларация опций.
- `config = {};`: Аналогично инициализации переменных, но здесь это указание значений для опций.
- `imports = [];`: Список путей к модулям или просто код модуля (attrset или lambda, которая возвращает attrset).

NixOS, Home Manager и Nix-Darwin имеют свои собственные модули, с которыми вы, скорее всего, уже работали. Поиск опций можно выполнить на этих сайтах:
- NixOS: https://search.nixos.org/options
- Home Manager: https://home-manager-options.extranix.com/
- Nix-Darwin: https://nix-darwin.github.io/nix-darwin/manual/

Пример кода собственного модуля NixOS без использования Denix:
```nix
{
  lib,
  config,
  ...
}: {
  options = {
    example = {
      enable = lib.mkEnableOption "example" // {default = true;};
      hostnames = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf (!config.example.enable) {
    networking.hosts."127.0.0.1" = config.example.hostnames;
  };
}
```
Тот же самый функционал, но уже с использованием Denix:
```nix
{delib, ...}:
delib.module {
  name = "example";

  options.example = with delib; {
    enable = boolOption true;
    hostnames = listOfOption str [];
  };

  nixos.ifEnabled = {cfg, ...}: {
    networking.hosts."127.0.0.1" = cfg.hostnames;
  };
}
```
Более подробно о модулях Denix можно узнать в [Модули](/ru/modules/introduction).

## Хосты {#hosts}
Хост (host) - это машина, такая как персональный компьютер, сервер и т.д.

Суть этой практики - разделение конфигурации на общую и уникальную для каждого хоста.

Пример модуля с конфигурацией хоста с использованием Denix:
```nix
{delib, ...}:
delib.host {
  name = "macbook";

  rice = "dark";
  type = "desktop";

  homeManagerSystem = "x86_64-darwin";
  home.home.stateVersion = "24.05";

  shared.myconfig = {
    services.openssh.authorizedKeys = ["ssh-ed25519 ..."];
  };
}
```
Более подробно о хостах Denix можно узнать в [Хосты](/hosts/introduction).

## Райсы {#rices}
Райс (rice) - это жаргонный термин, обозначающий настройки системы, обычно связанные с внешним видом.

В нашем случае это любая конфигурация, не привязанная к какому-либо хосту.

Пример модуля с конфигурацией райса с использованием Denix:
```nix
{delib, ...}:
delib.rice {
  name = "dark";

  home.stylix = {
    polarity = "dark";
    colors = {
      # ...
    };
  };
}
```
Более подробно о райсах Denix можно узнать в [Райсы](/ru/rices/introduction).
