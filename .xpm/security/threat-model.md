# Threat model

## Data stores

| Store | Component | Classification | Privacy NFR |
|---|---|---|---|
| Content file (content/en.yaml, published profile facts) | web | public | - |
| Act 1 played flag (visitor sessionStorage, no identifier) | web | public | - |
| Client-name denylist (Actions secret, gitignored local file) | web | confidential | - |
| Site bucket (built release) | infra | public | - |
| Terraform state bucket | infra | internal | - |

## web

Assets: the published profile's integrity, client anonymity, the visitor's privacy, the denylist.
Trust boundaries: author to public repo (every commit is public forever); build dependencies to the built page; built page to visitor browser.

| ID | STRIDE | Threat | Mitigation | Becomes | Residual |
|---|---|---|---|---|---|
| T-3 | I | A client name or identifying fact enters the content, a fixture, a commit message or a ticket and stays in public history | Denylist check in CI and pre-commit, fail closed without the secret, never printing a term; cards hold only cleared facts (ADR-0013, A-015) | NFR-015 | - |
| T-4 | I | A credential, private contact detail or image metadata is committed to the public repo | Secret scan over tree and history on every PR; metadata stripped from images; only published contact details | NFR-014 | - |
| T-5 | T | Injected or bundled script (unsafe content rendering, a compromised package) runs in the visitor's browser or calls another origin | CSP same-origin for every source, no inline script, content rendered escaped, test asserts no cross-origin request | NFR-017 | - |
| T-6 | I | The page tracks visitors through cookies, third-party requests or server logs | No cookies, no trackers, CloudFront logging off and policy-checked | NFR-016 | - |

## infra

Assets: the live site's content, the AWS account and its bill, the deploy role, Terraform state.
Trust boundaries: GitHub Actions to AWS (OIDC); internet to CloudFront; CloudFront to the bucket; DNS zone to the distribution.

| ID | STRIDE | Threat | Mitigation | Becomes | Residual |
|---|---|---|---|---|---|
| T-1 | TE | A compromised npm package or GitHub Action in the deploy job requests the OIDC token and overwrites the live site | Split jobs: build and test without id-token upload an artifact; the deploy job holds id-token and runs no install; actions pinned by SHA; lockfile installs with scripts off (PO, Q19) | NFR-033 | - |
| T-2 | D | A request or bandwidth flood pushes CloudFront cost past the 2 USD cap with no WAF | AWS Budgets alert at 80% and 100% of 2 USD in the MVP; every response edge-cached so origin requests stay near zero (PO, Q20) | NFR-034 | - |
| T-7 | SE | A token from a fork, a pull request or another repo assumes the deploy role, or the role can change more than the site | Trust policy limited to this repo's main branch; permissions limited to writing the site bucket and invalidating the distribution | NFR-013 | - |
| T-8 | IT | Visitors reach the bucket directly, are downgraded to HTTP or the page is framed by another site | Private bucket behind origin access control, HTTPS only with TLS 1.2+, HSTS, CSP and frame-ancestors set at CloudFront | NFR-012 | - |
| T-9 | S | After the cut-over a record still points at a retired distribution or bucket that another account can claim | Terraform owns the apex and www records; the runbook switches them before retiring old resources | NFR-035 | - |
| T-10 | I | Terraform state or account identifiers leak through the public repo | State only in the private, encrypted, versioned state bucket, never committed (ADR-0009) | NFR-020 | - |
| T-11 | R | A change to the live site cannot be traced to a reviewed commit | Only the main-branch deploy role writes the bucket, so every release is a GitHub Actions run of a merge commit; Terraform applies are attended (ADR-0010) | NFR-013 | - |
