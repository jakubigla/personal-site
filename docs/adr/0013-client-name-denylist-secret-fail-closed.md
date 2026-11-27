---
status: accepted
date: 2026-11-27
---

# Keep the client-name denylist in a GitHub Actions secret; the check fails closed

## Context and Problem Statement

autopilot decisions batch, Q14 (Client-name denylist source). NFR-015 AC5 needs a CI check against a client-name denylist kept outside the public repo. Where does it live, and what happens while it is missing?

Sources: .xpm/catalog/nfr/NFR-015.md#acceptance, .xpm/catalog/en/EN-003.md#notes, docs/source/brief-2026-11-27.md#positioning-source-content.

## Considered Options

- A GitHub Actions secret (one term per line) set by Jakub before the build starts, plus an optional gitignored local file for the pre-commit hook; the check fails closed when the secret is absent and never prints a term
- The same secret, but the check only warns while the secret is absent

## Decision Outcome

Chosen option: "A GitHub Actions secret (one term per line) set by Jakub before the build starts, plus an optional gitignored local file for the pre-commit hook; the check fails closed when the secret is absent and never prints a term", because the repo is public from the first commit and a leaked name can never be removed from history, so the check must not pass silently during an unattended, auto-merged run.

The PO chose this option in the autopilot decisions batch, Q14.

### Consequences

- Good, because the repo is public from the first commit, and a leaked name could never be removed from history (NFR-015 AC5).
- Good, because an optional gitignored local file feeds the same check in the pre-commit hook; no term is ever printed.
- Bad, because Jakub must set the secret before the build starts, or every CI run fails.
