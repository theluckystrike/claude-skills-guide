---

layout: default
title: "Claude Code Git Branch Naming"
description: "Master git branch naming conventions that work smoothly with Claude Code. Learn patterns, prefixes, and workflows to organize your development."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, git, branch-naming, development-workflow, version-control, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-git-branch-naming-conventions/
geo_optimized: true
last_tested: "2026-04-22"
---

Git branch naming is one of those topics that seems simple until your repository becomes a chaotic mess of branches named "fix", "update2", or "asdfasdf". When working with Claude Code, well-structured branch names become even more valuable, the AI assistant can parse your branch structure, understand your workflow intent, and provide better assistance throughout the development cycle.

This guide covers practical branch naming conventions that work with Claude Code, helping you maintain a clean repository while using AI-assisted development.

## The Case for Structured Branch Names

Claude Code reads your git history and branch structure to understand what you're working on. A branch named `feature/user-authentication` immediately tells the AI that this branch handles user authentication features. A branch named `fix-bug` provides much less context.

When you switch to a branch and describe your task to Claude Code, having a clear branch name reinforces your intent. The conversation might look like this:

```
User: I'm on the feature/user-dashboard branch and need to add a settings page.
Claude Code: I'll help you build the settings page on the user-dashboard feature branch.
```

The branch name acts as implicit context that Claude Code can reference throughout your session. This matters more than it might seem. When you return to a branch after a few days and open Claude Code, the AI can use the branch name to orient itself quickly. It can infer the likely files to look at, suggest related test files, and avoid making suggestions that belong to a different area of the codebase.

Compare these two scenarios:

| Branch Name | Claude Code's Starting Context |
|---|---|
| `fix2` | None. Claude must ask what you're fixing |
| `bugfix/PROJ-456-cart-total-rounding` | Project, type (bugfix), ticket number, affected area (cart), nature of problem (rounding) |
| `feature/user-notification-settings` | Type (feature), domain (user), subsystem (notifications), scope (settings) |
| `hotfix/payment-gateway-timeout` | Type (emergency), system (payment gateway), symptom (timeout) |

The information density of a well-named branch is significant, and Claude Code uses it at the start of every session.

## Standard Branch Prefix Conventions

Most teams benefit from a consistent set of prefixes that categorize branches by purpose. Here are the most common conventions:

## Feature Branches

Feature branches handle new functionality:

```
feature/user-dashboard
feature/payment-integration
feature/add-search-filtering
```

When working with the tdd skill, you might create branches like:

```
feature/tdd-user-profile-validation
feature/tdd-api-rate-limiting
```

The frontend-design skill pairs well with feature branches for UI work:

```
feature/design-checkout-flow
feature/design-mobile-navigation
```

## Bugfix Branches

Bugfix branches address specific issues:

```
bugfix/login-redirect-loop
bugfix/memory-leak-in-worker
bugfix/null-pointer-user-avatar
```

Including the bug identifier or ticket number helps with tracking:

```
bugfix/JIRA-1234-payment-failure
bugfix/GH-567-fix-sidebar-overflow
```

## Hotfix Branches

Hotfix branches address production issues requiring immediate attention:

```
hotfix/critical-security-patch
hotfix/database-connection-timeout
hotfix/production-crash-on-startup
```

Hotfixes should almost always branch from `main` (or whatever your production branch is called), not from `develop`. When you tell Claude Code you are on a hotfix branch, it will understand the urgency and avoid suggesting non-essential changes that would bloat the diff.

## Refactor Branches

Refactor branches handle code improvements without behavior changes:

```
refactor/extract-user-service
refactor/move-to-functional-components
refactor/rename-database-tables
```

The superMemory skill can help you track refactoring context across sessions:

```
refactor/superMemory-user-context-cleanup
refactor/superMemory-reduce-token-usage
```

## Release Branches

If your team uses Gitflow or a variation of it, release branches follow a versioning pattern:

```
release/1.4.0
release/2025-q2
release/v2-beta
```

Release branches are typically cut from `develop` and merged into both `main` and back into `develop` once finalized. Claude Code recognizes the `release/` prefix and understands you are likely doing stabilization work rather than adding features.

