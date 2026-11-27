---
status: accepted
date: 2026-11-27
---

# Build the site with Astro, TypeScript and plain CSS custom properties

## Context and Problem Statement

autopilot decisions batch, Q2 (Static site framework). Which framework builds the static page from the content file?

Sources: docs/source/brief-2026-11-27.md#constraints, .xpm/catalog/nfr/NFR-001.md#constraint, .xpm/catalog/nfr/NFR-002.md#acceptance, .xpm/catalog/nfr/NFR-004.md#constraint, .xpm/catalog/nfr/NFR-023.md#acceptance, .xpm/catalog/en/EN-001.md#notes.

## Considered Options

- Astro with TypeScript and plain CSS custom properties (static output, zero JS unless opted in)
- Eleventy templates plus a Vite-built vanilla TypeScript bundle
- React and Vite with build-time prerendering (the web-frontend blueprint's default stack)

## Decision Outcome

Chosen option: "Astro with TypeScript and plain CSS custom properties (static output, zero JS unless opted in)", because Astro emits plain HTML with no framework runtime, so hero text is in the first response (NFR-002, NFR-004) and the JS budget goes to motion only (NFR-001); its content collections validate the file with a schema (NFR-023 AC2).

The PO chose this option in the autopilot decisions batch, Q2.

### Consequences

- Good, because hero text ships as plain HTML in the first response with no framework runtime (NFR-002, NFR-004).
- Good, because the JavaScript budget goes to motion only (NFR-001); content collections validate the content file (NFR-023 AC2).
- Bad, because the web-frontend blueprint's default React stack is not used, so its scaffold is adapted to Astro.
