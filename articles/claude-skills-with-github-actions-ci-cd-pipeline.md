---
layout: default
title: "Claude Skills with GitHub Actions CI/CD Pipeline"
description: "Learn how to integrate Claude skills into your GitHub Actions CI/CD pipeline to automate code review, testing, and deployment workflows for developer teams."
date: 2026-03-13
author: theluckystrike
---

# Claude Skills with GitHub Actions CI/CD Pipeline

Integrating Claude skills with a GitHub Actions CI/CD pipeline gives development teams an automated assistant that participates directly in their build, test, and deployment workflows. This guide walks through practical patterns for wiring Claude Code skills into your existing pipelines — from triggering AI-powered code review on pull requests to running TDD-focused checks before merges.

## Why Combine Claude Skills with GitHub Actions

GitHub Actions handles orchestration. Claude handles intelligence. Together they let you run contextual, AI-powered steps at any point in your delivery pipeline without maintaining a separate AI service or polling loop.

Common use cases include:

- Automated code review comments on PRs using the `tdd` skill
- PDF report generation from test results using the `pdf` skill
- Accessibility and design checks on front-end PRs using `frontend-design`
- Persistent context across runs using `supermemory` to track regressions

## Prerequisites

- A GitHub repository with Actions enabled
- Claude API key (store as `CLAUDE_API_KEY` in repo secrets)
- Node.js 20+ in your runner environment
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)

## Step 1: Store Your API Key

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

```
CLAUDE_API_KEY=your_api_key_here
```

Never hardcode credentials in your workflow files.

## Step 2: Create the Workflow File

Create `.github/workflows/claude-review.yml`:

```yaml
name: Claude AI Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  claude-review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Claude Code CLI
        run: npm install -g @anthropic-ai/claude-code

      - name: Run Claude TDD skill on changed files
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
        run: |
          git diff origin/main...HEAD --name-only --diff-filter=AM | \
            grep -E '\.(ts|js|py)$' | \
            xargs -I {} claude --skill tdd --prompt "Review this file for test coverage gaps and suggest missing unit tests" {}

      - name: Generate review summary
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
        run: |
          git diff origin/main...HEAD > /tmp/pr_diff.txt
          claude --skill tdd \
            --prompt "Summarize this diff. Identify: 1) untested code paths, 2) potential regressions, 3) missing error handling" \
            /tmp/pr_diff.txt > /tmp/review_summary.md

      - name: Post review comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync('/tmp/review_summary.md', 'utf8');
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Claude AI Review\n\n${summary}`
            });
```

## Step 3: Add a Deployment Gate

Use Claude to validate infrastructure changes before deployment. Add this job after your test suite passes:

```yaml
  claude-infra-check:
    runs-on: ubuntu-latest
    needs: [test]
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Install Claude Code CLI
        run: npm install -g @anthropic-ai/claude-code

      - name: Validate IaC changes
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
        run: |
          git diff HEAD~1 -- '*.tf' '*.yaml' 'docker-compose*' > /tmp/infra_diff.txt
          if [ -s /tmp/infra_diff.txt ]; then
            claude --prompt "Review this infrastructure diff for security misconfigurations, overly permissive IAM policies, or exposed ports. Output PASS or FAIL with reasoning." \
              /tmp/infra_diff.txt | tee /tmp/infra_result.txt
            grep -q "^PASS" /tmp/infra_result.txt || exit 1
          fi
```

## Step 4: Using Supermemory for Context Persistence

The `supermemory` skill lets Claude retain context across pipeline runs — useful for tracking flaky tests, recurring review feedback, or build patterns over time.

```yaml
      - name: Check regression patterns with supermemory
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
          SUPERMEMORY_API_KEY: ${{ secrets.SUPERMEMORY_API_KEY }}
        run: |
          claude --skill supermemory \
            --prompt "Has this component had test failures in the last 5 runs? Current test output:" \
            /tmp/test_output.txt
```

## Step 5: Generate PDF Reports for Stakeholders

After a successful release, use the `pdf` skill to package a human-readable summary:

```yaml
      - name: Generate release PDF
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
        run: |
          claude --skill pdf \
            --prompt "Generate a release notes document from this changelog and test summary" \
            CHANGELOG.md /tmp/test_summary.txt \
            --output release-notes-${{ github.run_number }}.pdf

      - name: Upload release PDF
        uses: actions/upload-artifact@v4
        with:
          name: release-notes
          path: release-notes-*.pdf
```

## Caching Claude CLI Between Runs

Installing the CLI on every run adds latency. Cache it with:

```yaml
      - name: Cache Claude CLI
        uses: actions/cache@v4
        with:
          path: ~/.npm-global
          key: claude-cli-${{ runner.os }}-v1
```

## Handling Rate Limits

Claude API calls in CI can hit rate limits if many PRs open simultaneously. Implement a simple retry wrapper:

```bash
#!/bin/bash
# scripts/claude-with-retry.sh
MAX_RETRIES=3
COUNT=0
until claude "$@" || [ $COUNT -eq $MAX_RETRIES ]; do
  COUNT=$((COUNT + 1))
  echo "Retry $COUNT/$MAX_RETRIES after rate limit..."
  sleep $((COUNT * 10))
done
```

Then call `./scripts/claude-with-retry.sh --skill tdd ...` in your workflow steps.

## Security Considerations

- Always use `CLAUDE_API_KEY` from GitHub Secrets, never from environment variables committed to the repo
- Set `permissions` on jobs to the minimum required (prefer `pull-requests: write` over `write-all`)
- Review AI-generated comments before enabling auto-merge gates on them
- Use branch protection rules to require the `claude-review` job to pass before merging

## Conclusion

Wiring Claude skills with GitHub Actions CI/CD pipeline bridges the gap between automated testing and intelligent code analysis. By combining skills like `tdd`, `supermemory`, and `pdf` at specific pipeline stages, you get context-aware AI participation without building a separate service. Start with the PR review workflow and expand to deployment gates once you trust the output quality.

---

## Related Reading

- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/articles/best-claude-skills-for-devops-and-deployment/) — A curated list of skills that integrate with CI/CD workflows, infrastructure tooling, and deployment automation
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Covers the full spectrum of developer skills including tdd, supermemory, and code review automation
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — How to structure CI/CD skill invocations to minimize API spend while keeping pipeline coverage thorough

Built by theluckystrike — More at [zovo.one](https://zovo.one)
