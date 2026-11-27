---
surfaces:
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
table; each `## <surface>` section is the operational prose the exerciser seat receives.

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
- `bash infra/policies/check.sh` (the real roots must pass, including the budget-presence check)

Docs ACs (the runbook) are checked by reading `docs/runbooks/hosting-first-apply.md`.

Script skeleton: one bash file, `set -x`, one `echo "=== AC<N> ==="` block per AC, capture
everything, never grep-and-discard. Never pipe a command whose exit code is the verdict: write
`EXIT=$?` to the log. `raw_artifact` per AC is that block's slice of the `.out` file.
