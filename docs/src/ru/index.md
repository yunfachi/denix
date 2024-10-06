---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Denix Документация"
  text: "Библиотека Nix для конфигураций"
  tagline: Denix предоставляет инструменты для создания масштабируемых конфигураций NixOS и Home Manager с модулями, хостами и райсами
  image:
    light: https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/logo_light.svg
    dark: https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/logo_dark.svg
  actions:
    - theme: brand
      text: Введение
      link: /ru/getting_started/introduction
    - theme: alt
      text: GitHub с шаблонами
      link: https://github.com/yunfachi/denix

features:
  - title: Модули
    details: Собственные модули содержат опции и связанные с ними конфигурации, что позволяет удобно управлять всей системой
  - title: Хосты и райсы
    details: Хосты - это уникальные конфигурации для каждой машины, а райсы - это кастомизация, применимая ко всем хостам
  - title: NixOS и Home Manager
    details: Конфигурацию NixOS и Home Manager можно писать даже в одном файле, а Denix автоматически разделит их при сборке

---
