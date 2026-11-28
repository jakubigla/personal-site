#!/usr/bin/env bash
# Assert a workflow can neither plan nor apply the github stack nor hold a credential: only the
# owner plans and applies it, locally (ADR-0010). Comments are ignored so they may explain.
# The workflow's commands hide behind `mise run`, so every mise task it runs (and each task
# those depend on or run) is read from mise.toml and held to the same rules.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
file="${1:?usage: check-workflow.sh <workflow.yml> [mise.toml]}"
tasks="${2:-$here/../../../mise.toml}"

python3 -I - "$file" "$tasks" <<'PY'
import re, sys, tomllib

def strip_comments(raw):
    return "\n".join(l.split(" #")[0] if not l.lstrip().startswith("#") else "" for l in raw.splitlines())

text = strip_comments(open(sys.argv[1]).read())
with open(sys.argv[2], "rb") as fh:
    defined = tomllib.load(fh).get("tasks", {})

MISE_RUN = r"\bmise\s+(?:run|r)\s+([^\s;&|'\"]+)"
bad = []

# Resolve every mise task the workflow reaches: its run lines, its depends, and the tasks those
# run lines call in turn. A task mise.toml does not define cannot be checked, so it fails.
seen, todo, task_text = set(), re.findall(MISE_RUN, text), []
while todo:
    name = todo.pop()
    if name in seen:
        continue
    seen.add(name)
    task = defined.get(name)
    if not isinstance(task, dict):
        bad.append(f"runs mise task {name!r}, which mise.toml does not define")
        continue
    run = task.get("run", [])
    run = [run] if isinstance(run, str) else list(run)
    depends = task.get("depends", [])
    depends = [depends] if isinstance(depends, str) else list(depends)
    body = strip_comments("\n".join(str(r) for r in run))
    task_text.append(body)
    todo.extend(depends + re.findall(MISE_RUN, body))
commands = text + "\n" + "\n".join(task_text)

rules = {
    "requests an OIDC token (id-token permission)": (r"id-token\s*:", text),
    "assumes a cloud role or logs in to a cloud": (r"aws-actions/|azure/login|google-github-actions/auth|role-to-assume|AWS_(ACCESS|SECRET|SESSION|ROLE|WEB_IDENTITY)|ARM_(CLIENT|TENANT|SUBSCRIPTION)", commands),
    "reads a secret or a plan-identity variable": (r"secrets\.(?!GITHUB_TOKEN\b)|\bsecrets\s*:\s*inherit|GH_SETTINGS_", commands),
    "runs terraform plan, apply, import, destroy or state": (r"terraform\b[^\n]*\b(plan|apply|import|destroy|state|refresh)\b", commands),
    "runs a mise task that plans or applies": (r"mise\s+run\s+\S*(plan|apply)\b", commands),
    "grants a write permission (write-all or any scope: write)": (r"\bwrite-all\b|[\w-]+\s*:\s*write\b", text),
}
for why, (rx, where) in rules.items():
    if re.search(rx, where):
        bad.append(why)
if not re.search(r"^\s*pull_request\s*:", text, re.M) or re.search(r"pull_request_target|workflow_run|^\s*push\s*:|workflow_dispatch|schedule\s*:", text, re.M):
    bad.append("is not triggered by pull_request only (a trigger that carries secrets or writes is not allowed)")
if bad:
    print("workflow policy failures in " + sys.argv[1] + ":\n  " + "\n  ".join(bad))
    sys.exit(1)
print("workflow holds no credential and cannot plan or apply")
PY
