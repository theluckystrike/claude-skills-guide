---
layout: post
title: "Claude Code Skill Tool Not Found Error: Solutions"
description: "Fix the skill not found error in Claude Code: wrong skill name, missing skill file, incorrect directory location, and how to verify skills are installed."
date: 2026-03-13
categories: [guides, tutorials]
tags: [claude-code, claude-skills, debugging, troubleshooting]
author: "Claude Skills Guide"
reviewed: true
score: 6
---

# Claude Code Skill Tool Not Found Error: Solutions

When Claude Code can't find a skill you're trying to invoke, it usually means one of three things: the skill file doesn't exist where Claude Code looks, the name doesn't match, or the skill directory isn't configured. Here's how to diagnose and fix each case.

## How Skill Loading Actually Works

Claude Code skills are `.md` files stored in `~/.claude/skills/`. When you type `/pdf` or `/tdd`, Claude Code looks for a file matching that name in the skills directory. There are no Python packages to install for skills themselves — the skill is just a Markdown file with instructions for Claude.

Dependencies like `pypdf2`, `openpyxl`, or `playwright` are for your project code, not for loading the skill file itself.

## Cause 1: Skill File Missing

Check if the skill file exists:

```bash
ls ~/.claude/skills/
```

If `pdf.md` or `tdd.md` aren't there, the skill isn't installed. Obtain the skill file from the official source or community repository and place it in `~/.claude/skills/`.

## Cause 2: Wrong Skill Name

Skill names are case-sensitive and must match the filename exactly. `/PDF` won't find `pdf.md`. Check the exact name:

```bash
ls ~/.claude/skills/ | grep -i pdf
```

Use the name shown, not what you guessed.

## Cause 3: Custom Skills Directory

If Claude Code is configured to look in a non-default directory, your skills may be somewhere else:

```bash
# Check your Claude Code config
cat ~/.claude/settings.json 2>/dev/null | grep -i skill
```

If a custom `skillsDir` is configured, that's where to place skill files.

## Cause 4: Corrupted Skill File

If the file exists but the YAML front matter is invalid, Claude Code may fail to parse the skill:

```bash
# Quick YAML validation
python3 -c "
import yaml
with open(f'{__import__(\"os\").path.expanduser(\"~\")}/.claude/skills/my-skill.md') as f:
    content = f.read()
    # Extract front matter
    parts = content.split('---', 2)
    if len(parts) >= 3:
        yaml.safe_load(parts[1])
        print('Valid YAML')
    else:
        print('Missing front matter delimiters')
"
```

## Troubleshooting Flowchart

```
Skill not found?
│
├── Does ~/.claude/skills/<skillname>.md exist?
│   No → Add the skill file
│   Yes → Continue
│
├── Does the name match exactly (case-sensitive)?
│   No → Fix the invocation or rename the file
│   Yes → Continue
│
├── Is the YAML front matter valid?
│   No → Fix YAML syntax (see debugging guide)
│   Yes → Continue
│
└── Is Claude Code up to date?
    No → npm update -g @anthropic-ai/claude-code
    Yes → Check for Claude Code error output
```

## Verifying a Skill Works

After placing a skill file:

1. Restart your Claude Code session
2. Type `/skill-name` to invoke it
3. If it loads, Claude will acknowledge the skill context and proceed

If you're still getting errors, check the skill file's front matter has a valid `name` field matching the filename.

## Python Dependencies Are Separate

A common misconception: installing Python libraries (`uv pip install pypdf2`) does not install Claude skills. The `pdf` skill is a `.md` file. The Python library is what your code uses to actually process PDFs — Claude uses the skill file to understand how to help you write that code.

Keep these concerns separate:
- **Skill file** (`~/.claude/skills/pdf.md`) — tells Claude how to assist with PDF tasks
- **Python library** (`pypdf2`, `pdfplumber`) — the actual library your code imports

---

## Related Reading

- [Skill MD File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — Complete skill.md format reference
- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — Step-by-step skill creation guide
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


---

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
