# Summary - Jakub Igla personal site (jacops.pl)

Brief: docs/source/brief-2026-11-27.md

## Problem Statement

Today jacops.pl is three icons under a 2020-era "JacOps - Cloud Native and Cyber Security" title.
It says nothing about Jakub's current work: data platform architecture on Databricks, pre-sales,
and leading platform teams. People who look him up after a LinkedIn post, an RFP or a referral
find no page that shows his current profile or explains how to engage him.

The goal is one static page that works as a living CV and as a soft B2B offer through his
one-person company. The brand is the person, "Jakub Igla". JacOps appears only as the legal
entity in the footer. The page launches with a LinkedIn post, so the link preview and the first
screen matter most. Motion is the portfolio piece: a scroll-driven story about governance, scale
and delivery that proves fluent AI-assisted engineering, while every fact still reads as plain HTML.

## Primary Users / Roles

1. Consultancy partner - subcontracts architects and pre-sales. Wants proof of delivery at
   scale, RFP experience and team leadership.
2. End client (Head of Data, CTO, platform lead) - needs an architect, an audit or a target
   architecture. Wants similar problems solved and measurable outcomes.
3. Databricks ecosystem (field teams, partners) - looking for a Champion or a Resident
   Solutions Architect. Wants the credential, certifications and governance depth.
4. Owner (Jakub) - updates content a few times a year by editing one file and merging a PR.

Recruiters are not a target, but the page must read as a CV in 60 seconds.

## MVP Boundary

In:
- A one-page site: hero with the decided headline, proof strip, anonymized selected-work cards,
  the soft "How I can help" offer, experience timeline, certifications and speaking, contact
  links, and a footer with the legal entity, a privacy note and a "how this site was built" note.
- A signature scroll story (Acts 1-6). Act 1 and Act 2 are the minimum; the rest may ship as
  plain reveals. It must work fully with JavaScript off, with reduced motion and on low-power devices.
- All content in one structured content file with section flags, including a reserved,
  flagged-off "How I deliver" slot.
- A proper link preview (Open Graph, Person structured data).
- Static hosting on AWS defined in Terraform, plus CI/CD from GitHub Actions over OIDC. The first
  apply and the DNS cut-over are attended steps by Jakub.
- Should: a CV PDF built from the same content file, light and dark themes, a 404 page, and a
  www-to-apex redirect.

Out:
- A blog, a CMS, a contact form or any backend, a newsletter, rates, booking or payments.
- Client logos or names, multi-page case studies, or content for the delivery framework showcase.
- A Polish translation at launch, any login, cookie analytics, or rewriting the LinkedIn profile.

Hard guardrails:
- The repo is public from the first commit. No client name may ever enter the repo or its history.
- The traceability rule applies: no combination of facts may identify a client.
- No third-party runtime origins, no cookies, and a cost under 2 USD per month.
- Content readability must never depend on animation.

## Success Criteria

- A LinkedIn post produces a strong preview card. Within 60 seconds a partner or client
  understands the current profile, sees the proof, and knows how to make contact.
- The page scores Lighthouse 95+ in every category on a mid-range phone, has an LCP under
  2.5 s and meets WCAG 2.2 AA in both themes.
- The motion is good enough that people forward the link, and enterprise buyers do not read the
  page as a toy.

## Open Decisions

4 open decisions, none of them blocking:
- the exact Champion credential name and its badge file
- a real portrait to replace the placeholder
- whether the footer carries the NIP (company tax number)
- which acts survive the design gate

## Capability Tags

| Tag | Meaning |
|---|---|
| static-site-skeleton | Static site generator or build scaffold (framework picked at architecture) that outputs plain static files |
| content-model | The single structured content file, its schema and section flags; the single source of truth for all copy and the CV |
| design-direction-doc | Approved look and feel: navy canvas, gradients, glass cards, light and dark tokens, easing and duration tokens |
| motion-system | One scroll timeline engine (CSS scroll-driven with an IntersectionObserver/rAF fallback) with reduced-motion, no-JS and low-power fallbacks |
| constellation-graph | Canvas 2D or SVG node graph behind the page that drives the governance story acts |
| seo-link-preview | Meta tags, Open Graph image and Person JSON-LD for the LinkedIn card |
| aws-static-hosting | Terraform for a private S3 bucket, CloudFront with OAC, ACM, Route 53, security headers and the www redirect |
| ci-cd-oidc | GitHub Actions that build, test and deploy on merge to main, run on every PR, and reach AWS through OIDC with no long-lived keys |
| quality-budget-checks | Automated Lighthouse, accessibility and JS-size budget checks in CI |
| cv-pdf-build | Generates the CV PDF from the content file (print stylesheet or build step) |
| arch-direction | The architecture direction doc (docs/architecture.md) and its ADRs that every code ticket reads |
| design-system | The design system every screen builds on: palette, type, spacing, radius, motion tokens and core components, delivered as CSS custom properties |
| github-as-code | The repository's GitHub settings (ruleset, merge options, security features) imported into Terraform |
