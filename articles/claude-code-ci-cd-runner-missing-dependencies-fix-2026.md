---
layout: default
title: "CI/CD Runner Missing Dependencies Fix (2026)"
permalink: /claude-code-ci-cd-runner-missing-dependencies-fix-2026/
date: 2026-04-20
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




**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Quick setup →** Launch your project with our [Project Starter](/starter/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/)
- [Claude Code with Just Taskfile Runner](/claude-code-with-task-runners-just-taskfile/)
- [Claude Code Jest Test Runner Mock](/claude-code-jest-runner-mock-conflict-fix/)
- [Lighthouse Audit Runner Chrome](/chrome-extension-lighthouse-audit-runner/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>

{% endraw %}

## See Also

- [Stop Claude Code Adding Extra Dependencies (2026)](/claude-code-adds-unnecessary-dependencies-fix-2026/)
