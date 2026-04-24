---
title: "Claude Code GitHub Actions Secret (2026)"
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

## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Claude Code Secret Scanning](/claude-code-secret-scanning-prevent-credential-leaks-guide/)
- [Claude Code for Gitleaks Secret](/claude-code-for-gitleaks-secret-scanning-workflow/)
- [Claude Code GitHub Discussions](/claude-code-github-discussions-summarizer-workflow/)
- [Claude Code + GitHub Models for Cost](/claude-code-with-github-models-for-cost-efficient-pipelines/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>

{% endraw %}
