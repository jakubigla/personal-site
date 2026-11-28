#!/usr/bin/env bash
# Behaviour tests for check-workflow-security.py: the real workflows pass and each way of letting
# the OIDC token, an unpinned action or an unlocked install reach the deploy path is rejected.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
check="$here/check-workflow-security.py"
root="$here/.."
fails=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

expect() { # name, want-exit, got-exit
  if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (want exit $2, got $3)"; fails=$((fails + 1)); fi
}

sha=0123456789abcdef0123456789abcdef01234567

# A workflow that satisfies every rule; each case below changes one thing.
write() { # name, build-job extra yaml, deploy-job extra yaml, top-level extra
  cat >"$work/$1.yml" <<YAML
on: push
permissions:
  contents: read
$4
jobs:
  build:
    runs-on: ubuntu-latest
$2
    steps:
      - uses: actions/checkout@$sha
      - run: npm ci --ignore-scripts
      - uses: actions/upload-artifact@$sha
        with:
          name: site
          path: dist
  deploy:
    needs: [build]
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/download-artifact@$sha
        with:
          name: site
          path: site
$3
YAML
}

reject() { # name, build extra, deploy extra, top extra
  write "$1" "$2" "$3" "$4"
  "$check" --require-deploy "$work/$1.yml" >/dev/null 2>&1; expect "$1 is rejected" 1 $?
}

write clean "" "" ""
"$check" --require-deploy "$work/clean.yml" >/dev/null 2>&1; expect "a conforming workflow passes" 0 $?

reject build-id-token '    permissions:
      id-token: write' "" ""
reject build-write-all '    permissions: write-all' "" ""
# Conforming in every other way, so only the workflow-level rule can reject it.
reject top-id-token "" "" "  id-token: write"
reject deploy-installs "" '      - run: npm ci --ignore-scripts' ""
reject deploy-npx "" '      - run: npx wrangler deploy' ""
reject deploy-delete "" '      - run: aws s3 sync site s3://b --delete' ""
reject deploy-rm "" '      - run: aws s3 rm s3://b/_astro --recursive' ""
reject deploy-mise "" "      - uses: jdx/mise-action@$sha" ""
write deploy-no-token "" "" ""
sed -i.bak '/id-token: write/d' "$work/deploy-no-token.yml"
"$check" --require-deploy "$work/deploy-no-token.yml" >/dev/null 2>&1; expect "a deploy job without id-token is rejected" 1 $?
reject unpinned-tag "" '      - uses: actions/cache@v4' ""
reject short-sha "" '      - uses: actions/cache@3d3c42e' ""
write unlocked-install "" "" ""
sed -i.bak 's/npm ci --ignore-scripts/npm ci/' "$work/unlocked-install.yml"
"$check" "$work/unlocked-install.yml" >/dev/null 2>&1; expect "npm ci with scripts on is rejected" 1 $?
# A fresh file with scripts off, so only the lockfile rule can reject it.
write unlocked-install2 "" "" ""
sed -i.bak 's/npm ci --ignore-scripts/npm install --ignore-scripts/' "$work/unlocked-install2.yml"
"$check" "$work/unlocked-install2.yml" >/dev/null 2>&1; expect "npm install outside the lockfile is rejected" 1 $?
write missing-artifact "" "" ""
sed -i.bak '/download-artifact/,$ s/name: site/name: other/' "$work/missing-artifact.yml"
"$check" --require-deploy "$work/missing-artifact.yml" >/dev/null 2>&1; expect "an artifact no needed job uploads is rejected" 1 $?
printf 'on: push\njobs:\n  build:\n    runs-on: x\n    steps: []\n' >"$work/nodeploy.yml"
"$check" --require-deploy "$work/nodeploy.yml" >/dev/null 2>&1; expect "a missing deploy job is rejected when required" 1 $?
"$check" "$work/nodeploy.yml" >/dev/null 2>&1; expect "a missing deploy job is fine when not required" 0 $?
"$check" --forbid-deploy "$work/nodeploy.yml" >/dev/null 2>&1; expect "a workflow without a deploy job passes when one is forbidden" 0 $?
"$check" --forbid-deploy "$work/clean.yml" >/dev/null 2>&1; expect "a deploy job in a non-deploying workflow is rejected" 1 $?

cat >"$work/mise.toml" <<'TOML'
[tasks."web:install"]
run = "npm ci"
TOML
"$check" "$work/clean.yml" "$work/mise.toml" >/dev/null 2>&1; expect "a mise task installing with scripts on is rejected" 1 $?

"$check" --require-deploy "$root/.github/workflows/ci.yml" "$root/mise.toml"; expect "ci.yml passes" 0 $?
"$check" --forbid-deploy "$root/.github/workflows/github-config.yml" "$root/mise.toml"; expect "github-config.yml passes" 0 $?

exit "$fails"
