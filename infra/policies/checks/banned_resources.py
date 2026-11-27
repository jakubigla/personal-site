from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

# Each of these breaks the 2 USD monthly cap or the "no always-on compute" rule (NFR-019).
BANNED = [
    "aws_wafv2_web_acl",
    "aws_wafv2_web_acl_association",
    "aws_waf_web_acl",
    "aws_wafregional_web_acl",
    "aws_nat_gateway",
    "aws_instance",
    "aws_launch_template",
    "aws_autoscaling_group",
    "aws_ecs_service",
    "aws_eks_cluster",
    "aws_lb",
    "aws_alb",
    "aws_db_instance",
    "aws_rds_cluster",
    "aws_elasticache_cluster",
    "aws_apprunner_service",
]


class NoBannedResources(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="No WAF, NAT gateway or always-on compute in the stack",
            id="CKV_PS_007",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_resources=BANNED,
        )

    def scan_resource_conf(self, conf):
        return CheckResult.FAILED


check = NoBannedResources()
