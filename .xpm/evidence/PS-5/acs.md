# PS-5 acceptance criteria

Source: taken from the ticket as written.

## Acceptance Criteria

- AC1: A pull request, including one that changes only documentation, triggers the CI workflow and it reports a status check. ([EN-003](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-003.md) AC1)
- AC2: CI passes on main for the walking skeleton build and tests. ([EN-003](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-003.md) AC2)
- AC3: The deploy job authenticates to AWS by assuming an OIDC role; the repository and workflows contain no AWS access keys or other long-lived secrets. ([EN-003](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-003.md) AC3)
- AC4: The OIDC role trust policy is restricted to this repository and the main branch, and its permissions are limited to the site bucket and the distribution invalidation. ([EN-003](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-003.md) AC4)
- AC5: On merge to main the workflow syncs the build output and creates a CloudFront invalidation (verifiable once the attended first apply has run). ([EN-003](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-003.md) AC5)
- AC6: Build and test jobs hold no id-token permission and upload the release artifact; the deploy job alone holds id-token: write, downloads the artifact and runs no package install; every third-party action is pinned by full commit SHA and installs run from the lockfile with lifecycle scripts off, all checked in CI ([NFR-033](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-033.md)). ([EN-003](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-003.md) AC6)
- AC7: The deploy job is skipped cleanly while the deploy role variable is unset, and uploads hashed assets before HTML, sets long immutable caching on hashed assets and at most 300 s on HTML, never deletes hashed assets, and waits for the invalidation ([FR-025](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/fr/FR-025.md) AC6 to AC8, [ADR-0011](https://github.com/jakubigla/personal-site/blob/main/docs/adr/0011-never-delete-hashed-assets.md), [NFR-022](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-022.md) AC2). ([EN-003](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-003.md) AC7)
- AC8: Negative: the deploy role's trust policy rejects a token from a pull request, a fork, another branch or another repository, and a CI check fails a workflow change that grants id-token: write to any job other than deploy.
