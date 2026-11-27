from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import first

# Resources that exist only to hold or ship access logs. Enabling logging needs the
# privacy work of NFR-031 first, so a change that adds them is rejected.
LOG_STORES = [
    "aws_cloudfront_realtime_log_config",
    "aws_s3_bucket_logging",
    "aws_cloudwatch_log_delivery",
    "aws_cloudwatch_log_delivery_source",
    "aws_cloudwatch_log_delivery_destination",
]


class LoggingOff(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="CloudFront logging is off and no log store exists",
            id="CKV_PS_008",
            categories=[CheckCategories.LOGGING],
            supported_resources=["aws_cloudfront_distribution", *LOG_STORES],
        )

    def scan_resource_conf(self, conf):
        if self.entity_type in LOG_STORES:
            return CheckResult.FAILED
        if first(conf.get("logging_config")):
            return CheckResult.FAILED
        return CheckResult.PASSED


check = LoggingOff()
