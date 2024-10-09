# Examples {#examples}

## Minimally Recommended Rice Module: {#minimally-recommended}
An example of a minimal rice module configuration that serves as a baseline for all further settings:

```nix
{delib, ...}:
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

## Short Version {#short-version}
Using `delib.riceNamesAssertions` is strongly recommended, but it can also be omitted.

```nix
{delib, ...}:
delib.module {
  name = "rices";

  options = with delib; let
    rice.options = riceSubmoduleOptions;
  in {
    rice = riceOption rice;
    rices = ricesOption rice;
  };
}
```
