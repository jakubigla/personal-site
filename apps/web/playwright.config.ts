import { defineConfig } from "@playwright/test";

// Specs run against the production build, never the dev server. PORT and PW_WORKERS exist so
// shared machines and parallel runs each get a free port and a modest worker count.
const port = Number(process.env.PORT ?? 4173);

export default defineConfig({
  testDir: "e2e",
  workers: Number(process.env.PW_WORKERS ?? 2),
  reporter: "line",
  use: { baseURL: `http://localhost:${port}`, javaScriptEnabled: false },
  webServer: {
    command: `npm run build && npm run preview -- --port ${port} --strictPort --ignore-lock`,
    url: `http://localhost:${port}`,
    reuseExistingServer: false,
    timeout: 120_000,
  },
});
