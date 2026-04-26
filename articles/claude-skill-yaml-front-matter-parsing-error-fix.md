---
layout: default
title: "Fix YAML Front Matter Parsing Errors (2026)"
description: "Fix YAML frontmatter parsing errors in Claude Code skills. Missing delimiters, bad indentation, and special character issues solved with examples."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, yaml, front-matter]
author: "Claude Skills Guide"
reviewed: true
score: 8
last_tested: "2026-04-21"
permalink: /claude-skill-yaml-front-matter-parsing-error-fix/
geo_optimized: true
---

# Claude Skill YAML Front Matter Parsing Error Fix

A malformed [YAML front matter](/claude-skill-md-format-complete-specification-guide/) block is one of the most common reasons a Claude Code skill silently fails to load. The skill file exists, permissions are correct, but Claude either ignores the invocation or loads the skill without its configured metadata. This guide covers every known cause of YAML front matter parsing errors and gives you the exact fix for each.

## What YAML Front Matter Does in a Skill File

Skill `.md` files begin with a YAML front matter block delimited by triple dashes:

```yaml
---
name: tdd
description: "Test-driven development workflow for Claude Code"
---

The rest of the skill instructions go here...
```

[Claude Code skills recognize only name and description in front matter](/claude-skill-md-format-complete-specification-guide/) If the front matter fails to parse, the skill body may still load but the description will not be available to the skill system.

## Error 1: Missing or Mismatched Closing Delimiter

The most common mistake. YAML front matter requires exactly three dashes on the opening and closing lines.

```yaml
Broken. closing delimiter is missing
---
description: "Run tests first, then implement code"

Skill body starts here but YAML never closed...
```

```yaml
Fixed
---
description: "Run tests first, then implement code"
---
```

Also watch for trailing spaces after `---`. Some editors add a trailing space, which is invisible but causes the parser to miss the delimiter.

Check with:
```bash
cat -A ~/.claude/skills/tdd.md | head -10
Lines ending in $ are clean. Lines ending in $ have trailing spaces.
```

## Error 2: Tabs Instead of Spaces

YAML does not allow tabs for indentation. This is the single most common source of parse errors in skill files edited in IDEs with smart-tab enabled.

```yaml
Broken. tab characters used for indentation
---
description: "Format SQL queries with consistent style"
name:	sql-formatter
---
```

```yaml
Fixed. no tabs, use spaces
---
name: sql-formatter
description: "Format SQL queries with consistent style"
---
```

Check and fix:
```bash
Check for tabs in YAML front matter
python3 -c "
content = open('$HOME/.claude/skills/tdd.md').read()
front = content.split('---')[1]
if '\t' in front:
 print('TAB FOUND. replace with spaces')
else:
 print('No tabs found')
"

Replace tabs with spaces
expand -t 2 ~/.claude/skills/tdd.md > /tmp/tdd-fixed.md && mv /tmp/tdd-fixed.md ~/.claude/skills/tdd.md
```

## Error 3: Unquoted Strings With Colons

A colon followed by a space in an unquoted YAML value starts a new key-value pair. This breaks the intended value.

```yaml
Broken. the colon after "Fix:" confuses the parser
description: Fix: this value breaks YAML parsing
```

```yaml
Fixed. quote the string
description: "Fix: this value is properly quoted"
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
Broken
description: Use * and & for anchors # these are special chars
tags: [tdd, test-first] # this is actually valid inline list syntax

Safe approach. always quote description values
description: "Use * and & for anchors - special chars safely quoted"
```

## Error 5: Duplicate Keys

If the same key appears twice in the front matter block, most YAML parsers use the last value and silently discard the first. Some parsers throw an error. Either way, the behavior is unintended.

```yaml
Broken. description appears twice
---
name: my-skill
description: "First description value"
description: "Second description value overrides the first"
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

Quick Python check:
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

Batch validate all skills:
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

Extract front matter to a temp file and lint it
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
description: "A brief description of what this skill does"
---
```

Fields like `tools`, `version`, `tags`, `permissions`, `auto_invoke`, and `context_files` are not recognized by Claude Code. Do not add them to skill files.

