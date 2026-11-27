# PS-9 acceptance criteria

Source: assumed by an autonomous seat; AC3 and AC5 rewritten by the PO answer to q-20261127190511-d85d (keep ADR-0010).

## Acceptance Criteria

- AC1: `xpm init foundation status` answers step `vars-set` and `deferred` false (EN-011 AC1)
- AC2: [post-merge] The first github plan imported the live settings and changed nothing on GitHub (EN-011 AC2)
- AC3: A pull request touching foundation/github gets a github-config workflow run that executes only `terraform fmt -check`, `terraform validate` and the static policy checks, with no cloud credentials and no OIDC role assumed (ADR-0010; PO decision, q-20261127190511-d85d)
- AC4: [post-merge] `xpm doctor` shows github-as-code ok or only named free-plan gaps (EN-011 AC4)
- AC5: Negative: no CI identity can plan or apply the github stack: the github-config workflow holds no cloud credential and no GitHub token beyond read access, and only the PO plans and applies the github stack locally (ADR-0010; PO decision, q-20261127190511-d85d). Checked statically: the workflow has no credential step, no id-token permission, and no plan or apply command.
