---
layout: default
title: "Config File JSON Parse Error — Fix (2026)"
permalink: /claude-code-config-json-corrupted-parse-error-fix-2026/
date: 2026-04-20
description: "Fix 'unexpected token in JSON' config parse error. Reset corrupted Claude Code config file to defaults with one command."
last_tested: "2026-04-22"
---

## The Error

```
SyntaxError: Unexpected token } in JSON at position 342
  at JSON.parse (<anonymous>)
  Loading config from /Users/you/.claude/config.json
```

This error occurs when Claude Code's configuration file has been corrupted — typically by a partial write, manual edit mistake, or disk issue.

## The Fix

1. Back up the corrupted config:

```bash
cp ~/.claude/config.json ~/.claude/config.json.bak
```

2. Validate the JSON to find the error:

```bash
python3 -m json.tool ~/.claude/config.json
```

3. If the file is unrecoverable, reset to defaults:

```bash
rm ~/.claude/config.json
claude --version
```

Claude Code regenerates a default config on next launch.

4. Restore any custom settings you need:

```bash
claude config set model claude-sonnet-4-20250514
claude config set theme dark
```

## Why This Happens

The config file can become corrupted when Claude Code is killed mid-write (Ctrl+C during a config save), when multiple Claude Code instances write to the same config simultaneously, or when a user manually edits the JSON and introduces a syntax error (trailing comma, missing quote, extra bracket).

## If That Doesn't Work

- Try to fix the JSON manually using a validator:

```bash
# Show the exact error location
python3 -c "
import json
try:
    json.load(open('$HOME/.claude/config.json'))
except json.JSONDecodeError as e:
    print(f'Error at line {e.lineno}, column {e.colno}: {e.msg}')
"
```

- Check if the project-level config is also corrupted:

```bash
python3 -m json.tool .claude/config.json 2>&1 || echo "Project config also broken"
```

- Delete both global and project configs and start fresh.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Configuration
- Never manually edit ~/.claude/config.json. Use claude config set instead.
- Do not run multiple Claude Code instances that modify config simultaneously.
- Back up config before major changes: cp ~/.claude/config.json ~/.claude/config.json.bak
```

## See Also

- [Claude Code Config YAML Parse Error — Fix (2026)](/claude-code-config-yaml-parse-error-fix/)
- [JSON Parse Error on Malformed Response Fix](/claude-code-json-parse-error-malformed-response-fix-2026/)


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

- [Optimal Skill File Size and Complexity](/optimal-skill-file-size-and-complexity-guidelines/)
- [Claude Code Large File Refactoring](/best-way-to-use-claude-code-for-large-file-refactoring/)
- [Declaration File .d.ts Missing Error — Fix (2026)](/claude-code-declaration-file-dts-missing-fix-2026/)
- [Claude Code Enoent No Such File](/claude-code-enoent-no-such-file-directory-skill/)

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
