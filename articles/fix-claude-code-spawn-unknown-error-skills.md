---
title: "Fix Claude Code Spawn Unknown Error When Running Skill Scripts — 2026"
description: "Resolve spawn UNKNOWN errors caused by missing interpreters, permission failures, script encoding issues, and shell configuration in skills."
permalink: /fix-claude-code-spawn-unknown-error-skills/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, spawn-error, scripts, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

Your skill bundles a Python script. When Claude tries to execute it, you see an error like "spawn UNKNOWN" or "spawn ENOENT" in the output. The script runs fine when you execute it directly in your terminal. But when Claude's Bash tool tries to run it through the skill, the process fails to spawn. The issue is in the execution environment, not the script logic.

## Technical Foundation

Claude Code executes shell commands through Node.js's `child_process.spawn()`. The "spawn UNKNOWN" error occurs when the operating system cannot start the requested process. Common causes:

- The interpreter (python3, bash, node) is not in the PATH visible to Claude Code
- The script has Windows-style line endings (CRLF) that break the shebang line
- The file lacks execute permissions
- The `shell` frontmatter field does not match the command syntax

The `shell` field in SKILL.md frontmatter controls which shell processes `!`command`` and ` ```! ` blocks. It accepts `bash` (default) or `powershell`. This does not affect commands Claude runs via the Bash tool -- those always use the system shell.

## The Working SKILL.md

A skill with correct script execution setup:

```yaml
---
name: analyze-deps
description: >
  Analyze project dependencies for security vulnerabilities and
  outdated packages. Use when the user says "check dependencies",
  "audit packages", or "find vulnerable deps".
allowed-tools: Bash(python3 *) Bash(bash *) Bash(which *)
---

# Analyze Dependencies

Run the dependency analysis script.

## Prerequisites Check

Before running the script, verify the interpreter exists:
```bash
which python3 || echo "ERROR: python3 not found in PATH"
```

## Run Analysis

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/analyze.py
```

If python3 is not available, try:
```bash
python ${CLAUDE_SKILL_DIR}/scripts/analyze.py
```
```

## Cause 1: Interpreter Not in PATH

Claude Code inherits the PATH from the shell environment. If `python3` is not in PATH (e.g., installed via pyenv, conda, or nvm but not exported), the spawn fails.

```bash
# Check if the interpreter is available
which python3
which node
which bash

# Check Claude Code's PATH
echo $PATH
```

Fix for pyenv/conda users:

```bash
# Add to ~/.bashrc or ~/.zshrc:
export PATH="$HOME/.pyenv/shims:$PATH"
# or for conda:
export PATH="$HOME/miniconda3/bin:$PATH"
```

After updating PATH, restart Claude Code (it inherits environment at startup).

## Cause 2: Windows Line Endings (CRLF)

Scripts with CRLF line endings fail on Unix systems because the shebang line becomes `#!/usr/bin/env python3\r` -- the `\r` is treated as part of the interpreter name.

```bash
# Check for CRLF
file .claude/skills/analyze-deps/scripts/analyze.py
# If output contains "CRLF line terminators", that's the issue

# Fix: convert to LF
sed -i 's/\r$//' .claude/skills/analyze-deps/scripts/analyze.py

# Or use dos2unix if available
dos2unix .claude/skills/analyze-deps/scripts/analyze.py
```

Prevention: Add to `.gitattributes`:

```
*.sh text eol=lf
*.py text eol=lf
```

## Cause 3: Missing Shebang or Wrong Shebang

If a script lacks a shebang line and is executed directly (not via `python3 script.py`), the OS does not know which interpreter to use.

```python
# BROKEN: no shebang, executed as ./script.py
# OS doesn't know this is Python

# FIXED: add shebang
#!/usr/bin/env python3
"""Analyze dependencies."""
import json
# ...
```

Use `#!/usr/bin/env python3` instead of `#!/usr/bin/python3` for portability across different systems.

## Cause 4: Execute Permissions Missing

