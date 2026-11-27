---
status: accepted
date: 2026-11-27
---

# The `web` job of ci.yml is the main regression job

## Context and Problem Statement

Every push to main must run the full test suite so a regression is caught before or as it ships,
and xpm needs one named job to judge main by. The site's browser checks (no-JS, reduced motion,
360 px, no external requests, no cookies, axe) are a Playwright suite (ADR-0014), and a merge to
main both tests and deploys (FR-025). Which workflow and job carry that suite on main?

## Considered Options

- The `web` job of `.github/workflows/ci.yml`, which runs on every pull request and every push
  to main and gates the deploy job
- A separate nightly or post-deploy regression workflow

## Decision Outcome

Chosen option: "The `web` job of ci.yml", because it is the job that already builds the release
and runs the whole Playwright suite (`*.spec.ts`) against it, and the deploy job needs it, so a
red regression on main also stops the release (FR-025 AC3) with no second workflow to keep in step.

### Consequences

- Good, because one workflow and one job prove both pull requests and main, and its result gates
  the deploy.
- Good, because the suite runs against the exact artifact the deploy job publishes.
- Bad, because the job runs the browsers on every pull request, docs-only ones included
  (NFR-021), which costs CI minutes on a small repo.
