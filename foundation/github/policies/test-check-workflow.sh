#!/usr/bin/env bash
# Prove check-workflow.sh: the real workflow passes and each way of gaining a credential or a
# plan or apply command is rejected.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
real="$here/../../../.github/workflows/github-config.yml"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
status=0

base='on:
  pull_request:
    paths: [foundation/github/**]
permissions:
  contents: read
jobs:
  checks:
    runs-on: ubuntu-latest
    steps:
      - run: terraform fmt -check
'

reject() { # name, extra yaml appended to the base, optional mise.toml the workflow's tasks come from
  printf '%s%s\n' "$base" "$2" >"$tmp/$1.yml"
  if "$here/check-workflow.sh" "$tmp/$1.yml" ${3:+"$3"} >/dev/null 2>&1; then
    echo "FAIL $1 was accepted"; status=1
  else echo "ok   $1 rejected"; fi
}

printf '%s' "$base" >"$tmp/clean.yml"
if "$here/check-workflow.sh" "$tmp/clean.yml" >/dev/null; then echo "ok   clean fixture accepted"
else echo "FAIL clean fixture rejected"; status=1; fi

reject id-token '      - uses: x/y@v1
        with: {id-token: write}'
reject oidc-permission '    permissions:
      id-token: write'
reject aws-action '      - uses: aws-actions/configure-aws-credentials@v4'
reject role-variable '      - run: echo ${{ vars.GH_SETTINGS_PLAN_ROLE_ARN }}'
reject secret '      - run: echo ${{ secrets.GH_SETTINGS_ADMIN_TOKEN }}'
reject plan '      - run: terraform -chdir=foundation/github plan'
reject plain-plan '      - run: terraform plan -out=x'
reject apply '      - run: terraform apply -auto-approve'
reject import '      - run: terraform import a.b c'
reject write-permission '      - run: echo hi
permissions-extra: {contents: write}'
reject write-all 'permissions-extra: write-all'
reject job-write-all '    permissions: write-all'

# A plan hidden behind a mise task the workflow runs, directly or through depends.
cat >"$tmp/mise.toml" <<'TOML'
[tasks."gh:check"]
depends = ["gh:fmt", "gh:sneaky"]
[tasks."gh:fmt"]
run = "terraform fmt -check"
[tasks."gh:sneaky"]
run = ["terraform -chdir=foundation/github init", "terraform plan -out=x"]
[tasks."gh:clean"]
run = "terraform fmt -check"
TOML
reject mise-task-plan '      - run: mise run gh:check' "$tmp/mise.toml"
reject mise-task-undefined '      - run: mise run gh:missing' "$tmp/mise.toml"
printf '%s%s\n' "$base" '      - run: mise run gh:clean' >"$tmp/mise-clean.yml"
if "$here/check-workflow.sh" "$tmp/mise-clean.yml" "$tmp/mise.toml" >/dev/null; then echo "ok   clean mise task accepted"
else echo "FAIL clean mise task rejected"; status=1; fi

reject push-trigger 'extra:
  push:'
reject target-trigger 'on-extra: pull_request_target'

"$here/check-workflow.sh" "$real" || status=1
exit "$status"
