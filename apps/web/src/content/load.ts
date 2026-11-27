import { readFileSync } from "node:fs";
import { join } from "node:path";
import { parse } from "yaml";
import { contentSchema, type Content } from "./schema";

export class ContentError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ContentError";
  }
}

export function parseContent(source: string): Content {
  let data: unknown;
  try {
    data = parse(source);
  } catch (error) {
    throw new ContentError(`Content file is not valid YAML: ${(error as Error).message}`);
  }
  const result = contentSchema.safeParse(data);
  if (result.success) return result.data;
  const lines = result.error.issues.map((issue) => {
    const where = issue.path.length ? issue.path.join(".") : "(file)";
    const extra = issue.code === "unrecognized_keys" ? `: ${issue.keys.join(", ")}` : "";
    return `  - ${where}: ${issue.message}${extra}`;
  });
  throw new ContentError(`Content file is invalid:\n${lines.join("\n")}`);
}

// CONTENT_FILE lets tests build against a fixture without touching the committed file. The
// default is relative to the working directory because a built page runs from a bundled copy of
// this module, where a path relative to the module no longer points at apps/web.
export function loadContent(): Content {
  const path = process.env.CONTENT_FILE ?? join(process.cwd(), "content/en.yaml");
  return parseContent(readFileSync(path, "utf8"));
}
