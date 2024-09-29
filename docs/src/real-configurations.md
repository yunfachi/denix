# Real Configurations {#real-configurations}
This section presents a list of NixOS and Home Manager configurations that use Denix and can serve as examples of good practice*. You can add your configuration to this list via a [pull request](https://github.com/yunfachi/denix/pulls) or an [issue](https://github.com/yunfachi/denix/issues).

## Yunfachi - [nix-config](https://github.com/yunfachi/nix-config) {#yunfachi}
[![](https://github.com/user-attachments/assets/fc5ab8bf-613e-496a-aec9-8418b5d06173)](https://github.com/user-attachments/assets/fc5ab8bf-613e-496a-aec9-8418b5d06173)

**Features:**

- Extracting relevant options from modules into host options
- [Module](https://github.com/yunfachi/nix-config/blob/master/modules/config/args.nix) for specifying `_module.args`
- [Modules](https://github.com/yunfachi/nix-config/tree/master/modules/infras) for different infrastructures
- Shared and host-specific secrets using [SOPS](https://github.com/getsops/sops)
- Color scheme-based rices inheriting general configuration settings
