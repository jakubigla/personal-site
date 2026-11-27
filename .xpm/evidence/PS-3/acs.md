# PS-3 acceptance criteria

Source: taken from the ticket as written.

## Acceptance Criteria

- AC1: terraform fmt -check and terraform validate pass for the hosting stack. ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC1)
- AC2: A static policy or plan check confirms the bucket blocks all public access and is readable only by the CloudFront distribution through origin access control. ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC2)
- AC3: The CloudFront configuration redirects HTTP to HTTPS, attaches a response headers policy (HSTS, CSP, X-Content-Type-Options, Referrer-Policy, frame protection) and serves the custom 404 page for missing paths. ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC3)
- AC4: A request to the www host is configured to redirect to the apex domain. ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC4)
- AC5: The stack declares no always-on compute, NAT gateway or WAF plan. ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC5)
- AC6: A runbook in the repo describes the attended first apply and the DNS cut-over from the current page. ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC6)
- AC7: An AWS Budgets monthly budget of 2 USD with email notifications at 80% and 100% of actual spend is defined, to the contact address the page publishes ([NFR-034](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-034.md), [NFR-014](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-014.md) AC2). ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC7)
- AC8: CloudFront standard and real-time logging are off and no log store exists; Checkov custom policies in infra/policies fail a change that adds a WAF, NAT gateway, always-on compute or logging, or removes the budget ([NFR-019](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-019.md) AC3, [NFR-031](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-031.md) AC3, [NFR-034](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-034.md) AC4). ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC8)
- AC9: Remote state lives in a versioned, encrypted S3 bucket with native locking, created by a separate bootstrap root; no state file, account id or secret is committed ([ADR-0009](https://github.com/jakubigla/personal-site/blob/main/docs/adr/0009-s3-state-backend-native-locking.md), [NFR-014](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/nfr/NFR-014.md)). ([EN-002](https://github.com/jakubigla/personal-site/blob/main/.xpm/catalog/en/EN-002.md) AC9)
- AC10: Negative: a policy check fails a change that makes the site bucket publicly readable, removes origin access control, or lets CloudFront serve plain HTTP without the redirect.
