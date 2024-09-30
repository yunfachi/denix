# Introduction to Denix Rices {#introduction}
A rice is an attribute set returned by the function [`delib.rice`](/rices/structure), which enables or disables specific configurations depending on the value of the option `${myconfigName}.rice`. It also passes the input attribute set of the `delib.rice` function to the `${myconfigName}.rice.${delib.rice :: name}` option.

The term "rice" in slang refers to system settings, usually related to appearance. In the Denix context, a rice represents a configuration that can be applied **to any** host and will function correctly.

However, rices are not mandatory: to avoid using them, simply do not add the options `${myconfigName}.rices` and `${myconfigName}.rice`, and do not use the `delib.rice` function.

## Inheritance {#inheritance}
A rice can inherit all configurations of another rice via the `inherits` attribute. Additionally, you can set `inheritanceOnly = true;`, which will hide the rice from being generated in [`delib.system`](/TODO), leaving it only for inheritance.

Example of three rices, where the first two inherit all configurations from the "rounded" rice:

```nix
delib.rice {
  name = "black";
  inherits = ["rounded"];
  myconfig.colorscheme = "black";
}
```

```nix
delib.rice {
  name = "light";
  inherits = ["rounded"];
  myconfig.colorscheme = "light";
}
```

```nix
delib.rice {
  name = "rounded";
  inheritanceOnly = true;
  myconfig.hyprland.rounding = "6";
}
```

## Options {#options}
For rices to work, your configuration must include the options `${myconfigName}.rice` and `${myconfigName}.rices`, which **you define yourself** in one of the modules.

Example of a minimal recommended configuration for rices:

```nix
delib.module {
  name = "rices";

  options = with delib; let
    rice = {
      options = riceSubmoduleOptions;
    };
  in {
    rice = riceOption rice;
    rices = ricesOption rice;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.riceNamesAssertions myconfig.rices;
  };
}
```

More examples can be found in the [Examples](/rices/examples) section.
