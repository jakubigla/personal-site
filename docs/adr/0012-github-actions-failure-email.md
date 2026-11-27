---
status: accepted
date: 2026-11-27
---

# Deploy failures alert through GitHub Actions' built-in failed-run email

## Context and Problem Statement

autopilot decisions batch, Q13 (Deploy-failure alert channel). NFR-032 AC2 wants an email to Jakub when a deploy on main fails, and leaves the channel to architecture. Which?

Sources: .xpm/catalog/nfr/NFR-032.md#notes, .xpm/catalog/nfr/NFR-013.md#acceptance.

## Considered Options

- GitHub Actions' built-in failed-run email to the merging account (Jakub), with no extra secret or AWS permission
- An SNS email topic the deploy job publishes to on failure (adds sns:Publish to the deploy role)

## Decision Outcome

Chosen option: "GitHub Actions' built-in failed-run email to the merging account (Jakub), with no extra secret or AWS permission", because merges to main are Jakub's after launch, so GitHub's own notification reaches him at zero cost and keeps the deploy role minimal (NFR-013 AC3).

The PO chose this option in the autopilot decisions batch, Q13.

### Consequences

- Good, because it reaches Jakub, who merges to main after launch, at zero cost (NFR-032 AC2).
- Good, because it adds no secret and no AWS permission to the deploy role (NFR-013 AC3).
- Bad, because the email goes to the account that triggered the run; a merge by anyone else notifies them instead.
