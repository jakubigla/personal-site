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

The current page is served by the old 2021 distribution, which holds the `jacops.pl` and
`www.jacops.pl` aliases. CloudFront refuses to create a distribution with an alias another
distribution already uses (`CNAMEAlreadyExists`), so the first apply runs with
`serve_domain=false`: the distribution gets no aliases and the apex and www records are left
alone. Everything else, the bucket policy included, is created.

```bash
cd infra/environments/prod
terraform init
terraform plan -var serve_domain=false -out=hosting.tfplan
```

Read the plan. Expect new: the site bucket, its public access block, ownership, encryption and
policy, the CloudFront distribution with no aliases, origin access control, response headers
policy, the router function, the certificate and its validation records, and the budget.
Expect no apex or www record, and no WAF, NAT gateway, compute or logging resource. Then:

```bash
terraform apply hosting.tfplan
```

The apply creates the validation records, waits for the certificate and creates the
distribution. The old page stays live: nothing it uses is touched.

Confirm the budget subscription: AWS emails the contact address; open it if it asks you to
confirm.

## 4. Upload the site and check the new distribution

Upload the built site to the bucket named by `terraform output site_bucket` (the deploy job
does this once its role exists), then invalidate if needed. Check the distribution on its own
`*.cloudfront.net` name (it has no alias yet, so a `jacops.pl` host header would reach the old
distribution):

```bash
H=$(terraform output -raw distribution_domain)
curl -sI https://"$H"/ | head -20             # 200 with the new site
curl -sI https://"$H"/does-not-exist        # 404 with the custom page
curl -sI http://"$H"/                         # 301 to https
```

You should see `strict-transport-security`, `content-security-policy`,
`x-content-type-options`, `referrer-policy` and `x-frame-options` on every response. Do not go
on until all three answer as shown.

## 5. Cut-over: move the aliases, then the records

The cut-over is the alias move. `aws cloudfront associate-alias` moves an alias from the old
distribution to the new one in one call; the new one's certificate covers both names. From
that moment CloudFront serves the alias from the new distribution, even to clients whose DNS
still points at the old one, so the records can follow without downtime.

1. Note the old state so the move can be reversed:

   ```bash
   ZONE=$(aws route53 list-hosted-zones-by-name --dns-name jacops.pl \
     --query 'HostedZones[0].Id' --output text)
   aws route53 list-resource-record-sets --hosted-zone-id "$ZONE" > old-records.json
   OLD=<old distribution id>     # aws cloudfront list-distributions; the one with the aliases
   OLD_H=$(aws cloudfront get-distribution --id "$OLD" --query 'Distribution.DomainName' --output text)
   NEW=$(terraform output -raw distribution_id)
   NEW_H=$(terraform output -raw distribution_domain)
   ```

   Keep `old-records.json` outside the repo.
2. Lower the TTL of any non-alias apex or www record to 60 seconds and wait the old TTL.
3. Prove you own `www.jacops.pl` to CloudFront: create the `_www.jacops.pl` TXT record with the
   value `$NEW_H`. The apex cannot be proven this way: its proof record would be `_jacops.pl`,
   which sits beside the `jacops.pl` zone (under `.pl`), so Route 53 refuses it
   (`InvalidChangeBatch`). The apex moves in step 4 by releasing it from the old distribution.

   ```bash
   aws route53 change-resource-record-sets --hosted-zone-id "$ZONE" --change-batch \
     '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"_www.jacops.pl","Type":"TXT","TTL":60,"ResourceRecords":[{"Value":"\"'"$NEW_H"'\""}]}}]}'
   ```

4. Move the aliases. `www` moves with `associate-alias`. The apex is released from the old
   distribution: remove `jacops.pl` from its aliases (console, or `aws cloudfront
   update-distribution` with the `Aliases` list edited). From here until step 5 completes the
   apex does not serve the old site, so do this in a quiet window and go straight on to step 5.

   ```bash
   aws cloudfront associate-alias --target-distribution-id "$NEW" --alias www.jacops.pl
   ```

5. Point the records at the new distribution with the full apply (`serve_domain` defaults to
   true). The apply adds the apex alias to the new distribution (the old one no longer holds
   it) and creates the four apex and www `A`/`AAAA` records. If it fails with
   `CNAMEAlreadyExists`, the apex is still on the old distribution: stop, finish step 4, and
   plan again.

   ```bash
   terraform plan -out=hosting.tfplan
   terraform apply hosting.tfplan
   ```

6. Verify `https://jacops.pl/` serves the new site, `https://www.jacops.pl/` redirects to the
   apex with a 301, and `http://jacops.pl/` redirects to HTTPS.
7. Rollback if anything is wrong: apply with `serve_domain=false` (it removes the new
   distribution's aliases and the apex and www records), then put the aliases back on the old
   distribution: re-add `jacops.pl` to its `Aliases` (as in step 4), and for `www` set the
   `_www.jacops.pl` TXT value to `$OLD_H` and run
   `associate-alias --target-distribution-id "$OLD" --alias www.jacops.pl` (the old
   distribution's certificate still covers both names). Restore the apex and www records from
   `old-records.json` and investigate. Do not run a full `terraform apply` again until the cause
   is fixed: with `serve_domain` true it re-points the records at the new distribution.
8. Delete the `_www.jacops.pl` TXT record once the site is verified.

## 6. Retire the old site

Keep the old resources for at least a week, until the new site has served traffic cleanly.
The old 2021 Terraform state still holds the apex and www records, which now alias the new
distribution through `allow_overwrite`: a `terraform destroy` there would delete them and take
the site offline.

1. In the old stack's root, remove its record resources from its state first, so no destroy
   can touch them:

   ```bash
   terraform state list | grep aws_route53_record    # every record the old state holds
   terraform state rm <each apex and www record address>
   ```

   Keep any record the old state holds that is not the apex or www site record (MX, TXT,
   verification) out of the destroy the same way, or leave the old stack in place and delete the
   old distribution and bucket by hand instead.
2. Disable, then delete, the old distribution (it has no aliases left), and empty and delete the
   old bucket.
3. Remove every old record that served the old site, by name and type, as listed in
   `old-records.json`: anything that pointed at the old distribution (`$OLD_H`) or at an S3
   website or bucket endpoint, other than the four records step 5 replaced.
4. Check that no record dangles: every CloudFront or S3 target left in the zone must be the new
   distribution. This prints nothing when the zone is clean:

   ```bash
   aws route53 list-resource-record-sets --hosted-zone-id "$ZONE" --output json \
     | jq -r --arg new "$NEW_H." '.ResourceRecordSets[]
         | {n: .Name, t: .Type, v: ((.AliasTarget.DNSName // "") + " " + ([.ResourceRecords[]?.Value] | join(" ")))}
         | select(.v | test("cloudfront\\.net|amazonaws\\.com"; "i"))
         | select((.v | ascii_downcase | ltrimstr(" ") | rtrimstr(" ")) != ($new | ascii_downcase))
         | "\(.n) \(.t) \(.v)"'
   ```

## 7. After the cut-over

Raise the TTLs if you lowered them, and check the budget exists in AWS Budgets at 2 USD per
month with alerts at 80% and 100% of actual spend. Later infrastructure changes follow steps
1 and 3 only, without `-var serve_domain=false`: once the aliases have moved, the default
keeps them and the records in place.
