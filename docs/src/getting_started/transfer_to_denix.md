# Transfer to Denix {#transfer-to-denix}
If you already have a NixOS, Home Manager, or Nix-Darwin configuration, you can transfer most of the code without significant changes and then adapt it for Denix.

However, you will need to create the following from scratch:
- Hosts
- Rices (if you want)
- Some initial modules

The main part of the configuration can be fully reused from your old setup. The key is to separate the hardware configuration from the general configuration. See the section [How Does It Work?](#how-it-works).

## How Does It Work? {#how-it-works}
All Denix modules are standard NixOS, Home Manager, or Nix-Darwin modules but with additional logic for enabling and disabling configurations.

This means that you can add code or files from the old configuration into the new one, so they are imported through [`delib.configurations`](/configurations/introduction). You can place this code in the `modules` directory or create a new one, for example, `modules_nixos_old` for older configurations.

## Example of a Simple Configuration {#example-of-simple-configuration}
Suppose you have an old configuration consisting of two files: `configuration.nix` and `hardware-configuration.nix`, and you've already created hosts and the `modules/config` directory following the instructions. The configuration for your host should include `hardware-configuration.nix`, so all that remains is to copy `configuration.nix` into the `modules` directory and remove unnecessary options, like `system.stateVersion`.

## Example of a Complex Configuration {#example-of-complex-configuration}
Suppose you have an old configuration with hosts and multiple modules split across files. Hosts are typically specific to your system, so you will need to transfer them manually, usually by just copying the code.

Modules (e.g., for programs and services) can simply be copied into the `modules` directory or other files imported via [`delib.configurations`](/configurations/introduction).
