---
layout: post
title: "How to Build Claude Code GitHub Actions (2026)"
description: "Automate PR reviews, code generation, and testing with Claude Code in GitHub Actions. YAML templates and secret management included."
permalink: /claude-code-github-actions-workflow-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---
{% raw %}

## The Workflow

Integrate Claude Code directly into GitHub Actions workflows for automated PR reviews, code generation, test writing, and documentation updates. This covers YAML configuration, secret management, and practical workflow templates you can copy into any repository.

Expected time: 20-30 minutes for initial setup
Prerequisites: GitHub repository with Actions enabled, Anthropic API key, basic YAML knowledge

## Setup

### 1. Add Secrets to Your Repository

```bash
# Using GitHub CLI
gh secret set ANTHROPIC_API_KEY --body "sk-ant-YOUR_KEY_HERE"
```

Navigate to Repository Settings > Secrets and variables > Actions to verify.

### 2. Create the Workflow Directory

```bash
mkdir -p .github/workflows
```

### 3. Verify GitHub Actions Access

```bash
gh workflow list
# Expected output:
# Lists any existing workflows (or empty if new repo)
```

## Usage Example

### Automated PR Review Workflow

```yaml
# .github/workflows/claude-pr-review.yml
name: Claude Code PR Review

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Get PR diff
        id: diff
        run: |
          gh pr diff ${{ github.event.number }} > /tmp/pr-diff.txt
          echo "lines=$(wc -l < /tmp/pr-diff.txt)" >> $GITHUB_OUTPUT
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Skip large PRs
        if: steps.diff.outputs.lines > 2000
        run: echo "PR too large for automated review (>2000 lines)"

      - name: Run Claude Review
        if: steps.diff.outputs.lines <= 2000
        run: |
          REVIEW=$(claude --print "Review this pull request diff for:
          1. Security vulnerabilities
          2. Performance issues
          3. Logic errors
          4. Missing error handling

          Be concise. Only report actual issues, not style preferences.
          Format each issue as: **[SEVERITY]** file:line - description

          Diff:
          $(cat /tmp/pr-diff.txt)")

          # Post review as PR comment
          gh pr comment ${{ github.event.number }} \
            --body "## Claude Code Review

          $REVIEW

          ---
          *Automated review by Claude Code*"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Auto-Generate Tests for New Code

```yaml
# .github/workflows/claude-test-generation.yml
name: Generate Missing Tests

on:
  pull_request:
    types: [opened]
    paths:
      - 'src/**/*.ts'
      - '!src/**/*.test.ts'

jobs:
  generate-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.head_ref }}
          token: ${{ secrets.GITHUB_TOKEN }}

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Find files without tests
        id: find
        run: |
          FILES=""
          for f in $(git diff --name-only origin/main...HEAD -- 'src/**/*.ts' | grep -v '.test.ts'); do
            TEST_FILE="${f%.ts}.test.ts"
            if [ ! -f "$TEST_FILE" ]; then
              FILES="$FILES $f"
            fi
          done
          echo "files=$FILES" >> $GITHUB_OUTPUT

      - name: Generate tests
        if: steps.find.outputs.files != ''
        run: |
          for file in ${{ steps.find.outputs.files }}; do
            TEST_FILE="${file%.ts}.test.ts"
            echo "Generating tests for: $file"

            claude --print "Read $file and generate a comprehensive test file.
            Use Vitest as the testing framework.
            Cover: happy path, edge cases, error conditions.
            Use describe/it blocks with clear test names.
            Mock external dependencies.
            Write to $TEST_FILE" > /dev/null
          done
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: Verify tests pass
        run: npx vitest run --reporter=verbose

      - name: Commit generated tests
        run: |
          git config user.name "claude-code[bot]"
          git config user.email "claude-code[bot]@users.noreply.github.com"
          git add '*.test.ts'
          git diff --staged --quiet || git commit -m "test: add generated tests for new source files"
          git push
```

### Documentation Sync Workflow

```yaml
# .github/workflows/claude-docs-sync.yml
name: Sync Documentation

on:
  push:
    branches: [main]
    paths:
      - 'src/api/**'

jobs:
  update-docs:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Update API docs
        run: |
          claude --print "Read all files in src/api/ and generate
          API documentation in docs/api.md format:
          - List every endpoint with method, path, description
          - Show request/response types
          - Include example curl commands
          Update docs/api.md with the result."
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: Commit docs
        run: |
          git config user.name "claude-code[bot]"
          git config user.email "claude-code[bot]@users.noreply.github.com"
          git add docs/
          git diff --staged --quiet || git commit -m "docs: auto-update API documentation"
          git push
```

### Secret Management Best Practices

```yaml
# Never expose the API key in logs
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

# Restrict permissions to minimum needed
permissions:
  contents: read        # Read repo files
  pull-requests: write  # Comment on PRs

# Set timeouts to prevent runaway costs
timeout-minutes: 10

# Use conditional execution to avoid unnecessary API calls
if: github.event.pull_request.draft == false
```

Cost control with token limits:

```yaml
- name: Run Claude with budget
  run: |
    # Limit input size to control costs
    DIFF=$(cat /tmp/pr-diff.txt | head -500)
    claude --print "Review (first 500 lines only): $DIFF"
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## Common Issues

- **Action fails with "ANTHROPIC_API_KEY not set":** Verify the secret name matches exactly. Check that the secret is set at the repository level (not environment level) unless you specify the environment in the job.
- **Review comments are too verbose:** Add "Be concise. Maximum 5 issues. Skip style nitpicks." to your prompt. Token costs scale with output length.
- **Workflow runs on every push:** Use path filters (`paths: ['src/**']`) and event type filters (`types: [opened]`) to limit triggers. Add `if: github.event.pull_request.draft == false` to skip draft PRs.

## Why This Matters

Automated Claude Code in CI catches issues within minutes of pushing code, before human reviewers spend time. Teams report 40% fewer review rounds after adding automated pre-review.

## Related Guides

- [Claude Code Skills for Creating GitHub Actions Workflows](/claude-code-skills-for-creating-github-actions-workflows/)
- [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-with-github-actions-ci-cd-pipeline/)
- [Claude Code Pull Request Review Skill Guide 2026](/claude-code-pull-request-review-skill-2026/)

## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


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
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>

{% endraw %}

## See Also

- [Claude Code GitHub Actions Secret Missing in Fork — Fix (2026)](/claude-code-github-actions-secret-not-available-forked-pr-fix/)
