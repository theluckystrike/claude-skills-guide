---
title: "Locale LC_ALL Not Set Encoding Errors Fix"
permalink: /claude-code-locale-lc-all-not-set-encoding-errors-fix-2026/
description: "Fix locale LC_ALL not set causing encoding errors in Claude Code. Set LC_ALL=en_US.UTF-8 to resolve character encoding issues in file operations."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
  LC_ALL = (unset), LANG = "C"
Python UnicodeDecodeError: 'ascii' codec can't decode byte 0xc3
Claude Code file operations failing on non-ASCII filenames and content
```

This appears when the system locale is not configured for UTF-8, causing encoding failures in file operations, grep results, and script execution.

## The Fix

```bash
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
claude
```

1. Set the locale to UTF-8 for the current session.
2. Add both exports to your `~/.zshrc` or `~/.bashrc` for persistence.
3. Restart Claude Code to pick up the new locale.

## Why This Happens

Docker containers, minimal Linux installations, and SSH sessions often have `LC_ALL` unset or set to `C`/`POSIX`, which defaults to ASCII encoding. Claude Code processes UTF-8 text (source code with Unicode identifiers, comments in other languages, emoji in strings). When the locale is ASCII, tools like `grep`, `sort`, `perl`, and Python scripts fail on any non-ASCII byte. This cascades into Claude Code's file reading and writing operations.

## If That Doesn't Work

Install the locale on Linux:

```bash
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
```

In Docker, add locale installation to the Dockerfile:

```dockerfile
RUN apt-get update && apt-get install -y locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
```

Verify locale is correctly set:

```bash
locale
# All values should show en_US.UTF-8 or similar UTF-8 locale
```

## Prevention

```markdown
# CLAUDE.md rule
Set LC_ALL=en_US.UTF-8 and LANG=en_US.UTF-8 in shell profile, Docker images, and CI configs. Verify with 'locale' command — all values must show UTF-8. Never use LANG=C for development.
```
