# Runbook: first apply and DNS cut-over

Every Terraform apply is attended (ADR-0010). Nothing here runs in CI and CI holds no AWS
credential for these roots. You need: AWS credentials for the owner's account with rights to
create S3, CloudFront, ACM, Route 53 records and Budgets; Terraform 1.10 or newer; the
Route 53 hosted zone for `jacops.pl`, which already exists.

The bucket names (`jacops-pl-terraform-state`, `jacops-pl-site`) are global; if S3 reports one
taken, change it in `infra/bootstrap/main.tf` (and the `backend` block in
`infra/environments/prod/main.tf`) or in the `site_hosting` module call, and commit that.

## 1. Check the code locally

```bash
terraform fmt -check -recursive infra
infra/policies/test.sh
```

## 2. Bootstrap the state bucket (once)

```bash
cd infra/bootstrap
terraform init
terraform apply
```

Its own state stays in `terraform.tfstate` in this directory. It is gitignored: keep it, never
commit it. The bucket is versioned, encrypted, private and has `prevent_destroy`.

## 3. First apply of the hosting root

```bash
cd infra/environments/prod
terraform init
terraform plan -out=hosting.tfplan
```

Read the plan. Expect new: the site bucket and its policy, the CloudFront distribution, origin
access control, response headers policy, the router function, the certificate and its
validation records, the apex and www `A`/`AAAA` records, and the budget. Expect no WAF, NAT
gateway, compute or logging resource. Then:

```bash
terraform apply hosting.tfplan
```

The apply creates the validation records, waits for the certificate, and creates the
distribution. **It also replaces the apex and www records in the zone** (`allow_overwrite`),
so the cut-over happens at the end of this step, before any content is uploaded. To keep the
old page live until the new one is ready, apply with the records held back:

```bash
terraform apply -target=module.site_hosting.aws_acm_certificate_validation.site \
                -target=module.site_hosting.aws_cloudfront_distribution.site \
                -target=module.cost_guard
```

and run the full apply in step 5.

Confirm the budget subscription: AWS emails the contact address; open it if it asks you to
confirm.

## 4. Upload the site and check the new distribution

Upload the built site to the bucket named by `terraform output site_bucket` (the deploy job
does this once its role exists), then invalidate if needed. Check the distribution on its own
`*.cloudfront.net` name, forcing the host header:

```bash
D=$(terraform output -raw distribution_id)
H=$(aws cloudfront get-distribution --id "$D" --query 'Distribution.DomainName' --output text)
curl -sI --resolve jacops.pl:443:"$(dig +short "$H" | head -1)" https://jacops.pl/ | head -20
curl -sI https://"$H"/does-not-exist        # 404 with the custom page
curl -sI http://"$H"/                         # 301 to https
```

You should see `strict-transport-security`, `content-security-policy`,
`x-content-type-options`, `referrer-policy` and `x-frame-options` on every response.

## 5. DNS cut-over from the current page

1. Note the current apex and www records (`aws route53 list-resource-record-sets`) and the old
   distribution id, so the move can be reversed.
2. Lower the TTL of those records to 60 seconds and wait the old TTL.
3. Run the full `terraform apply`. The apex and www records now alias the new distribution.
4. Verify `https://jacops.pl/` serves the new site, `https://www.jacops.pl/` redirects to the
   apex with a 301, and `http://jacops.pl/` redirects to HTTPS.
5. Rollback if anything is wrong: re-create the noted records pointing at the old
   distribution, then investigate.
6. Keep the old resources for at least a week. Retire them (old distribution, bucket, any
   leftover records) only after the new site has served traffic cleanly; never before the
   records point at the new distribution.

## 6. After the cut-over

Raise the TTLs if you lowered them, and check the budget exists in AWS Budgets at 2 USD per
month with alerts at 80% and 100% of actual spend. Later infrastructure changes follow steps
1 and 3 only.
