---
title: "Python Virtualenv Not Activated Fix — Fix (2026)"
permalink: /claude-code-python-virtualenv-not-activated-fix-2026/
description: "Fix Python virtualenv not activated in Claude Code sessions. Source the activate script in CLAUDE.md or use absolute venv paths for correct Python environment."
last_tested: "2026-04-22"
---

## The Error

```
ModuleNotFoundError: No module named 'fastapi'
  Python path: /usr/bin/python3 (system Python, not virtualenv)
  Expected: /project/.venv/bin/python3
  Claude Code Bash tool does not inherit shell activation scripts
```

This appears when Claude Code runs Python commands using the system Python instead of the project's virtual environment, causing import errors for packages installed only in the venv.

## The Fix

```bash
# Add to CLAUDE.md:
# Before running any Python command, activate the virtualenv:
# source .venv/bin/activate && python your_script.py
```

1. Instruct Claude Code to activate the virtualenv before every Python command.
2. Alternatively, use the full path to the venv Python binary.
3. Add activation instructions to your project's CLAUDE.md file.

## Why This Happens

Virtual environment activation works by modifying the current shell's PATH to prepend the venv's `bin/` directory. Claude Code's Bash tool starts a fresh shell for each command, so `source .venv/bin/activate` from a previous command has no effect on subsequent commands. Each Bash call starts with the default system PATH, pointing to system Python.

## If That Doesn't Work

Use the venv Python binary directly:

```bash
.venv/bin/python -m pytest
.venv/bin/pip install fastapi
```

Set the Python path in CLAUDE.md:

```markdown
# CLAUDE.md
Always use `.venv/bin/python` instead of `python`.
Always use `.venv/bin/pip` instead of `pip`.
```

Chain commands with activation:

```bash
source .venv/bin/activate && pip install -r requirements.txt && python -m pytest
```

## Prevention

```markdown
# CLAUDE.md rule
This project uses a Python virtualenv at .venv/. Always prefix Python commands with 'source .venv/bin/activate &&' or use '.venv/bin/python' directly. Never use bare 'python' or 'pip' commands.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `bash: command not found: claude`
- `zsh: command not found: claude`
- `Error: shell profile not loaded`
- `Error: ENOENT: no such file or directory`
- `Cannot resolve path outside workspace`

## Frequently Asked Questions

### Why is the claude command not found after installation?

The installation directory is not in your PATH. Run `which claude` to check if it is accessible. If not, add the npm global bin directory to your PATH: `export PATH=$(npm bin -g):$PATH` and add this line to your shell profile (`~/.bashrc` or `~/.zshrc`).

### Which shell does Claude Code use for Bash commands?

Claude Code uses the system default shell, typically `/bin/bash` or `/bin/zsh`. It reads your shell profile (`.bashrc`, `.zshrc`) for environment variables and PATH configuration. If your profile has errors, Claude Code's shell commands may fail.

### How do I use Claude Code with fish or other non-POSIX shells?

Claude Code's Bash tool always uses a POSIX-compatible shell (`bash` or `zsh`) regardless of your login shell. Your fish configuration is not loaded. If you need fish-specific environment variables, add them as standard exports in a `.env` file or CLAUDE.md.

### Why does Claude Code reject paths outside the workspace?

Claude Code sandboxes file operations to the current workspace directory for security. Writing to paths outside the project root (like `/etc/` or `~/`) is blocked by default. This prevents accidental modification of system files or other projects.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)
- [Merge Conflict in Claude-Edited Files — Fix (2026)](/claude-code-merge-conflict-edited-files-fix-2026/)

## Environment Variable Management in Claude Code

Environment variables control Claude Code's behavior and API connectivity. Managing them properly prevents security leaks and configuration errors.

**Claude Code environment variables.** These control Claude Code itself:

| Variable | Purpose | Default |
|----------|---------|---------|
| `ANTHROPIC_API_KEY` | API authentication | None (required) |
| `CLAUDE_CODE_TRUST_WORKSPACE` | Skip trust prompt | `0` (prompt) |
| `CLAUDE_CODE_BASH_TIMEOUT` | Bash command timeout | `120` seconds |
| `CLAUDE_CODE_DEBUG` | Enable debug logging | `0` (off) |
| `HTTPS_PROXY` | HTTP proxy for API calls | None |

**Project environment variables.** Your application's `.env` file should be in `.gitignore` and `.claudeignore`. Claude Code should never read or commit secrets. Add to CLAUDE.md: "Never read, display, or commit .env files. Use environment variable names in code but never actual values."

**Loading .env in Claude Code sessions.** If your project uses dotenv, ensure the `.env` file is loaded before Claude Code runs commands:

```bash
# In your CLAUDE.md, specify:
# Before running the dev server or tests, source .env:
# set -a && source .env && set +a && npm run dev
```

## Security Checklist for Environment Variables

- [ ] `.env` is in `.gitignore`
- [ ] `.env` is in `.claudeignore`
- [ ] `CLAUDE.md` contains "never read or display .env contents"
- [ ] API keys are not hardcoded in any source file
- [ ] CI/CD uses secrets manager, not committed env files