## Documentation and Test Branches

Two additional prefixes that are often overlooked but worth standardizing:

```
docs/update-api-reference
docs/add-setup-guide
test/add-cart-unit-tests
test/integration-payment-flow
```

Separating documentation work and test additions from feature work makes your git log much cleaner. It also helps when doing code reviews, a reviewer knows at a glance that a `docs/` branch should not contain application logic changes.

## Practical Naming Patterns

Beyond prefixes, certain patterns make branches more useful:

## Include Ticket Numbers

When working with project management tools, include identifiers:

```
feature/PROJ-123-user-settings-page
bugfix/PROJ-456-cart-calculation-error
```

Claude Code can reference these numbers when discussing your work. This also makes it easy to trace a branch back to its origin ticket without opening the project management tool. Many git hooks and CI/CD pipelines also use ticket numbers for automatic linking, so including them is worth the extra characters.

For GitHub Issues, a common pattern is:

```
bugfix/GH-89-fix-null-avatar
feature/GH-102-dark-mode-support
```

## Use Hyphenated Lowercase

Stick to lowercase letters, numbers, and hyphens:

```
feature/add-user-avatar-upload
bugfix/fix-api-timeout-handling
```

Avoid: camelCase, spaces, underscores, or special characters. Some operating systems and tools handle mixed-case branch names inconsistently, and underscores are harder to double-click to select in terminals. Hyphens are universally safe.

## Keep It Descriptive but Concise

Aim for clarity without verbosity:

```
feature/user-profile-edit # Good
feature/add-ability-to-edit-user # Too verbose
feature/user-edit # is too vague
```

A good heuristic: if a new team member read the branch name in isolation, would they know roughly what this branch does? If yes, the name is good enough.

## Use Verb-Noun or Noun-Only Formats

```
feature/add-search # Verb-noun
feature/search-functionality # Noun-only
bugfix/login-fix # Noun-only (avoid, be specific)
bugfix/login-redirect-error # More specific
```

Verb-noun tends to work better for features (`add-`, `implement-`, `build-`) while noun-only or adjective-noun works better for bugfixes and refactors (`memory-leak`, `broken-redirect`, `slow-query`).

## Branch Naming with Claude Code Skills

Several Claude skills integrate well with branch-based workflows:

## The tdd Skill

When using test-driven development, create branches that signal TDD intent:

```
feature/tdd-shopping-cart-calculation
feature/tdd-api-validation-rules
```

This helps you maintain a test-first mindset throughout development. When you open Claude Code on a `tdd/` or `feature/tdd-*` branch, it is a useful cue to yourself (and any collaborators) that tests should be written before implementation code in that branch.

## The pdf Skill

For documentation branches:

```
docs/api-reference-update
docs/user-guide-payment-section
```

The pdf skill can generate documentation from your markdown files, making docs branches particularly useful.

## The git Skill

The git skill understands branch operations natively. A well-named branch makes commands like `git switch` and `git merge` more intuitive:

```bash
git switch -c feature/new-checkout-flow
git merge main feature/new-checkout-flow
```

When the git skill creates branches for you based on a task description, it will use the prefixes you have established in your project. If you consistently use `bugfix/` in your repository, the skill will pick that up from context and follow the same pattern.

## Team Conventions and Enforcement

Naming conventions only work when the whole team follows them. The most effective approach is to document the convention once and enforce it automatically.

## Git Hooks for Branch Name Validation

You can add a `pre-push` or `commit-msg` hook that rejects branches not matching your pattern. Here is a simple `pre-push` hook:

```bash
#!/usr/bin/env bash
.git/hooks/pre-push

BRANCH=$(git rev-parse --abbrev-ref HEAD)
VALID_PATTERN='^(feature|bugfix|hotfix|refactor|docs|test|experiment|release)/.+'

if ! echo "$BRANCH" | grep -qE "$VALID_PATTERN"; then
 echo "ERROR: Branch name '$BRANCH' does not follow naming convention."
 echo "Use format: type/short-description (e.g., feature/add-user-settings)"
 exit 1
fi
```

Make it executable:

```bash
chmod +x .git/hooks/pre-push
```

