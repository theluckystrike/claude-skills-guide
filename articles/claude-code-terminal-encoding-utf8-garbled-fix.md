---
layout: default
title: "Claude Code Terminal UTF-8 Garbled (2026)"
description: "Fix Claude Code terminal encoding UTF-8 garbled output. Set locale and terminal encoding to UTF-8 correctly. Step-by-step solution."
permalink: /claude-code-terminal-encoding-utf8-garbled-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Output: â€™re â€" â€œhelloâ€
  (Should show: 're — "hello")

# Or:
\xe2\x80\x99re \xe2\x80\x94 \xe2\x80\x9chello\xe2\x80\x9d

# Or:
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 14:
  ordinal not in range(128)

# Or Claude Code rendering:
â–ˆ â–' â—† (should show block characters for progress bars)
```

## The Fix

1. **Set your locale to UTF-8**

```bash
# Check current locale
locale

# Set UTF-8 locale (add to ~/.zshrc or ~/.bashrc)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# Apply immediately
source ~/.zshrc
```

2. **Configure your terminal emulator for UTF-8**

```bash
# For iTerm2: Preferences > Profiles > Terminal > Character Encoding: UTF-8
# For Terminal.app: Preferences > Profiles > Advanced > Text encoding: UTF-8
# For VS Code integrated terminal: already UTF-8 by default

# Verify terminal supports Unicode
echo "Test: \u2713 \u2717 \u2192 \u2022"
# Expected: Test: checkmark, X, arrow, bullet
```

3. **Verify the fix:**

```bash
locale | grep UTF-8 && echo "Locale OK" || echo "Locale NOT UTF-8"
python3 -c "print('\u2713 Unicode works: em-dash \u2014 smart quotes \u201c\u201d')"
claude --version
# Expected: Locale OK, readable Unicode characters, version number
```

## Why This Happens

Claude's responses frequently contain Unicode characters: smart quotes, em-dashes, code block borders, and special symbols. When the terminal's encoding doesn't match (ASCII or Latin-1 instead of UTF-8), multi-byte UTF-8 sequences are interpreted as individual bytes, producing garbled `â€™` patterns. This affects SSH sessions (which inherit the remote locale), Docker containers (which often default to POSIX/C locale), and Linux servers where `en_US.UTF-8` locale isn't generated.

## If That Doesn't Work

- **Alternative 1:** On Linux, generate the locale: `sudo locale-gen en_US.UTF-8 && sudo update-locale LANG=en_US.UTF-8`
- **Alternative 2:** In Docker, add to Dockerfile: `ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8` and install locales package
- **Check:** Run `echo $TERM` (should be `xterm-256color` or similar) and `tput colors` (should be 256) to verify terminal capabilities

## Prevention

Add to your `CLAUDE.md`:
```markdown
Ensure LANG=en_US.UTF-8 is set in all environments where Claude Code runs. In Docker, install the locales package and set ENV LANG. For SSH sessions, forward locale with SendEnv LANG in ssh_config. Test Unicode output before long sessions.
```

**Related articles:** [Claude Code Not Responding Fix](/claude-code-not-responding-terminal-hangs-fix/), [Docker Container Setup](/claude-code-with-docker-containers-guide/), [Troubleshooting Hub](/troubleshooting-hub/)

## See Also

- [Terminal Emulator Rendering Artifacts Fix](/claude-code-terminal-rendering-artifacts-fix-2026/)


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

- [Claude Code for Chalk Terminal Styling](/claude-code-for-chalk-feature-workflow-tutorial/)
- [Claude Code vs Warp AI Terminal](/claude-code-vs-warp-ai-terminal-2026/)
- [Claude Code for Kitty Terminal](/claude-code-for-kitty-terminal-workflow-guide/)
- [Claude Code for Tabby Terminal](/claude-code-for-tabby-terminal-workflow-guide/)

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
