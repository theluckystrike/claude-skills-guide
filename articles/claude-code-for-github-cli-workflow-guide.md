---
layout: default
title: "Claude Code for GitHub CLI (2026)"
description: "Claude Code for GitHub CLI — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-github-cli-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, github-cli, workflow]
---

## The Setup

You are using the GitHub CLI (`gh`) to manage pull requests, issues, releases, and workflows directly from the terminal. When paired with Claude Code, `gh` enables powerful automation — creating PRs with AI-generated descriptions, managing issue triage, and triggering workflows. Claude Code can write `gh` commands, but it defaults to the GitHub REST API with curl or Octokit instead.

## What Claude Code Gets Wrong By Default

1. **Uses curl with the GitHub API.** Claude writes `curl -H "Authorization: Bearer $TOKEN" https://api.github.com/...`. The `gh` CLI handles authentication automatically and provides simpler commands: `gh pr list`, `gh issue create`.

2. **Installs Octokit for GitHub automation.** Claude adds `@octokit/rest` as a dependency for GitHub operations. For CLI automation, `gh api` provides the same access without code dependencies.

3. **Opens the browser for PR creation.** Claude says "go to github.com to create a PR." With `gh pr create`, you can create PRs entirely from the terminal, including title, body, reviewers, and labels.

4. **Ignores `gh api` for custom queries.** Claude writes raw HTTP requests for GitHub API endpoints. Use `gh api repos/{owner}/{repo}/pulls --jq '.[] | .title'` for authenticated API access with built-in JSON processing.

## The CLAUDE.md Configuration

```
# GitHub CLI Workflow

## Tool
- CLI: gh (GitHub CLI, authenticated)
- Auth: gh auth login (automatic token management)
- API: gh api for any GitHub REST/GraphQL endpoint

## GitHub CLI Rules
- PRs: gh pr create, gh pr list, gh pr merge, gh pr review
- Issues: gh issue create, gh issue list, gh issue close
- Releases: gh release create v1.0.0 --generate-notes
- Workflows: gh workflow run, gh run list, gh run watch
- API: gh api endpoint --jq 'filter' for custom queries
- Auth: handled automatically, no manual token management
- JSON output: --json fields for machine-readable output

## Conventions
- Use gh for all GitHub operations (not browser or curl)
- PR descriptions in markdown with ## sections
- Labels set with --label flag on create commands
- Reviewers assigned with --reviewer flag
- Use gh pr checks to verify CI before merge
- gh run watch for monitoring workflow execution
- Template PRs with --body-file for consistent formatting
```

## Workflow Example

You want to create a PR with AI-generated description from Claude Code changes. Prompt Claude Code:

"Create a pull request for the current branch with a summary of all changes. Add the 'enhancement' label, request review from the team lead, and wait for CI checks to pass."

Claude Code should run `gh pr create --title "..." --body "..." --label enhancement --reviewer teamlead`, then `gh pr checks --watch` to monitor CI status, and report back when checks pass or fail.

## Common Pitfalls

1. **Not checking CI before merge.** Claude runs `gh pr merge` immediately after creation. Always run `gh pr checks` first to verify CI passes. Use `gh pr merge --auto` to auto-merge once checks pass.

2. **Missing `--jq` for API output parsing.** Claude pipes `gh api` output through `jq` as a separate command. The `gh api` command has built-in `--jq` support that is more convenient: `gh api repos/owner/repo/pulls --jq '.[].title'`.

3. **Draft PRs not marked correctly.** Claude creates PRs that are not ready for review without marking them as drafts. Use `gh pr create --draft` for work-in-progress PRs, then `gh pr ready` when the PR is ready for review.

## Related Guides

- [Claude Code Conventional Commits Enforcement Workflow](/claude-code-conventional-commits-enforcement-workflow/)
- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)
- [AI-Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)

## See Also

- [Claude Code for GitLab CLI glab — Guide](/claude-code-for-gitlab-cli-glab-workflow-guide/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\")."
      }
    }
  ]
}
</script>
