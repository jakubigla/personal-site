---
status: accepted
date: 2026-11-27
---

# Write the hosting stack fresh in infra/ instead of reusing the 2021 module

## Context and Problem Statement

autopilot decisions batch, Q9 (Hosting Terraform: reuse the 2021 module or write new). Reuse the old terraform-website-s3-cloudfront-route53 module, or write the hosting stack fresh in infra/?

Sources: .xpm/catalog/nfr/NFR-020.md#notes, .xpm/catalog/en/EN-002.md#notes, .xpm/catalog/nfr/NFR-012.md#acceptance, docs/source/brief-2026-11-27.md#constraints.

## Considered Options

- Write fresh resources in infra/ with the current AWS provider; the old site and its resources are retired after the attended cut-over
- Reuse and upgrade the 2021 module
- Import the current live bucket and distribution into new code

## Decision Outcome

Chosen option: "Write fresh resources in infra/ with the current AWS provider; the old site and its resources are retired after the attended cut-over", because a 2021 module predates CloudFront origin access control (2022) that NFR-012 AC1 requires, and response headers policies and CloudFront Functions are simpler written directly than retrofitted.

The PO chose this option in the autopilot decisions batch, Q9.

### Consequences

- Good, because current provider features such as CloudFront origin access control (NFR-012 AC1), response headers policies and CloudFront Functions are written directly.
- Good, because the old site and its resources are retired after the attended cut-over.
- Bad, because the cut-over must move DNS from the old distribution to the new one in one attended step (RAID A-016).
