---
surfaces:
  - name: web
    display_name: Web
    kind: local
    harness: playwright-spec
    app_dir: apps/web
    run: "npx playwright test <file> --reporter=line"
    port_env: PORT
    data: synthetic
    screenshot_required: false
    deployed_sha_required: false
    turn_budget: 60
  - name: local
    display_name: Local tooling
    kind: local
    harness: bash
    real: [filesystem, git, terraform, tflint, pre-commit]
    mocked: [github]
    data: synthetic
    screenshot_required: false
    deployed_sha_required: false
    turn_budget: 60
  - name: infra
    display_name: Infrastructure (static checks)
    kind: local
    harness: bash
    record: []
    real: [terraform, tflint, checkov, filesystem]
    mocked: [aws]
    data: synthetic
    screenshot_required: false
    deployed_sha_required: false
    turn_budget: 40
---

# Exercising profile

The surfaces acceptance criteria are exercised on. Frontmatter is the machine-read surface
table; each `## <surface>` section below is the operational prose the exerciser seat receives.

## web

For criteria about the built page: the headline, section flags, escaped content, reading with
JavaScript off, and no request leaving the origin. Specs live in `apps/web/e2e` and run against
the production build (`npm run build` then `astro preview`), never the dev server. The build
and content-file checks that need no browser are Vitest (`mise run web:test`). The first browser
run needs `mise run web:e2e-install`.

## local

For criteria about the repo's own tooling: the mise tasks, the Terraform root (`infra:fmt`,
`infra:validate`, `infra:lint`, no cloud credentials), the pre-commit hooks and the client-name
denylist script. Run the real task or script on the real filesystem; GitHub is the one mocked
dependency (never call the live API from a seat). Never pipe `mise run` inside the script: a
pipeline hides its exit code. Use only placeholder terms for the denylist, never a real name.

## infra

For criteria about the Terraform hosting stack under `infra/` and its Checkov policies.
Everything is static: no AWS credentials, no `terraform apply`, no network calls to AWS
(applies stay attended, ADR-0010). Use `terraform init -backend=false`, never a real backend.

Commands (same set CI's `infra` job runs, see `.github/workflows/ci.yml`):

- `terraform fmt -check -recursive infra`
- for each root in `infra/bootstrap` and `infra/environments/prod`:
  `terraform -chdir=<root> init -backend=false -input=false` then `terraform -chdir=<root> validate`
- `tflint --chdir=<dir> --config=<repo>/infra/.tflint.hcl` for each root and for
  `infra/modules/site-hosting` and `infra/modules/cost-guard`
- `bash infra/policies/test.sh` (negative fixtures must each be rejected by their policy)
- `bash infra/policies/check.sh --require-budget infra/environments/prod` and
  `bash infra/policies/check.sh infra/bootstrap` (the real roots must pass, including the
  budget-presence check)

Docs ACs (the runbook) are checked by reading `docs/runbooks/hosting-first-apply.md`.

Script skeleton: one bash file, `set -x`, one `echo "=== AC<N> ==="` block per AC, capture
everything, never grep-and-discard. Never pipe a command whose exit code is the verdict: write
`EXIT=$?` to the log. `raw_artifact` per AC is that block's slice of the `.out` file.
