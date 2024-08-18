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
  description: "Description English",
  
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
    ],
  }
}}

function themeConfigRussian() {return {
  label: "Русский",
  lang: "ru",
  link: "/ru/",
  title: "Denix Документация",
  description: "Русское описание",

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
    ],
  }
}}
