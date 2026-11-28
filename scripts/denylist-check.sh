#!/usr/bin/env bash
# Fails when a tracked file, or a file name, holds a term from the client-name denylist.
# The list comes from $DENYLIST (a CI secret, one term per line) or a gitignored .denylist.local.
# It fails closed when no list exists, and never prints a term: the repo is public, so a leaked
# name could not be taken back out of its history.
#
#   denylist-check.sh [--optional] [file...]
#
# --optional lets a local hook skip when no list is on the machine; CI never passes it.
# DENYLIST_COMMITS (a rev range such as base..head) adds those commits' messages, and
# DENYLIST_TITLE (a PR title) adds that text: a squash merge copies both into main's history.
set -u

# Case folding must reach non-ASCII letters (a Polish name in capitals), and a runner can start in the
# C locale. Use the first UTF-8 locale the machine has; a bare C locale would only fold ASCII.
for loc in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8; do
  if locale -a 2>/dev/null | grep -qix "$loc"; then
    export LC_ALL="$loc"
    break
  fi
done

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
# Blank lines would match every file. Drop CRs from a pasted secret, trim each term's leading and
# trailing whitespace (padding is not part of a name, so a padded term must still match) and skip
# the lines left empty.
tr -d '\r' <"$terms" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v '^$' >"$terms.clean" || true
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
  # -z: without it git C-quotes a non-ASCII path, the quoted name is no file, and it is skipped.
  while IFS= read -r -d '' f; do files+=("$f"); done < <(git ls-files -z)
fi

bad=0
unreadable=0
for f in "${files[@]}"; do
  [ -f "$f" ] || continue
  if printf '%s\n' "$f" | grep -qiFf "$terms"; then
    # The name itself holds a term, so printing it would print the term.
    echo "denylist-check: a file name holds a denied term (name withheld)" >&2
    bad=1
    continue
  fi
  # -a: binary files are scanned too, so a term inside one cannot slip through. grep exits 1 for
  # "no match" and 2 for "could not read": a file the check cannot read is a failure, not clean.
  grep -aqiFf "$terms" -- "$f" 2>/dev/null
  case $? in
    0)
      echo "denylist-check: denied term in $f" >&2
      bad=1
      ;;
    1) ;;
    *)
      echo "denylist-check: cannot read $f; failing closed" >&2
      unreadable=1
      ;;
  esac
done

if [ -n "${DENYLIST_COMMITS:-}" ]; then
  shas="$(git rev-list "$DENYLIST_COMMITS" --)" || {
    echo "denylist-check: cannot read the commits in DENYLIST_COMMITS; failing closed" >&2
    exit 2
  }
  for sha in $shas; do
    if git log -1 --format=%B "$sha" | grep -qiFf "$terms"; then
      echo "denylist-check: denied term in the message of commit $(git rev-parse --short "$sha")" >&2
      bad=1
    fi
  done
fi

if [ -n "${DENYLIST_TITLE:-}" ] && printf '%s\n' "$DENYLIST_TITLE" | grep -qiFf "$terms"; then
  echo "denylist-check: denied term in DENYLIST_TITLE (the pull request title)" >&2
  bad=1
fi

if [ "$bad" = 1 ]; then
  echo "denylist-check: failed; terms are never printed" >&2
  exit 1
fi
if [ "$unreadable" = 1 ]; then
  echo "denylist-check: a file could not be read, so the tree is unchecked" >&2
  exit 2
fi
echo "denylist-check: clean (${#files[@]} files)"
