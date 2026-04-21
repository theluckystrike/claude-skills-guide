---
title: "Claude Code GitHub Actions Secret Missing in Fork — Fix (2026)"
description: "Fix Claude Code GitHub Actions secret not available in forked PRs. Use pull_request_target trigger safely. Step-by-step solution."
permalink: /claude-code-github-actions-secret-not-available-forked-pr-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---
{% raw %}


## The Error

```
Error: ANTHROPIC_API_KEY is not set.
  Environment variable 'ANTHROPIC_API_KEY' is empty or undefined.

# In GitHub Actions logs:
Run claude -p "Review this PR"
  Error: Authentication required. Set ANTHROPIC_API_KEY environment variable.
  Process completed with exit code 1.

# The secret exists in repo settings but the workflow was triggered by a fork PR
```

## The Fix

1. **Use pull_request_target instead of pull_request for fork PRs**

```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review
on:
  pull_request_target:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
          # SECURITY: Only checkout the code, don't run untrusted scripts

      - name: Claude Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          npm install -g @anthropic-ai/claude-code
          claude -p "Review the changes in this PR" --trust --yes
```

2. **Add security controls to prevent secret exfiltration**

```yaml
      # Add this step BEFORE the Claude review step:
      - name: Validate PR safety
        run: |
          # Only review code changes, never run fork's CI scripts
          CHANGED=$(gh pr diff ${{ github.event.pull_request.number }} --name-only)
          if echo "$CHANGED" | grep -qE '(\.github/|Makefile|scripts/)'; then
            echo "::error::PR modifies CI files — manual review required"
            exit 1
          fi
        env:
          GH_TOKEN: ${{ github.token }}
```

3. **Verify the fix:**

```bash
# Test locally that the secret is accessible:
gh secret list --repo your-org/your-repo | grep ANTHROPIC
# Expected: ANTHROPIC_API_KEY  Updated 2026-XX-XX

# After pushing the workflow, create a test fork PR and check Actions output
gh run list --workflow=claude-review.yml
# Expected: Shows successful runs
```

## Why This Happens

GitHub Actions deliberately withholds repository secrets from workflows triggered by `pull_request` events from forks. This is a security measure — a malicious fork could modify the workflow to exfiltrate secrets. The `pull_request_target` trigger runs the workflow from the base branch (which you control) but has access to secrets. The trade-off is you must be careful not to execute untrusted code from the fork with access to those secrets.

## If That Doesn't Work

- **Alternative 1:** Use a GitHub App token instead of secrets — Apps can be scoped to specific permissions and repositories
- **Alternative 2:** Skip Claude Code for fork PRs entirely: `if: github.event.pull_request.head.repo.full_name == github.repository`
- **Check:** Verify the secret exists at the right scope: repo-level, org-level, or environment-level secrets have different access rules

## Prevention

Add to your `CLAUDE.md`:
```markdown
For CI workflows with Claude Code, use pull_request_target for fork PRs. Never run untrusted scripts from forks with secrets access. Add path-based safety checks before running Claude on fork contributions. Prefer GitHub App tokens over personal access tokens.
```

**Related articles:** [GitHub Actions Setup Guide](/claude-code-github-actions-setup-guide/), [GitHub Actions Step Failed](/claude-code-github-actions-skill-step-failed-debug/), [Troubleshooting Hub](/troubleshooting-hub/)
{% endraw %}
