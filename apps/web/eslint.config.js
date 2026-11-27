import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

// Astro files are covered by the build and the Vitest build checks; eslint reads the TypeScript.
export default tseslint.config(
  { ignores: ["dist", ".astro", "coverage", "playwright-report", "test-results"] },
  {
    extends: [eslint.configs.recommended, ...tseslint.configs.recommended],
    files: ["**/*.{ts,mjs,js}"],
  },
);
