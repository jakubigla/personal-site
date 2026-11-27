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

## Known limitation: unattributed-change approvals

The live ruleset has `pull_request.require_extra_approval_for_unattributed_changes = true`. The
integrations/github 6.13 provider has no such argument, so this stack cannot hold it. The first
plan only imports the ruleset (0 to change), so nothing is lost then. After any later reviewed
change to the ruleset, read the field back
(`gh api repos/<owner>/<repo>/rulesets/<id> --jq '.rules[]|select(.type=="pull_request").parameters'`)
and set it again if it reads false. Wire it once the provider supports it.
