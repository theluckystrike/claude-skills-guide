---
layout: default
title: "Windows WSL Path Conflict Error — Fix (2026)"
permalink: /claude-code-windows-wsl-path-conflict-fix-2026/
date: 2026-04-20
description: "Windows WSL Path Conflict Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
/mnt/c/Program Files/nodejs/node.exe: cannot execute binary file: Exec format error
$ which node
/mnt/c/Program Files/nodejs/node.exe
```

This error occurs in WSL when the PATH includes Windows directories, causing WSL to try running the Windows `node.exe` binary instead of a Linux-native node binary.

## The Fix

1. Install Node.js natively inside WSL:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install 22
```

2. Remove Windows paths from WSL PATH:

```bash
echo '[interop]
appendWindowsPath = false' | sudo tee -a /etc/wsl.conf
```

3. Restart WSL:

```powershell
# In Windows PowerShell:
wsl --shutdown
```

4. Reinstall Claude Code inside WSL:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

WSL2 by default appends Windows PATH entries to the Linux PATH. This means `node`, `npm`, and other commands resolve to their Windows `.exe` versions in `/mnt/c/Program Files/nodejs/`. These Windows binaries cannot execute in the Linux environment, causing "Exec format error." Claude Code must run with Linux-native Node.js inside WSL.

## If That Doesn't Work

- Manually override the PATH to prioritize WSL node:

```bash
export PATH="$HOME/.nvm/versions/node/v22.12.0/bin:$PATH"
echo 'export PATH="$HOME/.nvm/versions/node/v22.12.0/bin:$PATH"' >> ~/.bashrc
```

- Verify you are running the correct binary:

```bash
file $(which node)
# Should say: ELF 64-bit LSB executable (Linux)
# Not: PE32+ executable (Windows)
```

- If you need Windows interop for other tools, selectively remove only the nodejs path.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# WSL Configuration
- Set appendWindowsPath = false in /etc/wsl.conf.
- Install Node.js via nvm inside WSL, not from Windows.
- Always verify: file $(which node) shows ELF, not PE32+.
```

## See Also

- [Devcontainer Claude Code Path Missing Fix](/claude-code-devcontainer-path-missing-fix-2026/)
- [Certificate Pinning Conflict Error — Fix (2026)](/claude-code-certificate-pinning-conflict-fix-2026/)
- [Git Worktree Lock Conflict Fix](/claude-code-worktree-lock-conflict-fix-2026/)
- [Peer Dependency Conflict npm Error — Fix (2026)](/claude-code-peer-dependency-conflict-fix-2026/)
- [Claude Code Prettier Format Conflict — Fix (2026)](/claude-code-prettier-format-conflict-fix/)


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

**Quick setup →** Launch your project with our [Project Starter](/starter/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [PATH Not Updated After Install — Fix](/claude-code-path-not-updated-after-install-fix-2026/)
- [Claude Code Golden Path Templates &](/claude-code-golden-path-templates-workflow-tutorial/)
- [Wrong Node.js Version in PATH Fix](/claude-code-wrong-node-version-in-path-fix-2026/)
- [Claude Code Write Path Outside — Fix (2026)](/claude-code-write-tool-path-outside-workspace-fix-2026/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
