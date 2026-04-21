---
title: "Homebrew vs System Python Conflict Fix"
permalink: /claude-code-homebrew-vs-system-python-conflict-fix-2026/
description: "Fix Homebrew vs system Python conflict in Claude Code. Set correct Python path in CLAUDE.md to avoid import errors from wrong Python installation."
last_tested: "2026-04-22"
render_with_liquid: false
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
