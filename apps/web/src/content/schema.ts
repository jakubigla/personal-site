import { z } from "zod";

// Strict objects: an unknown key (a mistyped section flag, say) must fail the build, not vanish.
const text = z.string().trim().min(1);
const url = z.url({ protocol: /^https$/ });

export const contentSchema = z.strictObject({
  sections: z.strictObject({
    hero: z.boolean(),
    how_i_deliver: z.boolean(),
    footer: z.boolean(),
  }),
  hero: z.strictObject({
    name: text,
    role: text,
    headline: text,
    value_statement: text,
  }),
  how_i_deliver: z.strictObject({
    title: text,
    body: text,
  }),
  footer: z.strictObject({
    entity: text,
    privacy_note: text,
    contact: z.strictObject({
      email: z.email(),
      linkedin: url,
      github: url,
    }),
  }),
});

export type Content = z.infer<typeof contentSchema>;
