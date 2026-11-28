import json

from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import first

# What a site deploy needs and nothing more: write objects, list the bucket, invalidate.
ALLOWED = {
    "s3:PutObject",
    "s3:ListBucket",
    "cloudfront:CreateInvalidation",
    "cloudfront:GetInvalidation",
}


class DeployRolePermissionsAreNarrow(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="The deploy role's inline policy allows only the site bucket write and the distribution invalidation",
            id="CKV_PS_011",
            categories=[CheckCategories.IAM],
            supported_resources=["aws_iam_role_policy"],
        )

    def scan_resource_conf(self, conf):
        raw = first(conf.get("policy"))
        try:
            doc = json.loads(raw) if isinstance(raw, str) else raw
        except ValueError:
            return CheckResult.UNKNOWN
        if not isinstance(doc, dict):
            return CheckResult.UNKNOWN
        statements = doc.get("Statement", [])
        if isinstance(statements, dict):
            statements = [statements]
        for st in statements:
            if st.get("Effect") != "Allow":
                return CheckResult.FAILED
            actions = st.get("Action")
            actions = actions if isinstance(actions, list) else [actions]
            if not set(actions) <= ALLOWED:
                return CheckResult.FAILED
            resources = st.get("Resource")
            resources = resources if isinstance(resources, list) else [resources]
            if any(r == "*" or r is None for r in resources):
                return CheckResult.FAILED
        return CheckResult.PASSED


check = DeployRolePermissionsAreNarrow()
