---
title: "Shell RC File Not Sourced Error — Fix"
permalink: /claude-code-shell-rc-not-sourced-fix-2026/
description: "Fix Claude Code env vars not loading because .zshrc is not sourced. Add source line to .zprofile for login shells."
last_tested: "2026-04-22"
render_with_liquid: false
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
