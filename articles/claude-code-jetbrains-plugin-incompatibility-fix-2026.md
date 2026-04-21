---
title: "JetBrains Plugin Incompatibility Fix"
permalink: /claude-code-jetbrains-plugin-incompatibility-fix-2026/
description: "Fix JetBrains plugin incompatibility with Claude Code. Update IDE version, check plugin compatibility matrix, and resolve JetBrains AI Assistant conflicts."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Plugin 'Claude Code' is not compatible with the current version of IntelliJ IDEA 2025.3.1
  Required: IntelliJ Platform 2026.1+
  Installed: IntelliJ Platform 2025.3
  Plugin disabled to prevent IDE instability.
```

This appears when the Claude Code JetBrains plugin requires a newer IDE version than what you have installed.

## The Fix

```bash
# Update your JetBrains IDE:
# Help > Check for Updates > Download and Install

# Or install via Toolbox:
# JetBrains Toolbox > [Your IDE] > Update
```

1. Update your JetBrains IDE to the latest version.
2. Restart the IDE after the update.
3. Re-enable the Claude Code plugin: Settings > Plugins > Installed > Claude Code > Enable.

## Why This Happens

JetBrains plugins declare a minimum IDE platform version in their `plugin.xml`. When the Claude Code plugin is updated with features that use newer IDE APIs, older IDE versions cannot load the plugin. JetBrains disables incompatible plugins automatically to prevent crashes. This is more common with EAP (Early Access Program) plugin builds.

## If That Doesn't Work

Install a compatible older version of the plugin:

```
Settings > Plugins > Claude Code > gear icon > Install Specific Version
```

If JetBrains AI Assistant conflicts with Claude Code:

```
Settings > Plugins > Installed > JetBrains AI Assistant > Disable
```

Use Claude Code CLI in the JetBrains terminal tab instead:

```bash
# Open Terminal tab in JetBrains IDE (Alt+F12)
claude
```

Clear the plugin cache and reinstall:

```bash
rm -rf ~/.cache/JetBrains/IntelliJIdea*/plugins/claude-code
# Restart IDE and reinstall from marketplace
```

## Prevention

```markdown
# CLAUDE.md rule
Keep JetBrains IDE updated to the latest stable release. Check plugin compatibility before updating the Claude Code plugin. If the plugin fails, use Claude Code CLI in the terminal tab as a fallback.
```
