# PS-9 acceptance criteria

Source: assumed by an autonomous seat and not yet confirmed.

## Acceptance Criteria

- AC1: `xpm init foundation status` answers step `vars-set` and `deferred` false (EN-011 AC1)
- AC2: [post-merge] The first github plan imported the live settings and changed nothing on GitHub (EN-011 AC2)
- AC3: [post-merge] A pull request touching foundation/github gets a plan from the github-config workflow; verified in real use: that run assumed the cloud role and its plan job passed, not only that the role exists (EN-011 AC3)
- AC4: [post-merge] `xpm doctor` shows github-as-code ok or only named free-plan gaps (EN-011 AC4)
- AC5: Negative: the CI plan identity for the github stack is read-only: an apply or any write attempted with it is refused, and only the owner applies locally. Checked statically: the identity's IAM policy in the Terraform grants no write action and the workflow runs plan only.
