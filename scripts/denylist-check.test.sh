#!/usr/bin/env bash
# Behaviour tests for denylist-check.sh. Every term here is a made-up placeholder, never a real name.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
check="$here/denylist-check.sh"
fails=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

term="zzq-placeholder-client"

new_repo() {
  rm -rf "$work/repo" && mkdir -p "$work/repo" && cd "$work/repo" || exit 1
  git init -q . && git config user.email t@example.test && git config user.name t
  printf 'plain text\n' >clean.txt
}

expect() { # name, want-exit, got-exit
  if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (want exit $2, got $3)"; fails=$((fails + 1)); fi
}

new_repo
printf 'We worked with %s on the platform\n' "$term" >content.yaml
git add . && out="$(DENYLIST="$term" "$check" 2>&1)"; code=$?
expect "a denied term fails the check" 1 "$code"
case "$out" in *"$term"*) echo "FAIL the term was printed"; fails=$((fails + 1)) ;; *) echo "ok   the term is never printed" ;; esac
case "$out" in *content.yaml*) echo "ok   the offending file is named" ;; *) echo "FAIL the offending file is not named"; fails=$((fails + 1)) ;; esac

new_repo
printf 'We worked with %s\n' "$(printf '%s' "$term" | tr 'a-z' 'A-Z')" >content.yaml
git add . && DENYLIST="$term" "$check" >/dev/null 2>&1; expect "matching ignores case" 1 $?

new_repo
printf 'x\n' >"$term.txt"
git add . && out="$(DENYLIST="$term" "$check" 2>&1)"; code=$?
expect "a denied term in a file name fails" 1 "$code"
case "$out" in *"$term"*) echo "FAIL the term leaked through a file name"; fails=$((fails + 1)) ;; *) echo "ok   a file name holding a term is not echoed" ;; esac

new_repo
git add . && DENYLIST="$term" "$check" >/dev/null 2>&1; expect "a clean tree passes" 0 $?

new_repo
git add . && env -u DENYLIST "$check" >/dev/null 2>&1; expect "a missing denylist fails closed" 2 $?

new_repo
git add . && DENYLIST="" "$check" >/dev/null 2>&1; expect "an empty denylist fails closed" 2 $?

new_repo
git add . && DENYLIST=$'\n  \n' "$check" >/dev/null 2>&1; expect "a blank-only denylist fails closed" 2 $?

new_repo
printf '%s\n' "$term" >.denylist.local
printf 'about %s\n' "$term" >content.yaml
git add content.yaml clean.txt && env -u DENYLIST "$check" >/dev/null 2>&1; expect "the local file feeds the check" 1 $?

new_repo
git add . && env -u DENYLIST "$check" --optional >/dev/null 2>&1; expect "the hook may skip when no list exists" 0 $?

new_repo
printf 'about %s\n' "$term" >content.yaml
git add . && DENYLIST="$term" "$check" clean.txt >/dev/null 2>&1; expect "only the named files are scanned" 0 $?
DENYLIST="$term" "$check" content.yaml >/dev/null 2>&1; expect "a named file holding a term fails" 1 $?

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
