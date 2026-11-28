import { defineConfig } from "vitest/config";

// Playwright specs live in e2e/ and must never be collected here.
export default defineConfig({
  test: {
    include: ["src/**/*.test.ts", "tests/**/*.test.ts"],
    testTimeout: 120_000,
  },
});
