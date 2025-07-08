# Development {#development}
This section describes how to properly import extensions. For examples of creating extensions, study the source code of existing extensions.

## Importing {#importing}
First, decide how many extensions and files you want to import.

If you have multiple extensions, or they are split across files:

```nix
delib.callExtensions {
  paths = [./foo ./default.nix]; # default: []
  exclude = [./foo/test.nix];    # default: []
  recursive = true;              # default: true
}
# Returns an attrset where the keys are extension names and the values are the extensions themselves.
```

If you have a single extension represented by one file:

```nix
delib.callExtension ./default.nix
# Returns a single extension.
```

## Distributing {#distribution}
To make your extensions available for use in other flakes, add the `denixExtensions` attrset to `outputs`:

```nix
outputs = {denix, ...}: {
  denixExtensions = denix.lib.callExtensions {
    paths = [./extensions];
  };
};
```

You can also create a separate flake that contains only extensions:
::: code-group
<<< @/../../templates/extensions-collection/flake.nix
:::

You can use a template for this:

```sh
nix flake init -t github:yunfachi/denix#extensions-collection
```

If you want to use `denixExtensions` in the same flake that contains your configuration, refer to `self`:

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
