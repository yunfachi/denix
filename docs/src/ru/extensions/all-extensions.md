# Все расширения {#all}
В этом разделе описаны все официальные расширения Denix.

## Args {#args}
<table class="extension-table">
  <tr>
    <th>Название</th>
    <td><code>args</code></td>
  </tr>
  <tr>
    <th>Описание</th>
    <td>Более удобный способ задавать значение <code>_module.args</code> с помощью <code>myconfig</code></td>
  </tr>
  <tr>
    <th>Ответственные</th>
    <td>yunfachi (<a href='https://github.com/yunfachi'>GitHub</a>, <a href='https://t.me/yunfachi'>Telegram</a>)</td>
  </tr>
</table>

### Настройки {#args-settings}
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `path` | `"args"` | Путь в `myconfig`, где будут созданы опции |

## Base {#base}
<table class="extension-table">
  <tr>
    <th>Название</th>
    <td><code>base</code></td>
  </tr>
  <tr>
    <th>Описание</th>
    <td>Создаёт функциональные и тонко настраиваемые модули для хостов и райсов с минимальными усилиями</td>
  </tr>
  <tr>
    <th>Ответственные</th>
    <td>yunfachi (<a href='https://github.com/yunfachi'>GitHub</a>, <a href='https://t.me/yunfachi'>Telegram</a>)</td>
  </tr>
</table>

### Настройки {#base-settings}
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enableAll` {#base-settings-enableAll} | `true` | Обозначает значение по умолчанию для `hosts.enable` и `rices.enable` |

`args`
<blockquote>

| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` {#base-settings-args-enable} | `false` | Обозначает значение по умолчанию для `hosts.args.enable` и `rices.args.enable` |
| `path` {#base-settings-args-path} | `"args"` | Обозначает значение по умолчанию для `hosts.args.path` и `rices.args.path` |
</blockquote>

`assertions`
<blockquote>

| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` {#base-settings-assertions-enable} | `true` | Обозначает значение по умолчанию для `hosts.assertions.enable` и `rices.assertions.enable` |
| `moduleSystem` {#base-settings-assertions-moduleSystem} | `"home-manager"` | Обозначает значение по умолчанию для `hosts.assertions.moduleSystem` и `rices.assertions.moduleSystem` |
</blockquote>

`hosts`
<blockquote>

| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | [`enableAll`](#base-settings-enableAll) | Создавать ли модуль хостов |
| `extraSubmodules` | `[]` | Дополнительные подмодули, используемые для создания собственных опций в типе хоста. Пример значения: `[ ({ config, ... }:  { options.coolName = "cool " + config.name; }) ]` |

`hosts.args`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | [`args.enable`](#base-settings-args-enable) | Создавать ли аргументы `host` и `hosts` с расширением [`args`](#args) |
| `path` | [`args.path`](#base-settings-args-path) | Путь к опциям расширения [`args`](#args) |

`hosts.system`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | `true` | Создавать ли string-опцию `system` в подмодуле хоста, которая задает значения опциям `homeManagerSystem`, `nixos.nixpkgs.hostPlatform` и `darwin.nixpkgs.hostPlatform` |

`hosts.assertions`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | [`assertions.enable`](#base-settings-assertions-enable) | Добавлять ли `delib.hostNamesAssertions` в опцию `assertions` указанной модульной системы |
| `moduleSystem` | [`assertions.moduleSystem`](#base-settings-assertions-moduleSystem) | Модульная система в которую будут добавлены assertions. Можно указать любое значение, даже `"myconfig"`, если у вас есть специальный для этого модуль. Значения `"home-manager"` и `"nix-darwin"` автоматически преобразуются в `"home"` и `"darwin"` соответственно |

`hosts.type`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | `true` | Создавать ли enum-опцию `type` в подмодуле хоста |
| `generateIsType` | `true` | Генерировать ли булевую опцию для каждого `hosts.type.types` в следующем формате: `"is{Type}"` |
| `types` | `["desktop" "server"]` | Все допустимые значения для опции `type` в подмодуле хоста. Заметьте, если вы хотите добавить новый элемент в список, а не полностью перезаписать его, то это делается так: `types = prev.types ++ ["newType"];` |

`hosts.features`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | `true` | Создавать ли опцию `features` с типом enum-список в подмодуле хоста |
| `generateIsFeatured` | `true` | Генерировать ли булевую опцию для каждого `hosts.features.features` в следующем формате: `"{feature}Featured"` |
| `features` | `[]` | Все допустимые значения для опции `features` в подмодуле хоста |
| `default` | `[]` | Значение по умолчанию для опции `features` в подмодуле хоста |
| `defaultByHostType` | `{}` | Attrset, где ключи - это одно из значений `hosts.type.types`, а значения - список, аналогичный `hosts.features.default`. С `hosts.features.default` объединяется список, чей ключ равен значению опции `type` в подмодуле хоста |

`hosts.displays`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | `true` | Создавать ли опцию `displays` в подмодуле хоста, тип которой - это список подмодулей со следующими опциями:<br>`enable` (bool; по умолчанию `true`),<br>`name` (str; нет значения по умолчанию),<br>`primary` (bool; по умолчанию `true`, но только если элементов в опции хоста `displays` не более одного),<br>`touchscreen` (bool; по умолчанию `false`),<br>`refreshRate` (int; по умолчанию `60`),<br>`width` (int; по умолчанию `1920`),<br>`height` (int; по умолчанию `1080`),<br>`x` (int; по умолчанию `0`),<br>`y` (int; по умолчанию `0`) |
</blockquote>

`rices`
<blockquote>

| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | [`enableAll`](#base-settings-enableAll) | Создавать ли модуль райсов |
| `extraSubmodules` | `[]` | Дополнительные подмодули, используемые для создания собственных опций в типе райса. Пример значения: `[ ({ config, ... }:  { options.coolName = "cool " + config.name; }) ]` |

`rices.args`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | [`args.enable`](#base-settings-args-enable) | Создавать ли аргументы `rice` и `rices` с расширением [`args`](#args) |
| `path` | [`args.path`](#base-settings-args-path) | Путь к опциям расширения [`args`](#args) |

`rices.assertions`
| Название | Значение по умолчанию | Описание |
| - | - | - |
| `enable` | [`assertions.enable`](#base-settings-assertions-enable) | Добавлять ли `delib.riceNamesAssertions` в опцию `assertions` указанной модульной системы |
| `moduleSystem` | [`assertions.moduleSystem`](#base-settings-assertions-moduleSystem) | Модульная система в которую будут добавлены assertions. Можно указать любое значение, даже `"myconfig"`, если у вас есть специальный для этого модуль. Значения `"home-manager"` и `"nix-darwin"` автоматически преобразуются в `"home"` и `"darwin"` соответственно.
</blockquote>

## User {#user}
WIP
