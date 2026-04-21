---
title: "Claude Code Rust-Analyzer Conflict — Fix (2026)"
permalink: /claude-code-rust-analyzer-conflict-fix-2026/
description: "Disable Claude Code inline completions for Rust files in VS Code settings.json. Eliminates duplicate completion suggestions from rust-analyzer conflict."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Claude Code conflicts with rust-analyzer: duplicate completions
```

## The Fix

```json
// Add to your VS Code settings.json
{
  "claude-code.completions.disabledLanguages": ["rust"]
}
```

```bash
# Open VS Code settings directly
code ~/.config/Code/User/settings.json
```

## Why This Works

Both Claude Code and rust-analyzer register as completion providers for Rust files. VS Code merges their results, producing duplicates and slowing the completion popup. Disabling Claude Code completions for Rust files lets rust-analyzer handle language-specific completions while Claude Code still provides chat, edits, and tool use for Rust projects.

## If That Doesn't Work

```bash
# If duplicates persist, set completion provider priority
# Add to settings.json:
# "editor.snippetSuggestions": "bottom",
# "rust-analyzer.completion.autoimport.enable": true,
# "[rust]": { "editor.defaultFormatter": "rust-lang.rust-analyzer" }

# Alternatively, reload after the change
# Command Palette > Developer: Reload Window
```

Ensure you are running the latest versions of both extensions. Older versions of Claude Code (pre-1.2) lacked the `disabledLanguages` setting. If you use multiple Rust workspaces, apply the setting at the user level rather than the workspace level to avoid repeating the configuration in every project.

## Prevention

Add to your CLAUDE.md:
```
Claude Code inline completions are disabled for Rust files. Use Claude Code for chat-based assistance and refactoring in Rust projects, not inline completions.
```
