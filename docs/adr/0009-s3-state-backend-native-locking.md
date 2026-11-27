---
status: accepted
date: 2026-11-27
---

# Keep Terraform state in S3 with native locking, created by a bootstrap stack

## Context and Problem Statement

autopilot decisions batch, Q10 (Terraform state backend and region). Where is Terraform state kept with locking (NFR-020 AC3), and which region holds the site bucket and state?

Sources: .xpm/catalog/nfr/NFR-020.md#acceptance, .xpm/catalog/nfr/NFR-019.md#constraint, .xpm/catalog/nfr/NFR-022.md#acceptance.

## Considered Options

- S3 backend with S3 native locking (use_lockfile) in a versioned, encrypted state bucket created by a small bootstrap stack; eu-central-1, ACM in us-east-1
- S3 backend with a DynamoDB lock table; eu-central-1, ACM in us-east-1
- HCP Terraform free tier as the backend

## Decision Outcome

Chosen option: "S3 backend with S3 native locking (use_lockfile) in a versioned, encrypted state bucket created by a small bootstrap stack; eu-central-1, ACM in us-east-1", because it costs cents (NFR-019), needs no extra service or token, stays in Jakub's account; CloudFront requires its certificate in us-east-1 and the origin region barely matters behind CloudFront.

The PO chose this option in the autopilot decisions batch, Q10.

### Consequences

- Good, because it costs cents (NFR-019), needs no extra service or token, and stays in Jakub's account (NFR-020 AC3).
- Good, because site bucket and state live in eu-central-1; the CloudFront certificate is issued in us-east-1, as CloudFront requires.
- Bad, because the bootstrap stack keeps its own small local state, applied once by hand.
