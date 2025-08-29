# Introduction to Denix Options {#introduction}
Denix options are a wrapper for `lib.mkOption`. This means that any Denix option can be created using the standard `lib.mkOption`, and using Denix options is optional.

## Why use Denix options? {#why}
Using `lib.mkOption` can be cumbersome, and writing something like this every time:

```nix
lib.mkOption {type = lib.types.listOf lib.types.str; default = [];}
```

is inconvenient, especially when options are used extensively in your configuration. Instead, you can write something more concise:

```nix
delib.listOfOption delib.str []
```

Thus, instead of creating an option by specifying all parameters, you can use Denix functions for more readable and cleaner code.

## Working Principle {#principle}
Functions related to options are divided into four main types:

### Creating an Option with Type N
- `*Option <default>` - for example, `strOption "foo"`.
- `*OfOption <secondType> <default>` - for example, `listOfOption str ["foo" "bar"]`.
- `*ToOption <secondType> <default>` - for example, `lambdaToOption int (x: 123)`.

### Adding Type N to Option Type X
- `allow* <option>` - for example, `allowStr ...`.
- `allow*Of <secondType> <option>` - for example, `allowListOf str ...`.
- `allow*To <secondType> <option>` - for example, `allowLambdaTo int ...`.

### Directly Modifying the Attribute Set of an Option
- `noDefault <option>` - removes the `default` attribute from the option. It is rarely used since options without a default value are uncommon.
- `noNullDefault <option>` - removes the `default` attribute from the option if its value is `null`. Used for default value logic where its absence is allowed.
- `readOnly <option>` - adds the `readOnly` attribute with the value `true`.
- `apply <option> <apply>` - adds the `apply` attribute with the value passed to this function.
- `description <option> <description>` - adds the `description` attribute with the given value.

### Generating Specific Options
- `singleEnableOption <default> { name, ... }` - creates an attribute set using the expression `delib.setAttrByStrPath "${name}.enable" (boolOption default)`. This is commonly used in `delib.module :: options` with its [passed arguments](/modules/structure#passed-arguments), so you can simply write:

```nix
options = delib.singleEnableOption <default>;
```

- `singleCascadeEnableOption { parent, ... }` - creates an attribute set via `singleEnableOption` above, but uses `parent.enable` as the `<default>`. See the example:

```nix
# if current module's name is "programs.category.example",
# enable it by default if "programs.category" is enabled.
# will error if "programs.category.enable" is missing.
options = delib.singleCascadeEnableOption;
```

The list of current options can be found in the source code: [github:yunfachi/denix?path=lib/options.nix](https://github.com/yunfachi/denix/blob/master/lib/options.nix)

## Examples {#examples}

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

> *(Usually `{name = "git";}` is not required, as this function is mainly used in `delib.module :: options`)*
