# Введение в опции Denix {#introduction}
Опции Denix представляют собой обёртку для `lib.mkOption`. Это означает, что любую опцию Denix можно создать, используя стандартный `lib.mkOption`, и использование опций Denix является необязательным.

## Зачем использовать опции Denix? {#why}
Использование `lib.mkOption` может быть громоздким, и каждый раз писать что-то вроде:

```nix
lib.mkOption {type = lib.types.listOf lib.types.str; default = [];}
```

- неудобно, особенно когда опции в вашей конфигурации используются повсеместно. Вместо этого можно написать более лаконично:

```nix
delib.listOfOption delib.str []
```

Таким образом, вместо создания опции через указание всех параметров, можно использовать функции Denix для более читабельного и аккуратного кода.

## Принцип работы {#principle}
Функции, связанные с опциями, делятся на четыре основных типа:

### Создание опции с типом N
- `*Option <default>` - например, `strOption "foo"`.
- `*OfOption <secondType> <default>` - например, `listOfOption str ["foo" "bar"]`.
- `*ToOption <secondType> <default>` - например, `lambdaToOption int (x: 123)`.

### Добавление к типам опции X тип N
- `allow* <option>` - например, `allowStr ...`.
- `allow*Of <secondType> <option>` - например, `allowListOf str ...`.
- `allow*To <secondType> <option>` - например, `allowLambdaTo int ...`.

### Прямое изменение attribute set опции
- `noDefault <option>` - удаляет атрибут `default` из опции. Используется редко, так как редко бывают опции без значения по умолчанию.
- `noNullDefault <option>` - удаляет атрибут `default` из опции, если его значение равно `null`. Используется для логики значений по умолчанию, где допускается их отсутствие.
- `readOnly <option>` - добавляет атрибут `readOnly` со значением `true`.
- `apply <option> <apply>` - добавляет атрибут `apply` с переданным значением.
- `description <option> <description>` - добавляет атрибут `description` с переданным значением.

### Генерация конкретной опции/опций
- `singleEnableOption <default> { name, ... }` - создаёт attribute set с помощью выражения `delib.setAttrByStrPath "${name}.enable" (boolOption default)`. Обычно это используется в `delib.module :: options`, с её [передаваемыми аргументами](/ru/modules/structure#passed-arguments), поэтому достаточно написать:

```nix
options = delib.singleEnableOption <default>;
```

- `singleCascadeEnableOption { parent, ... }` - создаёт attribute set с помощью `singleEnableOption` выше, но использует `parent.enable` для `<default>`. Пример:

```nix
# если имя (name) текущего модуля это "programs.category.example",
# то он будет включен по умолчанию если "programs.category" включен.
# будет ошибка, если "programs.category.enable" не существует.
options = delib.singleCascadeEnableOption;
```

Список актуальных опций можно найти в исходном коде: [github:yunfachi/denix?path=lib/options.nix](https://github.com/yunfachi/denix/blob/master/lib/options.nix)

## Примеры {#examples}

| Denix                                                                       | lib.mkOption                                                                                             |
|-----------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `portOption 22`                                                             | `mkOption {type = types.port; default = 22;}`                                                            |
| `noDefault (portOption null)`                                               | `mkOption {type = types.port;}`                                                                          |
| `noNullDefault (if myconfig.server.enable then "127.0.0.1:4533" else null)` | `mkOption {type = types.str;} // (if myconfig.server.enable then {default = "127.0.0.1:4533";} else {})` |
| `allowNull (portOption null)`                                               | `mkOption {type = types.nullOr types.port; default = null;}`                                             |
| `allowStr (portOption "22")`                                                | `mkOption {type = types.strOr types.port; default = "22";}`                                              |
| `listOfOption port []`                                                      | `mkOption {type = types.listOf types.port; default = [];}`                                               |
| `readOnly (noDefault (portOption null))`                                    | `mkOption {type = types.port; readOnly = true;}`                                                         |
| `singleEnableOption true {name = "git";}`                                   | `git.enable = mkEnableOption "git" // {default = true;}`                                                 |

> *(Обычно `{name = "git";}` указывать не требуется, так как эта функция в основном используется в `delib.module :: options`)*
