#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml==6.0.4"]
# ///
"""Fail a workflow that weakens the deploy trust boundary.

Only the deploy job may hold the OIDC token and it must not install anything; every action is
pinned by commit SHA; package installs come from the lockfile with lifecycle scripts off; and the
release artifact the deploy job publishes is uploaded by a job it needs. The role's trust policy
gates only on the repository and the main branch, not on a workflow or job, so every workflow file
is checked: the one that deploys with --require-deploy, every other with --forbid-deploy.

usage: check-workflow-security.py [--require-deploy | --forbid-deploy] <workflow.yml> [<mise.toml>]
"""
import re
import sys
import tomllib

import yaml

DEPLOY = "deploy"
SHA = re.compile(r"^[^@\s]+@[0-9a-f]{40}$")
INSTALL = re.compile(r"\b(npm\s+(ci|install|i|add)|yarn(\s+(install|add))?|pnpm\s+(install|i|add)|pip3?\s+install|uv\s+(sync|pip)|bundle\s+install|mise\s+run\s+\S*install)\b")
NODE_INSTALL = re.compile(r"\bnpm\s+(ci|install|i|add)\b[^\n;&|]*")


def perms(node):
    """The scopes a permissions value grants, 'write-all' standing for every scope."""
    value = node.get("permissions") if isinstance(node, dict) else None
    if value == "write-all":
        return {"id-token": "write", "*": "write"}
    return value if isinstance(value, dict) else {}


def steps_of(job):
    return [s for s in job.get("steps", []) if isinstance(s, dict)]


def runs_of(job):
    return [str(s["run"]) for s in steps_of(job) if "run" in s]


def check(workflow, tasks, require_deploy, forbid_deploy=False):
    bad = []
    jobs = workflow.get("jobs", {})
    if perms(workflow).get("id-token") == "write":
        bad.append("the workflow grants id-token: write to every job; only the deploy job may hold it")
    for name, job in jobs.items():
        if name != DEPLOY and perms(job).get("id-token") == "write":
            bad.append(f"job {name!r} holds id-token: write; only {DEPLOY!r} may")
    deploy = jobs.get(DEPLOY)
    if deploy is not None and forbid_deploy:
        bad.append(f"job {DEPLOY!r} is only allowed in the deploying workflow, not here")
    if deploy is None:
        if require_deploy:
            bad.append(f"no job named {DEPLOY!r}")
    else:
        if perms(deploy).get("id-token") != "write":
            bad.append(f"job {DEPLOY!r} does not hold id-token: write, so it cannot assume the role")
        for step in steps_of(deploy):
            uses = str(step.get("uses", ""))
            if uses.startswith("jdx/mise-action") or uses.startswith("actions/setup-"):
                bad.append(f"job {DEPLOY!r} installs a toolchain ({uses.split('@')[0]}) while holding the OIDC token")
        for run in runs_of(deploy):
            if INSTALL.search(run) or re.search(r"\bnpx\b", run):
                bad.append(f"job {DEPLOY!r} runs a package install: {run.strip().splitlines()[0]}")
            if re.search(r"--delete\b|\bs3\s+(rm|rb|mv)\b|\bs3api\s+delete", run):
                bad.append(f"job {DEPLOY!r} deletes from the bucket, which would remove hashed assets: {run.strip().splitlines()[0]}")
        needs = deploy.get("needs", [])
        needs = [needs] if isinstance(needs, str) else needs
        wanted = {str(s.get("with", {}).get("name")) for s in steps_of(deploy) if str(s.get("uses", "")).startswith("actions/download-artifact@")}
        if not wanted:
            bad.append(f"job {DEPLOY!r} does not download the release artifact")
        uploaded = {
            str(s.get("with", {}).get("name"))
            for n in needs
            for s in steps_of(jobs.get(n, {}))
            if str(s.get("uses", "")).startswith("actions/upload-artifact@")
        }
        if wanted and not wanted <= uploaded:
            bad.append(f"job {DEPLOY!r} downloads {sorted(wanted - uploaded)}, which no job it needs uploads")
    for name, job in jobs.items():
        for step in steps_of(job):
            uses = step.get("uses")
            if uses and not str(uses).startswith("./") and not SHA.match(str(uses)):
                bad.append(f"job {name!r} uses {uses}, not pinned by a full commit SHA")
    commands = [(f"job {n!r}", r) for n, j in jobs.items() for r in runs_of(j)]
    for tname, task in tasks.items():
        run = task.get("run", [])
        commands += [(f"mise task {tname!r}", str(r)) for r in ([run] if isinstance(run, str) else run)]
    for where, cmd in commands:
        for m in NODE_INSTALL.finditer(cmd):
            if "--ignore-scripts" not in m.group(0):
                bad.append(f"{where} installs packages with lifecycle scripts on: {m.group(0).strip()}")
            if re.match(r"npm\s+(install|i|add)\b", m.group(0)):
                bad.append(f"{where} installs outside the lockfile (use npm ci): {m.group(0).strip()}")
    return bad


def main():
    args = sys.argv[1:]
    require_deploy = "--require-deploy" in args
    forbid_deploy = "--forbid-deploy" in args
    args = [a for a in args if a not in ("--require-deploy", "--forbid-deploy")]
    if require_deploy and forbid_deploy:
        sys.exit(__doc__)
    if not args:
        sys.exit(__doc__)
    sys.argv = [sys.argv[0], *args]
    with open(sys.argv[1]) as fh:
        workflow = yaml.safe_load(fh)
    tasks = {}
    if len(sys.argv) > 2:
        with open(sys.argv[2], "rb") as fh:
            tasks = tomllib.load(fh).get("tasks", {})
    bad = check(workflow, tasks, require_deploy, forbid_deploy)
    if bad:
        print(f"workflow security failures in {sys.argv[1]}:\n  " + "\n  ".join(bad))
        sys.exit(1)
    print(f"{sys.argv[1]}: only {DEPLOY} holds the OIDC token, actions are pinned, installs are locked")


main()
