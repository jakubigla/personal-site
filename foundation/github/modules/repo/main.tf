terraform {
  required_version = ">= 1.10"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
  }
}

locals {
  # The settings as they were live when this stack adopted the repository; `adopt` overrides them
  # so the first plan reproduces whatever is live and changes nothing.
  live = merge({
    description                      = null
    homepage_url                     = null
    topics                           = []
    has_issues                       = true
    has_projects                     = false
    has_wiki                         = false
    has_discussions                  = false
    allow_merge_commit               = false
    allow_squash_merge               = true
    allow_rebase_merge               = false
    allow_auto_merge                 = true
    allow_update_branch              = false
    delete_branch_on_merge           = true
    squash_merge_commit_title        = "COMMIT_OR_PR_TITLE"
    squash_merge_commit_message      = "COMMIT_MESSAGES"
    web_commit_signoff_required      = false
    default_workflow_permissions     = "read"
    can_approve_pull_request_reviews = false
    vulnerability_alerts             = true
    dependabot_security_updates      = true
    secret_scanning                  = "enabled"
    push_protection                  = "enabled"
    default_ruleset                  = true
    collaborators                    = {}
    teams                            = {}
    branch_protection                = null
  }, var.adopt)

  # A classic branch protection exists only on a repository that had one before adoption.
  legacy = local.live.branch_protection
}

resource "github_repository" "main" {
  name         = var.repository
  description  = local.live.description
  homepage_url = local.live.homepage_url
  visibility   = var.visibility
  topics       = local.live.topics

  has_issues      = local.live.has_issues
  has_projects    = local.live.has_projects
  has_wiki        = local.live.has_wiki
  has_discussions = local.live.has_discussions

  allow_merge_commit          = local.live.allow_merge_commit
  allow_squash_merge          = local.live.allow_squash_merge
  allow_rebase_merge          = local.live.allow_rebase_merge
  allow_auto_merge            = local.live.allow_auto_merge
  allow_update_branch         = local.live.allow_update_branch
  delete_branch_on_merge      = local.live.delete_branch_on_merge
  squash_merge_commit_title   = local.live.squash_merge_commit_title
  squash_merge_commit_message = local.live.squash_merge_commit_message
  web_commit_signoff_required = local.live.web_commit_signoff_required

  # Secret scanning and its push protection are a free feature of a public repository; the
  # block is omitted where the plan has none, so a plan never tries to set it.
  dynamic "security_and_analysis" {
    for_each = var.secret_scanning_available ? [1] : []
    content {
      secret_scanning {
        status = local.live.secret_scanning
      }
      secret_scanning_push_protection {
        status = local.live.push_protection
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Authoritative: the owner always has admin and is never listed, so everyone else live on adoption
# is listed here, or the first plan would remove them.
resource "github_repository_collaborators" "main" {
  repository = github_repository.main.name

  dynamic "user" {
    for_each = local.live.collaborators
    content {
      username   = user.key
      permission = user.value
    }
  }

  dynamic "team" {
    for_each = local.live.teams
    content {
      team_id    = team.key
      permission = team.value
    }
  }
}

resource "github_workflow_repository_permissions" "main" {
  repository                       = github_repository.main.name
  default_workflow_permissions     = local.live.default_workflow_permissions
  can_approve_pull_request_reviews = local.live.can_approve_pull_request_reviews
}

resource "github_repository_vulnerability_alerts" "main" {
  repository = github_repository.main.name
  enabled    = local.live.vulnerability_alerts
}

resource "github_repository_dependabot_security_updates" "main" {
  repository = github_repository.main.name
  enabled    = local.live.dependabot_security_updates

  depends_on = [github_repository_vulnerability_alerts.main]
}

# A repository adopted without xpm's ruleset gets it later, as its own reviewed tightening.
resource "github_repository_ruleset" "default" {
  count = local.live.default_ruleset ? 1 : 0

  repository  = github_repository.main.name
  name        = "default"
  target      = "branch"
  enforcement = var.rulesets_enforced ? "active" : "evaluate"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true

    pull_request {
      allowed_merge_methods             = ["rebase", "squash"]
      required_approving_review_count   = var.required_approvals
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = false
    }
  }
}

# Kept as it was live on adoption; removing it is its own reviewed tightening, never a side effect.
resource "github_branch_protection" "legacy" {
  # It reproduces the live protection, so its review count and signing rule are whatever was live
  # (.checkov.yaml says why CKV_GIT_5 and CKV_GIT_6 are skipped); the ruleset is where xpm sets rules.
  count = local.legacy == null ? 0 : 1

  repository_id                   = github_repository.main.node_id
  pattern                         = local.legacy.pattern
  enforce_admins                  = local.legacy.enforce_admins
  allows_deletions                = local.legacy.allows_deletions
  allows_force_pushes             = local.legacy.allows_force_pushes
  required_linear_history         = local.legacy.required_linear_history
  require_conversation_resolution = local.legacy.require_conversation_resolution
  require_signed_commits          = local.legacy.require_signed_commits
  lock_branch                     = local.legacy.lock_branch

  dynamic "required_status_checks" {
    for_each = local.legacy.required_status_checks == null ? [] : [local.legacy.required_status_checks]
    content {
      strict   = required_status_checks.value.strict
      contexts = required_status_checks.value.contexts
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = local.legacy.required_pull_request_reviews == null ? [] : [local.legacy.required_pull_request_reviews]
    content {
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      require_last_push_approval      = required_pull_request_reviews.value.require_last_push_approval
    }
  }
}
