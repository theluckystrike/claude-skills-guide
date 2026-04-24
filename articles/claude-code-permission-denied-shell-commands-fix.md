---
title: "Claude Code Permission Denied Shell"
description: "Fix Claude Code permission denied running shell commands. Update permissions allow-list in settings.json. Step-by-step solution."
permalink: /claude-code-permission-denied-shell-commands-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
