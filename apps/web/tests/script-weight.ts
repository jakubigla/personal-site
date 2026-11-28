import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { gzipSync } from "node:zlib";

const gzipped = (data: string | Buffer) => gzipSync(data).length;

// A JSON data block (JSON-LD, say) is never executed, so it counts toward neither budget.
const isData = (attrs: string) => /\btype=["']?application\/(ld\+)?json/i.test(attrs);

// Every script's gzipped size, and how much of it blocks rendering: a classic script with no
// async or defer, inline or loaded, stops the parser until it has run.
export function scriptWeight(outDir: string, html: string) {
  let total = 0;
  let blocking = 0;
  for (const [, attrs = "", body = ""] of html.matchAll(
    /<script\b([^>]*)>([\s\S]*?)<\/script>/gi,
  )) {
    if (isData(attrs)) continue;
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
