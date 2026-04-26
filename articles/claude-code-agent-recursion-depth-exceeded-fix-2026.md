---
layout: default
title: "Agent Recursion Depth Exceeded Fix (2026)"
permalink: /claude-code-agent-recursion-depth-exceeded-fix-2026/
date: 2026-04-20
description: "Fix agent recursion depth exceeded in Claude Code. Set max turns limit and break circular task delegation to stop infinite subagent loops."
last_tested: "2026-04-22"
---

## The Error

```
Error: Maximum agent recursion depth exceeded (depth: 10)
Subagent spawned subagent which spawned subagent — circular delegation detected.
Aborting to prevent infinite loop.
```

This appears when a Claude Code agent delegates a task to a subagent, which then delegates back or spawns further subagents, creating a recursive chain that exceeds the maximum depth.

## The Fix

```bash
claude --max-turns 5 "Fix the bug in auth.ts"
```

1. Use `--max-turns` to limit how many turns Claude Code can take, which caps recursion depth.
2. If using the Agent tool in a CLAUDE.md or custom workflow, ensure tasks are specific enough that subagents do not re-delegate.
3. Restart the session with a clearer, more targeted prompt that does not require multi-level delegation.

## Why This Happens

Claude Code's agent architecture allows spawning subagents for complex tasks. When the task description is vague (like "fix all issues"), a subagent may interpret its subtask as equally broad and spawn its own subagent. Each level adds to the recursion depth until the safety limit triggers. This is especially common with custom hooks or skills that invoke Claude Code recursively.

## If That Doesn't Work

Disable subagent spawning entirely for the current task:

```bash
claude --disallowedTools "Agent" "Fix the bug in auth.ts"
```

Break the task into explicit sequential steps:

```bash
claude "Step 1: Read auth.ts. Step 2: Identify the null check bug on line 45. Step 3: Fix only that line."
```

Check for recursive hooks that might be triggering agent loops:

```bash
cat .claude/settings.json | grep -A5 "hooks"
```

## Prevention

```markdown
# CLAUDE.md rule
Never delegate tasks to subagents that are broader than the original task. Always specify exact files and line numbers when possible. Use --max-turns 10 for automated pipelines.
```


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error


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


## Related Guides

- [Fix Skill Exceeded Maximum Output](/claude-code-skill-exceeded-maximum-output-length-error-fix/)
- [Context Window Exceeded — Fix (2026)](/claude-code-context-window-exceeded-mid-conversation-fix-2026/)
- [Fix Claude Rate Exceeded Error (2026)](/claude-rate-exceeded-error-fix/)
- [Fix Claude AI Rate Exceeded Error](/claude-ai-rate-exceeded-error-fix/)

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
