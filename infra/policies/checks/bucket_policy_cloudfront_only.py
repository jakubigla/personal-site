import json

from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import first


class BucketReadableOnlyByCloudFront(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="Site bucket policy allows reads only to CloudFront, scoped to one distribution",
            id="CKV_PS_001",
            categories=[CheckCategories.IAM],
            supported_resources=["aws_s3_bucket_policy"],
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
                continue
            principal = st.get("Principal")
            service = principal.get("Service") if isinstance(principal, dict) else None
            services = service if isinstance(service, list) else [service]
            if services != ["cloudfront.amazonaws.com"]:
                return CheckResult.FAILED
            cond = st.get("Condition", {}).get("StringEquals", {})
            if "AWS:SourceArn" not in cond:
                return CheckResult.FAILED
        return CheckResult.PASSED


check = BucketReadableOnlyByCloudFront()
