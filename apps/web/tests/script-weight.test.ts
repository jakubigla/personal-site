import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, describe, expect, it } from "vitest";
import { scriptWeight } from "./script-weight";

const dir = mkdtempSync(join(tmpdir(), "script-weight-"));
afterAll(() => rmSync(dir, { recursive: true, force: true }));

// A seeded generator gives text that does not compress, so a body's gzipped size stays near its length.
const noise = (n: number) => {
  let x = 12345;
  return Array.from({ length: n }, () => {
    x = (x * 1103515245 + 12345) % 2147483648;
    return String.fromCharCode(33 + ((x >> 8) % 90));
  }).join("");
};

describe("scriptWeight", () => {
  it("weighs nothing for a page with no script", () => {
    expect(scriptWeight(dir, "<html><body>hi</body></html>")).toEqual({ total: 0, blocking: 0 });
  });

  it("counts an inline classic script as blocking", () => {
    const { total, blocking } = scriptWeight(dir, `<script>${noise(600)}</script>`);
    expect(blocking).toBeGreaterThan(300);
    expect(total).toBe(blocking);
  });

  it("does not count a deferred or module script as blocking", () => {
    const html = `<script type="module">${noise(600)}</script><script defer>${noise(600)}</script>`;
    const { total, blocking } = scriptWeight(dir, html);
    expect(blocking).toBe(0);
    expect(total).toBeGreaterThan(600);
  });

  it("does not weigh a JSON data block as JavaScript", () => {
    const html = `<script type="application/ld+json">${noise(900)}</script><script>${noise(600)}</script><script type="application/json">${noise(900)}</script>`;
    const alone = scriptWeight(dir, `<script>${noise(600)}</script>`);
    expect(scriptWeight(dir, html)).toEqual(alone);
  });

  it("weighs a loaded blocking script by its file", () => {
    const out = mkdtempSync(join(dir, "loaded-"));
    writeFileSync(join(out, "gate.js"), noise(700));
    const { blocking } = scriptWeight(out, '<script src="/gate.js"></script>');
    expect(blocking).toBeGreaterThan(400);
  });
});
