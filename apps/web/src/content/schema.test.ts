import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { ContentError, parseContent } from "./load";

const valid = readFileSync(new URL("../../content/en.yaml", import.meta.url), "utf8");

describe("content file", () => {
  it("accepts the committed content file", () => {
    const content = parseContent(valid);
    expect(content.hero.headline.length).toBeGreaterThan(0);
  });

  it("keeps the How I deliver flag present and off", () => {
    expect(parseContent(valid).sections.how_i_deliver).toBe(false);
  });

  it("rejects a missing required field and names it", () => {
    const broken = valid.replace(/^ {2}headline:.*$/m, "");
    expect(() => parseContent(broken)).toThrow(ContentError);
    expect(() => parseContent(broken)).toThrow(/hero\.headline/);
  });

  it("rejects an unknown section flag and names it", () => {
    const broken = valid.replace(/^sections:\n/m, "sections:\n  surprise: true\n");
    expect(() => parseContent(broken)).toThrow(/surprise/);
  });

  it("rejects a link to a contact fact that does not exist and names it", () => {
    const broken = valid.replace(/^( {4}to:) linkedin$/m, "$1 mastodon");
    expect(() => parseContent(broken)).toThrow(/hero\.secondary_link\.to/);
  });

  it("rejects text that is not YAML with a readable error", () => {
    expect(() => parseContent("sections: [unclosed")).toThrow(ContentError);
  });
});
