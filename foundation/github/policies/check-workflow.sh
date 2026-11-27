#!/usr/bin/env bash
# Assert a workflow can neither plan nor apply the github stack nor hold a credential: only the
# owner plans and applies it, locally (ADR-0010). Comments are ignored so they may explain.
set -euo pipefail

file="${1:?usage: check-workflow.sh <workflow.yml>}"

python3 -I - "$file" <<'PY'
import re, sys

lines = [l.split(" #")[0] if not l.lstrip().startswith("#") else "" for l in open(sys.argv[1]).read().splitlines()]
text = "\n".join(lines)

rules = {
    "requests an OIDC token (id-token permission)": r"id-token\s*:",
    "assumes a cloud role or logs in to a cloud": r"aws-actions/|azure/login|google-github-actions/auth|role-to-assume|AWS_(ACCESS|SECRET|SESSION|ROLE|WEB_IDENTITY)|ARM_(CLIENT|TENANT|SUBSCRIPTION)",
    "reads a secret or a plan-identity variable": r"secrets\.(?!GITHUB_TOKEN\b)|\bsecrets\s*:\s*inherit|GH_SETTINGS_",
    "runs terraform plan, apply, import, destroy or state": r"terraform\b[^\n]*\b(plan|apply|import|destroy|state|refresh)\b|-chdir=\S+\s+(plan|apply|import|destroy)\b",
    "runs a mise task that plans or applies": r"mise\s+run\s+\S*(plan|apply)\b",
    "writes with the contents or other permission": r"(contents|pull-requests|issues|actions|checks|statuses|deployments|packages|administration|security-events)\s*:\s*write",
    "is not triggered by pull_request": None,
}
bad = []
for why, rx in rules.items():
    if rx is None:
        if not re.search(r"^\s*pull_request\s*:", text, re.M) or re.search(r"pull_request_target|workflow_run|^\s*push\s*:|workflow_dispatch|schedule\s*:", text, re.M):
            bad.append(why + " only (a trigger that carries secrets or writes is not allowed)")
    elif re.search(rx, text):
        bad.append(why)
if bad:
    print("workflow policy failures in " + sys.argv[1] + ":\n  " + "\n  ".join(bad))
    sys.exit(1)
print("workflow holds no credential and cannot plan or apply")
PY
