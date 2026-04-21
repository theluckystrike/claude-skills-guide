---
title: "Claude Code Permission Denied Sandbox Mode — Fix (2026)"
permalink: /claude-code-permission-denied-sandbox-mode-fix-2026/
description: "Add operation to permissions.allow in settings to fix sandbox denial. Or run with --dangerously-skip-permissions for fully trusted projects."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Permission denied: sandbox mode blocks this operation
```

## The Fix

```bash
# Allow specific operations through the sandbox by updating settings
# In .claude/settings.json:
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(npm test)",
      "Bash(git *)"
    ]
  }
}
EOF

# Or approve the operation interactively when prompted
# Type 'y' when Claude asks for permission
```

## Why This Works

Claude Code's sandbox mode restricts operations that could modify system state, access the network, or execute arbitrary code. Each blocked operation must be explicitly allowlisted in settings or approved at runtime. The sandbox intercepts the syscall and rejects it before execution, so the operation never partially completes.

## If That Doesn't Work

```bash
# Run Claude Code with the --dangerously-skip-permissions flag for trusted projects
claude --dangerously-skip-permissions "Run the full deploy pipeline"

# Or use the Bash tool's dangerouslyDisableSandbox parameter
# (only available when running as an SDK integration)

# Check if the issue is OS-level (macOS sandbox) vs Claude sandbox:
ls -la /path/to/blocked/resource
```

The `--dangerously-skip-permissions` flag bypasses all permission checks. Use only in trusted, local development environments.

## Prevention

Add to your CLAUDE.md:
```
Pre-approve all known build and test commands in .claude/settings.json under permissions.allow. Use glob patterns for command families (e.g., "Bash(npm *)"). Never use --dangerously-skip-permissions in shared or production environments.
```
