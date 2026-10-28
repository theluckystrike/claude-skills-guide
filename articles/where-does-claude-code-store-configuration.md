---
layout: default
title: "Where Does Claude Code Store Its Configuration?"
description: "Claude Code keeps five configuration files: user, project, local, managed and the internal ~/.claude.json. See what each file holds and which one wins."
date: 2026-10-28
last_modified_at: 2026-10-28
last_tested: "2026-10-28"
author: "Michael Lip"
permalink: /where-does-claude-code-store-configuration/
categories: [guides]
tags: [claude-code, configuration, settings, permissions]
reviewed: true
geo_optimized: true
---

# Where Does Claude Code Store Its Configuration?

Claude Code reads settings from more than one file. The file it uses depends on who the setting is for: you, your project, one checkout, or your whole organization. This page lists each file, what it holds, and which file wins when two of them set the same key.

## The five files

| File | Scope | Committed to git | Typical content |
|---|---|---|---|
| `~/.claude/settings.json` | You, in every project | No | Personal defaults: model, theme, allowed tools |
| `.claude/settings.json` | Everyone who clones the repository | Yes | Team permissions, hooks, plugins, shared environment variables |
| `.claude/settings.local.json` | You, in one project only | No | Personal overrides and experiments |
| `managed-settings.json` | Everyone in the organization | Deployed by IT | Security policy and compliance rules |
| `~/.claude.json` | You, internal state | No | Account details, MCP servers, trust decisions, `/config` keys |

A bare `.claude` in the table means the `.claude` folder inside the project root. `~/.claude` means the folder in your home directory.

Claude Code writes `~/.claude.json` itself. You do not need to edit it by hand. The file holds your account details, your MCP server configurations, per-project state such as trust decisions, and the global config keys that the `/config` command writes.

## Which file wins

When two files set the same key, Claude Code applies this order, highest first:

1. `managed-settings.json` from the organization
2. Command-line arguments
3. `.claude/settings.local.json`
4. `.claude/settings.json`
5. `~/.claude/settings.json`

A key in a higher file overrides the same key in a lower file. A key that appears in only one file is used as written, and unrelated keys merge instead of replacing each other.

## Check which file applies

Run the `/config` command inside Claude Code. The command opens the settings panel and shows the value that is in force. To see the files themselves, list both project locations:

```bash
ls -la .claude/settings.json .claude/settings.local.json
cat ~/.claude/settings.json
```

A setting that you change in the panel goes to the file that owns that key. A permission that every teammate needs belongs in `.claude/settings.json`, so commit that file.

## Keep settings out of git

Claude Code keeps `.claude/settings.local.json` out of git when it creates the file. If you create the file by hand, add it to `.gitignore` yourself:

```gitignore
.claude/settings.local.json
```

Commit `.claude/settings.json` instead. Everyone who clones the repository then gets the same permissions, hooks and plugins.

## Move the home-directory files

Set the `CLAUDE_CONFIG_DIR` environment variable to keep the home-directory files somewhere else. Claude Code then stores your settings, session history and plugins in that folder instead of `~/.claude`.

```bash
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
```

This is useful when you sync a dotfiles repository, or when a machine has a small home partition.

## Common mistake

Some guides name `~/.claude/config.json` and `.claude/config.json` as the settings files. Claude Code does not read those paths. The settings file is `settings.json`, and the file that Claude Code writes for its own state is `~/.claude.json` in your home directory.

## Related guides

- [How to manage Claude Code dotfiles](/claude-code-dotfiles-configuration-management-workflow/)
- [Custom keybindings configuration](/claude-code-custom-keybindings-configuration/)
- [Disallowed tools security configuration](/claude-code-disallowedtools-security-configuration/)
