<!-- xpm:begin - written by /xpm:xpm-init; a re-run rewrites only this block -->
## xpm

This project is delivered with the xpm plugin.

- Flow: `/xpm:xpm-ingest-brief <brief>` -> `/xpm:xpm-architect` -> `/xpm:xpm-plan-batch <scope>` -> `/xpm:xpm-orchestrate` (or `/xpm:xpm-start <KEY>` for one ticket). Each phase ends by saying where its work is saved: run `/clear`, then the next command it names.
- Where things live: `xpm paths committed catalog` (FR/NFR/EN catalog), `xpm paths committed raid`, `xpm paths state <store>` (runtime state, not committed). Resolve them; never type the paths.
- Settings: `xpm config get <key> --raw`; change them with `xpm config set` or by re-running `/xpm:xpm-init`.
- Pushes and PRs go through xpm (`xpm push_branch.sh`, `xpm push_paths.sh`), never a bare `git push`. A ticket session never merges: merging is the PO's.
- Gates (spec, plan and design approvals, review) wait for the PO; see and answer them in the cockpit (`xpm cockpit open` in a plain shell).
- Something broken: `xpm doctor`, then `xpm doctor --fix`.
<!-- xpm:end -->
