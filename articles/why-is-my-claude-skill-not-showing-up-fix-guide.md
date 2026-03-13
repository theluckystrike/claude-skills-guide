---
layout: default
title: "Why Is My Claude Skill Not Showing Up? Fix Guide"
description: "Complete fix guide for Claude Code skills not showing up or loading. Covers file location, naming rules, YAML parsing, permissions, and session restart steps."
date: 2026-03-13
author: theluckystrike
---

# Why Is My Claude Skill Not Showing Up? Fix Guide

You installed a Claude Code skill, you type `/skill-name`, and nothing happens. No acknowledgment from Claude, no error message, just the same default behavior as without the skill. This guide covers every reason why a Claude Code skill might not show up and gives you an ordered checklist to find and fix the issue.

## The Short Version

Claude Code skills are `.md` files in `~/.claude/skills/` (global) or `.claude/skills/` (project-local). They show up when:

1. The file exists in the right directory
2. The filename matches what you typed (case-sensitive)
3. The YAML front matter is valid
4. You are using Claude Code CLI (not the browser)
5. The session was started after the file was placed

If your skill is not showing up, one of these five conditions is not met.

## Check 1: Confirm the Skill File Location

```bash
# Global skills directory
ls ~/.claude/skills/

# Project-local skills directory
ls .claude/skills/ 2>/dev/null || echo "No project-local skills"
```

The file must be a `.md` file. A skill called `pdf` must exist as `pdf.md`. Not `pdf.txt`, not `pdf`, not `PDF.md`.

**If the directory does not exist:**
```bash
mkdir -p ~/.claude/skills
```

**If the file is missing:**
```bash
# Copy from wherever you downloaded it
cp ~/downloads/tdd.md ~/.claude/skills/tdd.md
chmod 644 ~/.claude/skills/tdd.md
```

## Check 2: Confirm the Filename Matches Your Invocation

Skill file lookup is **case-sensitive on Linux** and case-preserving on macOS.

| If you type... | The file must be... |
|---|---|
| `/tdd` | `tdd.md` |
| `/pdf` | `pdf.md` |
| `/docx` | `docx.md` |
| `/supermemory` | `supermemory.md` |
| `/frontend-design` | `frontend-design.md` |

Hyphens are literal — `/frontend-design` does NOT match `frontenddesign.md` or `frontend_design.md`.

```bash
# Find all skill files and show exact names
ls -1 ~/.claude/skills/
```

## Check 3: Verify the YAML Front Matter is Valid

A skill file with broken YAML silently fails to load. The front matter block is the `---` section at the top:

```yaml
---
description: "What this skill does"
tools:
  - Bash
  - Read
---
```

**Quick validation:**
```bash
python3 << 'EOF'
import yaml, os

path = os.path.expanduser('~/.claude/skills/tdd.md')
if not os.path.exists(path):
    print('FILE NOT FOUND')
else:
    content = open(path).read()
    parts = content.split('---')
    if len(parts) < 3:
        print('MISSING FRONT MATTER DELIMITERS')
    else:
        try:
            yaml.safe_load(parts[1])
            print('YAML OK')
        except yaml.YAMLError as e:
            print('YAML ERROR:', e)
EOF
```

**Most common YAML mistakes:**
- Tabs for indentation (must be spaces)
- Unquoted colons: `description: Handle: this case` (broken)
- Missing closing `---`
- Trailing space after `---`

## Check 4: Confirm You Are Using Claude Code CLI

The `/skill-name` invocation syntax is a Claude Code CLI feature. It does not work in:

- claude.ai browser interface
- The Anthropic API directly
- Third-party Claude integrations

Check you are running the Claude Code CLI:
```bash
which claude
claude --version
```

If `claude` is not found:
```bash
npm install -g @anthropic-ai/claude-code
```

## Check 5: Restart the Session After Adding the Skill

Claude Code reads skill files when a session starts. If you added a skill while a session was already running, it will not show up until you restart.

Exit the current session and start a new one:
```bash
# In Claude Code session
exit

# Start fresh
claude
```

Then invoke the skill again.

## Check 6: File Permissions

The skill file must be readable by the user running Claude Code:

```bash
ls -la ~/.claude/skills/
# Should show: -rw-r--r-- (644) or similar

# Fix if wrong
chmod 644 ~/.claude/skills/*.md
chmod 755 ~/.claude/skills/
```

If files are owned by root (can happen after `sudo claude`):
```bash
sudo chown -R $(whoami) ~/.claude/
```

## Check 7: Confirm the Skill Is Being Invoked Correctly

After invoking a skill, immediately ask Claude to confirm it loaded:

```
/tdd
Confirm you have loaded the tdd skill. What are your main instructions?
```

If Claude describes the skill accurately, it loaded. If Claude responds generically without mentioning the skill's content, it did not load.

## Check 8: Look for Conflicting Project vs. Global Skills

If you have both `.claude/skills/tdd.md` (project-local) and `~/.claude/skills/tdd.md` (global), the project-local version wins. If the project-local version is broken or outdated, the global one never loads.

```bash
# Check if both exist
ls .claude/skills/tdd.md 2>/dev/null && echo "PROJECT LOCAL EXISTS"
ls ~/.claude/skills/tdd.md 2>/dev/null && echo "GLOBAL EXISTS"
```

If both exist and the project-local version is broken, fix or remove it:
```bash
rm .claude/skills/tdd.md   # Remove broken project-local version
# Claude Code will now fall back to the global version
```

## Check 9: Verify the `supermemory` Skill Specifically

The `supermemory` skill needs a writable storage path. If the storage path is missing or on a read-only volume, `supermemory` may appear to load but not work:

```bash
# Default storage path
ls ~/.claude-memory/ 2>/dev/null || echo "Memory directory missing"

# Create it if missing
mkdir -p ~/.claude-memory
```

## Check 10: Check Claude Code Version

Older versions of Claude Code have skill compatibility limitations:

```bash
claude --version

# Update if outdated
npm update -g @anthropic-ai/claude-code
```

## Full Diagnostic One-Liner

```bash
python3 << 'EOF'
import yaml, os, glob
print("=== Skill Diagnostic ===")
for path in sorted(glob.glob(os.path.expanduser('~/.claude/skills/*.md'))):
    name = os.path.basename(path)
    content = open(path).read()
    parts = content.split('---')
    if len(parts) < 3:
        print(f"  BROKEN (no delimiters): {name}")
        continue
    try:
        yaml.safe_load(parts[1])
        size = os.path.getsize(path)
        perms = oct(os.stat(path).st_mode)[-3:]
        print(f"  OK [{perms}] {size}B: {name}")
    except yaml.YAMLError as e:
        print(f"  BROKEN (YAML error): {name} — {e}")
EOF
```

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
