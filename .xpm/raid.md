# RAID Log

Last updated: 2026-11-27

## Risks
| ID | Date | Title | Likelihood | Impact | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|---|

## Assumptions
| ID | Date | Title | Validation | Owner | Status |
|---|---|---|---|---|---|
| A-019 | 2026-11-27 | Act 1's overlay is drawn in the first frame over the hero, which paints beneath it and stays the LCP element; Act 1 never delays the hero's paint (FR-002 vs NFR-002 AC3) [frs: FR-002] | PO answer, autopilot decisions batch Q4; NFR-002 AC3 amended | PO | confirmed (PO, Q4) |
| A-018 | 2026-11-27 | PO waived data-retention-and-backup, Q14 | elicitation 2026-11-27 Q14 | PO | confirmed |
| A-017 | 2026-11-27 | PO waived scalability, Q14 | elicitation 2026-11-27 Q14 | PO | confirmed |
| A-016 | 2026-11-27 | The existing jacops.pl Route 53 zone in Jakub's AWS account is reused, and the first terraform apply plus DNS cut-over are an attended step outside autopilot | Jakub runs the first apply and cut-over; CI only plans until then | Jakub | open |
| A-015 | 2026-11-27 | The anonymized selected-work labels and figures as given in the brief are not identifying; any card whose combined facts would identify a client drops a fact | PO confirmed the brief table's labels and figures are cleared; cards add no client fact beyond them (autopilot decisions batch Q18) | Jakub | confirmed (PO, Q18) |
| A-014 | 2026-11-27 | Layout holds from 360 px wide with no horizontal scroll; timeline collapses to a single column and pointer parallax is off on touch | Visual and automated checks at 360 px and touch emulation | Jakub | open |
| A-013 | 2026-11-27 | The light theme reuses the same graph drawn in ink on paper and keeps WCAG 2.2 AA contrast over the animated background in both themes | Automated contrast check in both themes at representative scroll positions | Jakub | open |
| A-012 | 2026-11-27 | Flagged-off sections (How I deliver, testimonial) render no markup, no empty slot and no nav entry or anchor while their flag is off | Build with flags off and assert the sections and their links are absent | Jakub | open |
| A-011 | 2026-11-27 | Browsers without CSS scroll-driven animations get the IntersectionObserver plus requestAnimationFrame fallback with equivalent final states and native scroll speed | Test in a browser lacking scroll-timeline support confirms the same end states | Jakub | open |
| A-010 | 2026-11-27 | Act 1 is skipped when the page is opened with a chapter hash (e.g. #work, #timeline) or interrupted by any scroll, key or tap, and the target lands in that act's final state | Automated test opens each section hash and asserts final state with no intro overlay | Jakub | open |
| A-009 | 2026-11-27 | Repeat visits in the same session skip Act 1 using sessionStorage, which is not a cookie and needs no consent banner; if storage is unavailable Act 1 simply plays again | Test: second load in the same session lands on the final hero state; private-mode load does not error | Jakub | open |
| A-008 | 2026-11-27 | Low-power detection uses hardwareConcurrency, deviceMemory where available, and a one-second frame-time check; browsers lacking deviceMemory fall back to the frame-time signal alone | Motion prototype run on a mid-range phone and a throttled desktop drops to the reduced variant | Jakub | open |
| A-007 | 2026-11-27 | With prefers-reduced-motion set, Act 1 is skipped, the graph is shown fully drawn and static, counters show final values and reveals become opacity-only or none | Automated test emulating reduced motion checks final states and no running animations | Jakub | open |
| A-006 | 2026-11-27 | With JavaScript off, the page renders top to bottom as a styled CV showing the final state of every act, with all facts in plain HTML | Automated test loads the built page with JS disabled and asserts every section's content is present | Jakub | open |
| A-005 | 2026-11-27 | Act 1 and Act 2 survive the design gate as the minimum signature sequence; Acts 3 to 6 may ship as plain reveals if the performance budget is tight | Design gate: motion prototype with JS size and frame rate on a mid-range phone, approved by Jakub | Jakub | open |
| A-004 | 2026-11-27 | Footer carries only the legal entity 'Jakub Igla JacOps' and the privacy note at launch; no tax number (NIP) until Jakub decides | Jakub confirms whether NIP is added; a content-file field allows it without layout change | Jakub | open |
| A-003 | 2026-11-27 | Portrait stays a generated on-brand placeholder (initials or abstract avatar) at launch; a real photo replaces it later by changing one path in the content file | Swap the content-file path in a test build and confirm layout is unchanged | Jakub | open |
| A-002 | 2026-11-27 | The page ships with Champion status as text only and no badge image until the official credential file and its verification link are added to assets/ | Build passes and page renders with the badge field empty; badge appears once the file and link are set in the content file | Jakub | open |
| A-001 | 2026-11-27 | Headline credential name 'Databricks Partner Champion' is correct as written; the content file holds it as one editable string | PO confirmed 'Databricks Partner Champion', as written (autopilot decisions batch Q17) | Jakub | confirmed (PO, Q17) |

## Issues
| ID | Date | Title | Severity | Resolution | Owner | Status |
|---|---|---|---|---|---|---|

## Dependencies
| ID | Date | Title | On | Needed by | Owner | Status |
|---|---|---|---|---|---|---|
