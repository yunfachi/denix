# All Extensions {#all}
This section describes all official Denix extensions.

## Args {#args}
<table class="extension-table">
  <tr>
    <th>Name</th>
    <td><code>args</code></td>
  </tr>
  <tr>
    <th>Description</th>
    <td>More convenient way to configure <code>_module.args</code> via <code>myconfig</code></td>
  </tr>
  <tr>
    <th>Maintainers</th>
    <td>yunfachi (<a href='https://github.com/yunfachi'>GitHub</a>, <a href='https://t.me/yunfachi'>Telegram</a>)</td>
  </tr>
</table>

### Settings {#args-settings}
| Name | Default Value | Description |
| - | - | - |
| `path` | `"args"` | Path in `myconfig` where options will be created |

## Base {#base}
<table class="extension-table">
  <tr>
    <th>Name</th>
    <td><code>base</code></td>
  </tr>
  <tr>
    <th>Description</th>
    <td>Creates feature-rich and fine-tunable modules for hosts and rices with minimal effort</td>
  </tr>
  <tr>
    <th>Maintainers</th>
    <td>yunfachi (<a href='https://github.com/yunfachi'>GitHub</a>, <a href='https://t.me/yunfachi'>Telegram</a>)</td>
  </tr>
</table>

### Settings {#base-settings}
| Name | Default Value | Description |
| - | - | - |
| `enableAll` {#base-settings-enableAll} | `true` | Default value for `hosts.enable` and `rices.enable` |

`args`
<blockquote>

| Name | Default Value | Description |
| - | - | - |
| `enable` {#base-settings-args-enable} | `false` | Default value for `hosts.args.enable` and `rices.args.enable` |
| `path` {#base-settings-args-path} | `"args"` | Default value for `hosts.args.path` and `rices.args.path` |
</blockquote>

`assertions`
<blockquote>

| Name | Default Value | Description |
| - | - | - |
| `enable` {#base-settings-assertions-enable} | `true` | Default value for `hosts.assertions.enable` and `rices.assertions.enable` |
| `moduleSystem` {#base-settings-assertions-moduleSystem} | `"home-manager"` | Default value for `hosts.assertions.moduleSystem` and `rices.assertions.moduleSystem` |
</blockquote>

`hosts`
<blockquote>

| Name | Default Value | Description |
| - | - | - |
| `enable` | [`enableAll`](#base-settings-enableAll) | Whether to create the hosts module |

`hosts.args`
| Name | Default Value | Description |
| - | - | - |
| `enable` | [`args.enable`](#base-settings-args-enable) | Whether to create `host` and `hosts` arguments with the [`args`](#args) extension |
| `path` | [`args.path`](#base-settings-args-path) | Path to options of the [`args`](#args) extension |

`hosts.assertions`
| Name | Default Value | Description |
| - | - | - |
| `enable` | [`assertions.enable`](#base-settings-assertions-enable) | Whether to add `delib.hostNamesAssertions` to the `assertions` option of the specified module system |
| `moduleSystem` | [`assertions.moduleSystem`](#base-settings-assertions-moduleSystem) | Module system to which assertions will be added. Any value is allowed, even `"myconfig"` if you have a dedicated module for that. Values `"home-manager"` and `"nix-darwin"` will be automatically converted to `"home"` and `"darwin"` respectively |

`hosts.type`
| Name | Default Value | Description |
| - | - | - |
| `enable` | `true` | Whether to create an enum option `type` in the host submodule |
| `generateIsType` | `true` | Whether to generate a boolean option for each value in `hosts.type.types`, formatted as `"is{Type}"` |
| `types` | `["desktop" "server"]` | All allowed values for the `type` option in the host submodule. Note: to append to the list rather than overwrite it, use: `types = prev.types ++ ["newType"];` |

`hosts.features`
| Name | Default Value | Description |
| - | - | - |
| `enable` | `true` | Whether to create the `features` option with an enum-list type in the host submodule |
| `generateIsFeatured` | `true` | Whether to generate a boolean option for each value in `hosts.features.features`, formatted as `"{feature}Featured"` |
| `features` | `[]` | All allowed values for the `features` option in the host submodule |
| `default` | `[]` | Default value for the `features` option in the host submodule |
| `defaultByHostType` | `{}` | Attrset where keys are one of the `hosts.type.types` values and values are lists similar to `hosts.features.default`. Merged with `hosts.features.default` and the list whose key matches the value of the `type` option in the host submodule |

`hosts.displays`
| Name | Default Value | Description |
| - | - | - |
| `enable` | `true` | Whether to create the `displays` option in the host submodule. Its type is a list of submodules with the following options:<br>`enable` (bool; default `true`),<br>`name` (str; no default),<br>`primary` (bool; default `true`, but only if the `displays` options in the host submodule contains one item),<br>`touchscreen` (bool; default `false`),<br>`refreshRate` (int; default `60`),<br>`width` (int; default `1920`),<br>`height` (int; default `1080`),<br>`x` (int; default `0`),<br>`y` (int; default `0`) |
</blockquote>

`rices`
<blockquote>

| Name | Default Value | Description |
| - | - | - |
| `enable` | [`enableAll`](#base-settings-enableAll) | Whether to create the rices module |

`rices.args`
| Name | Default Value | Description |
| - | - | - |
| `enable` | [`args.enable`](#base-settings-args-enable) | Whether to create `rice` and `rices` arguments using the [`args`](#args) extension |
| `path` | [`args.path`](#base-settings-args-path) | Path to options of the [`args`](#args) extension |

`rices.assertions`
| Name | Default Value | Description |
| - | - | - |
| `enable` | [`assertions.enable`](#base-settings-assertions-enable) | Whether to add `delib.riceNamesAssertions` to the `assertions` option of the specified module system |
| `moduleSystem` | [`assertions.moduleSystem`](#base-settings-assertions-moduleSystem) | Module system to which assertions will be added. Any value is allowed, even `"myconfig"` if you have a dedicated module for that. `"home-manager"` and `"nix-darwin"` will be automatically converted to `"home"` and `"darwin"` respectively |
</blockquote>

## User {#user}
WIP
