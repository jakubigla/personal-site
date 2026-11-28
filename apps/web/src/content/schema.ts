import { z } from "zod";

// Strict objects: an unknown key (a mistyped section flag, say) must fail the build, not vanish.
const text = z.string().trim().min(1);
const url = z.url({ protocol: /^https$/ });
// A link names a contact fact rather than repeating it, so each fact is edited in one place.
const link = z.strictObject({
  label: text,
  to: z.enum(["email", "linkedin", "github"]),
});

const contentFileSchema = z.strictObject({
  sections: z.strictObject({
    hero: z.boolean(),
    how_i_deliver: z.boolean(),
    footer: z.boolean(),
  }),
  contact: z.strictObject({
    email: z.email(),
    linkedin: url,
    github: url,
  }),
  hero: z.strictObject({
    name: text,
    role: text,
    headline: text,
    value_statement: text,
    primary_link: link,
    secondary_link: link,
  }),
  how_i_deliver: z.strictObject({
    title: text,
    body: text,
  }),
  footer: z.strictObject({
    entity: text,
    privacy_note: text,
    links: z.array(link).min(1),
  }),
});

// Layout code gets ready-to-render hrefs; resolving them here keeps the contact lookup in one spot.
export const contentSchema = contentFileSchema.transform((file) => {
  const resolve = ({ label, to }: z.infer<typeof link>) => ({
    label,
    href: to === "email" ? `mailto:${file.contact.email}` : file.contact[to],
  });
  return {
    ...file,
    hero: {
      ...file.hero,
      primary_link: resolve(file.hero.primary_link),
      secondary_link: resolve(file.hero.secondary_link),
    },
    footer: { ...file.footer, links: file.footer.links.map(resolve) },
  };
});

export type Content = z.output<typeof contentSchema>;
