---
layout: default
title: "Claude Code CI/CD Integration Guide (2026)"
description: "Integrate Claude Code into CI/CD pipelines for automated code review, test generation, documentation, and quality gates using API mode."
permalink: /claude-code-ci-cd-integration-guide-2026/
date: 2026-04-20
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code CI/CD Integration Guide (2026)

Claude Code's API mode turns it into a pipeline step. It can review PRs, generate tests, update documentation, and enforce quality standards -- all without human interaction. This guide covers the patterns, configurations, and gotchas.

## Prerequisites

- Claude Code CLI installed in your CI runner
- `ANTHROPIC_API_KEY` stored as a CI secret
- Your repository has a CLAUDE.md with project rules

## Architecture

```
Developer pushes code
  -> CI pipeline triggers
    -> Claude Code API mode runs
      -> Reads changed files
      -> Performs task (review, test gen, doc gen)
      -> Outputs result
    -> Pipeline processes result
      -> Posts comment / creates file / gates merge
```

## Pattern 1: Automated PR Review

### GitHub Actions

{% raw %}
```yaml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Review changes
        run: |
          DIFF=$(git diff origin/main...HEAD)
          claude -p "Review these changes for security and quality issues. Be specific about file and line numbers. Output as markdown.

          $DIFF" \
            --allowedTools "Read" \
            --max-turns 20 \
            --output-format text > review.md
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: Comment on PR
        if: always()
        run: |
          if [ -s review.md ]; then
            gh pr comment ${{ github.event.pull_request.number }} --body-file review.md
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
{% endraw %}

### GitLab CI

```yaml
ai-review:
  stage: review
  script:
    - DIFF=$(git diff origin/main...HEAD)
    - |
      claude -p "Review these changes: $DIFF" \
        --allowedTools "Read" \
        --output-format text > review.md
    - cat review.md
  artifacts:
    paths:
      - review.md
  only:
    - merge_requests
```

## Pattern 2: Test Generation

Generate tests for new code automatically:

```yaml
- name: Generate missing tests
  run: |
    CHANGED=$(git diff --name-only origin/main...HEAD | grep '\.ts$' | grep -v '\.test\.')
    for file in $CHANGED; do
      TEST_FILE="${file%.ts}.test.ts"
      if [ ! -f "$TEST_FILE" ]; then
        claude -p "Generate Vitest tests for $file. Cover happy path, edge cases, and error conditions. Follow the testing patterns in our CLAUDE.md." \
          --allowedTools "Read,Write" \
          --max-turns 15
      fi
    done
```

## Pattern 3: Documentation Generation

Auto-generate changelog entries:

```yaml
- name: Generate changelog
  run: |
    COMMITS=$(git log origin/main...HEAD --oneline)
    claude -p "Generate a changelog entry for these commits:
    $COMMITS
    Format: ## [Version] - Date
    ### Added / Changed / Fixed sections
    Output only the changelog markdown." \
      --allowedTools "Read" \
      --output-format text > CHANGELOG_ENTRY.md
```

## Pattern 4: Quality Gate

Block merges based on Claude Code analysis:

```yaml
- name: Quality gate
  run: |
    RESULT=$(claude -p "Analyze these changes for critical issues only: security vulnerabilities, data loss risks, or breaking API changes. Output JSON: {\"pass\": true/false, \"issues\": [...]}" \
      --allowedTools "Read" \
      --output-format text)

    PASS=$(echo "$RESULT" | jq -r '.pass')
    if [ "$PASS" != "true" ]; then
      echo "Quality gate FAILED"
      echo "$RESULT" | jq '.issues'
      exit 1
    fi
```

## Security in CI

### Restrict Tool Access

In CI, limit Claude Code's tools:

```bash
# Read-only review (safest)
claude -p "..." --allowedTools "Read"

# Read + write (for test/doc generation)
claude -p "..." --allowedTools "Read,Write"

# Never in CI:
# --allowedTools "Bash"  (can run arbitrary commands)
```

### Cost Control

Set max turns to prevent runaway sessions:

```bash
claude -p "..." --max-turns 20
```

For large PRs, this prevents Claude Code from reading every file in the repository.

### Secret Management

Never expose API keys in logs:

{% raw %}
```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```
{% endraw %}

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) covers CI security patterns in its threat model section.

## Cost Management in CI

Automated reviews run on every PR. Costs add up:

| PR Frequency | Cost Per Review | Monthly Cost |
|-------------|-----------------|--------------|
| 10 PRs/week | $0.20 | $8 |
| 50 PRs/week | $0.20 | $40 |
| 200 PRs/week | $0.20 | $160 |

### Cost Optimization
- Only run on PRs that modify source files (skip docs-only changes)
- Limit review scope to changed files, not the entire codebase
- Use `--max-turns` to cap token usage
- Skip review for PRs from bots (dependabot, renovate)

```yaml
on:
  pull_request:
    paths:
      - 'src/**'
      - '!**/*.md'
```

## Integration with Ecosystem Tools

### claude-task-master in CI

Use [claude-task-master](https://github.com/eyaltoledano/claude-task-master) (27K+ stars) to validate that PRs address specific tasks:

```bash
task-master verify --pr $PR_NUMBER
```

### ccusage for CI Cost Tracking

Track CI-specific Claude Code costs:

```bash
npx ccusage --project ci-reviews --format json >> ci-costs.json
```

### claude-code-templates for CI Agents

The [claude-code-templates](https://github.com/davila7/claude-code-templates) library includes CI-specific agent configurations:

```bash
npx claude-code-templates@latest
# Select: CI/CD > Code Review Agent
```

## Troubleshooting

### Review is empty or generic
- Check that CLAUDE.md exists and is read by the CI runner
- Verify the diff is passed correctly (check for quoting issues)
- Increase `--max-turns` if the review is truncated

### API rate limiting
- Add retry logic with exponential backoff
- Stagger CI jobs to avoid burst requests
- Use Anthropic's rate limit headers for adaptive throttling

### Cost spikes
- Check for large PRs triggering expensive reviews
- Add file-count or diff-size limits before running Claude Code
- Monitor with ccusage and set alerts

## FAQ

### Should every PR get an AI review?
Start with PRs to main/production branches. Expand to feature branches if the cost-benefit ratio is positive.

### Can Claude Code approve PRs?
Technically, yes (via GitHub API). Practically, keep AI reviews as comments, not approvals. Human approval should remain required.

### How do I handle false positives?
Track false positives and add exclusion rules to CLAUDE.md: "In our codebase, X pattern is intentional and not a security issue."

### Does CI review replace local review?
No. CI review catches what developers miss. Local slash command reviews (`/review`) catch issues before push. The two are complementary.

For API mode details, see the [API mode guide](/claude-code-api-mode-vs-interactive-2026/). For review automation patterns, read the [code review guide](/claude-code-code-review-automation-2026/). For security in automation, see the [threat model guide](/claude-code-security-threat-model-2026/).


## Related

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) and safer alternatives
- [CI/CD Runner Missing Dependencies Fix](/claude-code-ci-cd-runner-missing-dependencies-fix-2026/)
