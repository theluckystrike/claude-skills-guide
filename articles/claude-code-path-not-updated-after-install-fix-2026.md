---
layout: default
title: "PATH Not Updated After Install — Fix (2026)"
permalink: /claude-code-path-not-updated-after-install-fix-2026/
date: 2026-04-20
description: "Fix PATH not updated after Claude Code install. Source your shell rc file or open a new terminal to pick up PATH changes."
last_tested: "2026-04-22"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Before and After](/before-and-after-switching-to-claude-code-workflow/)
- [Prisma Generate Failure After Schema](/claude-code-prisma-generate-failure-fix-2026/)
- [Fix Claude Code Not Working After](/claude-code-not-working-after-update-how-to-fix/)
- [Fix Claude Command Not Found After](/claude-code-command-not-found-after-install-troubleshooting/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
