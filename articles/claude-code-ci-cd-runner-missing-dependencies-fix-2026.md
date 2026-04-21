---
title: "CI/CD Runner Missing Dependencies Fix"
permalink: /claude-code-ci-cd-runner-missing-dependencies-fix-2026/
description: "Fix CI/CD runner missing dependencies for Claude Code. Add Node.js setup, Claude Code install, and API key to your GitHub Actions or CI pipeline config."
last_tested: "2026-04-22"
render_with_liquid: false
---
{% raw %}


## The Error

```
Run: claude --print "Review this PR"
/bin/bash: claude: command not found
  Error: Claude Code not installed on CI runner
  Missing: Node.js 18+, @anthropic-ai/claude-code, ANTHROPIC_API_KEY
  GitHub Actions runner: ubuntu-latest (no Claude Code pre-installed)
```

This appears when a CI/CD pipeline tries to use Claude Code but the runner does not have it installed or configured.

## The Fix

```yaml
# .github/workflows/claude-review.yml
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm install -g @anthropic-ai/claude-code
      - run: claude --print "Review the changes in this PR"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

1. Add Node.js setup and Claude Code installation steps to your CI workflow.
2. Store `ANTHROPIC_API_KEY` as a repository secret.
3. Use `claude --print` for non-interactive CI usage.

## Why This Happens

CI/CD runners start with a clean environment on each run. Unlike your local development machine, the runner does not have Claude Code globally installed. GitHub Actions runners include Node.js but not npm global packages. The API key is also not available unless explicitly configured as a secret. Each CI run is a fresh environment that needs full setup.

## If That Doesn't Work

Cache the npm global installation for faster runs:

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-claude-code
- run: npm install -g @anthropic-ai/claude-code
```

For GitLab CI:

```yaml
claude-review:
  image: node:20
  script:
    - npm install -g @anthropic-ai/claude-code
    - claude --print "Review changes"
  variables:
    ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY
```

Use the official Claude Code GitHub Action if available:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: "Review this PR"
```

## Prevention

```markdown
# CLAUDE.md rule
CI pipelines must install Claude Code explicitly. Add ANTHROPIC_API_KEY to CI secrets. Use --print flag for non-interactive CI usage. Cache npm global installs for faster CI runs.
```
{% endraw %}
