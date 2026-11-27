from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import blocks, first


class OriginAccessControlOnEveryOrigin(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="Every CloudFront origin is reached through origin access control",
            id="CKV_PS_002",
            categories=[CheckCategories.IAM],
            supported_resources=["aws_cloudfront_distribution"],
        )

    def scan_resource_conf(self, conf):
        origins = blocks(conf, "origin")
        if not origins:
            return CheckResult.FAILED
        for origin in origins:
            if not first(origin.get("origin_access_control_id")):
                return CheckResult.FAILED
        return CheckResult.PASSED


check = OriginAccessControlOnEveryOrigin()
