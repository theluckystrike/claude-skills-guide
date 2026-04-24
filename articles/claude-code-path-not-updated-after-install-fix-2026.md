---
title: "PATH Not Updated After Install — Fix"
permalink: /claude-code-path-not-updated-after-install-fix-2026/
description: "Fix PATH not updated after Claude Code install. Source your shell rc file or open a new terminal to pick up PATH changes."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
$ claude --version
zsh: command not found: claude
$ ls ~/.npm-global/bin/claude
/Users/you/.npm-global/bin/claude
```

The binary exists at the expected location but your current shell session does not have the updated PATH. This typically happens right after modifying `.zshrc` or `.bashrc`.

## The Fix

1. Source your shell configuration:

```bash
source ~/.zshrc
# or for bash users:
source ~/.bashrc
```

2. Verify PATH now includes the npm bin directory:

```bash
echo $PATH | tr ':' '\n' | grep npm
```

3. Confirm claude is accessible:

```bash
which claude && claude --version
```

## Why This Happens

When you add a directory to PATH in your `.zshrc` or `.bashrc`, it only takes effect in new shell sessions. Your current terminal still uses the old PATH. Running `source` reloads the profile in the current session. Some installers (like nvm) modify the shell profile but do not source it automatically.

## If That Doesn't Work

- Open a completely new terminal window (not just a new tab in some terminals).
- Check if your PATH modification is in the wrong file:

```bash
echo $SHELL
# If /bin/zsh, use ~/.zshrc
# If /bin/bash, use ~/.bashrc or ~/.bash_profile
```

- Verify the export line is correct:

```bash
tail -5 ~/.zshrc
```

- If using tmux or screen, reload the environment:

```bash
tmux source-file ~/.tmux.conf
# Then open a new pane
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Shell Configuration
- After modifying PATH, always run: source ~/.zshrc
- Keep PATH modifications in one file only (.zshrc for zsh, .bashrc for bash).
- Test with: which claude — after any installation step.
```

## See Also

- [Push Rejected After Claude Rebase Fix](/claude-code-push-rejected-after-rebase-fix-2026/)
- [Detached HEAD After Claude Checkout Fix](/claude-code-detached-head-after-checkout-fix-2026/)
- [claude: command not found After Install — Fix (2026)](/claude-code-binary-not-found-after-install-fix-2026/)
