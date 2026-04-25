---
layout: default
title: "Claude Code Config YAML Parse Error (2026)"
description: "Fix Claude Code config file YAML parse error. Validate syntax and fix common indentation mistakes. Step-by-step solution."
permalink: /claude-code-config-yaml-parse-error-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Error: Failed to parse configuration file
YAMLException: bad indentation of a mapping entry (2:3)
  at /Users/you/.claude/settings.json

# Or for CLAUDE.md YAML frontmatter:
Error: Invalid YAML frontmatter in CLAUDE.md
  expected a single document in the stream
  but found another document at line 5, column 1

# Or:
SyntaxError: Unexpected token ':' in JSON at position 42
  Could not parse settings.json
```

## The Fix

1. **Validate your config file syntax**

```bash
# For JSON config (settings.json):
python3 -c "import json; json.load(open('$HOME/.claude/settings.json')); print('JSON valid')"

# For YAML frontmatter in CLAUDE.md:
python3 -c "
import yaml
with open('CLAUDE.md') as f:
    content = f.read()
    if content.startswith('---'):
        end = content.index('---', 3)
        yaml.safe_load(content[3:end])
        print('YAML frontmatter valid')
"
```

2. **Fix common syntax mistakes**

```bash
# settings.json — must be valid JSON, no trailing commas
cat > ~/.claude/settings.json << 'ENDJSON'
{
  "permissions": {
    "allow": ["Bash", "Read", "Write"],
    "deny": []
  }
}
ENDJSON
```

3. **Verify the fix:**

```bash
# Validate and start Claude Code
python3 -c "import json; json.load(open('$HOME/.claude/settings.json')); print('Config OK')" && claude --version
# Expected: Config OK followed by version number
```

## Why This Happens

Claude Code reads configuration from `~/.claude/settings.json` (JSON format) and project-level `CLAUDE.md` files (which may contain YAML frontmatter). JSON is strict about syntax — trailing commas, unquoted keys, and single quotes are all parse errors. YAML frontmatter in CLAUDE.md requires proper indentation (spaces only, no tabs) and must be enclosed between `---` delimiters. Editors that auto-insert smart quotes or tabs break both formats silently.

## If That Doesn't Work

- **Alternative 1:** Delete and recreate the config: `mv ~/.claude/settings.json ~/.claude/settings.json.bak && claude` — Claude Code creates a fresh default config
- **Alternative 2:** Use an online JSON/YAML validator like jsonlint.com to pinpoint the exact character
- **Check:** Run `cat -A ~/.claude/settings.json` to reveal hidden characters like tabs (shown as `^I`) and carriage returns (shown as `^M`)

## Prevention

Add to your `CLAUDE.md`:
```markdown
Use spaces not tabs in all config files. Validate JSON with python3 -c "import json; json.load(open('file'))" after editing. Never use trailing commas in JSON config files.
```

**Related articles:** [Claude Code Config File Location](/claude-code-config-file-location/), [YAML Frontmatter Parse Error Fix](/claude-code-skill-yaml-frontmatter-parse-error-fix-2026/), [Troubleshooting Hub](/troubleshooting-hub/)


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
- [Streaming SSE Event Parse Error — Fix (2026)](/claude-code-streaming-sse-event-parse-error-fix-2026/)
- [Config File JSON Parse Error — Fix (2026)](/claude-code-config-json-corrupted-parse-error-fix-2026/)
- [XDG Config Directory Permissions Fix](/claude-code-xdg-config-directory-permissions-fix-2026/)


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

- [Claude Code Enterprise Setup and Config](/claude-code-enterprise-setup-guide-2026/)
- [How to Use VSCode Reload: Hot Config](/claude-code-for-hot-config-reload-workflow-guide/)
- [Claude Code for AWS Config Rules](/claude-code-for-aws-config-rules-workflow/)
- [EACCES Permission Denied Config Dir — Fix (2026)](/claude-code-config-dir-permission-denied-fix-2026/)

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
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error. This fix also applies if you see variations of this error: - Connection or process errors with similar root causes in the same subsystem - Timeout variants where the operation starts but does not complete - Permission variants where access is denied to the same resource - Configuration variants where the same setting is missing or malformed If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message."
      }
    }
  ]
}
</script>
