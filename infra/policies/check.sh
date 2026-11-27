#!/usr/bin/env bash
# Scan one Terraform root with the built-in checks plus the custom policies and fail on any
# finding. With --require-budget the root must also contain a budget that passes CKV_PS_009:
# a per-resource policy cannot fire on a resource that was deleted, so absence is asserted here.
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
require_budget=0
if [ "${1:-}" = "--require-budget" ]; then require_budget=1; shift; fi
root="${1:?usage: check.sh [--require-budget] <terraform root>}"

out="$(mktemp)"
trap 'rm -f "$out"' EXIT

checkov -d "$root" --config-file "$here/../.checkov.yaml" --external-checks-dir "$here/policies/checks" \
  -o json >"$out" || true

python3 -I - "$out" "$require_budget" <<'PY'
import json, sys

data = json.load(open(sys.argv[1]))
reports = data if isinstance(data, list) else [data]
failed, passed = [], set()
for rep in reports:
    res = rep.get("results", {})
    failed += [f'{c["check_id"]} {c["resource"]} ({c["file_path"]})' for c in res.get("failed_checks", [])]
    passed |= {c["check_id"] for c in res.get("passed_checks", [])}
if failed:
    print("policy failures:\n  " + "\n  ".join(sorted(set(failed))))
    sys.exit(1)
if sys.argv[2] == "1" and "CKV_PS_009" not in passed:
    print("policy failure: CKV_PS_009 no monthly budget in this root")
    sys.exit(1)
print("policies pass")
PY
