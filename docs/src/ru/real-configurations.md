# Реальные конфигурации {#real-configurations}
В этом разделе представлен список конфигураций NixOS, Home Manager и Nix-Darwin, которые используют Denix и могут служить примерами хорошей практики*. Вы можете добавить свою конфигурацию в этот список через [pull request](https://github.com/yunfachi/denix/pulls) или [issue](https://github.com/yunfachi/denix/issues).

## Yunfachi - [nix-config](https://github.com/yunfachi/nix-config) (NixOS, Home Manager) {#yunfachi}
[![](https://github.com/user-attachments/assets/c7406818-e906-47b0-9a31-6a2d9916e4fa)](https://github.com/user-attachments/assets/c7406818-e906-47b0-9a31-6a2d9916e4fa)

**Особенности:**

- Вынос подходящих опций из модулей в опции хоста
- [Модуль](https://github.com/yunfachi/nix-config/blob/master/modules/config/args.nix) для указания `_module.args`
- [Модули](https://github.com/yunfachi/nix-config/tree/master/modules/infras) для различных инфраструктур
- Общие и уникальные для каждого хоста секреты с использованием [SOPS](https://github.com/getsops/sops)
- Райсы под цветовые схемы, наследующие общие конфигурации
