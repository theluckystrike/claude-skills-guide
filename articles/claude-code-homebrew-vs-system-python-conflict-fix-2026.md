---
layout: default
title: "Homebrew vs System Python Conflict Fix (2026)"
permalink: /claude-code-homebrew-vs-system-python-conflict-fix-2026/
date: 2026-04-20
description: "Fix Homebrew vs system Python conflict in Claude Code. Set correct Python path in CLAUDE.md to avoid import errors from wrong Python installation."
last_tested: "2026-04-22"
---

## The Error

```
ImportError: No module named 'requests'
  Python path: /usr/bin/python3 (macOS system Python 3.9.6)
  Packages installed in: /opt/homebrew/lib/python3.12/site-packages/
  Claude Code used system Python but packages are in Homebrew Python
```

This appears when Claude Code runs Python using the system binary while packages are installed under a different Homebrew Python installation.

## The Fix

```bash
# Add to CLAUDE.md:
# Always use /opt/homebrew/bin/python3 for Python commands on this project.
# Never use bare 'python' or 'python3' as it may resolve to system Python.
```

1. Tell Claude Code to use the full path to the correct Python.
2. Verify which Python has your packages: `/opt/homebrew/bin/python3 -c "import requests"`.
3. Add the instruction to CLAUDE.md so it persists across sessions.

## Why This Happens

macOS ships with a system Python at `/usr/bin/python3` (often 3.9.x, read-only). Homebrew installs a newer Python at `/opt/homebrew/bin/python3` (3.12+). `pip install` adds packages to whichever Python ran pip. If you installed packages with `pip3 install requests` and pip3 points to Homebrew Python, but Claude Code runs `python3 script.py` which resolves to system Python, the import fails because system Python does not have those packages.

## If That Doesn't Work

Check all Python installations and their package paths:

```bash
which -a python3
/usr/bin/python3 -c "import sys; print(sys.path)"
/opt/homebrew/bin/python3 -c "import sys; print(sys.path)"
```

Create an alias in your shell profile:

```bash
echo 'alias python3=/opt/homebrew/bin/python3' >> ~/.zshrc
echo 'alias pip3=/opt/homebrew/bin/pip3' >> ~/.zshrc
source ~/.zshrc
```

Use pyenv to manage Python versions consistently:

```bash
brew install pyenv
pyenv install 3.12.0
pyenv global 3.12.0
eval "$(pyenv init -)"
```

## Prevention

```markdown
# CLAUDE.md rule
Use /opt/homebrew/bin/python3 for all Python commands on macOS. Or use the project virtualenv: source .venv/bin/activate. Never rely on bare 'python3' resolving to the correct installation.
```

## See Also

- [Homebrew Formula Outdated Error — Fix (2026)](/claude-code-homebrew-formula-outdated-fix-2026/)


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

- [Claude Code for Buck2 Build System](/claude-code-for-buck2-build-system-workflow-guide/)
- [Claude Code Hooks System](/understanding-claude-code-hooks-system-complete-guide/)
- [Claude Code for Trading System](/claude-code-trading-system-backtesting-2026/)
- [Read Claude Code System Prompts Repo](/how-to-read-claude-code-system-prompts-2026/)

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
