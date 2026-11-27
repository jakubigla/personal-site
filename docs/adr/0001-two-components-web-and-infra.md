---
status: accepted
date: 2026-11-27
---

# Two components: the Astro site in apps/web and Terraform hosting in infra

## Context and Problem Statement

autopilot decisions batch, Q1 (Components). The profile lists no components. Confirm these two, or answer other with the rows to drop or change: the static site and its build (web-frontend, Astro) and the AWS hosting plus deploy role in Terraform (terraform, aws). CI workflows stay repo-level under .github/.

Sources: .xpm/catalog/nfr/NFR-018.md#constraint, .xpm/catalog/nfr/NFR-020.md#constraint, .xpm/catalog/en/EN-001.md#outcome, .xpm/catalog/en/EN-002.md#outcome, docs/source/brief-2026-11-27.md#constraints.

## Considered Options

- web (web-frontend, apps/web, astro), infra (terraform, infra, aws)
- site (web-frontend, site, astro), infra (terraform, infra, aws)

## Decision Outcome

Chosen option: "web (web-frontend, apps/web, astro), infra (terraform, infra, aws)", because static files only (NFR-018) plus Terraform hosting (NFR-020) make two deployable units; plain aws stack because it is one site, one account, one environment (foundation.md section 1); starter tier until section 1 revisits it.

The PO chose this option in the autopilot decisions batch, Q1.

### Consequences

- Good, because two deployable units match what ships: static files (NFR-018) and the hosting stack (NFR-020).
- Good, because CI workflows stay repo-level under .github/, outside both components.
- Bad, because a third unit (an API, a worker) needs a new component and ADR; none is planned.
