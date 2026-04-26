---
layout: default
title: "Claude Code in CI/CD: Permission Configuration (2026)"
description: "Configure Claude Code permissions for CI/CD pipelines: GitHub Actions setup, --allowedTools vs YOLO mode, sandbox strategies, and production-safe workflow YAML."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-ci-cd-permission-configuration-guide/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, permissions, ci-cd, github-actions]
---

# Claude Code in CI/CD: Permission Configuration

Running Claude Code in CI/CD pipelines requires a different permission strategy than local development. There is no developer to click "Allow" -- the agent runs unattended. But granting full access with `--dangerously-skip-permissions` turns your CI pipeline into an attack surface. The right approach is `--allowedTools` with a scoped tool list. Use the [Permissions Configurator](/permissions/) to generate CI-specific permission sets for your pipeline.

## The CI Permission Problem

CI/CD pipelines are unattended by definition. Claude Code's default mode (prompt for every tool call) is impossible in CI -- there is no human to approve. You have two options:

```bash
# Option A: Skip all permissions (risky)
claude --dangerously-skip-permissions "Review this PR"

# Option B: Allowlist specific tools (recommended)
claude --allowedTools "Read,Glob,Grep" "Review this PR"
```

Option A lets Claude Code run any command, edit any file, and make network requests. In a CI environment with access to secrets, deployment credentials, and production databases, this is a significant risk.

Option B restricts Claude Code to only the tools you name. It can read files and search code, but nothing else.

## GitHub Actions: Complete Setup

Here is a production-ready GitHub Actions workflow:

```yaml
name: Claude Code PR Review
on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  claude-review:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for diff context

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Run Claude Code Review
        run: |
          # Get the diff for context
          DIFF=$(git diff origin/main...HEAD)

          claude --print \
            --allowedTools "Read,Glob,Grep,Bash(npm test),Bash(npm run lint)" \
            --output-format json \
            "Review the following code changes for bugs, security
             issues, and test coverage gaps. Run tests and lint.

             Changes:
             $DIFF" > review-output.json
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: Post Review Comment
        if: always()
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const output = fs.readFileSync('review-output.json', 'utf8');
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## Claude Code Review\n\n${output}`
            });
```

### Key Security Decisions in This Workflow

1. **`--allowedTools` restricts capabilities**: Claude Code can read code, search files, run tests, and run lint -- nothing else. No file edits, no git operations, no network requests.

2. **`timeout-minutes: 10`**: Prevents runaway sessions from consuming unlimited CI minutes and API tokens.

3. **`permissions: contents: read`**: The GitHub token has read-only access to the repository. Even if Claude Code tried to push, it would fail.

4. **Separate API key**: Use a dedicated `ANTHROPIC_API_KEY` for CI with its own spend limits in the Anthropic console.

## Tool Allowlists by CI Task

Different CI tasks need different tool sets:

```bash
# Code review (read-only analysis)
--allowedTools "Read,Glob,Grep"

# Review with test execution
--allowedTools "Read,Glob,Grep,Bash(npm test),Bash(npm run lint)"

# Review with type checking
--allowedTools "Read,Glob,Grep,Bash(npx tsc --noEmit)"

# Automated bug fixes (careful -- edits code)
--allowedTools "Read,Glob,Grep,Edit,Bash(npm test)"

# Documentation generation
--allowedTools "Read,Glob,Grep,Write"

# Full test suite with coverage
--allowedTools "Read,Glob,Grep,Bash(npm test -- --coverage)"
```

## Safer Alternative to YOLO

If you need Claude Code to edit files in CI (e.g., automated formatting or fix generation), use `--allowedTools` with Edit instead of YOLO:

```yaml
# Automated formatting (instead of YOLO mode)
- name: Auto-format with Claude
  run: |
    claude --print \
      --allowedTools "Read,Glob,Grep,Edit,Bash(npm run format),Bash(npm run lint:fix)" \
      "Fix all formatting issues in the changed files.
       Run format and lint:fix after making changes."

    # Commit any changes
    git config user.name "claude-code[bot]"
    git config user.email "claude-code[bot]@users.noreply.github.com"
    git add -A
    git diff --staged --quiet || git commit -m "style: auto-format"
    git push
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

This gives Claude Code the ability to edit files and run formatters, but it cannot run arbitrary commands, install packages, or access the network.

## Environment Variable Handling

Never expose sensitive environment variables to Claude Code in CI:

