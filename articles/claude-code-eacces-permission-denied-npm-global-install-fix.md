---
title: "Claude Code EACCES Permission Denied (2026)"
description: "Fix Claude Code EACCES permission denied on npm global install. Change npm prefix to home directory. Step-by-step solution."
permalink: /claude-code-eacces-permission-denied-npm-global-install-fix/
last_tested: "2026-04-21"
---

## The Error

```
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /usr/local/lib/node_modules/@anthropic-ai/claude-code
npm ERR! errno -13
npm ERR! Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/@anthropic-ai/claude-code'
npm ERR! Please try running this command again as root/Administrator.
```

## The Fix

1. **Set npm's global prefix to a user-owned directory (never use sudo)**

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
```

2. **Add the new path to your shell profile**

```bash
# For zsh (macOS default):
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For bash:
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

3. **Verify the fix:**

```bash
npm install -g @anthropic-ai/claude-code
claude --version
# Expected: @anthropic-ai/claude-code/X.X.X
```

## Why This Happens

The default npm global install directory (`/usr/local/lib/node_modules`) is owned by root on most systems. Running `npm install -g` as your user account fails because it cannot write to root-owned directories. Using `sudo npm install -g` creates files owned by root that cause further permission issues later. The correct fix is changing npm's prefix to a directory your user account controls.

## If That Doesn't Work

- **Alternative 1:** Use `npx @anthropic-ai/claude-code` to run without global install — it downloads and executes in one step
- **Alternative 2:** Install via `nvm` which manages its own prefix: `nvm install 20 && npm install -g @anthropic-ai/claude-code`
- **Check:** Run `npm config get prefix` and `ls -la $(npm config get prefix)/lib/node_modules/` to verify ownership

## Prevention

Add to your `CLAUDE.md`:
```markdown
Never use sudo for npm install -g. Set npm prefix to ~/.npm-global. Use nvm or volta for Node.js version management to avoid system permission conflicts.
```

**Related articles:** [Claude Code Command Not Found Fix](/claude-code-command-not-found-after-install-fix/), [NPM Install EACCES Fix](/claude-code-npm-install-eacces-permission-fix/), [Troubleshooting Hub](/troubleshooting-hub/)


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
- [npm Global Install Permission Denied — Fix (2026)](/claude-code-npm-global-install-permission-denied-fix-2026/)
- [EACCES npm Cache Permission Error — Fix (2026)](/claude-code-eacces-npm-cache-fix-2026/)


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

- [EACCES Permission Denied Config Dir — Fix (2026)](/claude-code-config-dir-permission-denied-fix-2026/)
- [Claude Code Skill Permission Denied](/claude-code-skill-permission-denied-error-fix-2026/)
- [Claude Code Permission Denied Shell](/claude-code-permission-denied-shell-commands-fix/)
- [Claude Code Permission Denied](/claude-code-permission-denied-when-executing-skill-commands/)

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
