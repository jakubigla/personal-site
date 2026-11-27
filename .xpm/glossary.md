# Glossary

The language of Jakub Igla's one-page personal site: the content that tells his profile, the
scroll story that stages it, and how a change reaches the live page.

## Content

**Content file**:
The one structured file per language that holds every fact, label and link the page, the link
preview and the CV PDF show; the single source of truth.
_Avoid_: data file, config, CMS

**Section**:
One block of the page (hero, proof strip, selected work, offer, timeline, certifications and
speaking, contact, footer), rendered only while its section flag is on.
_Avoid_: block, module, panel

**Section flag**:
The on or off switch in the content file that decides whether a section renders at all; an off
section leaves no markup, slot or link behind.
_Avoid_: toggle, feature flag

**Work card**:
One anonymized entry of selected work: a label, the problem, what was built, outcome figures and
tech pills, and nothing that could identify the client.
_Avoid_: case study, project, client card

**Proof figure**:
One number or short fact in the proof strip (years, credentials, scale figures).
_Avoid_: stat, KPI, metric

**Offer item**:
One of the four "How I can help" entries: who it is for and what they get.
_Avoid_: service, package, product

**Traceability rule**:
The rule that no fact or combination of facts on the page or in the repo may identify a client.
_Avoid_: anonymity policy, NDA rule

**Denylist**:
The private list of client names and identifying terms the CI check refuses; it lives outside the
public repository.
_Avoid_: blocklist, banned words

## Scroll story

**Act**:
One chapter of the scroll story (Act 1 to Act 6), tied to one section and drawn to a defined
final state.
_Avoid_: scene, animation, step

**Final state**:
What an act looks like once it has fully played; the state shown with JavaScript off, with
reduced motion and on a deep link.
_Avoid_: end frame, resting state

**Reduced variant**:
The whole page in final states with opacity-only or no motion, entered on reduced motion,
on a low-power device or when frames run over budget.
_Avoid_: lite mode, fallback mode

**Constellation**:
The decorative node graph behind the page that drifts, then orders into governed layers as the
story advances; every name on it is invented.
_Avoid_: particles, network, background graph

**Chapter link**:
A URL hash naming a section (for example #work) that opens the page at that act's final state.
_Avoid_: anchor, deep link, permalink

**Act 1 gate**:
The tiny same-origin head script that decides, before first paint, whether Act 1 plays.
_Avoid_: intro script, splash

## Delivery

**Release**:
The static output built from one commit on main and published to the site bucket.
_Avoid_: deployment, version, build

**Attended step**:
An infrastructure change Jakub runs himself (every Terraform apply and the DNS cut-over); no
automation performs it.
_Avoid_: manual deploy, ops step
