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

## See Also

- [Claude Code Rust Crate Development Guide (2026)](/claude-code-rust-crate-development-guide/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `Error reading configuration file`
- `JSON parse error in config`
- `Config key not recognized`
- `SyntaxError: Unexpected token in JSON at position 0`
- `JSON.parse: unexpected character at line 1 column 1`

## Frequently Asked Questions

### Where does Claude Code store its configuration?

Configuration is stored in `~/.claude/config.json` for global settings and `.claude/config.json` in the project root for project-specific settings. Project settings override global settings for any overlapping keys.

### How do I reset Claude Code configuration?

Delete the configuration file and restart Claude Code: `rm ~/.claude/config.json && claude`. Claude Code recreates the file with default values on next startup. Back up the file first if you have custom settings you want to preserve.

### Can I share configuration across a team?

Yes. The project-level `.claude/config.json` and `CLAUDE.md` files can be committed to version control. Team members get consistent Claude Code behavior when they check out the repository. Keep API keys and personal preferences in the global config only.

### Why does JSON parsing fail on API responses?

JSON parse failures on API responses typically indicate a network issue where an intermediate proxy returned an HTML error page instead of JSON. Check the raw response by enabling debug logging with `CLAUDE_LOG_LEVEL=debug` to see the actual content received.
