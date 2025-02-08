# Common Errors {#troubleshooting}
This section lists some common errors and their possible solutions.

## Conditional Imports {#conditional-imports}
If for some reason you need to perform an import inside the [Denix module](/modules/introduction), then attempting to set `[nixos|home].[ifEnabled|ifDisabled].imports` will cause an `infinite recursion` error.

This means that if you need to import, for example, a third-party library, you should first add it to `[nixos|home].always.imports`, and then, if necessary, set option values in `[nixos|home].[always|ifEnabled|ifDisabled]`.

Discussion on "Conditional module imports": [discourse.nixos.org](https://discourse.nixos.org/t/conditional-module-imports/34863)

### Incorrect Code
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

### Correct Code
```nix
{delib, ...}:
delib.module {
  name = "correct";
  options = delib.singleEnableOption true;

  nixos.always.imports = [<someModule>];

  nixos.ifEnabled.someModuleOptions.enable = true;
}
```
