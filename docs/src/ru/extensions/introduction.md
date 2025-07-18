# Введение в расширения Denix {#introduction}
Некоторые функции, противоречащие философии Denix или являющиеся сугубо опциональными, всё равно могут быть реализованы в виде отдельных расширений. Также, если конфигурации необходимо предоставить какую-либо собственную функцию или изменить поведение существующей - это можно сделать с помощью собственного расширения.

В данный момент API расширений позволяет:
- Расширять `delib`, добавляя в него новые функции или переопределяя существующие.
- Добавлять модули, которые автоматически добавляются в конфигурацию.

## Использование {#usage}
Чтобы подключить расширения, необходимо передать аргумент `extensions` в функцию `delib.configurations`. Этот аргумент представляет собой список расширений.

Официальные расширения находятся в `delib.extensions` (см. [Все расширения](/ru/extensions/all-extensions)). Помимо них можно также подключать собственные расширения следующими способами:
* Если расширение - это один файл:

```nix
delib.callExtension ./myExtension.nix
```

* Если расширение состоит из нескольких файлов:

```nix
delib.mergeExtensions "myExtensionName" [
  (delib.callExtension ./myExtensionPart1.nix)
  (delib.callExtension ./myExtensionPart2.nix)
]
```

* Если расширений много:

```nix
(delib.callExtensions { paths = [./myExtensions]; }).myExtension
```

Некоторые расширения поддерживают собственную настройку (не путать с опциями модулей). Настройка производится через `withConfig`:

```nix
delib.extensions.someExtension.withConfig {
  someOption = "value";
}
```
В качестве параметра может использоваться либо оверлей, либо attrset (он будет автоматически преобразован в оверлей). Подробнее см. [NixOS Wiki - Overlays](https://nixos.wiki/wiki/Overlays).

### Пример
```nix
delib.configurations {
  # ...
  extensions =
    with delib.extensions;
    with delib.callExtensions { paths = [./myExtensions]; };
    [
      args
      (base.withConfig (final: prev: {
        args.enable = true;
        hosts.type.types = prev.hosts.type.types ++ ["laptop"];
      }))
      (delib.callExtension ./myExtension.nix)
      extensionFromMyExtensions
      (anotherExtensionFromMyExtensions.withConfig { someConfig = "someValue"; })
    ];
}
```
