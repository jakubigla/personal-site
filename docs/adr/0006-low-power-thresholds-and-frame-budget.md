---
status: accepted
date: 2026-11-27
---

# Drop to low-power motion at 4 cores or 2 GB, or a 25 ms median frame for 1 s

## Context and Problem Statement

autopilot decisions batch, Q7 (Low-power thresholds and frame budget). NFR-006 leaves the low-power thresholds and frame budget open. Which starting values does the motion system use?

Sources: .xpm/catalog/nfr/NFR-006.md#notes, .xpm/raid.md#assumptions, docs/source/brief-2026-11-27.md#motion-budget-and-fallbacks.

## Considered Options

- hardwareConcurrency 4 or fewer, or deviceMemory 2 GB or less; drop when the median frame time stays over 25 ms for 1 s
- hardwareConcurrency 2 or fewer, or deviceMemory 1 GB or less; drop when the median frame time stays over 33 ms for 1 s

## Decision Outcome

Chosen option: "hardwareConcurrency 4 or fewer, or deviceMemory 2 GB or less; drop when the median frame time stays over 25 ms for 1 s", because mid-range phones report 8 cores and 4 GB or more so they keep full motion, while budget devices drop early; the values are named constants (NFR-006 AC3) the design gate prototype can retune.

The PO chose this option in the autopilot decisions batch, Q7.

### Consequences

- Good, because mid-range phones (8 cores, 4 GB or more) keep full motion; budget devices drop early (NFR-006).
- Good, because the values are named constants (NFR-006 AC3) the design gate prototype can retune.
- Bad, because deviceMemory is not exposed by every browser; where absent, only the core count and the frame-time check apply.
