# Introduction to Denix Hosts {#introduction}
A Denix host is an attribute set returned by the function [`delib.host`](/hosts/structure), which enables or disables specific configurations depending on the value of the option `${myconfigName}.host`. It also passes the input attribute set of the `delib.host` function to the `${myconfigName}.host.${delib.host :: name}` option.

In simple terms, this allows you to separate the NixOS, Home Manager, Nix-Darwin, and custom options configuration into those that apply only to the current host and those that apply to all hosts. For example, the former can be used to enable or disable certain programs, while the latter can be used to add the current host's SSH key to the `authorizedKeys` of all hosts.

A host can also be compared to a module, because all hosts are imported regardless of which one is active, but the applied configurations depend on the active host.

It is also worth mentioning that, by default, the Home Manager module is automatically included in the NixOS and Nix-Darwin configurations of each host. If you do not want to use the Home Manager module for a particular host, simply add `useHomeManagerModule = false;` to the arguments of the `delib.host` function.

## Options {#options}
For hosts to work, the configuration must include the options `${myconfigName}.host` and `${myconfigName}.hosts`, which **you define yourself** in one of the modules.

Here is an example of a minimal recommended host configuration:

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

More examples can be found in the [Examples](/hosts/examples) section.