For teams, distribute hooks via a `scripts/` directory and reference them in your onboarding docs, or use a tool like `husky` to manage hooks in your package.json.

## GitHub Branch Protection Rules

GitHub lets you restrict branch creation to patterns matching a regex. Under repository Settings → Branches → Branch protection rules, you can require that any branch merging into `main` or `develop` starts with an allowed prefix. This is a harder guardrail than hooks because it is enforced server-side regardless of local configuration.

## Example Workflow

Here is a practical workflow demonstrating branch naming with Claude Code:

1. Start a feature branch:
 ```bash
 git checkout -b feature/user-notification-settings
 ```

2. Describe your task to Claude Code:
 ```
 I'm working on the user-notification-settings feature. Need to add email and SMS preferences.
 ```

3. Claude Code understands the context and assists:
 It recognizes the branch purpose and can suggest relevant files, tests, and implementation patterns.

4. Create sub-branches for related work:
 ```bash
 feature/user-notification-settings
 feature/user-notification-settings-email
 feature/user-notification-settings-sms
 test/user-notification-settings-validation
 ```

5. Merge when ready:
 ```bash
 git checkout main
 git merge feature/user-notification-settings
 ```

This sub-branch pattern is particularly useful for larger features where you want to review email and SMS changes independently before merging the complete feature. It also makes it easier to abandon one sub-feature without losing the other.

## Branch Naming Across Different Git Workflows

Different branching strategies impose different conventions:

| Workflow | Core Branches | Feature Convention |
|---|---|---|
| Gitflow | `main`, `develop`, `release/*`, `hotfix/*` | `feature/*` off `develop` |
| GitHub Flow | `main` only | Any descriptive branch name |
| Trunk-based | `main` only | Short-lived `feature/*` merged within a day |
| GitLab Flow | `main`, environment branches | `feature/*`, `fix/*` |

If your team uses Gitflow, your branch names already carry structural meaning because the workflow requires specific prefixes. If your team uses GitHub Flow (simpler, just `main` plus short-lived branches), the conventions in this guide are entirely up to you to define, which makes standardization even more important.

## Common Mistakes to Avoid

- Using dates in branch names: `feature/2024-01-15-user-settings` becomes meaningless quickly
- Vague names: `feature/stuff`, `fix/something`, `update`
- Mixed conventions: Some `feature/`, some `feat/`, some `new-`
- Too many levels: `feature/team/project/feature-name` adds complexity without benefit
- Personal identifiers: `feature/mike-user-settings` works better as `feature/user-settings`
- Encoding who owns it: Branches belong to the team, not to an individual. If Mike leaves the company, his branches become orphans no one wants to touch
- Reusing old branch names: After merging and deleting `feature/search`, do not reuse the name later. Create `feature/search-v2` or something distinct to avoid confusion in the git log

## Quick Reference

```
feature/ New functionality
bugfix/ Bug corrections
hotfix/ Production emergencies
refactor/ Code improvements
docs/ Documentation only
test/ Test additions or fixes
release/ Release stabilization
experiment/ Exploratory work
```

Consistent branch naming is one of the simplest ways to improve your development workflow. When combined with Claude Code's context understanding, well-structured branches become a powerful tool for maintaining clarity across your project. The investment is small, agreeing on a prefix set takes one team meeting, but the returns compound over time as your repository history becomes a readable record of the work done rather than a list of cryptic identifiers.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-git-branch-naming-conventions)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Git Workflow Best Practices Guide](/claude-code-git-workflow-best-practices-guide/). Branch naming is a core git best practice
- [Claude Code Gitflow Workflow Automation Guide](/claude-code-gitflow-workflow-automation-guide/). Gitflow defines specific branch naming rules
- [Claude Skills Workflows Hub](/workflows/). Git and workflow automation guides

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Branch Protection Bypass Attempt Fix](/claude-code-branch-protection-bypass-attempt-fix-2026/)
- [Git Credentials Expired Mid-Session Fix](/claude-code-git-credentials-expired-mid-session-fix-2026/)
- [Pre-commit Hook Failed in Claude Code — Fix (2026)](/claude-code-git-hook-blocked-commit-fix-2026/)
