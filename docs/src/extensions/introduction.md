# Introduction to Denix Extensions {#introduction}
Some features that contradict the philosophy of Denix or are purely optional can still be implemented as separate extensions. Also, if a configuration needs to provide a custom function or modify the behavior of an existing one - this can be done through a custom extension.

Currently, the extension API allows you to:
- Extend `delib` by adding new functions or overriding existing ones.
- Add modules that are automatically included in the configuration.

## Usage {#usage}
To add extensions, you need to pass the `extensions` argument to the `delib.configurations` function. This argument is a list of extensions.

Official extensions are located in `delib.extensions` (see [All extensions](/extensions/all-extensions)). In addition to them, you can also add custom extensions in the following ways:
* If the extension is a single file:

```nix
delib.callExtension ./myExtension.nix
```

* If the extension consists of multiple files:

```nix
delib.mergeExtensions "myExtensionName" [
  (delib.callExtension ./myExtensionPart1.nix)
  (delib.callExtension ./myExtensionPart2.nix)
]
```

* If there are many extensions:

```nix
(delib.callExtensions { paths = [./myExtensions]; }).myExtension
```

Some extensions support their own configuration (not to be confused with module options). Configuration is done via `withConfig`:

```nix
delib.extensions.someExtension.withConfig {
  someOption = "value";
}
```
The parameter can be either an overlay or an attrset (it will automatically be converted to an overlay). For details, see [NixOS Wiki - Overlays](https://nixos.wiki/wiki/Overlays).

### Example
```nix
delib.configurations {
  # ...
  extensions =
    with delib.extensions;
    with delib.callExtensions { paths = [./myExtensions]; };
    [
      args
      (base.withConfig (final: prev: {
        args.enable = true;
        hosts.type.types = prev.hosts.type.types ++ ["laptop"];
      }))
      (delib.callExtension ./myExtension.nix)
      extensionFromMyExtensions
      (anotherExtensionFromMyExtensions.withConfig { someConfig = "someValue"; })
    ];
}
```
