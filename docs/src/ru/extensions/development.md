# Разработка {#development}
В этом разделе описано, как правильно импортировать расширения. Для примеров создания расширений изучите исходный код существующих расширений.

## Импортирование {#importing}
Для начала определитесь, сколько расширений и файлов вы хотите импортировать.

Если расширений несколько, или они разбиты на файлы:

```nix
delib.callExtensions {
  paths = [./foo ./default.nix]; # по умолчанию: []
  exclude = [./foo/test.nix];    # по умолчанию: []
  recursive = true;              # по умолчанию: true
}
# Возвращает attrset, где ключи - это имена расширений, а значения - сами расширения.
```

Если расширение одно и представляет собой один файл:

```nix
delib.callExtension ./default.nix
# Возвращает одно расширение.
```

## Распространение {#distribution}
Чтобы предоставить свои расширения для использования в других флейках, добавьте в `outputs` attrset `denixExtensions`:

```nix
outputs = {denix, ...}: {
  denixExtensions = denix.lib.callExtensions {
    paths = [./extensions];
  };
};
```

Можно также создать отдельный флейк, содержащий только расширения:
::: code-group
<<< @/../../templates/extensions-collection/flake.nix
:::

Для этого можно использовать шаблон:

```sh
nix flake init -t github:yunfachi/denix#extensions-collection
```

Если вы хотите использовать `denixExtensions` в том же флейке, где находится конфигурация, обращайтесь к `self`:

```nix
outputs = {denix, self, ...}: let
  mkConfigurations = moduleSystem:
    # ...
    denix.lib.configurations {
      extensions = with denix.lib.extensions; with self.denixExtensions; [
        args # denix.lib.extensions
        awesomeExtension # self.denixExtensions
      ];
    };
in {
  denixExtensions = denix.lib.callExtensions {paths = [./extensions];};
};
```
