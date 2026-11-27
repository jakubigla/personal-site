from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import blocks, first

SAFE_POLICIES = {"redirect-to-https", "https-only"}


class RedirectsHttpAndRequiresTls12(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="CloudFront redirects HTTP to HTTPS on every behavior and requires TLS 1.2 or newer",
            id="CKV_PS_003",
            categories=[CheckCategories.ENCRYPTION],
            supported_resources=["aws_cloudfront_distribution"],
        )

    def scan_resource_conf(self, conf):
        behaviors = blocks(conf, "default_cache_behavior") + blocks(conf, "ordered_cache_behavior")
        if not behaviors:
            return CheckResult.FAILED
        for b in behaviors:
            if first(b.get("viewer_protocol_policy")) not in SAFE_POLICIES:
                return CheckResult.FAILED
        cert = first(conf.get("viewer_certificate"), {})
        minimum = first(cert.get("minimum_protocol_version")) if isinstance(cert, dict) else None
        if not isinstance(minimum, str) or not minimum.startswith("TLSv1.2"):
            return CheckResult.FAILED
        return CheckResult.PASSED


check = RedirectsHttpAndRequiresTls12()