```bash
# Check permissions
ls -la .claude/skills/analyze-deps/scripts/

# If -rw-r--r-- (no x):
chmod +x .claude/skills/analyze-deps/scripts/analyze.py
chmod +x .claude/skills/analyze-deps/scripts/*.sh

# Commit with execute bit
git add .claude/skills/analyze-deps/scripts/
git commit -m "fix: add execute permissions to skill scripts"
```

## Cause 5: Shell Mismatch for Dynamic Injection

The `shell` frontmatter field controls dynamic context injection:

```yaml
# If your !`command` uses PowerShell syntax on Windows:
---
shell: powershell
---

# If using bash syntax (default):
---
shell: bash
---
```

If `shell: powershell` is set but the system only has bash, `!`command`` blocks fail with spawn errors.

## Diagnostic Skill

Create a skill that diagnoses execution environment issues:

```yaml
---
name: check-env
description: Check the execution environment for skill compatibility
disable-model-invocation: true
allowed-tools: Bash(which *) Bash(echo *) Bash(file *) Bash(ls *)
---

# Environment Check

Run these diagnostics:

1. Check interpreters:
   ```bash
   echo "bash: $(which bash 2>/dev/null || echo 'NOT FOUND')"
   echo "python3: $(which python3 2>/dev/null || echo 'NOT FOUND')"
   echo "python: $(which python 2>/dev/null || echo 'NOT FOUND')"
   echo "node: $(which node 2>/dev/null || echo 'NOT FOUND')"
   ```

2. Check PATH:
   ```bash
   echo "PATH: $PATH"
   ```

3. Check skill directory:
   ```bash
   ls -laR ${CLAUDE_SKILL_DIR}/scripts/ 2>/dev/null || \
     echo "No scripts directory"
   ```

4. Check line endings:
   ```bash
   for f in ${CLAUDE_SKILL_DIR}/scripts/*; do
     echo "$f: $(file "$f" | grep -o 'CRLF\|ASCII\|UTF-8')"
   done
   ```
```

## Common Problems and Fixes

**Python works in terminal but not in Claude**: Claude Code may not inherit your shell's pyenv/nvm initialization. These tools modify PATH in `.bashrc`/`.zshrc` profile scripts. Ensure PATH is set in a location that Claude Code reads at startup.

**Script runs on macOS but fails on Linux (or vice versa)**: macOS uses `/usr/bin/env` differently than some Linux distributions. Use `#!/usr/bin/env python3` and test on both platforms.

**spawn error only happens in CI**: CI containers may not have the required interpreters installed. Add installation steps to your CI workflow, or ensure the skill documents its runtime dependencies.

**Error only on first run**: Some interpreters (especially pyenv, rbenv) need a shim refresh. Run `pyenv rehash` or equivalent before starting Claude Code.

## Production Gotchas

The `allowed-tools` field pre-approves commands but does not install interpreters. `Bash(python3 *)` tells Claude it can run python3 without prompting, but if python3 is not installed, the spawn still fails.

When distributing skills via plugins or git, document the runtime dependencies. Add a "Prerequisites" section to the SKILL.md body listing required interpreters and their minimum versions.

The `disableSkillShellExecution: true` setting prevents `!`command`` execution but does NOT prevent Claude from running scripts via the Bash tool. It only affects the dynamic context injection syntax. If scripts fail only in `!`command`` blocks, check this setting.

## Checklist

- [ ] Required interpreters (python3, node, bash) in PATH
- [ ] Scripts have execute permissions (chmod +x)
- [ ] No CRLF line endings on Unix systems
- [ ] Shebang line uses `#!/usr/bin/env interpreter`
- [ ] `shell` frontmatter field matches system capabilities

## Related Guides

- [Claude Skills with Embedded Scripts](/claude-skills-with-embedded-scripts/)
- [Fix ENOENT No Such File or Directory Error](/fix-claude-code-enoent-skills/)
- [Fix Claude Skill Timeout Errors](/fix-claude-skill-timeout-errors/)
