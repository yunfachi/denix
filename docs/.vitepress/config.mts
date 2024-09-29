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
  themeConfig: {
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
  description: "Nix library for creating scalable NixOS and Home Manager configurations with modules, hosts, and rices",
  
  themeConfig: {
    editLink: {
      pattern: "https://github.com/yunfachi/denix/edit/master/docs/src/:path",
      text: "Edit this page on Github"
    },

    nav: [
      { text: "Home", link: "/" },
      { text: "Introduction", link: "/introduction" }
    ],

    sidebar: [
      {
        text: "Introduction",
        items: [{ text: "Introduction", link: "/introduction" }],
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
        text: "Hosts",
        items: [
          { text: "Introduction", link: "/hosts/introduction" },
          { text: "Structure", link: "/hosts/structure" },
          { text: "Examples", link: "/hosts/examples" }
        ],
      },
      { text: "Real Configurations", link: "/real-configurations" },
    ],
  }
}}

function themeConfigRussian() {return {
  label: "Русский",
  lang: "ru",
  link: "/ru/",
  title: "Denix Документация",
  description: "Библиотека Nix для создания масштабируемых конфигураций NixOS и Home Manager с модулями, хостами и райсами",

  themeConfig: {
    editLink: {
      pattern: "https://github.com/yunfachi/denix/edit/master/docs/src/:path",
      text: "Редактировать эту страницу на GitHub"
    },

    nav: [
      { text: "Главная", link: "/ru/" },
      { text: "Вступление", link: "/ru/introduction" }
    ],

    sidebar: [
      {
        text: "Вступление",
        items: [{ text: "Вступление", link: "/ru/introduction" }],
      },
      {
        text: "Модули",
        items: [
          { text: "Вступление в модули NixOS", link: "/ru/modules/introduction-nixos" },
          { text: "Вступление", link: "/ru/modules/introduction" },
          { text: "Структура", link: "/ru/modules/structure" },
          { text: "Примеры", link: "/ru/modules/examples" }
        ],
      },
      {
        text: "Хосты",
        items: [
          { text: "Вступление", link: "/ru/hosts/introduction" },
          { text: "Структура", link: "/ru/hosts/structure" },
          { text: "Примеры", link: "/ru/hosts/examples" }
        ],
      },
      { text: "Реальные конфигурации", link: "/real-configurations" },
    ],
  }
}}
