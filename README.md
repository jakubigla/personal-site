# refs/xpm/register

This ref holds the xpm agent decision register: an append-only record of what xpm did and
decided in this repository (pushes, merges, PR and ticket writes, gates, choices, outcomes).
`xpm register sync` writes it. Nothing else should move it, and it is never force-pushed.

## What the tree holds

- `<machine>/<stream>.jsonl`: one file per machine and stream, one JSON record per line.
  `machine` is a random id made once per checkout (`register.machine` in `config.local.toml`).
  `stream` is `main` (attended sessions and scripts), `conductor` (the autopilot) or
  `seat-<KEY>` (a dispatched seat). Each machine writes only its own paths, so two machines
  never edit the same file.
- `HEADS.json`: `{"<machine>/<stream>": {"seq": <n>, "hash": "sha256:..."}}`, the last record
  of each stream when it was pushed.
- `README.md`: this file.

Each commit is a sync: the previous tree plus the syncing machine's files. A stream file only
grows. If a remote copy is not a byte prefix of the local file, sync refuses and pushes nothing.

## Record schema (`xpm.register/1`)

Top-level fields:

- `schema`: `"xpm.register/1"`; it changes only on a breaking change.
- `id`: `dec_` + a ULID (time-sortable). It is the Decision-Id that commits (`Xpm-Decision-Id`),
  PR bodies and tracker comments carry.
- `kind`: `effect | gate | choice | outcome | correction | override` (an agent acting past an autopilot stop on evidence xpm read).
- `action`: from a closed list, for example `git.push`, `pr.open`, `pr.merge`,
  `tracker.transition`, `seat.dispatch`, `approval.review`, `guard.merge`, `decide`.
- `stream`, `machine`: the file the record lives in.
- `seq`: 1, 2, 3, ... within the file.
- `prev`: the previous record's `hash` in the same file (`sha256:genesis` for the first).
- `hash`: `sha256:` + sha256 of the record's canonical JSON with `hash` left out.
- `at`: UTC time, `YYYY-MM-DDTHH:MM:SSZ`.
- `observed`, `reported`, `outcome`: the field classes below.
- `supersedes`: on a `correction`, the id it corrects.

Field classes:

- **observed**: what the framework saw. Audit-grade. It holds `actor`, `principal`, `subject`
  (repo, ticket, pr, branch, sha), `effect`, `policy`, `inputs` (by reference and hash),
  `options` / `chosen`, `expected`, `parents` (ids this record follows from), `trace` (session
  and tool-use ids), `sanctioned`, and `result` (`ok | failed | denied | asked`).
- **reported**: what an agent said, such as a rationale. Only on choices and agent-written gate
  notes. It is a claim, not an observation.
- **derived**: outcomes (reverts, post-merge CI, overrides) are separate `kind: outcome` records
  with `outcome: {"of": "dec_...", "status": "observed|unknown", "signal": "...", "value": ...}`.
  Records are never edited: a correction or an outcome is a new record.

Not stored: prompts, diffs, command output, tool payloads. `principal.on_behalf_of` is a salted
hash, not an address.

Readers ignore unknown fields.

## Verify a chain by hand

`xpm register verify --remote` does all of this. By hand, for one stream file:

```sh
git fetch origin +refs/xpm/register:refs/xpm/register-fetched
git show refs/xpm/register-fetched:<machine>/<stream>.jsonl >stream.jsonl

prev="sha256:genesis"
while IFS= read -r line; do
  # The hash covers the record with `hash` removed, keys sorted, no whitespace.
  want="sha256:$(printf '%s' "$line" | jq -cS 'del(.hash)' | tr -d '\n' | shasum -a 256 | cut -d' ' -f1)"
  [ "$(printf '%s' "$line" | jq -r .hash)" = "$want" ] || echo "hash mismatch: $line"
  [ "$(printf '%s' "$line" | jq -r .prev)" = "$prev" ] || echo "chain broken before: $line"
  prev="$(printf '%s' "$line" | jq -r .hash)"
done <stream.jsonl
```

`jq -cS` sorts keys and prints compact JSON with non-ASCII text unescaped, matching xpm's
canonical form. The last `hash` should equal the stream's entry in `HEADS.json`.

Caveats for the jq recipe:

- It needs jq 1.7 or newer. Older jq turns large integers and some numbers into floats
  (`1e+17`), so the bytes, and therefore the hash, differ.
- jq writes U+007F (DEL) as `\u007f`, but xpm's canonical form keeps it as a raw byte. A record
  that holds DEL in a string fails this check even though it is intact. `xpm register verify
  --remote` hashes the canonical form itself and has no such gap.
