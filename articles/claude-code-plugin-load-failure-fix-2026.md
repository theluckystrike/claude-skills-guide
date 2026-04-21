---
title: "Plugin Load Failure Error — Fix (2026)"
permalink: /claude-code-plugin-load-failure-fix-2026/
description: "Fix Claude Code plugin load failure. Check plugin path, Node version compatibility, and reinstall the failing plugin."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Failed to load plugin '@claude/plugin-git-hooks' from /Users/you/.claude/plugins/git-hooks
  Reason: Cannot find module 'node:test' (Node 16 detected, requires Node 18+)
```

This error occurs when a Claude Code plugin cannot be loaded due to missing dependencies, incompatible Node version, or a corrupted plugin installation.

## The Fix

1. Check which plugins are installed:

```bash
ls -la ~/.claude/plugins/ 2>/dev/null
```

2. Reinstall the failing plugin:

```bash
rm -rf ~/.claude/plugins/git-hooks
claude plugins install @claude/plugin-git-hooks
```

3. Ensure your Node version meets the plugin's requirements:

```bash
node --version
# Must be 18+ for most Claude Code plugins
nvm use 22
```

4. Verify all plugins load correctly:

```bash
claude --version
```

## Why This Happens

Claude Code plugins are Node.js modules loaded at startup. They fail when: the plugin's dependencies are missing (deleted node_modules), the plugin requires a newer Node version than what is running, the plugin's entry point file has been deleted or moved, or the plugin is incompatible with the current Claude Code version.

## If That Doesn't Work

- Disable the failing plugin temporarily:

```bash
claude config set disabledPlugins '["@claude/plugin-git-hooks"]'
```

- Clear all plugins and reinstall:

```bash
rm -rf ~/.claude/plugins
claude plugins install @claude/plugin-git-hooks
```

- Check for plugin version mismatch:

```bash
cat ~/.claude/plugins/git-hooks/package.json | python3 -c "import sys,json; print(json.load(sys.stdin).get('engines',{}))"
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Plugins
- Pin plugin versions in your project config.
- Test plugins after every Node.js version upgrade.
- Keep plugins list minimal — each plugin adds startup time and failure risk.
```
