---
title: "Claude Code Config YAML Parse Error"
description: "Fix Claude Code config file YAML parse error. Validate syntax and fix common indentation mistakes. Step-by-step solution."
permalink: /claude-code-config-yaml-parse-error-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
