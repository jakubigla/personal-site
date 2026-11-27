# Elicitation changes (2026-11-27)

All 38 proposal rows applied (autopilot: the PO's sent answers are the approval).

| # | Change | Target | Source |
|---|---|---|---|
| 1 | new NFR | NFR-030 99.5% monthly availability with revert-and-redeploy rollback (should, not MVP) | Q3 |
| 2 | new NFR | NFR-031 No visitor logs kept - CloudFront access logging off (must, MVP) | Q4 |
| 3 | data class | NFR-031 personal | Q4 |
| 4 | new NFR | NFR-032 Cost and deploy-failure alerts by email (should, not MVP) | Q6 |
| 5 | new FR | FR-033 Preview a content change on its pull request (could, not MVP) | Q10 |
| 6 | edit FR | FR-015 plain mailto link, spam accepted (AC5, notes) | Q13 |
| 7 | edit FR | FR-021 legal entity plus NIP in footer; privacy note tied to logging off (AC4, notes) | Q8 |
| 8 | edit FR | FR-024 Open Graph image 1200 x 627 px generated at build (AC5-AC7, notes) | Q5 |
| 9 | edit FR | FR-025 live within 10 min, awaited invalidation, cache split (AC5-AC8, notes) | Q7 |
| 10 | edit FR | FR-026 old 2020 CV URL 301 to current CV; needs + aws-static-hosting (AC5, notes) | Q12 |
| 11 | edit FR | FR-032 CloudFront logs only, IPs minimised, 30-day expiry, privacy note (AC4-AC7, notes) | Q9 |
| 12 | waive | scalability - RAID A-017 | Q14 |
| 13 | waive | data-retention-and-backup - RAID A-018 | Q14 |
| 14-15 | priority | FR-005, FR-011 should (mvp true) | Q2 |
| 16-20 | priority | FR-007, FR-016, FR-017, FR-018, FR-019 should (mvp true) | Q1 |
| 21 | priority | FR-031 wont (mvp false) | Q11 |
| 22, 25, 28-31 | priority | NFR-002, NFR-008, NFR-025, NFR-026, NFR-028, NFR-029 must (mvp true) | Q1 |
| 23-24, 26-27 | priority | NFR-006, NFR-007, NFR-009, NFR-010 should (mvp true) | Q1 |
| 32 | link NFRs | FR-033 + NFR-011, NFR-014, NFR-015, NFR-021 | Q10 |
| 33 | link NFRs | FR-015 + NFR-003, NFR-004, NFR-018, NFR-023 | Q13 |
| 34 | link NFRs | FR-021 + NFR-016, NFR-023, NFR-025, NFR-026, NFR-031 | Q8 |
| 35 | link NFRs | FR-024 + NFR-001, NFR-015, NFR-023, NFR-026, NFR-027 | Q5 |
| 36 | link NFRs | FR-025 + NFR-012, NFR-013, NFR-020, NFR-021, NFR-022, NFR-030, NFR-032 | Q7 |
| 37 | link NFRs | FR-026 + NFR-015, NFR-020, NFR-023, NFR-025, NFR-029 | Q12 |
| 38 | link NFRs | FR-032 + NFR-016, NFR-017, NFR-018, NFR-019, NFR-020, NFR-031 | Q9 |

Rows 33-38 were applied in the same catalog_set call as their edit row (one History entry per FR).

## data-class

- data class: personal (NFR-031)
- set security.block_severity = medium: the requirements say this product holds personal data (names, emails, logins) (NFR-031)
