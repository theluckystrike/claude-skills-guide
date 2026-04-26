---
layout: default
title: "Claude Code for GitLab CLI glab — Guide (2026)"
description: "Claude Code for GitLab CLI glab — Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-gitlab-cli-glab-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, gitlab-cli, workflow]
---

## The Setup

You are using glab, the official GitLab CLI, for managing merge requests, issues, CI/CD pipelines, and repositories from the terminal. glab mirrors GitHub CLI's workflow but for GitLab, supporting both GitLab.com and self-hosted instances. Claude Code can automate Git workflows, but it defaults to `gh` (GitHub CLI) commands that do not work with GitLab.

## What Claude Code Gets Wrong By Default

1. **Uses `gh` commands instead of `glab`.** Claude writes `gh pr create` and `gh issue list`. GitLab uses merge requests, not pull requests, and the command is `glab mr create` and `glab issue list`.

2. **References GitHub-specific features.** Claude mentions GitHub Actions, GitHub Pages, and Dependabot. GitLab equivalents are GitLab CI/CD (`.gitlab-ci.yml`), GitLab Pages, and Dependency Scanning — different configuration and commands.

3. **Uses GitHub API endpoints.** Claude calls `api.github.com` for automation. glab has its own API command: `glab api` that hits your GitLab instance's API with proper authentication.

4. **Creates `.github/` directory structure.** Claude puts workflows in `.github/workflows/`. GitLab CI configuration goes in `.gitlab-ci.yml` at the project root — there is no `.github/` directory.

## The CLAUDE.md Configuration

```
# GitLab CLI (glab) Project

## Platform
- VCS: GitLab (self-hosted or GitLab.com)
- CLI: glab (official GitLab CLI)
- CI/CD: .gitlab-ci.yml
- Merge Requests: glab mr (not gh pr)

## glab Rules
- Merge requests: glab mr create, glab mr list, glab mr merge
- Issues: glab issue create, glab issue list
- CI/CD: glab ci view, glab ci status
- Pipelines: glab ci list, glab ci retry
- API: glab api /projects/:id/... for custom operations
- Auth: glab auth login for token management

## Conventions
- Use glab for all GitLab operations, never gh
- Merge request titles: conventional commits format
- CI config: .gitlab-ci.yml at project root
- Use glab mr create -f for draft merge requests
- Pipeline status: glab ci status before merging
- Labels: glab mr update --label "review"
- Self-hosted: glab config set -g host gitlab.company.com
```

## Workflow Example

You want to create a merge request with CI pipeline check from the terminal. Prompt Claude Code:

"Create a merge request for the current branch targeting main, with a description summarizing the recent commits. Wait for the CI pipeline to pass, then merge it automatically. Use glab commands."

Claude Code should run `glab mr create --target-branch main --fill` to create the MR with auto-filled description from commits, then `glab ci status --wait` to wait for the pipeline, and finally `glab mr merge --when-pipeline-succeeds` to auto-merge when CI passes.

## Common Pitfalls

1. **Self-hosted GitLab not configured.** Claude uses glab commands but they hit GitLab.com instead of your self-hosted instance. Run `glab auth login --hostname gitlab.company.com` to configure authentication for your instance.

2. **Missing CI pipeline check before merge.** Claude merges immediately with `glab mr merge`. Always check pipeline status first with `glab ci status` — merging with a failed pipeline can break the main branch.

3. **PR terminology in descriptions.** Claude writes "this PR" in merge request descriptions. GitLab uses "merge request" or "MR" terminology — using "PR" indicates the description was not written for GitLab.

## Related Guides

- [Claude Code for GitHub CLI Workflow Guide](/claude-code-for-github-cli-workflow-guide/)
- [Claude Code Git Workflow Best Practices Guide](/claude-code-git-workflow-best-practices-guide/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)

## Related Articles

- [Claude Code Sre On Call Incident — Complete Developer Guide](/claude-code-sre-on-call-incident-response-workflow-guide/)
- [Claude Code For Cloudwatch Rum — Complete Developer Guide](/claude-code-for-cloudwatch-rum-workflow/)
- [Claude Code for Aave Flash Loan Workflow](/claude-code-for-aave-flash-loan-workflow/)
- [Claude Code for Find References Workflow Tutorial](/claude-code-for-find-references-workflow-tutorial/)
- [How Claude Code Changed My — Complete Developer Guide](/how-claude-code-changed-my-development-workflow/)
- [Claude Code for README Generation Workflow Tutorial](/claude-code-for-readme-generation-workflow-tutorial/)
- [Claude Code for Echidna Fuzzing Workflow](/claude-code-for-echidna-fuzzing-workflow/)
- [Claude Code for Metacontroller Workflow Guide](/claude-code-for-metacontroller-workflow-guide/)


## Common Questions

### How do I get started with claude code for gitlab cli glab -?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Building A CLI Devtool With Claude Code](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code API Client TypeScript Guide](/claude-code-api-client-typescript-guide/)
