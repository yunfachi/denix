# Showcase {#showcase}
This section presents a list of NixOS, Home Manager, and Nix-Darwin configurations that use Denix and can serve as examples of good practice*. You can add your configuration to this list via a [pull request](https://github.com/yunfachi/denix/pulls) or an [issue](https://github.com/yunfachi/denix/issues).

## Yunfachi - [nix-config](https://github.com/yunfachi/nix-config) (NixOS, Home Manager) {#yunfachi}
[![](https://github.com/user-attachments/assets/c7406818-e906-47b0-9a31-6a2d9916e4fa)](https://github.com/user-attachments/assets/c7406818-e906-47b0-9a31-6a2d9916e4fa)

**Features:**

- Extracting relevant options from modules into host options
- [Module](https://github.com/yunfachi/nix-config/blob/master/modules/config/args.nix) for specifying `_module.args`
- [Modules](https://github.com/yunfachi/nix-config/tree/master/modules/infras) for different infrastructures
- Shared and host-specific secrets using [SOPS](https://github.com/getsops/sops)
- Color scheme-based rices inheriting general configuration settings

## Conneroisu - [dotfiles](https://github.com/conneroisu/dotfiles) (NixOS, Home Manager, Nix-Darwin) {#conneroisu}
[![image](https://github.com/user-attachments/assets/a4f1091c-081e-4c76-b308-ca85080a1011)](https://github.com/user-attachments/assets/aba0e56d-4543-47d4-a5df-b5ed537a2568)

**Features:**

- NixOS and Nix-Darwin configurations
- Custom packages
- Determinate Nix support
