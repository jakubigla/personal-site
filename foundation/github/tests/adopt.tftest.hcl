# The first plan of an adopted repository must reproduce what is live, so every key that
# `xpm init foundation render` writes into `adopt` has to reach the resource it describes.
# A mocked provider keeps this a credential-free plan.

mock_provider "github" {}

run "defaults_manage_the_repository_as_xpm_sets_it_up" {
  command = plan

  module {
    source = "./modules/repo"
  }

  variables {
    repository                = "personal-site"
    visibility                = "public"
    required_approvals        = 0
    rulesets_enforced         = true
    secret_scanning_available = true
  }

  assert {
    condition     = length(github_repository_ruleset.default) == 1
    error_message = "Without adopt, the stack must create the default ruleset."
  }

  assert {
    condition     = length(github_branch_protection.legacy) == 0
    error_message = "Without adopt, no classic branch protection is managed."
  }

  assert {
    condition     = length(github_repository_collaborators.main.user) == 0
    error_message = "Without adopt, the repository has no direct collaborator besides the owner."
  }

  assert {
    condition     = github_repository_vulnerability_alerts.main.enabled && github_repository_dependabot_security_updates.main.enabled
    error_message = "Without adopt, Dependabot alerts and security updates are on."
  }
}

run "adopt_reproduces_the_live_settings" {
  command = plan

  module {
    source = "./modules/repo"
  }

  variables {
    repository                = "personal-site"
    visibility                = "public"
    required_approvals        = 0
    rulesets_enforced         = true
    secret_scanning_available = true
    adopt = {
      default_ruleset             = false
      collaborators               = { octocat = "push" }
      teams                       = {}
      vulnerability_alerts        = false
      dependabot_security_updates = false
      secret_scanning             = "disabled"
      push_protection             = "disabled"
      branch_protection = {
        pattern                         = "main"
        enforce_admins                  = true
        allows_deletions                = false
        allows_force_pushes             = false
        required_linear_history         = true
        require_conversation_resolution = true
        require_signed_commits          = false
        lock_branch                     = false
        required_status_checks          = { strict = true, contexts = ["ci-ok"] }
        required_pull_request_reviews = {
          required_approving_review_count = 1
          dismiss_stale_reviews           = true
          require_code_owner_reviews      = false
          require_last_push_approval      = false
        }
      }
    }
  }

  assert {
    condition     = length(github_repository_ruleset.default) == 0
    error_message = "A repository without a live default ruleset must not get one on the first plan."
  }

  assert {
    condition     = length(github_branch_protection.legacy) == 1
    error_message = "A live classic branch protection must be managed, or its import has no target."
  }

  assert {
    condition     = github_branch_protection.legacy[0].pattern == "main" && github_branch_protection.legacy[0].enforce_admins && github_branch_protection.legacy[0].require_conversation_resolution
    error_message = "The classic branch protection must keep its live arguments."
  }

  assert {
    condition     = github_branch_protection.legacy[0].required_status_checks[0].strict && contains(github_branch_protection.legacy[0].required_status_checks[0].contexts, "ci-ok")
    error_message = "The classic branch protection must keep its live required status checks."
  }

  assert {
    condition     = github_branch_protection.legacy[0].required_pull_request_reviews[0].required_approving_review_count == 1 && github_branch_protection.legacy[0].required_pull_request_reviews[0].dismiss_stale_reviews
    error_message = "The classic branch protection must keep its live review rules."
  }

  assert {
    condition     = one([for u in github_repository_collaborators.main.user : u if u.username == "octocat"]).permission == "push"
    error_message = "A live direct collaborator must be kept with its role, not removed."
  }

  assert {
    condition     = !github_repository_vulnerability_alerts.main.enabled && !github_repository_dependabot_security_updates.main.enabled
    error_message = "Live Dependabot alerts and security updates must be reproduced as they are."
  }

  assert {
    condition     = github_repository.main.security_and_analysis[0].secret_scanning[0].status == "disabled" && github_repository.main.security_and_analysis[0].secret_scanning_push_protection[0].status == "disabled"
    error_message = "Live secret scanning and push protection statuses must be reproduced as they are."
  }
}
