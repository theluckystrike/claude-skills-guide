---
layout: default
title: "Fix Claude Code Crashing in VS Code (2026)"
description: "Stop Claude Code from crashing VS Code with fixes for memory limits, extension conflicts, and terminal configuration issues. Tested and working in 2026."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-crashing-vscode/
categories: [guides]
tags: [claude-code, claude-skills, vscode, crash-fix]
reviewed: true
score: 7
geo_optimized: true
last_tested: "2026-04-22"
---

Claude Code crashing inside VS Code is usually caused by memory limits, extension conflicts, or terminal misconfiguration. This guide walks through each cause and gives you a fix that gets Claude Code stable in VS Code.

## The Problem

You run Claude Code from VS Code's integrated terminal and it crashes — either Claude Code itself freezes and dies, or the entire VS Code window becomes unresponsive. This may happen immediately on launch or after running for a while during a complex coding session. The crash may produce an error message or VS Code may simply freeze without explanation.

## Quick Solution

**Step 1:** Increase VS Code's memory limit. Create or edit `argv.json`:

```bash
# macOS/Linux
code ~/.vscode/argv.json
```

Add or update the max memory setting:

```json
{
  "max-memory": 8192
}
```

Restart VS Code.

**Step 2:** Check for extension conflicts. Disable all other extensions temporarily:

```bash
code --disable-extensions
```

Launch Claude Code in the terminal. If it works, re-enable extensions one by one to find the conflict. Common culprits: other AI coding assistants (Copilot, Cody, Continue) competing for resources.

**Step 3:** Use an external terminal instead of VS Code's integrated terminal. Open your system terminal (Terminal.app on macOS, gnome-terminal on Linux) and run Claude Code from there:

```bash
cd /path/to/your/project
claude
```

If Claude Code works fine in an external terminal but crashes in VS Code, the issue is VS Code's terminal environment.

**Step 4:** Fix VS Code's terminal environment. Ensure your shell profile is sourced correctly. In VS Code settings (`settings.json`):

```json
{
  "terminal.integrated.env.osx": {
    "ANTHROPIC_API_KEY": "sk-ant-your-key"
  },
  "terminal.integrated.shellArgs.osx": ["-l"]
}
```

The `-l` flag ensures your shell runs as a login shell, sourcing your profile.

**Step 5:** If VS Code freezes entirely (not just Claude Code), the issue is likely VS Code's PTY process. Kill zombie processes and restart:

```bash
pkill -f "claude"
```

Then reopen VS Code.

## How It Works

Claude Code runs as a Node.js (or Bun) process inside VS Code's integrated terminal. VS Code's terminal is a pseudo-terminal (PTY) managed by VS Code's Electron process. When Claude Code makes heavy API calls and processes large responses with streaming output, it puts load on both the Node.js process and VS Code's PTY renderer. If VS Code's Electron process runs out of memory (it shares a V8 heap with extensions, the editor, and the terminal), everything freezes. Additionally, VS Code's integrated terminal may not inherit all environment variables from your shell profile, causing authentication failures that manifest as crashes.

## Common Issues

**Environment variables not loaded.** VS Code's integrated terminal may not source `~/.zshrc` or `~/.bashrc` properly. If `ANTHROPIC_API_KEY` is not available, Claude Code may crash on startup. Use `terminal.integrated.env` in VS Code settings or switch to a login shell.

**Competing AI extensions.** Running Claude Code alongside GitHub Copilot, Cody, or other AI extensions doubles the memory usage and can cause VS Code to run out of heap space. Disable competing extensions while using Claude Code.

**Large workspace with many open files.** If VS Code has many files open and large Git diffs loaded, there is less memory available for Claude Code. Close unused tabs and editors before starting a Claude Code session.

## Example CLAUDE.md Section

```markdown
# VS Code Integration

## Terminal Setup
- Run Claude Code in VS Code integrated terminal
- Shell: zsh with login flag (-l) for full profile sourcing
- Environment: ANTHROPIC_API_KEY set in terminal.integrated.env

## Memory Management
- VS Code max-memory set to 8192 in argv.json
- Close unused editor tabs before starting Claude Code sessions
- Disable competing AI extensions (Copilot, Cody) during Claude Code use

## Crash Recovery
- If VS Code freezes: force quit and reopen (Cmd+Q on macOS)
- If only Claude Code crashes: run `pkill -f claude` then restart
- Check git status after any crash for partial file writes
- Alternative: run Claude Code in external terminal for stability

## VS Code Settings for Claude Code
- terminal.integrated.shellArgs.osx: ["-l"]
- editor.formatOnSave: true (Claude Code writes formatted code)
```

## Best Practices

1. **Use an external terminal for long sessions.** VS Code's integrated terminal is convenient but adds overhead. For sessions over 30 minutes or heavy refactoring, use a dedicated terminal window.

2. **Set VS Code max-memory to at least 8GB.** The default is 4GB, which is not enough when running Claude Code alongside other extensions. Edit `argv.json` once and forget about it.

3. **Disable competing AI extensions.** You only need one AI assistant active at a time. Disable Copilot and similar extensions when using Claude Code to free up memory and avoid interference.

4. **Keep VS Code updated.** VS Code's terminal handling and memory management improve with each release. Run `code --update` or enable auto-updates.

5. **Monitor Activity Monitor or Task Manager.** If VS Code's memory usage climbs above 6GB, wrap up your current task and restart VS Code before it crashes.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-crashing-vscode)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Way to Use Claude Code for Debugging Sessions](/best-way-to-use-claude-code-for-debugging-sessions/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## See Also

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code vs VS Code IntelliSense: Completion Compared](/claude-code-vs-vscode-intellisense-comparison/)
- [Fix Claude Code Not Working VSCode — Quick Guide (2026)](/claude-code-not-working-vscode/)
