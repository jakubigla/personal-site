#!/usr/bin/env bash
# Fails when a tracked file, or a file name, holds a term from the client-name denylist.
# The list comes from $DENYLIST (a CI secret, one term per line) or a gitignored .denylist.local.
# It fails closed when no list exists, and never prints a term: the repo is public, so a leaked
# name could not be taken back out of its history.
#
#   denylist-check.sh [--optional] [file...]
#
# --optional lets a local hook skip when no list is on the machine; CI never passes it.
set -u

optional=0
if [ "${1:-}" = "--optional" ]; then
  optional=1
  shift
fi

root="$(git rev-parse --show-toplevel)" || exit 2
cd "$root" || exit 2

terms="$(mktemp)"
trap 'rm -f "$terms"' EXIT

if [ -n "${DENYLIST:-}" ]; then
  printf '%s\n' "$DENYLIST" >"$terms"
elif [ -f .denylist.local ]; then
  cat .denylist.local >"$terms"
fi
# Blank lines would match every file; drop them and CRs from a pasted secret.
tr -d '\r' <"$terms" | grep -v '^[[:space:]]*$' >"$terms.clean" || true
mv "$terms.clean" "$terms"

if [ ! -s "$terms" ]; then
  if [ "$optional" = 1 ]; then
    echo "denylist-check: no denylist on this machine, skipped (CI still checks)"
    exit 0
  fi
  echo "denylist-check: no denylist found (set DENYLIST or create .denylist.local); failing closed" >&2
  exit 2
fi

if [ "$#" -gt 0 ]; then
  files=("$@")
else
  files=()
  while IFS= read -r f; do files+=("$f"); done < <(git ls-files)
fi

bad=0
for f in "${files[@]}"; do
  [ -f "$f" ] || continue
  if printf '%s\n' "$f" | grep -qiFf "$terms"; then
    # The name itself holds a term, so printing it would print the term.
    echo "denylist-check: a file name holds a denied term (name withheld)" >&2
    bad=1
  elif grep -qIiFf "$terms" -- "$f"; then
    echo "denylist-check: denied term in $f" >&2
    bad=1
  fi
done

if [ "$bad" = 1 ]; then
  echo "denylist-check: failed; terms are never printed" >&2
  exit 1
fi
echo "denylist-check: clean (${#files[@]} files)"
