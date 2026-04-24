---
title: "Claude Code Permission Denied Shell (2026)"
description: "Fix Claude Code permission denied running shell commands. Update permissions allow-list in settings.json. Step-by-step solution."
permalink: /claude-code-permission-denied-shell-commands-fix/
last_tested: "2026-04-21"
---

## The Error

```
Permission denied: Claude Code is not allowed to run Bash commands.
  Tool "Bash" is not in the allowed tools list.
  Update your permissions in settings to allow this tool.

# Or:
Claude wants to run: npm test
  [Allow] [Deny] [Allow Always]
  → User selected Deny

# Or:
Error: Command "rm -rf node_modules" was blocked by permission policy.
  Destructive commands require explicit approval.
```

## The Fix

1. **Update permissions in your settings file**

```bash
# Check current permissions
cat ~/.claude/settings.json 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
print('Allow:', data.get('permissions', {}).get('allow', []))
print('Deny:', data.get('permissions', {}).get('deny', []))
"
```

2. **Add the tools you need to the allow list**

```bash
cat > ~/.claude/settings.json << 'ENDJSON'
{
  "permissions": {
    "allow": [
      "Bash(npm test)",
      "Bash(npm run *)",
      "Bash(git *)",
      "Bash(npx *)",
      "Read",
      "Write",
      "Edit"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(sudo *)"
    ]
  }
}
ENDJSON
```

3. **Verify the fix:**

```bash
claude -p "Run npm test" --trust --yes
# Expected: Test suite runs without permission prompt
```

## Why This Happens

Claude Code uses a permission system that controls which tools (Bash, Read, Write, Edit, etc.) it can use and which shell commands it can execute. By default, Claude Code prompts for confirmation before running any Bash command. If you deny a command, it's blocked for the session. The settings.json file lets you pre-approve patterns (like `git *` for all git commands) to avoid repeated prompts. Without proper configuration, every Bash command triggers an interactive approval dialog that can break automated workflows.

## If That Doesn't Work

- **Alternative 1:** Use the `--yes` flag to auto-approve all tool usage for the session: `claude --yes -p "Run tests"`
- **Alternative 2:** Use project-level settings in `.claude/settings.json` for project-specific permissions
- **Check:** Run `claude config list` to see all active configuration values and verify permissions are loaded correctly

## Prevention

Add to your `CLAUDE.md`:
```markdown
Pre-approve common commands (git, npm, npx, pnpm) in ~/.claude/settings.json permissions.allow. Use glob patterns like "Bash(npm *)" for flexibility. Never add "Bash(rm -rf *)" or "Bash(sudo *)" to the allow list. Review denied commands before overriding.
```

**Related articles:** [Permission Denied Sandbox Fix](/claude-code-permission-denied-sandbox-mode-fix-2026/), [Config File Location](/claude-code-config-file-location/), [Troubleshooting Hub](/troubleshooting-hub/)


## Related

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to --dangerously-skip-permissions and safer alternatives


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

- [Claude Code Skill Permission Denied](/claude-code-skill-permission-denied-error-fix-2026/)
- [EACCES Permission Denied Config Dir — Fix (2026)](/claude-code-config-dir-permission-denied-fix-2026/)
- [Claude Code Permission Denied](/claude-code-permission-denied-when-executing-skill-commands/)
- [npm Global Install Permission Denied](/claude-code-npm-global-install-permission-denied-fix-2026/)

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
