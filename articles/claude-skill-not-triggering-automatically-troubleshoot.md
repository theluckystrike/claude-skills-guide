---
layout: default
title: "Claude Skill Not Triggering: Troubleshoot Guide (2026)"
description: "Troubleshoot Claude Code skill not triggering automatically. Fix invocation syntax, file location, permissions, and YAML front matter issues."
date: 2026-03-13
author: "Claude Skills Guide"
categories: [guides]
reviewed: true
score: 8
tags: [claude-code, claude-skills, troubleshooting, invocation]
---

# Claude Skill Not Triggering Automatically: Troubleshoot Guide

You typed `/tdd` or `/pdf` in a Claude Code session and nothing happened — or Claude responded as if the skill did not exist. This is one of the most-reported issues with Claude skills, and it is almost always a configuration or file-placement problem. This guide walks through every known cause and gives you a fix for each one.

## How Skill Invocation Works

When you type `/skill-name` in Claude Code, the runtime looks for a matching `.md` file in two locations (checked in this order):

1. `.claude/skills/` inside your current project directory
2. `~/.claude/skills/` in your home directory (global skills)

The filename must match the invocation name exactly. `/tdd` looks for `tdd.md`, not `TDD.md`, not `tdd.txt`. If the file is found and readable, its YAML front matter and body are loaded into the session context. If not found, the invocation is silently dropped.

There is no automatic context-based triggering in 2026 — you must invoke skills explicitly.

## Step 1: Confirm the Skill File Exists

```bash
# Check global skills
ls ~/.claude/skills/

# Check project-local skills
ls .claude/skills/ 2>/dev/null || echo "No project-local skills directory"
```

If the file is missing, install it:

```bash
# Install globally
cp path/to/tdd.md ~/.claude/skills/tdd.md

# Install project-local
mkdir -p .claude/skills/
cp path/to/tdd.md .claude/skills/tdd.md
```

## Step 2: Verify Filename Case and Hyphens

Skill filenames are **case-sensitive** on Linux and case-preserving on macOS. Hyphens must match exactly.

| Invocation | Required filename |
|---|---|
| `/tdd` | `tdd.md` |
| `/pdf` | `pdf.md` |
| `/docx` | `docx.md` |
| `/supermemory` | `supermemory.md` |
| `/frontend-design` | `frontend-design.md` |

```bash
# Rename if case is wrong
mv ~/.claude/skills/TDD.md ~/.claude/skills/tdd.md
```

## Step 3: Check File Permissions

Claude Code must be able to read the skill file. Restrictive permissions cause silent failures:

```bash
ls -la ~/.claude/skills/
# Skill files should show -rw-r--r-- (644) or -rw-rw-r-- (664)

# Fix if needed
chmod 644 ~/.claude/skills/*.md
chmod 755 ~/.claude/skills/
```

## Step 4: Validate the YAML Front Matter

A malformed YAML block at the top of the skill file can cause issues. Verify the front matter is valid YAML with only supported fields. Claude Code skills recognize `name` and `description` in front matter:

```yaml
---
name: tdd
description: "Run tests before implementation using TDD principles"
---
```

Note: `tools:` is not a recognized front matter field and has no effect. Common YAML mistakes:
- Missing closing `---`
- Tabs instead of spaces in the YAML block
- Unquoted string values containing colons (e.g., `title: Fix: the bug` breaks YAML)

Test it:
```bash
python3 -c "
import sys
content = open('$HOME/.claude/skills/tdd.md').read()
front = content.split('---')[1]
import yaml; yaml.safe_load(front)
print('YAML OK')
"
```

## Step 5: Confirm You Are in Claude Code CLI

The `/skill-name` syntax is a **Claude Code CLI** feature. It does not work on claude.ai in the browser, in the API, or in third-party Claude integrations. Confirm you are running the CLI:

```bash
which claude
claude --version
```

If `claude` is not found, install it:
```bash
npm install -g @anthropic-ai/claude-code
```

## Step 6: Check for CLAUDE.md Auto-Invocation Config

Some workflows configure skills to load automatically via `CLAUDE.md`. If you expected automatic triggering (not manual `/skill-name` invocation), you may need to add the skill to your `CLAUDE.md`:

```markdown
<!-- CLAUDE.md in project root -->
# Project Instructions

Load the following skills at session start:
- /supermemory
- /tdd
```

Without this, `supermemory` and `tdd` skills need explicit invocation every session.

## Step 7: Debug With an Explicit Confirmation Prompt

After invoking a skill, immediately ask Claude to confirm it loaded:

```
/tdd
You have just loaded the tdd skill. Confirm this and summarize its instructions in one sentence.
```

If the skill loaded, Claude will describe it accurately. If it did not load, Claude will respond generically — which tells you the file was not read.

## Step 8: Check for Conflicting Project and Global Skill Names

If you have a `tdd.md` in both `.claude/skills/` and `~/.claude/skills/`, the project-local version takes priority. If the project-local version is outdated or broken, the global one never loads.

```bash
# See both versions
diff .claude/skills/tdd.md ~/.claude/skills/tdd.md 2>/dev/null || echo "Only one version found"
```

## Step 9: Restart the Claude Code Session

Claude Code reads skill files when the session starts, not on every invocation. If you added or modified a skill file while a session was already running, you need to restart:

```bash
# Exit the current session
exit

# Start a new session
claude
```

Then invoke your skill again.

## Checking the `pdf` and `docx` Skills Specifically

The [`pdf` skill](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) and `docx` skills have an additional dependency — the underlying tools they call must be installed. If `/pdf` triggers but then fails immediately, the skill loaded but its tool dependencies are missing:

```bash
# Check if pdftotext is available (used by the pdf skill)
which pdftotext || brew install poppler

# Check pandoc (used by docx skill)
which pandoc || brew install pandoc
```

## The `frontend-design` Skill Not Applying Conventions

If the [`frontend-design` skill](/claude-skills-guide/articles/best-claude-code-skills-for-frontend-development/) loads but ignores your project's design system, the skill file likely lacks project-specific context. The skill itself is generic — you need to customise it:

```bash
cat >> ~/.claude/skills/frontend-design.md << 'EOF'

## Project Conventions
- Use Tailwind CSS only — no inline styles
- Import components from `@/components/ui/`
- Color tokens defined in `src/tokens/colors.ts`
EOF
```

## Summary Checklist

- File exists in `~/.claude/skills/` or `.claude/skills/`
- Filename matches invocation exactly (case-sensitive)
- File permissions are `644` or more permissive
- YAML front matter is valid (no tabs, closing `---` present)
- You are using Claude Code CLI, not claude.ai browser
- Session was restarted after adding the skill file

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — Reference for the exact YAML front matter fields that control how skills are loaded and matched
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — A guide for writing skills that actually fire, covering trigger phrases, descriptions, and invocation testing
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How the matching algorithm determines whether a skill fires automatically or needs manual invocation

Built by theluckystrike — More at [zovo.one](https://zovo.one)
