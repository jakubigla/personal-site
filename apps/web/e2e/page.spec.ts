import { expect, test } from "@playwright/test";

// The config disables JavaScript for every spec: the page must be complete without it.
test("the page reads top to bottom with JavaScript off", async ({ page }) => {
  await page.goto("/");
  await expect(
    page.getByRole("heading", { level: 1, name: /Principal Data Platform Architect/ }),
  ).toBeVisible();
  await expect(page.getByRole("link", { name: "LinkedIn" })).toBeVisible();
  await expect(page.getByRole("link", { name: "GitHub" })).toBeVisible();
  await expect(page.getByText("This site sets no cookies")).toBeVisible();
  await expect(page.getByRole("heading", { name: "How I deliver" })).toHaveCount(0);
});

test("the page makes no request to another origin", async ({ page, baseURL }) => {
  const requested: string[] = [];
  page.on("request", (request) => requested.push(request.url()));
  await page.goto("/");
  expect(requested.filter((url) => !url.startsWith(`${baseURL}/`))).toEqual([]);
});
