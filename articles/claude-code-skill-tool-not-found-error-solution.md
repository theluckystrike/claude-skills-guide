---
layout: post
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

The **tool not found** error in Claude Code skills appears in two distinct scenarios: Claude cannot find the skill file itself, or a tool declared inside the skill definition is unavailable in the current session. Both produce similar error messages but require different fixes. This guide covers both cases.

## Understanding the Two Types of "Not Found"

**Type 1 — Skill file not found:**
```
Error: Skill 'tdd' not found
Unknown skill: /tdd
```
Claude looked for `tdd.md` in the skills directories and did not find it.

**Type 2 — Tool not found (within a skill):**
```
ToolNotFoundError: Tool 'Bash' is not available in this session
SkillError: declared tool 'WebSearch' not found
```
The skill file loaded, but a tool it declared in its YAML front matter is not available.

Each type has a separate fix.

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

## Fixing Type 2: Tool Not Found Within a Skill

### Step 1: Check what tools the skill declares

Open the skill file and look at the `tools` field in the YAML front matter:

```bash
python3 -c "
import yaml, os
path = os.path.expanduser('~/.claude/skills/pdf.md')
content = open(path).read()
parts = content.split('---')
if len(parts) >= 3:
    data = yaml.safe_load(parts[1])
    print('Declared tools:', data.get('tools', 'none declared'))
"
```

### Step 2: Check which tools are available in your session

In a Claude Code session, run:
```
What tools do you have available in this session? List them.
```

Claude will enumerate its available tools. Compare this list against what the skill declares.

### Step 3: Tool name case matters

Built-in Claude Code tools use Title Case. Common mismatches:

| Wrong | Correct |
|---|---|
| `bash` | `Bash` |
| `read` | `Read` |
| `write` | `Write` |
| `websearch` | `WebSearch` |
| `glob` | `Glob` |
| `grep` | `Grep` |

Fix the skill's front matter to use the correct tool names:

```yaml
---
description: "Run TDD workflows with test-first development"
tools:
  - Bash
  - Read
  - Write
  - Glob
---
```

### Step 4: Some tools are not available in all contexts

The `WebSearch` tool is only available when Claude Code is connected to a network-enabled session. If you are running in an offline or restricted environment, skills that declare `WebSearch` will fail.

**Fix — make the skill tool-declaration optional:**
```yaml
---
description: "Research and implement feature"
tools:
  - Bash
  - Read
  - Write
  # Remove WebSearch if not available in your environment
---
```

### Step 5: External tool dependencies (pdf, docx skills)

The [`pdf` skill](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/), `docx` skill, and similar document-processing skills require external binaries. These are separate from Claude Code's built-in tools.

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

The [`supermemory` skill](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) writes session memory to disk. If the storage path is on a read-only filesystem, writes fail. Fix this by explicitly directing the skill to a writable path:

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

The [`frontend-design` skill](/claude-skills-guide/articles/best-claude-code-skills-for-frontend-development/) optionally calls ESLint and Prettier for output validation. If these are not installed in your project, the validation step produces a tool-not-found error.

```bash
# Install project-local (preferred)
npm install --save-dev eslint prettier

# Or install globally
npm install -g eslint prettier
```

## Diagnostic Command

Run this to check all skills and their declared tools at once:

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
        tools = data.get('tools', [])
        name = os.path.basename(path)
        print(f'{name}: tools={tools}')
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

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — The authoritative reference for the `tools` field and all other YAML front matter fields in skill files
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — A hands-on walkthrough for writing skill files that correctly declare their tool dependencies
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Minimizing declared tools is also a token optimization strategy; this article explains the full picture

Built by theluckystrike — More at [zovo.one](https://zovo.one)
