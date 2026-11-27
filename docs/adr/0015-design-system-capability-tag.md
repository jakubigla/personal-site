---
status: accepted
date: 2026-11-27
---

# EN-005 provides the design-system tag alongside design-direction-doc

## Context and Problem Statement

autopilot decisions batch, Q16 (Design-system capability tag). The catalog has design-direction-doc but no design-system tag, which UI tickets expect. How is it named?

Sources: .xpm/catalog/en/EN-005.md#outcome, .xpm/summary.md#capability-tags.

## Considered Options

- EN-005 provides design-system alongside design-direction-doc; FR tags stay as they are
- Rename design-direction-doc to design-system on EN-005 and every FR

## Decision Outcome

Chosen option: "EN-005 provides design-system alongside design-direction-doc; FR tags stay as they are", because EN-005 already owns palette, type, spacing and motion tokens; adding the tag closes the lens 9 gap without touching 20 FRs.

The PO chose this option in the autopilot decisions batch, Q16.

### Consequences

- Good, because UI tickets find the design-system capability they expect, closing the lens 9 gap.
- Good, because no FR's tags change.
- Bad, because two tags name the same enabler; both point to EN-005.
