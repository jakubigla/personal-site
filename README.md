# Jakub Igla - personal site

The source of jacops.pl: a static Astro site built from one content file, plus the Terraform that
hosts it. The page, its link preview and its CV are all derived from `apps/web/content/en.yaml`.

- `apps/web` - the site (Astro, TypeScript). Edit text in `content/en.yaml`; a section shows only
  while its flag under `sections:` is `true`. The file is checked against a Zod schema on every
  build, so a mistyped flag or a missing field fails with a readable message.
- `infra` - Terraform for hosting. CI checks it without cloud credentials; applies are attended.
- `docs` - the architecture and the decision records.

## Run locally

Needs [mise](https://mise.jdx.dev) and nothing else: it installs Node, Terraform, tflint,
pre-commit and gitleaks at the pinned versions. No environment variable is needed; the site reads only the
committed content file, which holds published details only.

1. `mise trust && mise install` - installs the pinned tools.
2. `mise run web:install` - installs the web packages from the lockfile.
3. `mise run web:dev` - serves the site at http://localhost:4321 and reloads on edits.
4. Stop it with Ctrl-C in that terminal.

### Other tasks

- `mise run web:test` - unit tests and build checks (schema, section flags, escaping).
- `mise run web:e2e-install` once, then `mise run web:e2e` - browser specs against the production
  build, with JavaScript off. They serve it on port 4173 (set `PORT` to move it).
- `mise run web:lint`, `mise run web:build` - format and type checks; the static build in
  `apps/web/dist`.
- `mise run infra:fmt`, `infra:validate`, `infra:lint` - Terraform checks, no credentials needed.
- `mise run repo:lint` - every pre-commit hook over every file. `mise run repo:test` - the
  repo's own script tests. `mise run repo:secrets` - gitleaks over every commit in history
  (`.gitleaks.toml` holds its allowlist).

### Client-name denylist

CI fails closed unless the `DENYLIST` Actions secret (one term per line) is set; no term is ever
printed. To check locally, put the same terms in a gitignored `.denylist.local` and run
`mise run repo:denylist`. Run `pre-commit install --hook-type pre-commit --hook-type pre-push`
(or `xpm init hooks`) once so the hooks guard every commit and push.
