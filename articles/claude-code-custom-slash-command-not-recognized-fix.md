---
layout: default
title: "Claude Code Custom Slash Command Not (2026)"
description: "Fix Claude Code custom slash command not recognized error. Place command files in the correct .claude/commands/ directory. Step-by-step solution."
permalink: /claude-code-custom-slash-command-not-recognized-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Unknown command: /my-review
  Available commands: /help, /clear, /compact, /cost, /mcp, ...

# Or:
Error: Slash command "my-review" not found.
  Searched in:
    - /Users/you/projects/myapp/.claude/commands/
    - /Users/you/.claude/commands/

# Or:
Error: Failed to parse slash command file "my-review.md"
  Invalid frontmatter or missing template
```

## The Fix

1. **Create the command file in the correct directory**

```bash
# Project-level commands (available in this project only)
mkdir -p .claude/commands

# Create a slash command
cat > .claude/commands/my-review.md << 'EOF'
Review the code changes in the current git diff. Focus on:
1. Security issues (SQL injection, XSS, auth bypass)
2. Performance problems (N+1 queries, missing indexes)
3. Error handling gaps

Run `git diff --staged` to see the changes, then provide a structured review.
EOF
```

2. **For global commands available in all projects**

```bash
mkdir -p ~/.claude/commands

cat > ~/.claude/commands/test-and-fix.md << 'EOF'
Run the project's test suite. If any tests fail:
1. Read the failing test file
2. Read the implementation file
3. Fix the implementation (not the test)
4. Run the test again to verify
EOF
```

3. **Verify the fix:**

```bash
# List available commands inside Claude Code
ls .claude/commands/ ~/.claude/commands/ 2>/dev/null
# Expected: my-review.md (and any other command files)

# Test it in Claude Code:
claude -p "/my-review" --trust --yes
# Expected: Claude executes the review command
```

## Why This Happens

Custom slash commands are markdown files placed in `.claude/commands/` (project-level) or `~/.claude/commands/` (global). The filename without extension becomes the command name. Common reasons for "not recognized": wrong directory path (`.claude/` vs `claude/`), file extension mismatch (must be `.md`), file placed at the wrong level in the directory hierarchy, or Claude Code started before the command file was created (requires restart to detect new commands).

## If That Doesn't Work

- **Alternative 1:** Restart Claude Code after adding new commands — it only scans for commands at startup
- **Alternative 2:** Use the full path syntax: `/project:my-review` for project commands or `/user:test-and-fix` for user commands
- **Check:** Run `find . -name "*.md" -path "*/.claude/commands/*"` to locate all command files and verify their paths

## Prevention

Add to your `CLAUDE.md`:
```markdown
Store project slash commands in .claude/commands/ as .md files. Global commands go in ~/.claude/commands/. Restart Claude Code after adding new commands. Use descriptive filenames — the filename becomes the command name.
```

**Related articles:** [Claude Code Config File Location](/claude-code-config-file-location/), [Claude Code Debugging Skill](/claude-code-debugging-skill/), [Troubleshooting Hub](/troubleshooting-hub/)

## See Also

- [Create Custom Slash Commands for Claude (2026)](/how-to-create-custom-slash-command-claude-2026/)


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

- [Fix zsh: command not found: claude](/zsh-command-not-found-claude-fix/)
- [Claude Code Bash Command Timeout 120s — Fix (2026)](/claude-code-bash-command-timeout-120s-fix-2026/)
- [Fix Claude Command Not Found After](/claude-code-command-not-found-after-install-troubleshooting/)
- [Claude /compact Command Token Savings](/claude-compact-command-token-savings/)

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
