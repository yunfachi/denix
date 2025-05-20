# Распространённые ошибки {#troubleshooting}
В этом разделе перечислены некоторые распространённые ошибки и их возможные решения.

## Условные импорты {#conditional-imports}
Если по какой-либо причине необходимо выполнить импорт внутри [модуля Denix](/ru/modules/introduction), то попытка задать `[nixos|home|darwin].[ifEnabled|ifDisabled].imports` вызовет ошибку `infinite recursion`.

Это означает, что если вам нужно импортировать, например, стороннюю библиотеку, следует сначала добавить её в `[nixos|home|darwin].always.imports`, а затем, при необходимости, задавать значения опций в `[nixos|home|darwin].[always|ifEnabled|ifDisabled]`.

Обсуждение "Conditional module imports": [discourse.nixos.org](https://discourse.nixos.org/t/conditional-module-imports/34863)

### Ошибочный код
```nix
{delib, ...}:
delib.module {
  name = "wrong";
  options = delib.singleEnableOption true;

  nixos.ifEnabled = {
    imports = [<someModule>];

    someModuleOptions.enable = true;
  };
}
```

### Правильный код
```nix
{delib, ...}:
delib.module {
  name = "correct";
  options = delib.singleEnableOption true;

  nixos.always.imports = [<someModule>];

  nixos.ifEnabled.someModuleOptions.enable = true;
}
```