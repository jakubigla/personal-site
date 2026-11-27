# Elicitation research

## Queries

- `independent consultant portfolio website best practices for B2B credibility` - sent
- `Polish sole proprietorship website legal information requirements electronic services` - sent
- `LinkedIn link preview Open Graph image size requirements` - sent
- `CloudFront S3 static website security headers Content-Security-Policy best practices` - sent
- `scroll-driven animations accessibility pitfalls prefers-reduced-motion` - sent
- `European Accessibility Act microenterprise services exemption` - sent
- `GDPR CDN access logs IP address personal data static website` - sent
- `S3 CloudFront static site deployment cache invalidation rollback` - sent
- `low cost uptime monitoring and budget alerts for a static website on AWS` - sent
- `publishing email address on website spam harvesting mitigation` - sent

## Findings

- Consultant sites earn B2B trust with specific, measurable outcomes and outside validation (talks, credentials) rather than self-description, and with contact that takes one click; testimonials naming a concrete result are the strongest proof, which the catalog defers to a flagged-off slot. ([How to Build a Consulting Website](https://umbrex.com/resources/consulting-website/))
- Providers of electronic services in Poland fall under the 2002 Electronic Services Act; guides list company details among the usual site disclosures, and sole proprietors are registered in the national business register. This bears on the open decision about showing the company tax number in the footer; no source quoted the exact statutory list, so a legal check is needed. ([Ecommerce in Poland](https://cms.law/en/int/expert-guides/ecommerce-in-CEE/poland))
- The professional network's link preview reads og:title, og:description, og:url and og:image; secondary guides put the image at 1200 x 627 px minimum, 1.91:1, under 5 MB. The network caches previews, so a pre-launch check with its post inspector belongs in the launch step. ([Make your website shareable](https://www.linkedin.com/help/linkedin/answer/46687))
- CDN security headers are not added by default and come from a response headers policy with override on; the Content-Security-Policy value is capped at 1783 characters, so any inline scripts or styles the build emits must be few enough to hash within that limit or moved to files. ([Understand response headers policies](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/understanding-response-headers-policies.html))
- Browsers do not switch off scroll-linked animations under reduced motion on their own; script-driven motion must read the media query itself and listen for changes at runtime, and automated audits do not reliably catch reduced-motion failures, so it needs its own scripted test. ([prefers-reduced-motion: Sometimes less movement is more](https://web.dev/articles/prefers-reduced-motion))
- The European Accessibility Act exempts microenterprises (under 10 staff, turnover under 2 million EUR) providing services, so WCAG 2.2 AA here is a chosen quality bar, not a legal duty; enterprise buyers still increasingly expect documented conformance. ([Microenterprise guidelines on the European Accessibility Act](https://www.ccpc.ie/business/enforcement/accessibility/european-accessibility-act-guidelines-for-microenterprises/))
- CDN and web server access logs hold IP addresses and user agents, which are personal data under GDPR; a "no tracking" privacy note stays true only if logging is off or the logs are minimised, retained for a set period and covered by the note. This matters for the cookieless visit counter idea that relies on CDN logs. ([GDPR and web server logs](https://ctrl.blog/entry/gdpr-web-server-logs))
- A deploy by bucket sync with delete removes the previous build, so rolling back a bad release needs object versioning or per-release prefixes; the usual cache split is long TTLs on hashed assets, short on HTML, and an invalidation the pipeline waits for, since a visitor mid-invalidation can get old HTML with new assets. ([Controlling how long content is cached](https://docs.aws.amazon.com/whitepapers/latest/build-static-websites-aws/controlling-how-long-amazon-s3-content-is-cached-by-amazon-cloudfront.html))
- Budget alerts at 80 and 100 percent of a small monthly cap are the standard cost guard but fire hours late, so they warn rather than cap; a scheduled serverless uptime check with an email alert costs cents a month. ([Cost monitoring and budget alarms](https://stevekinney.com/courses/aws/cost-monitoring-and-budget-alarms))
- A plain mailto address on a public page will be harvested; script-based obfuscation conflicts with a page that must read fully without JavaScript, so the realistic options are accepting the spam, a dedicated alias, or a no-JS munged display. ([Email-address harvesting](https://en.wikipedia.org/wiki/Email_harvesting))

## NFR checklist

| Area | Result | Ref |
|---|---|---|
| security | covered | NFR-012 |
| privacy-and-compliance | gap | CDN access-log IPs and retention; provider disclosure under national e-services law |
| performance | covered | NFR-001 |
| availability-and-recovery | gap | no uptime target and no rollback of a bad release (only cut-over rollback in NFR-022) |
| scalability | likely-n/a | static files behind a CDN absorb a launch-post spike; cost under load sits with NFR-019 |
| data-retention-and-backup | likely-n/a | no user data; content and its history live in git |
| observability | gap | no uptime check, cost alert or deploy-failure notice |
| accessibility | covered | NFR-003 |
| internationalisation | covered | NFR-024 |
| maintainability | covered | NFR-023 |
| portability-and-deployment | covered | NFR-020 |
| cost | covered | NFR-019 |
