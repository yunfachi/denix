---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Denix Documentation"
  text: "Nix Library for Configurations"
  tagline: "Denix provides extensible tools for creating scalable NixOS, Home Manager, and Nix-Darwin configurations with modules, hosts, and rices"
  image:
    light: https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/logo_light.svg
    dark: https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/logo_dark.svg
  actions:
    - theme: brand
      text: Introduction
      link: /getting_started/introduction
    - theme: alt
      text: GitHub with Templates
      link: https://github.com/yunfachi/denix

features:
  - title: Modules
    details: Custom modules contain options and related configurations, making it easy to manage the entire system
  - title: Hosts and Rices
    details: Hosts are unique configurations for each machine, while rices are customizations applicable to all hosts
  - title: NixOS, Home Manager, and Nix-Darwin
    details: NixOS, Home Manager, and Nix-Darwin configurations can be written in the same file, and Denix will automatically separate them
  - title: Extensions
    details: Use built-in extensions for Denix that provide predefined modules and functions, or create your own

---
