---
title: "Fix Claude Code Making Assumptions (2026)"
description: "Stop Claude Code from silently choosing libraries, patterns, and architecture — add Don't Assume rules to CLAUDE.md with exact code blocks."
permalink: /claude-code-keeps-making-assumptions-karpathy-fix-2026/
last_tested: "2026-04-22"
---

# Fix Claude Code Making Assumptions (2026)

Claude Code picks libraries, patterns, and architectural decisions without asking. This produces code you'll rewrite. Here's the fix.

## The Problem

You ask Claude Code to add a feature. Instead of clarifying ambiguities, it silently chooses:
- Which library to use
- Where to put the files
- What error handling pattern to follow
- How to structure the implementation
- What additional features to include

The generated code works but doesn't match your project's conventions, leading to rejected PRs and wasted sessions.

## Root Cause

Claude Code is trained to be helpful and decisive. Without behavioral constraints, "helpful" means "pick the most common approach and implement it." The model has no mechanism to distinguish "I should ask" from "I should decide" unless your CLAUDE.md tells it.

## The Fix

Add this to your project's CLAUDE.md:

```markdown
## Stop Making Assumptions

### Always Ask Before
- Choosing a library not already in the project
- Creating a new file or directory pattern
- Picking an implementation approach when 2+ are valid
- Adding scope beyond the explicit request

### How to Ask
When uncertain, present options:
**Decision needed:** [what needs deciding]
**Options:**
1. [option A — tradeoffs]
2. [option B — tradeoffs]
**My recommendation:** [pick with reasoning]
```

## CLAUDE.md Rule to Add

For the strongest effect, combine with project-specific technology directives:

```markdown
## Technology Decisions (DO NOT DEVIATE)
- ORM: [your ORM]. No alternatives.
- Test framework: [your test framework]. No alternatives.
- Styling: [your approach]. No alternatives.
- When a technology choice isn't listed here, ASK before choosing.
```

## Verification

Give Claude Code an ambiguous task:

```
Add caching to the API
```

**Bad response:** installs Redis, writes a cache layer, picks TTL values
**Good response:** asks about cache backend, which endpoints, TTL strategy, and invalidation approach

If it still assumes, add the specific assumption to the "Always Ask Before" list.

Related: [Karpathy Don't Assume Principle](/karpathy-dont-assume-principle-claude-code-2026/) | [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) | [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/)


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Prevention

Add these rules to your project's `CLAUDE.md` to prevent this issue from recurring:

```markdown
# Environment Checks
Before running commands, verify the required tools are available.
Check versions match project requirements before proceeding.
If a command fails, read the error message carefully before retrying.
Do not retry failed commands without changing something first.
```

Additionally, consider adding a project setup validation script:

```bash
#!/bin/bash
# validate-env.sh — run before starting Claude Code sessions
set -euo pipefail

echo "Checking environment..."
node --version | grep -q "v2[0-2]" || echo "WARN: Node.js 20+ recommended"
command -v git >/dev/null || echo "ERROR: git not found"
[ -f package.json ] || echo "ERROR: not in project root"
echo "Environment check complete."
```


## Related Guides

- [Claude Code Keeps Making Same Mistake](/claude-code-keeps-making-same-mistake-fix-guide/)

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
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error. This fix also applies if you see variations of this error: - Connection or process errors with similar root causes in the same subsystem - Timeout variants where the operation starts but does not complete - Permission variants where access is denied to the same resource - Configuration variants where the same setting is missing or malformed If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message. Add these rules to your project's `CLAUDE.md` to prevent this issue from recurring: ```markdown # Environment Checks Before running commands, verify the required tools are available. Check versions match project requirements before proceeding. If a command fails, read the error message carefully before retrying. Do not retry failed commands without changing something first. ``` Additionally, consider adding a project setup validation script: ```bash #!/bin/bash # validate-env.sh — run before starting Claude Code sessions set -euo pipefail echo \"Checking environment...\" node --version | grep -q \"v2[0-2]\" || echo \"WARN: Node.js 20+ recommended\" command -v git >/dev/null || echo \"ERROR: git not found\" [ -f package.json ] || echo \"ERROR: not in project root\" echo \"Environment check complete.\" ``` - [Claude Code Keeps Making Same Mistake](/claude-code-keeps-making-same-mistake-fix-guide/)"
      }
    }
  ]
}
</script>
