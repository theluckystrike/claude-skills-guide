---
title: "Claude Code Terminal UTF-8 Garbled"
description: "Fix Claude Code terminal encoding UTF-8 garbled output. Set locale and terminal encoding to UTF-8 correctly. Step-by-step solution."
permalink: /claude-code-terminal-encoding-utf8-garbled-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
