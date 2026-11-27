# GitHub settings stack: the owner's local plan and apply

Only the owner plans and applies `foundation/github`, locally and attended (ADR-0010). CI runs the
static checks only (`mise run github:check`) and holds no credential.

1. Sign in: `gh auth login` and an AWS profile that can read and write the state bucket.
2. Write `backend.hcl` with the platform bucket (`jacops-pl-terraform-state`), the key
   `github/terraform.tfstate`, region `eu-central-1`, `encrypt = true`, `use_lockfile = true`.
   It is not committed.
3. `GITHUB_TOKEN="$(gh auth token)" terraform -chdir=foundation/github init -backend-config=backend.hcl`.
4. Pin the identity xpm renders with (`render` refuses until one is pinned):
   `xpm init foundation pin --cloud aws --identity <aws-profile> --region eu-central-1`.
5. `xpm init foundation render` writes `terraform.tfvars` (the live settings) and `imports.tf`
   (an `import` block for every resource the stack manages). Commit both.
6. Plan. Every resource must show as imported, none as created: a create means the live repo would
   be recreated, so stop and add its import. The first plan must also show no change; anything else
   means the live setting differs from the code: fix the code.
7. Apply only after a clean first plan.
