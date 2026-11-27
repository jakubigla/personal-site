# GitHub settings stack: the owner's local plan and apply

Only the owner plans and applies `foundation/github`, locally and attended (ADR-0010). CI runs the
static checks only (`mise run github:check`) and holds no credential.

1. Sign in: `gh auth login` and an AWS profile that can read and write the state bucket.
2. Write `backend.hcl` with the platform bucket (`jacops-pl-terraform-state`), the key
   `github/terraform.tfstate`, region `eu-central-1`, `encrypt = true`, `use_lockfile = true`.
   It is not committed.
3. `GITHUB_TOKEN="$(gh auth token)" terraform -chdir=foundation/github init -backend-config=backend.hcl`.
4. Import the live settings (`xpm init foundation render` writes `imports.tf`), then plan. The first
   plan must show no change; anything else means the live setting differs from the code: fix the code.
5. Apply only after a clean first plan.
