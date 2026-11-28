# Runbook: switching the deploy job on

The deploy job in `.github/workflows/ci.yml` is skipped while the repository variable
`DEPLOY_ROLE_ARN` is unset. It assumes one role through GitHub's OIDC issuer and holds no key or
secret. The apply is attended (ADR-0010) and follows the hosting first apply
(`hosting-first-apply.md`), because the role is scoped to the bucket and distribution that apply
creates.

## 1. Apply

From `infra/environments/prod`, plan and apply as in the hosting runbook. The plan adds the
GitHub OIDC provider, the `site-deploy` role and its inline policy. The provider exists once per
account: if the account already has one for `token.actions.githubusercontent.com`, import it
first (`terraform import module.deploy_role.aws_iam_openid_connect_provider.github <arn>`) and
check the plan shows no change to it.

## 2. Set the repository variables

Variables, not secrets: none of the three is sensitive.

```bash
cd infra/environments/prod
gh variable set DEPLOY_ROLE_ARN --body "$(terraform output -raw deploy_role_arn)"
gh variable set SITE_BUCKET     --body "$(terraform output -raw site_bucket)"
gh variable set DISTRIBUTION_ID --body "$(terraform output -raw distribution_id)"
```

Set `DEPLOY_ROLE_ARN` last: it is the switch.

## 3. Check

The next merge to main runs the deploy job: it uploads `_astro/` (hashed, immutable), then the
HTML (five minutes), then invalidates and waits. The role trusts only the subject
`repo:jakubigla/personal-site:ref:refs/heads/main`, so a pull request, a fork or another branch
cannot assume it. The job always runs on a GitHub-hosted runner, which ships the AWS CLI, and
never on the self-hosted one.
