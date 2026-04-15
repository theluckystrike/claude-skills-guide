---
layout: default
title: "Claude Code GitHub Actions Setup Guide"
description: "Set up Claude Code GitHub Actions for automated PR creation, code review, and issue implementation with @claude mentions."
date: 2026-04-15
permalink: /claude-code-github-actions-setup-guide/
categories: [guides, claude-code]
tags: [github-actions, CI-CD, automation, pull-requests]
---

# Claude Code GitHub Actions Setup Guide

## The Problem

You want Claude Code to automatically respond to GitHub issues, review pull requests, and implement features directly in your CI/CD pipeline, but you do not know how to set up the integration.

## Quick Fix

The fastest setup uses Claude Code's built-in installer. Open Claude Code and run:

```text
/install-github-app
```

This guides you through installing the GitHub app and configuring repository secrets.

## What's Happening

Claude Code GitHub Actions brings AI-powered automation to your GitHub workflow. When you mention `@claude` in any PR or issue comment, Claude analyzes your code, creates pull requests, implements features, and fixes bugs while following your project's CLAUDE.md standards.

The action is built on the Claude Agent SDK and runs on GitHub's runners, so your code stays within GitHub's infrastructure. It supports two modes: interactive mode (responds to `@claude` mentions) and automation mode (runs immediately with a prompt).

## Step-by-Step Fix

### Step 1: Install the GitHub app

You need repository admin access. Install the Claude GitHub app:

Visit [github.com/apps/claude](https://github.com/apps/claude) and install it to your repository.

The app requires these permissions:
- **Contents**: Read & write (to modify repository files)
- **Issues**: Read & write (to respond to issues)
- **Pull requests**: Read & write (to create PRs and push changes)

### Step 2: Add your API key

Add `ANTHROPIC_API_KEY` to your repository secrets:

1. Go to your repository Settings
2. Navigate to Secrets and Variables > Actions
3. Click "New repository secret"
4. Name: `ANTHROPIC_API_KEY`
5. Value: your Anthropic API key

### Step 3: Create the workflow file

Create `.github/workflows/claude.yml`:

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened]

jobs:
  claude:
    if: contains(github.event.comment.body, '@claude') || contains(github.event.issue.body, '@claude')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Step 4: Customize with claude_args

Pass additional configuration to Claude Code:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: |
      --append-system-prompt "Follow our coding standards"
      --max-turns 10
      --model claude-sonnet-4-6
```

### Step 5: Create automation workflows

For tasks that run automatically (not triggered by `@claude` mentions), use the `prompt` input:

```yaml
name: Auto Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: "Review this PR for security issues and code quality"
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Step 6: Use with Bedrock or Vertex AI

For AWS Bedrock:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    claude_args: --model bedrock:us.anthropic.claude-sonnet-4-6-20250514-v1:0
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_REGION: us-east-1
```

### Step 7: Test the integration

Create a test issue or PR comment with `@claude` followed by a task description:

```text
@claude Review this PR for potential security issues and suggest improvements
```

Claude will respond with its analysis directly in the GitHub conversation.

### Migrating from beta

If you are upgrading from the beta version:

| Old Beta Input | New v1.0 Input |
|---------------|---------------|
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |

## Prevention

Add a CLAUDE.md file to your repository with project-specific instructions. Claude Code GitHub Actions reads this file automatically, ensuring consistent behavior across all automated tasks.

Set reasonable `--max-turns` limits to control API costs per workflow run. Start with 10 turns and adjust based on your needs.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

**[Get Claude Code Mastery — included in Zovo Lifetime →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=article&utm_campaign=claude-code-github-actions-setup-guide)**

16 CLAUDE.md templates · 80+ prompts · orchestration configs · workflow playbooks. $99 once, free forever.

---

## Related Guides

- [Claude Code for ACT Local GitHub Actions Workflow](/claude-code-for-act-local-github-actions-workflow/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
