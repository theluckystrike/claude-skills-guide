---
title: "Shell RC File Not Sourced Error — Fix (2026)"
permalink: /claude-code-shell-rc-not-sourced-fix-2026/
description: "Shell RC File Not Sourced Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
Error: ANTHROPIC_API_KEY is not set. Set it with: export ANTHROPIC_API_KEY=sk-ant-...
$ echo $ANTHROPIC_API_KEY
(empty)
$ grep ANTHROPIC ~/.zshrc
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```

The API key is defined in `.zshrc` but the variable is empty in your current session. Your shell is not sourcing the RC file.

## The Fix

1. Determine your shell type:

```bash
echo $SHELL
```

2. For zsh (macOS default), ensure `.zprofile` sources `.zshrc`:

```bash
echo '[[ -f ~/.zshrc ]] && source ~/.zshrc' >> ~/.zprofile
source ~/.zprofile
```

3. For bash, ensure `.bash_profile` sources `.bashrc`:

```bash
echo '[[ -f ~/.bashrc ]] && source ~/.bashrc' >> ~/.bash_profile
source ~/.bash_profile
```

4. Verify:

```bash
echo $ANTHROPIC_API_KEY | head -c 15
```

## Why This Happens

Login shells (opened by terminal apps, SSH, tmux) source `.zprofile` or `.bash_profile` but not `.zshrc` or `.bashrc`. Interactive non-login shells source the RC files. If your environment variables are only in `.zshrc` and your terminal opens login shells, those variables are never set. macOS Terminal.app and iTerm2 both open login shells by default.

## If That Doesn't Work

- Check if your terminal is opening a login shell:

```bash
shopt -q login_shell && echo "login" || echo "non-login"
# For zsh:
[[ -o login ]] && echo "login" || echo "non-login"
```

- Put environment variables in `.zshenv` which is always sourced regardless of shell type:

```bash
echo 'export ANTHROPIC_API_KEY="your-key"' >> ~/.zshenv
```

- If using VS Code's integrated terminal, check `terminal.integrated.shellArgs.osx` setting.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Environment Variables
- Put ANTHROPIC_API_KEY in ~/.zshenv (always sourced) not ~/.zshrc.
- Alternatively, use direnv with a .envrc file per project.
- Test with: echo $ANTHROPIC_API_KEY — in every new shell before starting work.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `AuthenticationError: invalid x-api-key`
- `Error: API key not found in environment`
- `401 Unauthorized: invalid_api_key`
- `bash: command not found: claude`
- `zsh: command not found: claude`

## Frequently Asked Questions

### Where should I store my Anthropic API key?

Store it in the `ANTHROPIC_API_KEY` environment variable in your shell profile (`~/.bashrc`, `~/.zshrc`). Never hardcode API keys in source code or commit them to version control. For CI/CD, use your platform's secrets manager.

### How do I rotate my API key?

Generate a new key at console.anthropic.com, update the `ANTHROPIC_API_KEY` environment variable, then reload your shell with `source ~/.zshrc`. The old key is revoked when you delete it from the console. Active sessions using the old key will fail after the key is deleted.

### Can I use different API keys for different projects?

Yes. Set the `ANTHROPIC_API_KEY` in a project-level `.env` file or use direnv to automatically load project-specific environment variables when you enter a directory. Claude Code reads the key from the environment, so per-directory env files work seamlessly.

### Why is the claude command not found after installation?

The installation directory is not in your PATH. Run `which claude` to check if it is accessible. If not, add the npm global bin directory to your PATH: `export PATH=$(npm bin -g):$PATH` and add this line to your shell profile (`~/.bashrc` or `~/.zshrc`).


## Related Guides

- [Optimal Skill File Size and Complexity](/optimal-skill-file-size-and-complexity-guidelines/)
- [Claude Code Large File Refactoring](/best-way-to-use-claude-code-for-large-file-refactoring/)
- [Declaration File .d.ts Missing Error — Fix (2026)](/claude-code-declaration-file-dts-missing-fix-2026/)
- [Claude Code Enoent No Such File](/claude-code-enoent-no-such-file-directory-skill/)

## Terminal and CLI Setup for Claude Code

A properly configured terminal improves Claude Code's reliability and your development experience:

**Shell compatibility.** Claude Code supports bash, zsh, and fish shells. Zsh (default on macOS) and bash (default on Linux) have the best compatibility. Fish shell requires additional configuration because its syntax differs from POSIX shells.

**Tab completion setup.** Claude Code provides shell completions that help you type commands faster:

```bash
# For zsh (macOS default)
claude completion zsh > ~/.zsh/completions/_claude
source ~/.zshrc

# For bash
claude completion bash > /etc/bash_completion.d/claude
source ~/.bashrc

# For fish
claude completion fish > ~/.config/fish/completions/claude.fish
```

**Terminal emulator recommendations.** Use a terminal that supports 256 colors, Unicode, and does not mangle escape sequences. Recommended: iTerm2 (macOS), Alacritty (cross-platform), Windows Terminal (Windows). Avoid: old versions of Terminal.app, PuTTY, or CMD.exe.

## Command-Line Flags Reference

| Flag | Purpose | Example |
|------|---------|---------|
| `-p "prompt"` | Non-interactive (pipe mode) | `claude -p "list all TODO comments"` |
| `--trust` | Skip workspace trust prompt | `claude --trust -p "run tests"` |
| `--yes` | Auto-approve all tool calls | `claude --yes -p "fix lint errors"` |
| `--model` | Override default model | `claude --model claude-sonnet-4-20250514 -p "quick fix"` |
| `--verbose` | Show debug output | `claude --verbose -p "diagnose build failure"` |
