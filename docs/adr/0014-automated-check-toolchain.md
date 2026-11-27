---
status: accepted
date: 2026-11-27
---

# Run checks with Vitest, Playwright with axe, Lighthouse CI, tflint and Checkov

## Context and Problem Statement

autopilot decisions batch, Q15 (Automated check toolchain). Which tools carry the automated checks: unit and schema tests, browser checks (no-JS, reduced motion, 360 px, no external requests, no cookies), accessibility, Lighthouse, and Terraform policy checks?

Sources: .xpm/catalog/en/EN-004.md#acceptance, .xpm/catalog/nfr/NFR-020.md#acceptance, .xpm/catalog/nfr/NFR-019.md#acceptance, .xpm/catalog/nfr/NFR-031.md#acceptance, .xpm/catalog/nfr/NFR-005.md#acceptance.

## Considered Options

- Vitest; Playwright with @axe-core/playwright; Lighthouse CI; tflint plus Checkov with custom policies for NFR-019 AC3 and NFR-031 AC3
- Vitest; Playwright with @axe-core/playwright; Lighthouse CI; tflint plus Trivy and Conftest (OPA) policies

## Decision Outcome

Chosen option: "Vitest; Playwright with @axe-core/playwright; Lighthouse CI; tflint plus Checkov with custom policies for NFR-019 AC3 and NFR-031 AC3", because Playwright covers every browser-level NFR check and also renders the PDF and OG image; Checkov gives the static security scan and the resource-ban policies in one offline tool.

The PO chose this option in the autopilot decisions batch, Q15.

### Consequences

- Good, because Playwright covers every browser-level NFR check (no-JS, reduced motion, 360 px, no external requests, no cookies) and also renders the PDF and OG image.
- Good, because Checkov gives the static security scan and custom policies for NFR-019 AC3 and NFR-031 AC3 in one offline tool.
- Bad, because Checkov custom policies are written in its own YAML/Python format.
