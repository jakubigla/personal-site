---
status: accepted
date: 2026-11-27
---

# Deploys never delete content-hashed assets; only stale non-hashed files go

## Context and Problem Statement

autopilot decisions batch, Q12 (Pruning old hashed assets on deploy). FR-025 AC8 keeps the previous release's hashed assets, while NFR-030 allows a sync with delete. What does a deploy delete?

Sources: .xpm/catalog/fr/FR-025.md#acceptance, .xpm/catalog/nfr/NFR-030.md#notes, .xpm/catalog/nfr/NFR-019.md#constraint.

## Considered Options

- Never delete content-hashed assets; delete only stale non-hashed files after the new HTML is live
- Delete hashed assets not referenced by the current or the previous release, using a manifest kept in the bucket

## Decision Outcome

Chosen option: "Never delete content-hashed assets; delete only stale non-hashed files after the new HTML is live", because a few releases a year add only kilobytes, so storage stays far under NFR-019's cap while every old HTML still loads its assets (FR-025 AC8) with no manifest logic.

The PO chose this option in the autopilot decisions batch, Q12.

### Consequences

- Good, because every older cached HTML still loads its assets (FR-025 AC8), with no manifest logic.
- Good, because a few releases a year add only kilobytes, far under NFR-019's cost cap.
- Bad, because the bucket grows slowly over the years; a manual prune stays possible if it ever matters.
