---
layout: default
title: "Install SuperClaude Framework Step (2026)"
description: "Install SuperClaude with pipx in 5 minutes. Get 30 slash commands, 16 agents, and 7 behavioral modes for Claude Code. Full setup and verification."
permalink: /how-to-install-superclaude-framework-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# How to Install SuperClaude Framework Step by Step (2026)

SuperClaude adds 30 slash commands, 16 specialized agents, and 7 behavioral modes to Claude Code. Here is the full installation process with verification at each step.

## Prerequisites

- Python 3.10+ installed (`python3 --version`)
- pipx installed (`pipx --version`) — if not: `python3 -m pip install --user pipx`
- Claude Code installed and working
- Terminal access

## Step 1: Install SuperClaude

```bash
pipx install superclaude
```

This installs SuperClaude in an isolated Python environment. Verify:

```bash
superclaude --version
```

## Step 2: Run the Installer

```bash
superclaude install
```

The installer does several things:
- Detects your Claude Code installation
- Installs slash command definitions
- Configures agent personalities
- Sets up behavioral mode switching
- Creates configuration files

Watch the output for any errors. A clean install ends with a success message listing the installed components.

## Step 3: Verify Slash Commands

Start a Claude Code session:

```bash
claude
```

Test a slash command:

```
/help
```

SuperClaude's `/help` should list all 30 available commands. Key commands to know:

- `/architect` — Design system architecture
- `/code` — Generate code with context awareness
- `/review` — Perform code review
- `/debug` — Diagnose and fix issues
- `/test` — Generate tests
- `/deploy` — Deployment assistance
- `/plan` — Create project plans
- `/refactor` — Refactor existing code

## Step 4: Test Behavioral Modes

Switch between modes to verify they work:

```
/mode careful
```

In careful mode, Claude is more thorough, asks more questions, and produces more detailed output. Test the difference:

```
/mode fast
```

In fast mode, Claude prioritizes speed over thoroughness. The 7 available modes:

1. **careful** — Thorough, detail-oriented
2. **fast** — Quick, minimal
3. **teaching** — Explains reasoning
4. **pair** — Collaborative style
5. **autonomous** — Minimal questions, maximum action
6. **review** — Critical, analytical
7. **planning** — Strategic, forward-looking

## Step 5: Test an Agent

Invoke a specialized agent:

```
/architect
```

The architect agent should shift Claude's behavior to focus on system design, component relationships, and scalability considerations. Ask it to design something and verify the output matches the architectural focus.

## Verification Checklist

- [ ] `superclaude --version` returns a version number
- [ ] `superclaude install` completed without errors
- [ ] `/help` lists all 30 commands in Claude Code
- [ ] `/mode careful` changes Claude's behavior noticeably
- [ ] `/architect` activates the architecture-focused agent

## Choosing Your Default Mode

After installation, select a default mode that matches your typical work style:

**For careful, methodical developers**: Set `careful` as your default. Claude asks more questions, provides more detailed output, and catches more edge cases.

**For fast-moving prototypers**: Set `fast` as your default. Claude makes reasonable assumptions and produces code quickly with minimal back-and-forth.

**For developers learning a new codebase**: Set `teaching` as your default. Claude explains its reasoning and teaches you about the code as it works.

**For pair programming sessions**: Set `pair` as your default. Claude acts as a collaborative partner, discussing approaches before coding.

You can always override your default with `/mode [mode-name]` during any session.

## Command Reference Quick Sheet

Keep this reference handy during your first week:

| Command | Use When |
|---|---|
| `/architect` | Designing system components |
| `/code` | Writing new code |
| `/review` | Reviewing existing code |
| `/debug` | Diagnosing bugs |
| `/test` | Generating tests |
| `/refactor` | Improving existing code |
| `/deploy` | Deployment tasks |
| `/plan` | Project planning |
| `/doc` | Writing documentation |
| `/security` | Security auditing |

The other 20 commands cover more specialized tasks. Explore them as your needs arise.

## Troubleshooting

**"superclaude: command not found"**: pipx may not be on your PATH. Run `pipx ensurepath` and restart your terminal. On macOS, you may need to add `export PATH="$HOME/.local/bin:$PATH"` to your `~/.zshrc`.

**Install fails with permission errors**: Do not use `sudo`. pipx should install to your user directory. If using a system Python, install pipx with `--user` flag first: `python3 -m pip install --user pipx`.

**Slash commands not appearing in Claude**: Restart Claude Code after installation. SuperClaude's commands are loaded at session start. If they still do not appear, run `superclaude install` again and check for error messages.

**Mode switching has no visible effect**: The effect is subtle in short responses. Test with a complex task (e.g., "review this 100-line file") to see the behavioral difference between careful and fast modes. The difference is more pronounced with longer outputs.

**Conflicts with existing commands**: If you have custom slash commands with the same names, SuperClaude may override them. Rename your custom commands or configure SuperClaude to use a prefix. Check `.claude/commands/` for name collisions.

## Next Steps

- Compare SuperClaude with [Karpathy Skills](/superclaude-vs-karpathy-skills-workflow-2026/) to understand the philosophical differences
- Learn to [combine both tools](/how-to-combine-karpathy-superclaude-2026/) for maximum effect
- Explore [Claude Code hooks](/understanding-claude-code-hooks-system-complete-guide/) that complement SuperClaude's commands
- Browse the [skills directory](/claude-skills-directory-where-to-find-skills/) for additional plugins

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Install Awesome Claude Code Toolkit (2026)](/how-to-install-awesome-claude-code-toolkit-2026/)
- [Install Karpathy Skills in Claude Code (2026)](/how-to-install-karpathy-skills-claude-code-2026/)
