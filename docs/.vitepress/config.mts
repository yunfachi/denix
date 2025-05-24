import { defineConfig } from "vitepress"

// https://vitepress.dev/reference/site-config
export default defineConfig({
  cleanUrls: true,
  lastUpdated: true,
  srcDir: './src',
  base: '/denix/', // github pages
  ignoreDeadLinks: [
    '/TODO'
  ],
  sitemap: {
    hostname: 'https://yunfachi.github.io/denix/'
  },
  head: [
    ["link", { rel: "icon", href: "https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/logo_dark.svg" }],
  ],
  themeConfig: {
    logo: {
      light: "https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/logo_light.svg",
      dark: "https://raw.githubusercontent.com/yunfachi/denix/master/.github/assets/logo_dark.svg",
    },
    // https://vitepress.dev/reference/default-theme-config
    socialLinks: [
      { icon: "github", link: "https://github.com/yunfachi/denix" }
    ],
    search: {
      provider: "local",
    }
  },
  locales: {
    root: themeConfigEnglish(),
    ru: themeConfigRussian()
  }
})

function themeConfigEnglish() {return {
  label: "English",
  lang: "en",
  link: "/",
  title: "Denix Documentation",
  description: "Nix library for creating scalable NixOS, Home Manager, and Nix-Darwin configurations with modules, hosts, and rices",

  themeConfig: {
    editLink: {
      pattern: "https://github.com/yunfachi/denix/edit/master/docs/src/:path",
      text: "Edit this page on Github"
    },

    nav: [
      { text: "Home", link: "/" },
      { text: "Introduction", link: "/getting_started/introduction" }
    ],

    sidebar: [
      {
        text: "Getting Started",
        items: [
          { text: "Introduction", link: "/getting_started/introduction" },
          { text: "Initialization", link: "/getting_started/initialization" },
          { text: "First Modules", link: "/getting_started/first_modules" },
          { text: "Transfer to Denix", link: "/getting_started/transfer_to_denix" },
        ],
      },
      {
        text: "Modules",
        items: [
          { text: "Introduction to NixOS Modules", link: "/modules/introduction-nixos" },
          { text: "Introduction", link: "/modules/introduction" },
          { text: "Structure", link: "/modules/structure" },
          { text: "Examples", link: "/modules/examples" }
        ],
      },
      {
        text: "Options",
        items: [
          { text: "Introduction", link: "/options/introduction" },
        ],
      },
      {
        text: "Hosts",
        items: [
          { text: "Introduction", link: "/hosts/introduction" },
          { text: "Structure", link: "/hosts/structure" },
          { text: "Examples", link: "/hosts/examples" }
        ],
      },
      {
        text: "Configurations (flakes)",
        items: [
          { text: "Introduction", link: "/configurations/introduction" },
          { text: "Structure", link: "/configurations/structure" }
        ],
      },
      {
        text: "Rices",
        items: [
          { text: "Introduction", link: "/rices/introduction" },
          { text: "Structure", link: "/rices/structure" },
          { text: "Examples", link: "/rices/examples" }
        ],
      },
      { text: "Common Errors", link: "/troubleshooting" },
      { text: "Real Configurations", link: "/real-configurations" },
    ],
  }
}}

function themeConfigRussian() {return {
  label: "Русский",
  lang: "ru",
  link: "/ru/",
  title: "Denix Документация",
  description: "Библиотека Nix для создания масштабируемых конфигураций NixOS, Home Manager и Nix-Darwin с модулями, хостами и райсами",

  themeConfig: {
    editLink: {
      pattern: "https://github.com/yunfachi/denix/edit/master/docs/src/:path",
      text: "Редактировать эту страницу на GitHub"
    },

    nav: [
      { text: "Главная", link: "/ru/" },
      { text: "Вступление", link: "/ru/getting_started/introduction" }
    ],

    sidebar: [
      {
        text: "Начнем",
        items: [
          { text: "Вступление", link: "/ru/getting_started/introduction" },
          { text: "Инициализация", link: "/ru/getting_started/initialization" },
          { text: "Первые модули", link: "/ru/getting_started/first_modules" },
          { text: "Перенос на Denix", link: "/ru/getting_started/transfer_to_denix" },
        ],
      },
      {
        text: "Модули",
        items: [
          { text: "Вступление в модули NixOS", link: "/ru/modules/introduction-nixos" },
          { text: "Вступление", link: "/ru/modules/introduction" },
          { text: "Структура", link: "/ru/modules/structure" },
          { text: "Примеры", link: "/ru/modules/examples" },
        ],
      },
      {
        text: "Опции",
        items: [
          { text: "Вступление", link: "/ru/options/introduction" },
        ],
      },
      {
        text: "Хосты",
        items: [
          { text: "Вступление", link: "/ru/hosts/introduction" },
          { text: "Структура", link: "/ru/hosts/structure" },
          { text: "Примеры", link: "/ru/hosts/examples" },
        ],
      },
      {
        text: "Конфигурации (флейки)",
        items: [
          { text: "Вступление", link: "/ru/configurations/introduction" },
          { text: "Структура", link: "/ru/configurations/structure" },
        ],
      },
      {
        text: "Райсы",
        items: [
          { text: "Вступление", link: "/ru/rices/introduction" },
          { text: "Структура", link: "/ru/rices/structure" },
          { text: "Примеры", link: "/ru/rices/examples" },
        ],
      },
      { text: "Распространённые ошибки", link: "/ru/troubleshooting" },
      { text: "Реальные конфигурации", link: "/ru/real-configurations" },
    ],
  }
}}
