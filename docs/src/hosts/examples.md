# Examples {#examples}

## Minimally Recommended Host Module: {#minimally-recommended}
An example of a minimal host module configuration that serves as a baseline for all further settings:

```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {
      options = hostSubmoduleOptions;
    };
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.hostNamesAssertions myconfig.hosts;
  };
}
```

## With the `type` Option {#type-option}
The `type` option **is very** useful for default values in your modules. For example, the option `enable = boolOption host.isDesktop` can be used for some GUI programs. This simplifies configuration management based on the type of device.

```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {config, ...}: {
      options =
        hostSubmoduleOptions
        // {
          type = noDefault (enumOption ["desktop" "server"] null);

          isDesktop = boolOption (config.type == "desktop");
          isServer = boolOption (config.type == "server");
        };
    };
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.hostNamesAssertions myconfig.hosts;
  };
}
```

## With the `displays` Option {#displays-option}
This option can be useful for configuring monitors; however, it can be implemented as a separate module.

```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host = {config, ...}: {
      options =
        hostSubmoduleOptions
        // {
          displays = listOfOption (submodule {
            options = {
              enable = boolOption true;
              touchscreen = boolOption false;

              # e.g. DP-1, HDMI-A-1
              name = noDefault (strOption null);
              primary = boolOption (builtins.length config.displays == 1);
              refreshRate = intOption 60;

              width = intOption 1920;
              height = intOption 1080;
              x = intOption 0;
              y = intOption 0;
            };
          }) [];
        };
    };
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };

  home.always = {myconfig, ...}: {
    assertions = delib.hostNamesAssertions myconfig.hosts;
  };
}
```

## Short Version {#short-version}
Using `delib.hostNamesAssertions` is strongly recommended, but it can also be omitted.

```nix
{delib, ...}:
delib.module {
  name = "hosts";

  options = with delib; let
    host.options = hostSubmoduleOptions;
  in {
    host = hostOption host;
    hosts = hostsOption host;
  };
}
```
