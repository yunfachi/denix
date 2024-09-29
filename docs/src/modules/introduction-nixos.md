# Introduction to NixOS Modules {#introduction-nixos}
A NixOS module is a file containing a Nix expression with a specific structure. It defines options (options) and values for those options (config). For example, the `/etc/nixos/configuration.nix` file is also a module.

Home Manager modules work similarly, but they can be used not only in NixOS but also on other systems.

This is not a comprehensive guide on Nix modules, so it is recommended to read the [NixOS Wiki article on modules](https://nixos.wiki/wiki/NixOS_modules).

## Structure {#structure}
The structure of a NixOS module:

```nix
{
  imports = [
    # Paths to other modules or Nix expressions.
  ];

  options = {
    # Declaration of options.
  };

  config = {
    # Assigning values to previously declared options.
    # For example, networking.hostName = "denix";
  };

  # However, values are usually assigned to options not in config, but here.
  # For example, networking.hostName = "denix";
}
```

### Function {#structure-function}
A module can also be a function (lambda) that returns an attribute set:

```nix
{lib, ...} @ args: {
  # Formally, this is config._module.args.hostname
  _module.args.hostname = lib.concatStrings ["de" "nix"];

  imports = [
    {hostname, config, ...}: {
      config = lib.mkIf config.customOption.enable {
        networking.hostName = hostname;
      };
    }
  ];
}
```

### Imports
`imports` is a list of relative and absolute paths, as well as [functions](#structure-function) and attribute sets:

```nix
{
  imports = [
    ./pureModule.nix
    /etc/nixos/impureModule.nix
    {pkgs, ...}: {
      # ...
    }
  ];
}
```

### Nixpkgs Options
Options are usually declared using `lib.mkOption`:

```nix
optionName = lib.mkOption {
  # ...
};
```

`lib.mkOption` accepts an attribute set. Some attributes include:

- `type`: the type of value for this option, e.g., `lib.types.listOf lib.types.port`.
- `default`: the default value for this option.
- `example`: an example value for this option, used in documentation.
- `description`: a description of this option, also used in documentation.
- `readOnly`: whether the option can be modified after declaration.

For more information on Nixpkgs options, see the [NixOS Wiki](https://nixos.wiki/wiki/Declaration).

### Denix Options
Denix uses a different approach to options, although both methods can be used simultaneously.

An example of a module with options using Denix:

```nix
{denix, ...}:
delib.module {
  name = "coolmodule";

  options.coolmodule = with delib; {
    # boolOption <default>
    enable = boolOption false;
    # noDefault (listOf) <default>
    ports = noDefault (listOfOption port null);
    # allowNull (strOption) <default>
    email = allowNull (strOption null);
  };
}
```

For more information on Denix options, see the [Options](/TODO) section.

## Creating Your Own Modules (Options)
Declaring your own options is a great practice if you want to enable or disable certain parts of the code. This can be useful if you have multiple hosts (machines) with the same configuration, and, for example, machine `foo` does not need a program that is used on machine `bar`.

An example of a NixOS module for simple git configuration:

```nix
{lib, config, ...}: {
  options.programs.git = {
    enable = lib.mkEnableOption "git";
  };

  config = lib.mkIf config.programs.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;

      config = {
        init.defaultBranch = "master";
      };
    };
  };
}
```

The same configuration but using Denix:

```nix
{delib, ...}:
delib.module {
  name = "programs.git";

  options = delib.singleEnableOption true;

  nixos.ifEnabled.programs.git = {
    enable = true;
    lfs.enable = true;

    config = {
      init.defaultBranch = "master";
    };
  };
}
```
