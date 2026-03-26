import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://omarchy-zellij-theme.reposito.rio.br",
  integrations: [
    starlight({
      title: "omarchy-zellij-theme",
      customCss: ["./src/styles/global.css"],
      components: {
        Footer: "./src/components/Footer.astro",
        PageFrame: "./src/components/PageFrame.astro",
      },
    }),
  ],
  vite: { plugins: [tailwindcss()] },
});
