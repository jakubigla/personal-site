import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { gzipSync } from "node:zlib";

const root = new URL("..", import.meta.url).pathname;
const committed = readFileSync(join(root, "content/en.yaml"), "utf8");
const work = mkdtempSync(join(tmpdir(), "site-build-"));

// The page JavaScript budget (ADR-0005): 50 KB gzipped in total, at most 1 KB render-blocking.
const JS_BUDGET_BYTES = 50 * 1024;
const BLOCKING_JS_BUDGET_BYTES = 1024;

function gzipped(text: string | Buffer) {
  return gzipSync(text).length;
}

// Every script's gzipped size, and how much of it blocks rendering: a classic script with no
// async or defer, inline or loaded, stops the parser until it has run.
function scriptWeight(outDir: string, html: string) {
  let total = 0;
  let blocking = 0;
  for (const [, attrs = "", body = ""] of html.matchAll(
    /<script\b([^>]*)>([\s\S]*?)<\/script>/gi,
  )) {
    const src = /\bsrc=["']?([^"' >]+)/i.exec(attrs)?.[1];
    const size = src ? gzipped(readFileSync(join(outDir, src.replace(/^\//, "")))) : gzipped(body);
    total += src ? 0 : size;
    if (!/\b(async|defer)\b|type=["']?module/i.test(attrs)) blocking += size;
  }
  const files = readdirSync(outDir, { recursive: true }).map(String);
  for (const file of files.filter((f) => /\.m?js$/.test(f))) {
    total += gzipped(readFileSync(join(outDir, file)));
  }
  return { total, blocking };
}

function build(name: string, contentText: string) {
  const contentFile = join(work, `${name}.yaml`);
  const outDir = join(work, `${name}-dist`);
  writeFileSync(contentFile, contentText);
  const run = spawnSync("npx", ["astro", "build", "--outDir", outDir], {
    cwd: root,
    env: { ...process.env, CONTENT_FILE: contentFile },
    encoding: "utf8",
  });
  const html = existsSync(join(outDir, "index.html"))
    ? readFileSync(join(outDir, "index.html"), "utf8")
    : "";
  return { run, outDir, html, output: `${run.stdout}\n${run.stderr}` };
}

afterAll(() => rmSync(work, { recursive: true, force: true }));

describe("static build", () => {
  let base: ReturnType<typeof build>;
  beforeAll(() => {
    base = build("base", committed);
  });

  it("emits plain static files and nothing that needs a server", () => {
    expect(base.run.status).toBe(0);
    const files = readdirSync(base.outDir, { recursive: true }).map(String);
    expect(files).toContain("index.html");
    expect(files.some((f) => f.endsWith(".css")) || base.html.includes("<style")).toBe(true);
    expect(files.some((f) => /\.(mjs|cjs)$/.test(f) && f.includes("server"))).toBe(false);
  });

  it("renders the headline from the content file", () => {
    const changed = build(
      "headline",
      committed.replace(/^( {2}headline:).*$/m, '$1 "A brand new headline"'),
    );
    expect(changed.run.status).toBe(0);
    expect(changed.html).toContain("A brand new headline");
    expect(base.html).not.toContain("A brand new headline");
  });

  it("omits How I deliver while its flag is off and shows it when on", () => {
    expect(base.html).not.toContain('id="how-i-deliver"');
    const on = build(
      "deliver-on",
      committed.replace(/how_i_deliver: false/, "how_i_deliver: true"),
    );
    expect(on.html).toContain('id="how-i-deliver"');
  });

  it("removes the hero when its flag is off", () => {
    expect(base.html).toContain('id="hero"');
    const off = build("hero-off", committed.replace(/hero: true/, "hero: false"));
    expect(off.run.status).toBe(0);
    expect(off.html).not.toContain('id="hero"');
    expect(off.html).not.toContain("<h1");
  });

  it("removes the footer when its flag is off", () => {
    expect(base.html).toContain("<footer");
    const off = build("footer-off", committed.replace(/footer: true/, "footer: false"));
    expect(off.html).not.toContain("<footer");
  });

  it("takes the footer link labels from the content file", () => {
    const relabelled = build(
      "footer-labels",
      committed.replace(/^( {4}- label:) GitHub$/m, "$1 Code on GitHub"),
    );
    expect(relabelled.run.status).toBe(0);
    expect(relabelled.html).toMatch(/<footer[\s\S]*>Code on GitHub<\/a>/);
    expect(base.html).not.toContain("Code on GitHub");
  });

  it("updates every link to a contact fact from its one entry in the content file", () => {
    const moved = build(
      "contact-moved",
      committed.replace(/^( {2}email:).*$/m, "$1 someone@example.org"),
    );
    expect(moved.run.status).toBe(0);
    expect(moved.html.match(/href="mailto:someone@example\.org"/g)).toHaveLength(2);
    expect(moved.html).not.toMatch(/href="mailto:(?!someone@example\.org)/);
  });

  it("is readable without JavaScript: the text is in the HTML and no script ships", () => {
    expect(base.html).toContain("<h1");
    expect(base.html).not.toMatch(/<script/i);
  });

  it("keeps page JavaScript inside its size budget", () => {
    const weight = scriptWeight(base.outDir, base.html);
    expect(weight.total).toBeLessThanOrEqual(JS_BUDGET_BYTES);
    expect(weight.blocking).toBeLessThanOrEqual(BLOCKING_JS_BUDGET_BYTES);
  });

  it("fails the build readably on an invalid content file", () => {
    const bad = build("bad", committed.replace(/^ {2}headline:.*$/m, ""));
    expect(bad.run.status).not.toBe(0);
    expect(bad.output).toMatch(/hero\.headline/);
  });

  it("renders markup in content as escaped text, never as markup or script", () => {
    const hostile = build(
      "hostile",
      committed.replace(
        /^( {2}headline:).*$/m,
        `$1 "<script>alert(1)</script><img src=x onerror=alert(2)><b>bold</b>"`,
      ),
    );
    expect(hostile.run.status).toBe(0);
    expect(hostile.html).toContain("&lt;script&gt;alert(1)&lt;/script&gt;");
    expect(hostile.html).not.toContain("<script");
    expect(hostile.html).not.toContain("<img src=x");
    expect(hostile.html).not.toContain("<b>bold");
  });
});
