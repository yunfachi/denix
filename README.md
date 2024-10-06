<p align="center">
  <a href="#">
    <picture>
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/banner_light.svg">
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/banner_dark.svg">
      <img src="https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/banner_light.svg" width="500px" alt="Denix">
    </picture>
  </a>
</p>

Denix is a Nix library designed to help you build scalable configurations for [NixOS](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager).

## Documentation

You can find the documentation here: [Denix Documentation](https://yunfachi.github.io/denix/getting_started/introduction)

## Key Features

### Modular System
Custom modules allow you to define options and related configurations in a flexible way, simplifying the management of your entire system.

### Hosts and Rices
* **Hosts**: Unique configurations tailored for each machine.
* **Rices**: Customizations that can be applied to all hosts.

### Unified NixOS and Home Manager Configurations
Write your NixOS and Home Manager configurations in a single file*, and Denix will automatically handle the separation for you.

## Templates

### [minimal](./templates/minimal/) (recommended)
Hosts, rices, and initial modules for quick setup:
```sh
nix flake init -t github:yunfachi/denix#minimal
```

### [minimal-no-rices](./templates/minimal-no-rices/)
Hosts and initial modules without rices:
```sh
nix flake init -t github:yunfachi/denix#minimal-no-rices
```
