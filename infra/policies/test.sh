#!/usr/bin/env bash
# Prove the policies: the real roots pass, and every fixture under tests/ is rejected by the
# check that guards it.
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
status=0

run_fixture() { # fixture, check id
  local out
  out="$(mktemp)"
  checkov -d "$here/policies/tests/$1" --framework terraform --skip-download \
    --external-checks-dir "$here/policies/checks" --check "$2" --compact --quiet -o json >"$out" || true
  if python3 -I - "$out" "$2" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
reports = data if isinstance(data, list) else [data]
failed = {c["check_id"] for r in reports for c in r.get("results", {}).get("failed_checks", [])}
sys.exit(0 if sys.argv[2] in failed else 1)
PY
  then echo "ok   $1 rejected by $2"
  else echo "FAIL $1 not rejected by $2"; status=1; fi
  rm -f "$out"
}

run_fixture public-bucket CKV_AWS_53
run_fixture open-bucket-policy CKV_PS_001
run_fixture unscoped-bucket-policy CKV_PS_001
run_fixture no-oac CKV_PS_002
run_fixture plain-http CKV_PS_003
run_fixture old-tls CKV_PS_003
run_fixture headers-incomplete CKV_PS_004
run_fixture no-custom-404 CKV_PS_005
run_fixture no-www-redirect CKV_PS_006
run_fixture waf CKV_PS_007
run_fixture nat-gateway CKV_PS_007
run_fixture compute CKV_PS_007
run_fixture logging CKV_PS_008
run_fixture realtime-logging CKV_PS_008
run_fixture log-store CKV_PS_008
run_fixture budget-wrong CKV_PS_009

# A root without a budget must fail the presence assertion.
if "$here/policies/check.sh" --require-budget "$here/policies/tests/budget-missing" >/dev/null 2>&1; then
  echo "FAIL budget-missing passed the budget requirement"; status=1
else
  echo "ok   budget-missing rejected by CKV_PS_009 presence"
fi

"$here/policies/check.sh" --require-budget "$here/environments/prod" || status=1
"$here/policies/check.sh" "$here/bootstrap" || status=1
exit "$status"
