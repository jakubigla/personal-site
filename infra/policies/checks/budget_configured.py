from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

from _conf import blocks, first


class MonthlyBudgetConfigured(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="Monthly budget of 2 USD emails at 80% and 100% of actual spend",
            id="CKV_PS_009",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_resources=["aws_budgets_budget"],
        )

    def scan_resource_conf(self, conf):
        limit = first(conf.get("limit_amount"))
        try:
            amount = float(limit)
        except (TypeError, ValueError):
            return CheckResult.FAILED
        if first(conf.get("limit_unit")) != "USD" or first(conf.get("time_unit")) != "MONTHLY" or amount > 2:
            return CheckResult.FAILED
        seen = set()
        for n in blocks(conf, "notification"):
            emails = n.get("subscriber_email_addresses")
            if (
                first(n.get("notification_type")) == "ACTUAL"
                and first(n.get("threshold_type")) == "PERCENTAGE"
                and first(n.get("comparison_operator")) == "GREATER_THAN"
                and emails
                and first(emails)
            ):
                seen.add(first(n.get("threshold")))
        return CheckResult.PASSED if {80, 100} <= {int(float(s)) for s in seen if s is not None} else CheckResult.FAILED


check = MonthlyBudgetConfigured()