## Diagnosing Skills That Load But Behave Incorrectly

A skill whose front matter parses correctly can still malfunction if the metadata causes the skill system to behave unexpectedly. Two common cases:

Name mismatch: The `name` field in front matter must match the filename (without `.md`). If your file is `tdd.md` but the front matter says `name: test-driven-development`, Claude Code may not correctly associate the `/tdd` invocation with this skill.

```yaml
File: ~/.claude/skills/tdd.md
Correct. name matches filename
---
name: tdd
description: "Test-driven development workflow"
---

Incorrect. name doesn't match filename
---
name: test-driven-development
description: "Test-driven development workflow"
---
```

Description too long: While there's no hard character limit documented, extremely long `description` values (multi-paragraph strings) can cause issues with how the skill is displayed in the skill list. Keep descriptions to one or two sentences, describe what the skill does, not how it does it.

A quick check to find skills where name doesn't match filename:

```bash
python3 << 'EOF'
import yaml, os, glob

skills_dir = os.path.expanduser('~/.claude/skills')

for path in glob.glob(f'{skills_dir}/*.md'):
 filename_base = os.path.splitext(os.path.basename(path))[0]
 content = open(path).read()
 parts = content.split('---')
 if len(parts) < 3:
 continue
 try:
 data = yaml.safe_load(parts[1])
 skill_name = data.get('name', '')
 if skill_name != filename_base:
 print(f'MISMATCH: file={filename_base} name={skill_name} ({path})')
 else:
 print(f'OK: {filename_base}')
 except yaml.YAMLError as e:
 print(f'PARSE ERROR: {filename_base}: {e}')
EOF
```

## Creating a Pre-Commit Hook for Skill File Validation

If you manage skill files in a git repository (useful for sharing skills across a team), a pre-commit hook that validates YAML front matter prevents broken skills from being committed.

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
Validate YAML front matter in Claude skill files before commit

set -e

SKILL_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.claude/skills/.*\.md$' || true)

if [ -z "$SKILL_FILES" ]; then
 exit 0
fi

echo "Validating Claude skill YAML front matter..."

ERRORS=0

for file in $SKILL_FILES; do
 result=$(python3 -c "
import yaml, sys

path = '$file'
try:
 content = open(path).read()
except FileNotFoundError:
 sys.exit(0) # Deleted file, skip

parts = content.split('---')
if len(parts) < 3:
 print(f'ERROR: {path}: missing front matter delimiters')
 sys.exit(1)

try:
 data = yaml.safe_load(parts[1])
 if not data:
 print(f'ERROR: {path}: empty front matter')
 sys.exit(1)
 if 'name' not in data:
 print(f'WARNING: {path}: missing name field')
 if 'description' not in data:
 print(f'WARNING: {path}: missing description field')
 print(f'OK: {path}')
except yaml.YAMLError as e:
 print(f'ERROR: {path}: {e}')
 sys.exit(1)
" 2>&1)

 echo "$result"

 if echo "$result" | grep -q "^ERROR:"; then
 ERRORS=$((ERRORS + 1))
 fi
done

if [ "$ERRORS" -gt 0 ]; then
 echo ""
 echo "Commit blocked: $ERRORS skill file(s) have YAML errors. Fix them and re-stage."
 exit 1
fi

echo "All skill files valid."
```

Make it executable with `chmod +x .git/hooks/pre-commit`. Now any skill file with a YAML parse error is rejected at commit time rather than discovered when a team member tries to invoke the skill.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skill-yaml-front-matter-parsing-error-fix)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Skill .md File Format Explained With Examples](/claude-skill-md-format-complete-specification-guide/). The canonical reference for valid YAML front matter fields, including all optional configuration keys
- [How to Write a Skill .md File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/). A walkthrough for writing skill files from scratch with properly structured YAML that avoids common parse errors
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). How skill design and YAML front matter affect token consumption, helping you tune for cost efficiency
- [Fix Malformed YAML Frontmatter in SKILL.md Files — 2026](/fix-malformed-yaml-frontmatter-skill-md/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


