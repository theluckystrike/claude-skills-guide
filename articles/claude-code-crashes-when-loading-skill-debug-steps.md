---
layout: post
title: "Claude Code Crashes When Loading Skill: Debug Steps"
description: "Fix Claude Code skill loading crashes: YAML front matter errors, file permissions, skill directory structure, and systematic isolation techniques."
date: 2026-03-13
categories: [guides, tutorials]
tags: [claude-code, claude-skills, debugging, troubleshooting]
author: "Claude Skills Guide"
reviewed: true
score: 6
---

# Claude Code Crashes When Loading Skill: Debug Steps

When Claude Code fails loading a skill, it usually comes down to one of three things: invalid YAML in the skill file, a missing file, or a naming mismatch. Here's a systematic approach to find and fix the problem.

## What a Skill File Actually Is

Claude Code skills are single `.md` files — plain Markdown with YAML front matter. There are no companion `.js` files, no compiled assets, no build steps. The entire skill lives in one file:

```
~/.claude/skills/
└── my-skill.md
```

If you're expecting a directory structure with `skill.js` or `skill.json`, that's the source of the crash.

## Step 1: Check the File Exists

Verify the skill file is where Claude Code expects it:

```bash
ls -la ~/.claude/skills/
```

If the file is missing or misnamed, Claude can't load it. Skill names are case-sensitive — `TDD.md` and `tdd.md` are different.

## Step 2: Validate YAML Front Matter

The most common crash cause is malformed YAML at the top of the skill file. The front matter must be valid YAML between `---` delimiters:

```yaml
---
name: my-skill
description: "What this skill does"
---
```

Common YAML mistakes that cause crashes:

```yaml
# BROKEN — colon in unquoted string
description: Handles: multiple cases

# FIXED
description: "Handles: multiple cases"
```

```yaml
# BROKEN — mixed indentation (tabs vs spaces)
config:
  option: true
	other: false   # tab here breaks YAML

# FIXED — consistent 2-space indentation
config:
  option: true
  other: false
```

Validate your YAML with:

```bash
python3 -c "import yaml; yaml.safe_load(open('~/.claude/skills/my-skill.md').read())"
```

Or use `yamllint`:

```bash
pip install yamllint
yamllint ~/.claude/skills/my-skill.md
```

## Step 3: Check File Permissions

Claude Code needs read access to skill files:

```bash
# Fix permissions if needed
chmod 644 ~/.claude/skills/my-skill.md

# Check ownership
ls -la ~/.claude/skills/
```

If the file is owned by root or another user, Claude Code may fail silently.

## Step 4: Isolate the Problem Skill

If you have multiple skills and only some are crashing, isolate by temporarily moving others out:

```bash
mkdir ~/.claude/skills.disabled
mv ~/.claude/skills/*.md ~/.claude/skills.disabled/

# Re-add one at a time to find the bad one
mv ~/.claude/skills.disabled/suspected-bad.md ~/.claude/skills/
```

Restart Claude Code after each move and test if the crash reproduces.

## Step 5: Check for Encoding Issues

Skills copied from Windows or certain editors sometimes have UTF-16 encoding or Windows line endings (`\r\n`) that break YAML parsing:

```bash
# Check encoding
file ~/.claude/skills/my-skill.md

# Convert to UTF-8 with Unix line endings if needed
iconv -f UTF-16 -t UTF-8 my-skill.md > my-skill-fixed.md
# or
sed -i 's/\r$//' my-skill.md
```

## Step 6: Check Claude Code Version

Outdated Claude Code may have compatibility issues with skill features:

```bash
claude --version

# Update via npm
npm update -g @anthropic-ai/claude-code
```

## Prevention

- Store skill files in version control
- Validate YAML before deploying new skills: `python3 -c "import yaml; yaml.safe_load(open('skill.md').read())"`
- Keep a backup of known-working skill configurations: `cp -r ~/.claude/skills/ ~/.claude/skills.backup/`
- Test new skills in isolation before adding them to your main directory

---

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
