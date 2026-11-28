import json
import re

from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import first

# The one subject a deploy may present: this repository's main branch. Pinned here so a change
# of repository is a reviewed change to the policy, not only to the role.
SUBJECT = "repo:jakubigla/personal-site:ref:refs/heads/main"
ISSUER = "token.actions.githubusercontent.com"


class DeployRoleTrustsOnlyMain(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="A role trusting GitHub's OIDC issuer is limited by an exact subject to this repository's main branch",
            id="CKV_PS_010",
            categories=[CheckCategories.IAM],
            supported_resources=["aws_iam_role"],
        )

    def scan_resource_conf(self, conf):
        raw = first(conf.get("assume_role_policy"))
        try:
            doc = json.loads(raw) if isinstance(raw, str) else raw
        except ValueError:
            return CheckResult.UNKNOWN
        if not isinstance(doc, dict):
            return CheckResult.UNKNOWN
        statements = doc.get("Statement", [])
        if isinstance(statements, dict):
            statements = [statements]
        federated = False
        for st in statements:
            if st.get("Effect") != "Allow":
                continue
            principal = st.get("Principal")
            fed = principal.get("Federated") if isinstance(principal, dict) else None
            if not fed:
                continue
            federated = True
            cond = st.get("Condition", {})
            # Only StringEquals binds an exact value; StringLike and the others admit patterns.
            if set(cond) != {"StringEquals"}:
                return CheckResult.FAILED
            eq = cond["StringEquals"]
            if eq.get(f"{ISSUER}:sub") != SUBJECT or eq.get(f"{ISSUER}:aud") != "sts.amazonaws.com":
                return CheckResult.FAILED
        return CheckResult.PASSED if federated else CheckResult.UNKNOWN


check = DeployRoleTrustsOnlyMain()
