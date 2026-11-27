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
  }, var.adopt)
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
        status = "enabled"
      }
      secret_scanning_push_protection {
        status = "enabled"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# The owner always has admin and is not listed; a team adds users here.
resource "github_repository_collaborators" "main" {
  repository = github_repository.main.name
}

resource "github_workflow_repository_permissions" "main" {
  repository                       = github_repository.main.name
  default_workflow_permissions     = local.live.default_workflow_permissions
  can_approve_pull_request_reviews = local.live.can_approve_pull_request_reviews
}

resource "github_repository_vulnerability_alerts" "main" {
  repository = github_repository.main.name
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "main" {
  repository = github_repository.main.name
  enabled    = true

  depends_on = [github_repository_vulnerability_alerts.main]
}

resource "github_repository_ruleset" "default" {
  count = 1

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

# No classic branch protection is live: the ruleset above is the only protection.
resource "github_branch_protection" "legacy" {
  count = 0

  repository_id = github_repository.main.node_id
  pattern       = "main"
}
