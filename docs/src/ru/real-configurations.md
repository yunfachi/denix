# Реальные конфигурации {#real-configurations}
В этом разделе представлен список конфигураций NixOS и Home Manager, которые используют Denix и могут служить примерами хорошей практики*. Вы можете добавить свою конфигурацию в этот список через [pull request](https://github.com/yunfachi/denix/pulls) или [issue](https://github.com/yunfachi/denix/issues).

## Yunfachi - [nix-config](https://github.com/yunfachi/nix-config) {#yunfachi}
[![](https://github.com/user-attachments/assets/fc5ab8bf-613e-496a-aec9-8418b5d06173)](https://github.com/user-attachments/assets/fc5ab8bf-613e-496a-aec9-8418b5d06173)

**Особенности:**

- Вынос подходящих опций из модулей в опции хоста
- [Модуль](https://github.com/yunfachi/nix-config/blob/master/modules/config/args.nix) для указания `_module.args`
- [Модули](https://github.com/yunfachi/nix-config/tree/master/modules/infras) для различных инфраструктур
- Общие и уникальные для каждого хоста секреты с использованием [SOPS](https://github.com/getsops/sops)
- Райсы под цветовые схемы, наследующие общие конфигурации
