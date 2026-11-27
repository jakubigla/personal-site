---
status: accepted
date: 2026-11-27
---

# Keep content in one YAML file per language, validated by a Zod schema at build

## Context and Problem Statement

autopilot decisions batch, Q3 (Content file format). Which format is the single content file, one file per language (content/en.*)?

Sources: docs/source/brief-2026-11-27.md#needs, .xpm/catalog/fr/FR-022.md#notes, .xpm/catalog/nfr/NFR-023.md#notes, .xpm/catalog/nfr/NFR-024.md#acceptance.

## Considered Options

- YAML validated by a Zod schema at build
- JSON validated by a JSON Schema at build
- A typed TypeScript module

## Decision Outcome

Chosen option: "YAML validated by a Zod schema at build", because Jakub edits it a few times a year in a PR: YAML allows comments and multi-line prose, a per-language file keeps the Polish path open (NFR-024 AC2) and the schema gives readable build errors (NFR-023 AC2).

The PO chose this option in the autopilot decisions batch, Q3.

### Consequences

- Good, because YAML allows comments and multi-line prose for the few edits a year.
- Good, because a per-language file (content/en.yaml) keeps the Polish path open (NFR-024 AC2); schema errors are readable (NFR-023 AC2).
- Bad, because YAML's implicit typing (e.g. unquoted yes/no, dates) needs the schema to coerce or reject values explicitly.
