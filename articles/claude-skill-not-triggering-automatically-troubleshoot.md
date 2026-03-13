---
layout: post
title: "Claude Skill Not Triggering? Troubleshooting Guide"
description: "Claude skill not triggering when you type /skill-name? This guide covers installation checks, file location, invocation syntax, and common configuration issues."
date: 2026-03-13
categories: [guides, tutorials]
tags: [claude-code, claude-skills, troubleshooting, debugging]
author: "Claude Skills Guide"
reviewed: true
score: 5
---

# Claude Skill Not Triggering Automatically? Here's How to Troubleshoot

Claude skills are invoked manually with `/skill-name` — they do not activate automatically based on context detection or relevance scoring. If your skill is not responding when you type `/skill-name`, the issue is almost always one of: the skill file does not exist where Claude looks, the filename does not match what you typed, or there is a permission problem preventing Claude from reading the file.

This guide walks through each cause systematically.

## How Skill Invocation Actually Works

When you type `/tdd` or `/pdf` in a Claude Code session, Claude looks for a file named `tdd.md` or `pdf.md` in:

1. `.claude/skills/` in your current project directory (project-local skills)
2. `~/.claude/skills/` in your home directory (global skills)

If the file is found and readable, its contents are loaded into the conversation as instructions. If the file is not found, Claude either ignores the invocation or treats it as plain text.

There is no automatic triggering based on what you are doing — you must invoke the skill explicitly.

## Step 1: Verify the Skill File Exists

Check both locations:

```bash
# Check global skills
ls ~/.claude/skills/

# Check project-local skills
ls .claude/skills/
```

If your skill does not appear in either listing, it is not installed. For community or built-in skills, copy the `.md` file to the appropriate directory:

```bash
# Install a skill globally
cp tdd.md ~/.claude/skills/tdd.md

# Or install it for the current project only
mkdir -p .claude/skills/
cp tdd.md .claude/skills/tdd.md
```

## Step 2: Check the Filename Matches Your Invocation

Skill filenames are case-sensitive and must match exactly. If the file is named `TDD.md` and you type `/tdd`, it will not be found on case-sensitive filesystems (Linux). The file must be `tdd.md` to match `/tdd`.

Common mismatches:

| What you type | File must be named |
|---------------|-------------------|
| `/tdd` | `tdd.md` |
| `/frontend-design` | `frontend-design.md` |
| `/pdf` | `pdf.md` |
| `/supermemory` | `supermemory.md` |

```bash
# Rename if the case is wrong
mv ~/.claude/skills/TDD.md ~/.claude/skills/tdd.md
```

## Step 3: Check File Permissions

Claude Code must be able to read the skill file. If the file is not world-readable, it may fail silently:

```bash
# Check permissions
ls -la ~/.claude/skills/

# Fix if needed (skills should be readable)
chmod 644 ~/.claude/skills/*.md
chmod 755 ~/.claude/skills/
```

## Step 4: Confirm You Are in a Claude Code Session

Skill invocation with `/skill-name` is a Claude Code feature. If you are using Claude through claude.ai in a browser, the `/skill-name` syntax is not supported — skills only work in Claude Code (the CLI tool).

Verify you are in an active Claude Code session:

```bash
# Start Claude Code if not already running
claude
```

## Step 5: Check for Typos and Hyphenation

Hyphens in skill names must be exact. `/frontend-design` is different from `/frontenddesign` or `/frontend design` (with a space). Check the actual filename:

```bash
ls ~/.claude/skills/ | grep -i frontend
```

Use the exact name shown in the listing as your `/skill-name` invocation.

## Step 6: Explicit Invocation Debugging

If you are unsure whether the skill is loading, ask Claude directly after invoking it:

```
/tdd
Confirm you have loaded the tdd skill and summarize
its instructions in one sentence.
```

If the skill loaded, Claude will describe its purpose. If it did not load, Claude will respond without the skill's context — often just treating `/tdd` as part of your message.

## Practical Examples

### PDF Skill Not Responding

```bash
# Check the file exists and has the right name
ls -la ~/.claude/skills/pdf.md

# If missing, install it
# If present, verify permissions:
chmod 644 ~/.claude/skills/pdf.md
```

Then invoke:
```
/pdf
Extract the table of contents from contract.pdf
```

### TDD Skill Not Applying Test-First Behavior

If you invoke `/tdd` and Claude jumps straight to implementation without writing tests first, the skill file may not be loading. Verify:

```bash
ls ~/.claude/skills/tdd.md
# Should exist and be readable
```

If the file is present and readable but behavior seems wrong, check the file content:

```bash
cat ~/.claude/skills/tdd.md
```

The skill file should contain instructions telling Claude to write tests before implementation. If the file is empty or malformed, that explains the behavior.

### Frontend-Design Skill Ignoring Project Conventions

If `/frontend-design` is not applying your design system conventions, the skill file likely does not include them. Edit the skill to add your project-specific instructions:

```bash
# Add project context to the skill
echo "\n## Project Conventions\n- Use Tailwind classes only\n- Colors from /packages/ui/tokens.ts" >> ~/.claude/skills/frontend-design.md
```

## Preventing Future Issues

1. Keep skill files in `~/.claude/skills/` with permissions `644`
2. Name files exactly as you intend to invoke them (`/tdd` → `tdd.md`)
3. For project-specific skills, use `.claude/skills/` in the project root
4. Periodically run `ls ~/.claude/skills/` to audit what is installed

## Summary

Claude skills do not trigger automatically — you invoke them with `/skill-name`. If invocation is not working, check that the file exists in `~/.claude/skills/` or `.claude/skills/`, the filename matches your invocation exactly (case-sensitive), and the file has read permissions. Those three checks resolve the vast majority of issues.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Full developer skill stack including tdd
- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/articles/best-claude-skills-for-devops-and-deployment/) — Automate deployments with Claude skills
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically
