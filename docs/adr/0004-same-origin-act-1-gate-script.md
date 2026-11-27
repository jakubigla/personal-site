---
status: accepted
date: 2026-11-27
---

# Gate Act 1 with a tiny same-origin head script; CSP stays script-src 'self'

## Context and Problem Statement

autopilot decisions batch, Q5 (Act 1 gate script and CSP). Deciding before first paint whether Act 1 shows (JS on, motion allowed, first visit this session) needs a script in the head, while the CSP at CloudFront allows same-origin scripts only. How is the gate delivered?

Sources: .xpm/catalog/nfr/NFR-012.md#acceptance, .xpm/catalog/nfr/NFR-017.md#acceptance, .xpm/catalog/nfr/NFR-026.md#acceptance, .xpm/catalog/fr/FR-002.md#acceptance, .xpm/raid.md#assumptions.

## Considered Options

- A tiny same-origin gate script in the head (under 1 KB, cached immutable); CloudFront CSP stays script-src 'self' with no inline hashes
- An inline gate script whose hash the build writes into a meta CSP; the CloudFront header keeps frame-ancestors and base-uri only
- No head gate: the overlay is added by the deferred module, accepting a flash of the hero before Act 1

## Decision Outcome

Chosen option: "A tiny same-origin gate script in the head (under 1 KB, cached immutable); CloudFront CSP stays script-src 'self' with no inline hashes", because keeps NFR-012 AC4 and NFR-017 AC3 exactly and avoids syncing build hashes into Terraform, whose applies stay attended (NFR-022); the cost is one small request on first load.

The PO chose this option in the autopilot decisions batch, Q5.

### Consequences

- Good, because NFR-012 AC4 and NFR-017 AC3 hold exactly, with no inline-script hashes.
- Good, because no build hash has to be synced into Terraform, whose applies stay attended (NFR-022).
- Bad, because one extra small request on first load; the script stays under 1 KB and is cached immutable.
