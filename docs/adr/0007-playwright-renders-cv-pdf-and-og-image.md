---
status: accepted
date: 2026-11-27
---

# Render the CV PDF and OG image at build with Playwright Chromium

## Context and Problem Statement

autopilot decisions batch, Q8 (Build-time rendering of the CV PDF and OG image). The CV PDF (FR-026) and the 1200 x 627 OG image (FR-024, Q5) are both generated at build from the content file. With which tool?

Sources: .xpm/catalog/fr/FR-026.md#capability, .xpm/catalog/en/EN-009.md#acceptance, .xpm/catalog/en/EN-008.md#acceptance, .xpm/catalog/nfr/NFR-023.md#acceptance.

## Considered Options

- Playwright Chromium at build: prints a /cv print page to PDF and screenshots an /og page to PNG, both from the same templates and tokens
- Typst for the PDF and Satori plus resvg for the PNG

## Decision Outcome

Chosen option: "Playwright Chromium at build: prints a /cv print page to PDF and screenshots an /og page to PNG, both from the same templates and tokens", because one tool the browser tests already need, selectable PDF text (EN-009 AC4) and one set of styles, so neither output can drift from the page (NFR-023 AC3); nothing reaches the published site at runtime.

The PO chose this option in the autopilot decisions batch, Q8.

### Consequences

- Good, because one tool the browser tests already need; the PDF keeps selectable text (EN-009 AC4).
- Good, because the /cv and /og pages share templates and tokens with the site, so neither output drifts from it (NFR-023 AC3).
- Bad, because the build needs a Chromium download, which adds time to CI builds.