```yaml
# BAD: All secrets available
- name: Run Claude
  run: claude --dangerously-skip-permissions "Deploy to production"
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    # Claude Code could read these via Bash(env) or Bash(echo $DATABASE_URL)

# GOOD: Only the API key
- name: Run Claude
  run: |
    claude --print \
      --allowedTools "Read,Glob,Grep" \
      "Review this code"
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    # No other secrets exposed
```

## Sandbox Strategies

For maximum isolation, run Claude Code inside a container with restricted access:

```yaml
# Docker-based sandbox
- name: Run Claude in Sandbox
  run: |
    docker run --rm \
      --read-only \
      --network=none \
      --memory=2g \
      --cpus=1 \
      -v $(pwd):/workspace:ro \
      -e ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY }} \
      node:20-slim \
      bash -c "
        npm install -g @anthropic-ai/claude-code &&
        cd /workspace &&
        claude --print --allowedTools 'Read,Glob,Grep' \
          'Review the code for security issues'
      "
```

This sandbox provides: read-only filesystem, no network (except Anthropic API), memory limits, and CPU limits.

## Try It Yourself

The [Permissions Configurator](/permissions/) includes a CI/CD mode. Select your CI platform (GitHub Actions, GitLab CI, CircleCI), pipeline task type, and security requirements. It generates a complete workflow file with the right `--allowedTools` configuration and security settings.

## Frequently Asked Questions

<details>
<summary>Can I use --allowedTools and --dangerously-skip-permissions together?</summary>
No, they are mutually exclusive. --dangerously-skip-permissions overrides all permission checks including --allowedTools. If you use both flags, the skip flag wins and all tools are available. Always use --allowedTools alone for CI pipelines. Configure the exact tool set in the <a href="/permissions/">Permissions Configurator</a>.
</details>

<details>
<summary>How do I set API spend limits for CI?</summary>
Create a separate API key for CI in the Anthropic console (console.anthropic.com/settings/keys). Set a per-key monthly spend limit appropriate for your CI volume. A typical code review pipeline uses 20,000-50,000 tokens per PR, so a $50/month limit covers hundreds of reviews on Sonnet. See the <a href="/commands/">Commands Reference</a> for output format options that help track CI token usage.
</details>

<details>
<summary>Does Claude Code support GitLab CI and other platforms?</summary>
Yes. Claude Code is a CLI tool that runs anywhere Node.js is available. The --allowedTools and --print flags work identically across GitHub Actions, GitLab CI, CircleCI, Jenkins, and any other CI platform. Adapt the YAML syntax for your platform. Check <a href="/configuration/">Configuration</a> for platform-specific tips.
</details>

<details>
<summary>What if Claude Code needs to install dependencies to run tests?</summary>
Add the install command to your allowedTools list: --allowedTools "Read,Glob,Grep,Bash(npm ci),Bash(npm test)". Use npm ci instead of npm install for deterministic installs. Or run npm ci as a separate step before invoking Claude Code so it does not need the permission. See <a href="/best-practices/">Best Practices</a> for CI setup.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I use --allowedTools and --dangerously-skip-permissions together in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, they are mutually exclusive. --dangerously-skip-permissions overrides all permission checks including --allowedTools. Always use --allowedTools alone for CI pipelines."
      }
    },
    {
      "@type": "Question",
      "name": "How do I set API spend limits for Claude Code in CI?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Create a separate API key for CI in the Anthropic console and set a per-key monthly spend limit. A typical code review pipeline uses 20,000-50,000 tokens per PR, so $50/month covers hundreds of reviews on Sonnet."
      }
    },
    {
      "@type": "Question",
      "name": "Does Claude Code support GitLab CI and other platforms?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code runs anywhere Node.js is available. The --allowedTools and --print flags work identically across GitHub Actions, GitLab CI, CircleCI, Jenkins, and any other CI platform."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code needs to install dependencies to run tests in CI?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add the install command to your allowedTools list or run npm ci as a separate step before invoking Claude Code so it does not need the permission."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Permissions Configurator](/permissions/) -- Generate CI-specific permission configs
- [Commands Reference](/commands/) -- CLI flags for --allowedTools and --print
- [Configuration Guide](/configuration/) -- settings.json for CI environments
- [Best Practices](/best-practices/) -- Security guidelines for automated pipelines
- [Advanced Usage](/advanced-usage/) -- Advanced CI/CD patterns with Claude Code
