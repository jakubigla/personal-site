# PS-9 acceptance criteria

Source: assumed by an autonomous seat and not yet confirmed.

## Acceptance Criteria

- AC1: [post-merge] after the owner pins and renders the foundation, `xpm init foundation status` answers step `rendered` or later; `deferred` stays true by design under ADR-0010 (no CI plan role, no repo variable) (EN-011 AC1, reworded to fit ADR-0010)
- AC2: [needs-secret: GITHUB_TOKEN] The first local github plan (run by the PO) imported the live settings and changed nothing on GitHub (EN-011 AC2)
- AC3: A pull request touching foundation/github gets a github-config workflow run that executes only terraform fmt, validate and the static policy checks, with no cloud credentials and no OIDC role assumed (PO decision: keep ADR-0010)
- AC4: `xpm doctor` shows github-as-code ok or only named free-plan gaps (EN-011 AC4)
- AC5: Negative: no CI identity can plan or apply the github stack: the workflow file references no cloud credential, secret or OIDC role, and the docs state only the PO plans and applies the github stack locally (PO decision: keep ADR-0010)
