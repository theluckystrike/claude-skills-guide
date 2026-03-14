---
layout: default
title: "Claude Skill YAML Front Matter Parsing Error Fix"
description: "Fix YAML front matter parsing errors in Claude Code skill files. Covers indentation, special characters, missing closing delimiters, and validation tools."
date: 2026-03-13
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, yaml, front-matter]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skill-yaml-front-matter-parsing-error-fix/
---

# Claude Skill YAML Front Matter Parsing Error Fix

A malformed [YAML front matter](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) block is one of the most common reasons a Claude Code skill silently fails to load. The skill file exists, permissions are correct, but Claude either ignores the invocation or loads the skill without its configured metadata. This guide covers every known cause of YAML front matter parsing errors and gives you the exact fix for each.

## What YAML Front Matter Does in a Skill File

Skill `.md` files begin with a YAML front matter block delimited by triple dashes:

```yaml
---
name: tdd
description: "Run tests before writing implementation code (TDD)"
---

# The rest of the skill instructions go here...
```

[Claude Code skills recognize only name and description in front matter](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) If the front matter fails to parse, the skill body may still load but the description will not be available to the skill system.

## Error 1: Missing or Mismatched Closing Delimiter

The most common mistake. YAML front matter requires exactly three dashes on the opening and closing lines.

```yaml
# Broken — closing delimiter is missing
---
description: "My skill"

# Skill body starts here but YAML never closed...
```

```yaml
# Fixed
---
description: "My skill"
---
```

Also watch for trailing spaces after `---`. Some editors add a trailing space, which is invisible but causes the parser to miss the delimiter.

**Check with:**
```bash
cat -A ~/.claude/skills/tdd.md | head -10
# Lines ending in $ are clean. Lines ending in  $ have trailing spaces.
```

## Error 2: Tabs Instead of Spaces

YAML does not allow tabs for indentation. This is the single most common source of parse errors in skill files edited in IDEs with smart-tab enabled.

```yaml
# Broken — tab characters used for indentation
---
description: "My skill"
name:	sql-formatter
---
```

```yaml
# Fixed — no tabs, use spaces
---
name: sql-formatter
description: "My skill"
---
```

**Check and fix:**
```bash
# Check for tabs in YAML front matter
python3 -c "
content = open('$HOME/.claude/skills/tdd.md').read()
front = content.split('---')[1]
if '\t' in front:
    print('TAB FOUND — replace with spaces')
else:
    print('No tabs found')
"

# Replace tabs with spaces
expand -t 2 ~/.claude/skills/tdd.md > /tmp/tdd-fixed.md && mv /tmp/tdd-fixed.md ~/.claude/skills/tdd.md
```

## Error 3: Unquoted Strings With Colons

A colon followed by a space in an unquoted YAML value starts a new key-value pair. This breaks the intended value.

```yaml
# Broken — the colon after "Fix:" confuses the parser
description: Fix: handle edge cases in auth
```

```yaml
# Fixed — quote the string
description: "Fix: handle edge cases in auth"
```

This hits frequently with `description` fields in the `tdd` and `frontend-design` skills when people write descriptions like "Step 1: write test, Step 2: implement".

## Error 4: Unquoted Special Characters

Certain characters have special meaning in YAML and must be quoted when used literally:

| Character | Problem | Fix |
|---|---|---|
| `:` | Starts key-value pair | Quote the string |
| `#` | Starts a comment | Quote the string |
| `{` `}` | Flow mapping | Quote the string |
| `[` `]` | Flow sequence | Quote the string |
| `*` `&` | Anchors and aliases | Quote the string |

```yaml
# Broken
description: Use {curly braces} for templates
tags: [tdd, test-first]  # this is actually valid inline list syntax

# Safe approach — always quote description values
description: "Use {curly braces} for templates"
```

## Error 5: Duplicate Keys

If the same key appears twice in the front matter block, most YAML parsers use the last value and silently discard the first. Some parsers throw an error. Either way, the behavior is unintended.

```yaml
# Broken — description appears twice
---
name: my-skill
description: "My skill v1"
description: "My skill v2"
---
```

Grep for duplicates:
```bash
python3 -c "
content = open('$HOME/.claude/skills/supermemory.md').read()
front = content.split('---')[1]
import yaml
data = yaml.safe_load(front)
print('Keys:', list(data.keys()))
"
```

## Validating Your Skill Files

**Quick Python check:**
```bash
python3 -c "
import yaml, sys

path = '$HOME/.claude/skills/pdf.md'
content = open(path).read()
parts = content.split('---')
if len(parts) < 3:
    print('ERROR: front matter delimiters not found')
    sys.exit(1)
try:
    data = yaml.safe_load(parts[1])
    print('VALID:', list(data.keys()))
except yaml.YAMLError as e:
    print('PARSE ERROR:', e)
"
```

**Batch validate all skills:**
```bash
python3 << 'EOF'
import yaml, os, glob

for path in glob.glob(os.path.expanduser('~/.claude/skills/*.md')):
    content = open(path).read()
    parts = content.split('---')
    if len(parts) < 3:
        print(f'MISSING DELIMITERS: {path}')
        continue
    try:
        yaml.safe_load(parts[1])
        print(f'OK: {os.path.basename(path)}')
    except yaml.YAMLError as e:
        print(f'ERROR {os.path.basename(path)}: {e}')
EOF
```

## Using yamllint for Strict Validation

`yamllint` catches issues Python's `yaml.safe_load` tolerates:

```bash
pip install yamllint

# Extract front matter to a temp file and lint it
python3 -c "
content = open('$HOME/.claude/skills/docx.md').read()
front = content.split('---')[1]
open('/tmp/skill-front.yaml', 'w').write(front)
"
yamllint /tmp/skill-front.yaml
```

## Minimum Valid Front Matter

Claude Code skills recognize two front matter fields: `name` and `description`. This is the complete valid front matter for a skill:

```yaml
---
name: my-skill
description: "One sentence description of what this skill does"
---
```

Fields like `tools`, `version`, `tags`, `permissions`, `auto_invoke`, and `context_files` are not recognized by Claude Code. Do not add them to skill files.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — The canonical reference for valid YAML front matter fields, including all optional configuration keys
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) — A walkthrough for writing skill files from scratch with properly structured YAML that avoids common parse errors
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — How skill design and YAML front matter affect token consumption, helping you tune for cost efficiency

Built by theluckystrike — More at [zovo.one](https://zovo.one)
