from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import first


class SecurityHeadersPolicyComplete(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="Response headers policy sets HSTS, CSP, nosniff, Referrer-Policy and frame protection",
            id="CKV_PS_004",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_resources=["aws_cloudfront_response_headers_policy"],
        )

    def scan_resource_conf(self, conf):
        sec = first(conf.get("security_headers_config"))
        if not isinstance(sec, dict):
            return CheckResult.FAILED
        for block in (
            "strict_transport_security",
            "content_security_policy",
            "content_type_options",
            "referrer_policy",
        ):
            if not first(sec.get(block)):
                return CheckResult.FAILED
        csp = first(sec.get("content_security_policy"), {})
        policy = first(csp.get("content_security_policy")) if isinstance(csp, dict) else None
        has_frame_options = bool(first(sec.get("frame_options")))
        has_frame_ancestors = isinstance(policy, str) and "frame-ancestors" in policy
        if not (has_frame_options or has_frame_ancestors):
            return CheckResult.FAILED
        return CheckResult.PASSED


check = SecurityHeadersPolicyComplete()
