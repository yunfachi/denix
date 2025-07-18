# Structure {#structure}
Each extension is created using `delib.extension`.

## Function arguments {#function-arguments}
- `name`: string. Must be unique. Used to look up the extension in `delib.extensions` or `delib.callExtensions`.
- `description`: string. A short description. Defaults to `""`, but is required for official extensions.
- `maintainers`: a list of maintainers responsible for the extension. Defaults to `[]`.
- `config`: overlay. If a lambda with 1 parameter or an attrset is provided, it will be converted into a lambda with 2 parameters using `nixpkgs.lib.toExtension`, where the lambda with 1 parameter is treated as `prev`. Defaults to `final: prev: {}`.
- `initialConfig`: an object to which overlays are applied, or null. If an attrset is provided, it will be converted into a lambda with 1 parameter `final`. If you merge extensions, only one of them may have a non-null `initialConfig`. Defaults to `null`.
- `configOrder`: integer. Specifies the order in which the `config` of this extension is composed with the `config` of other extensions when merged. The smaller the number, the earlier it is applied. Defaults to `0`.
- `libExtension`: an overlay with the extension's configuration. If a lambda with 1 parameter is provided, it is `config`; if two - `config` and `prev`. Applied to `delib`. Defaults to `config: final: prev: {}`.
- `libExtensionOrder`: integer. Specifies the order in which the `libExtension` of this extension is composed with the `libExtension` of other extensions when merged. The smaller the number, the earlier it is applied. Defaults to `0`.
- `modules`: a list of modules with the extension's configuration. If a lambda with 1 parameter is provided, that parameter is `config`. The listed modules will be imported into configurations using this extension. It is strongly discouraged to use `delib` from the arguments of the file where the extension is defined when declaring modules. Instead, use `delib` inside the modules themselves: `modules = [({delib, ...}: delib.module {/* ... */})]`. Defaults to `[]`.

## Pseudocode {#pseudocode}
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
