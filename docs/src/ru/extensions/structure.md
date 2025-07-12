# Структура {#structure}
Каждое расширение создаётся через `delib.extension`.

## Аргументы функции {#function-arguments}
- `name`: строка. Должно быть уникальным. Используется для поиска в `delib.extensions` или `delib.callExtensions`.
- `description`: строка. Краткое описание. По умолчанию `""`, но для официальных расширений заполнение обязательное.
- `maintainers`: список ответственных за расширение. По умолчанию `[]`.
- `config`: оверлей. Если указана lambda с 1 параметром или attrset, то значение будет преобразовано в lambda с 2 параметрами с помощью `nixpkgs.lib.toExtension`, где lambda с 1 параметром - это `prev`. По умолчанию `final: prev: {}`.
- `initialConfig`: объект, на который накладываются оверлеи, или null. Если указан attrset, он будет преобразован в lambda с 1 параметром `final`. Если вы мержите расширения, то только у одного из них может быть значение `initialConfig`, отличающееся от `null`. По умолчанию `null`.
- `configOrder`: целое число. Указывает порядок композиции `config` этого расширения с `config` других расширений при мерже. Чем меньше число, тем раньше, а следовательно и важнее. По умолчанию `0`.
- `libExtension`: оверлей с конфигурацией расширения. Если указана lambda с 1 параметром, то этот параметр - `config`, а если с двумя - `config` и `prev`. Применяется к `delib`. По умолчанию `config: final: prev: {}`.
- `libExtensionOrder`: целое число. Указывает порядок композиции `libExtension` этого расширения с `libExtension` других расширений при мерже. Чем меньше число, тем раньше, а следовательно и важнее. По умолчанию `0`.
- `modules`: список модулей с конфигурацией расширения. Если указана lambda с 1 параметром, то этот параметр - `config`. Импортирует указанные модули в конфигурациях, использующих это расширение. Настоятельно не рекомендуется использовать `delib` из аргументов файла, в котором создаётся расширение, при создании модулей. Вместо этого используйте `delib` в самих модулях: `modules = [({delib, ...}: delib.module {/* ... */})]`. По умолчанию `[]`.

## Псевдокод {#pseudocode}
```nix
delib.extension {
  name = "test";
  description = "";
  maintainers = with delib.maintainers; [sjohn];

  # config = {};
  # config = prev: {};
  config = final: prev: {};

  # initialConfig = {};
  # initialConfig = final: {}
  initialConfig = null;

  configOrder = 0;

  # libExtension = {};
  # libExtension = config: {};
  # libExtension = config: prev: {};
  libExtension = config: final: prev: {};

  libExtensionOrder = 0;

  # modules = config: [];
  modules = [];
}
```
