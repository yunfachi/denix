# Introduction {#introduction}
In this section, you will learn about what Denix is, why it is needed, who can benefit from it, and popular practices for system configuration.

## What is Denix {#what-is-denix}
Denix is a Nix library designed for creating scalable configurations for [NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), and [Nix-Darwin](https://github.com/nix-darwin/nix-darwin).

It provides functions that transform input data into a module according to a specific algorithm. Thanks to this, if for any reason you need to create a module without using Denix, it will be sufficient to import the file with it, and everything will work.

The provided functions are generally divided into five categories:
- Creating configurations for Flake ([NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), or [Nix-Darwin](https://github.com/nix-darwin/nix-darwin))
- Options - an analogue of types and functions for creating options from [Nixpkgs](https://github.com/NixOS/nixpkgs)
- [Modules](#modules)
- [Hosts](#hosts)
- [Rices](#rices)

## Why and Who Needs Denix {#why-and-who-needs-denix}
Denix is primarily needed to simplify the creation, editing, and readability of configuration code. It eliminates the need to create typical expressions for your own modules, hosts, rices, etc.

If you plan to expand your configuration across multiple machines (hosts), want to have various system settings (rices) that can be changed with a single command, and strive to write readable and clean code, then you should consider trying Denix. Conversely, if you're creating a small configuration for a single machine and don't plan to expand it, Denix might be unnecessary.

Configuration templates using Denix can be found in the `templates` directory of the GitHub repository: [github:yunfachi/denix?path=templates](https://github.com/yunfachi/denix/tree/master/templates).

## Modules {#modules}
Custom modules are possibly the best practice for creating scalable configurations.

A module includes options, configuration, and importing other modules.
- `options = {};`: Similar to declaring variables in programming, but here it's a declaration of options.
- `config = {};`: Similar to initializing variables, but here it's about specifying values for options.
- `imports = [];`: A list of paths to modules or just module code (attrset or lambda that returns attrset).

NixOS, Home Manager, and Nix-Darwin have their own modules, which you have likely already worked with. You can search for options on these sites:
- NixOS: https://search.nixos.org/options
- Home Manager: https://home-manager-options.extranix.com/
- Nix-Darwin: https://nix-darwin.github.io/nix-darwin/manual/

Example of custom NixOS module code without using Denix:
```nix
{
  lib,
  config,
  ...
}: {
  options = {
    example = {
      enable = lib.mkEnableOption "example" // {default = true;};
      hostnames = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf (!config.example.enable) {
    networking.hosts."127.0.0.1" = config.example.hostnames;
  };
}
```
The same functionality but using Denix:
```nix
{delib, ...}:
delib.module {
  name = "example";

  options.example = with delib; {
    enable = boolOption true;
    hostnames = listOfOption str [];
  };

  nixos.ifEnabled = {cfg, ...}: {
    networking.hosts."127.0.0.1" = cfg.hostnames;
  };
}
```
You can learn more about Denix modules in [Modules](/modules/introduction).

## Hosts {#hosts}
Host is any machine, such as a personal computer, server, etc.

The essence of this practice is to separate the configuration into a shared part and a unique part for each host.

Example of a host configuration module using Denix:
```nix
{delib, ...}:
delib.host {
  name = "macbook";

  rice = "dark";
  type = "desktop";

  homeManagerSystem = "x86_64-darwin";
  home.home.stateVersion = "24.05";

  shared.myconfig = {
    services.openssh.authorizedKeys = ["ssh-ed25519 ..."];
  };
}
```
You can learn more about Denix hosts in [Hosts](/hosts/introduction).

## Rices {#rices}
Rice is a slang term used to describe system settings, especially related to appearance.

In our case, this is any configuration not tied to a specific host.

Example of a rice configuration module using Denix:
```nix
{delib, ...}:
delib.rice {
  name = "dark";

  home.stylix = {
    polarity = "dark";
    colors = {
      # ...
    };
  };
}
```
You can learn more about Denix rices in [Rices](/rices/introduction).
