---
layout: default
title: "nvm Switching to Wrong Node Version (2026)"
permalink: /claude-code-nvm-switching-wrong-node-fix-2026/
date: 2026-04-20
description: "nvm Switching to Wrong Node Version — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## The Error

```
$ nvm use 22
Now using node v22.12.0
$ cd ~/myproject
$ node --version
v16.20.2
$ claude
Error: Claude Code requires Node.js 18 or higher.
```

This error occurs when nvm auto-switches to an old Node version specified by a project's `.nvmrc` file or when the default alias points to an old version.

## The Fix

1. Set the nvm default to Node 22:

```bash
nvm alias default 22
```

2. Verify the default is set:

```bash
nvm alias default
# Should show: default -> 22 (-> v22.x.x)
```

3. If the project has an `.nvmrc` file with an old version, update it:

```bash
echo "22" > .nvmrc
nvm use
```

4. Reinstall Claude Code on the correct Node:

```bash
nvm use default
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

nvm manages multiple Node versions and switches between them. If a project has an `.nvmrc` file specifying Node 16 and you have nvm auto-switching enabled, entering that directory switches to Node 16. Global packages (like Claude Code) installed on Node 22 are not available when nvm switches to Node 16. Each Node version has its own global package directory.

## If That Doesn't Work

- Install Claude Code on every Node version you use:

```bash
nvm use 16 && npm install -g @anthropic-ai/claude-code
nvm use 18 && npm install -g @anthropic-ai/claude-code
nvm use 22 && npm install -g @anthropic-ai/claude-code
```

- Disable auto-switching by removing the nvm cd hook from your shell profile.
- Use `npx @anthropic-ai/claude-code` which does not depend on global installs.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# nvm Configuration
- Set nvm alias default 22 to ensure Claude Code always works.
- Update .nvmrc to 22 in all active projects.
- If you must use Node 16 for a project, install Claude Code on that version too.
```

## See Also

- [Wrong Node.js Version in PATH Fix](/claude-code-wrong-node-version-in-path-fix-2026/)
- [Claude Amending Wrong Commit Fix](/claude-code-amending-wrong-commit-fix-2026/)


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

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [CLAUDE.md Version Control Strategies](/claude-md-version-control-strategies/)
- [Claude Code for Version Matrix Workflow](/claude-code-for-version-matrix-workflow-tutorial-guide/)
- [Claude Code Version History and Changes](/claude-code-version-history-changes-2026/)
- [TLS Version Negotiation Failure — Fix](/claude-code-tls-version-negotiation-failure-fix-2026/)

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
