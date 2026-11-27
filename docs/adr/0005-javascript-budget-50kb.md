---
status: accepted
date: 2026-11-27
---

# Cap page JavaScript at 50 KB gzipped, at most 1 KB render-blocking

## Context and Problem Statement

autopilot decisions batch, Q6 (JavaScript size budget). NFR-001 leaves the JavaScript budget to architecture. What total does CI enforce for the page, all acts enabled?

Sources: .xpm/catalog/nfr/NFR-001.md#notes, .xpm/catalog/en/EN-004.md#notes, docs/source/brief-2026-11-27.md#design-gate.

## Considered Options

- 50 KB gzipped total, of which at most 1 KB render-blocking
- 80 KB gzipped total
- 30 KB gzipped total

## Decision Outcome

Chosen option: "50 KB gzipped total, of which at most 1 KB render-blocking", because vanilla TypeScript motion engine plus a Canvas 2D graph fits well under 50 KB with no framework runtime, leaving headroom for Lighthouse 95+ and LCP under 2.5 s; the design gate's prototype reading may tighten it.

The PO chose this option in the autopilot decisions batch, Q6.

### Consequences

- Good, because a vanilla TypeScript motion engine plus a Canvas 2D graph fits with headroom for Lighthouse 95+ and LCP under 2.5 s (NFR-001).
- Good, because CI enforces one number for the whole page with all acts enabled.
- Bad, because the design gate's prototype reading may tighten the budget; a change is a new ADR.
