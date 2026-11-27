---
status: accepted
date: 2026-11-27
---

# Every Terraform apply stays attended; CI holds only the site-deploy role

## Context and Problem Statement

autopilot decisions batch, Q11 (How infrastructure changes reach AWS after the first apply). After Jakub's first apply, do later Terraform changes stay attended, or does CI plan and apply them? RAID A-016 says CI plans, but NFR-013 AC2 restricts the only role to main.

Sources: .xpm/catalog/nfr/NFR-013.md#acceptance, .xpm/catalog/nfr/NFR-022.md#acceptance, .xpm/catalog/nfr/NFR-020.md#acceptance, .xpm/raid.md#assumptions.

## Considered Options

- Every apply stays attended; CI runs fmt, validate and the static policy checks with no AWS credentials, and the only CI role is the narrow site-deploy role
- CI plans on pull requests with a read-only OIDC role and applies on merge with a broader infra role

## Decision Outcome

Chosen option: "Every apply stays attended; CI runs fmt, validate and the static policy checks with no AWS credentials, and the only CI role is the narrow site-deploy role", because infra changes are rare for one static site, and a CI role able to change IAM and CloudFront would break NFR-013 AC3's least privilege; static checks already cover NFR-012, NFR-019 and NFR-031.

The PO chose this option in the autopilot decisions batch, Q11.

### Consequences

- Good, because CI runs fmt, validate and static policy checks with no AWS credentials, covering NFR-012, NFR-019 and NFR-031.
- Good, because no CI role can change IAM or CloudFront, keeping NFR-013 AC3's least privilege; RAID A-016's 'CI plans' becomes static checks only.
- Bad, because infra changes wait for Jakub to apply them; rare for one static site.
