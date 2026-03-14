---
layout: default
title: "Fix Claude Code Skill Tool Not Found Error (2026)"
description: "Solve the tool not found error in Claude Code skills. Fix tool name mismatches, missing skill declarations, sandbox restrictions, and dependencies."
date: 2026-03-13
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, tools]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code Skill Tool Not Found Error Solution

The **tool not found** error in Claude Code skills typically means Claude cannot find the skill file itself. Skills are plain Markdown files — they do not declare tools in front matter, and there is no `tools:` configuration field. This guide covers how to fix skill file loading errors.

## Understanding "Not Found" Errors

**Skill file not found:**
```
Error: Skill 'tdd' not found
Unknown skill: /tdd
```
Claude looked for `tdd.md` in the skills directories and did not find it. The fix is to ensure the file exists in `~/.claude/skills/`.

If Claude mentions a tool is unavailable during a skill session, that is a session-level permissions issue, not a skill configuration issue. Skills cannot declare or restrict which tools Claude uses.

## Fixing Type 1: Skill File Not Found

### Step 1: Verify the file exists

```bash
# Check global skills
ls ~/.claude/skills/

# Check project-local skills
ls .claude/skills/ 2>/dev/null
```

### Step 2: Confirm the filename matches

Skill names are case-sensitive. `/tdd` maps to `tdd.md`, not `TDD.md` or `Tdd.md`.

```bash
ls ~/.claude/skills/ | grep -i tdd
# Must output exactly: tdd.md
```

### Step 3: Install the missing skill

If the file is absent, place it in the correct directory:

```bash
# Install a skill globally
cp ~/downloads/tdd.md ~/.claude/skills/tdd.md
chmod 644 ~/.claude/skills/tdd.md
```

### Step 4: Check for a custom skills directory

Your `settings.json` may redirect skill loading:

```bash
cat ~/.claude/settings.json | python3 -m json.tool | grep -A2 skill
```

If `skillsDir` is set, skills must live in that path, not `~/.claude/skills/`.

## Tool Access Issues During Skill Sessions

Skills do not configure which tools Claude can use. If Claude cannot use a specific tool (like `WebSearch` or `Bash`) during a skill session, check:

1. **Session permissions** — In your Claude Code session, type `What tools do you have available?` to see the current tool list
2. **Network access** — `WebSearch` requires network access. If your environment is offline, this tool is unavailable regardless of which skill is active
3. **Claude Code settings** — Tool availability is controlled by `~/.claude/settings.json`, not skill files

### External tool dependencies (pdf, docx skills)

The [`pdf` skill](/claude-skills-guide/best-claude-skills-for-data-analysis/), `docx` skill, and similar document-processing skills require external binaries. These are separate from Claude Code's built-in tools.

**For the `pdf` skill:**
```bash
# Check if pdftotext is available
which pdftotext || brew install poppler   # macOS
which pdftotext || apt install poppler-utils   # Debian/Ubuntu
```

**For the `docx` skill:**
```bash
which pandoc || brew install pandoc
which pandoc || apt install pandoc
```

When the external binary is missing, the skill loads but the tool call fails with a "command not found" error that surfaces as a tool error.

## The `supermemory` Skill: Storage Issues

The [`supermemory` skill](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) writes session memory to disk. If the storage path is on a read-only filesystem, writes fail. Fix this by explicitly directing the skill to a writable path:

```
/supermemory
Save memory to ~/notes/project-memory.md
```

Or set the environment variable:
```bash
export CLAUDE_MEMORY_PATH="$HOME/.claude-memory"
mkdir -p ~/.claude-memory
```

## The `frontend-design` Skill: Missing Linter Tools

The [`frontend-design` skill](/claude-skills-guide/best-claude-code-skills-for-frontend-development/) optionally calls ESLint and Prettier for output validation. If these are not installed in your project, the validation step produces a tool-not-found error.

```bash
# Install project-local (preferred)
npm install --save-dev eslint prettier

# Or install globally
npm install -g eslint prettier
```

## Diagnostic Command

Run this to check all skills and verify their front matter parses correctly:

```bash
python3 << 'EOF'
import yaml, os, glob

for path in glob.glob(os.path.expanduser('~/.claude/skills/*.md')):
    content = open(path).read()
    parts = content.split('---')
    if len(parts) < 3:
        print(f'NO FRONT MATTER: {os.path.basename(path)}')
        continue
    try:
        data = yaml.safe_load(parts[1])
        name = os.path.basename(path)
        desc = data.get('description', '(no description)')
        print(f'{name}: description={desc!r}')
    except Exception as e:
        print(f'PARSE ERROR {os.path.basename(path)}: {e}')
EOF
```

## Minimum Working Skill File

If you want to rule out a tool declaration issue entirely, strip the skill to minimum:

```markdown
---
description: "Test skill with no tool declarations"
---

# Test Skill

This is a minimal skill. Claude will use default tool access.
```

If the stripped skill works but the original does not, a tool declaration in the original is causing the error.

## Summary

- **Skill file not found**: check `~/.claude/skills/`, verify filename case, confirm no custom `skillsDir`
- **Tool not found within skill**: check YAML `tools` list for case mismatches, verify the tool is available in your session type, install external binaries for `pdf`/`docx` skills
- When in doubt: strip the skill to minimum front matter and add declarations back one by one

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — The authoritative reference for the `tools` field and all other YAML front matter fields in skill files
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) — A hands-on walkthrough for writing skill files that correctly declare their tool dependencies
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — How skill design affects token consumption and API costs

Built by theluckystrike — More at [zovo.one](https://zovo.one)
