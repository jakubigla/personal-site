from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import blocks, first


class ServesCustom404(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="CloudFront serves a custom page with status 404 for missing paths",
            id="CKV_PS_005",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_resources=["aws_cloudfront_distribution"],
        )

    def scan_resource_conf(self, conf):
        for resp in blocks(conf, "custom_error_response"):
            if (
                first(resp.get("error_code")) in (403, 404, "403", "404")
                and first(resp.get("response_code")) in (404, "404")
                and first(resp.get("response_page_path"))
            ):
                return CheckResult.PASSED
        return CheckResult.FAILED


check = ServesCustom404()
