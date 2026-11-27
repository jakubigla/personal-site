from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import first


class WwwRedirectsToApex(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="CloudFront function redirects the www host to the apex with a 301",
            id="CKV_PS_006",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_resources=["aws_cloudfront_function"],
        )

    def scan_resource_conf(self, conf):
        code = first(conf.get("code"))
        if not isinstance(code, str):
            return CheckResult.UNKNOWN
        if "www." in code and "301" in code and "location" in code:
            return CheckResult.PASSED
        return CheckResult.FAILED


check = WwwRedirectsToApex()
