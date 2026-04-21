---
title: "Skill YAML Frontmatter Parse Error in Claude — Fix (2026)"
permalink: /claude-code-skill-yaml-frontmatter-parse-error-fix-2026/
description: "Fix YAML indentation and quoting errors in Claude Code skill frontmatter. Quote values with colons, use two-space indent not tabs."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
YAML parse error in skill frontmatter: unexpected token at line 3
```

## The Fix

```bash
# Common causes: unquoted colons, tabs instead of spaces, missing quotes
# Check line 3 of your skill file for these issues:

# BAD (unquoted colon in value):
#   description: Fix this: now
# GOOD (quoted):
#   description: "Fix this: now"

# BAD (tab indentation):
#	name: my-skill
# GOOD (2 spaces):
#   name: my-skill

# Validate with yamllint:
pip install yamllint && yamllint .claude/skills/my-skill.md
```

## Why This Works

YAML frontmatter in skill files must follow strict YAML 1.2 syntax. Colons inside unquoted values are interpreted as key-value separators. Tabs are invalid in YAML (only spaces allowed). The parser fails at the exact line where it encounters ambiguous or illegal syntax. Quoting values and using consistent 2-space indentation resolves nearly all parse failures.

## If That Doesn't Work

```bash
# Strip and rewrite the frontmatter from scratch
cat > /tmp/valid-frontmatter.md << 'EOF'
---
name: "my-skill"
description: "Performs a specific task"
args:
  - name: "input"
    required: true
---
EOF

# Copy the body of your skill after this valid header
tail -n +$(grep -n "^---$" .claude/skills/my-skill.md | sed -n '2p' | cut -d: -f1) \
  .claude/skills/my-skill.md >> /tmp/valid-frontmatter.md
mv /tmp/valid-frontmatter.md .claude/skills/my-skill.md
```

Starting fresh with known-valid YAML eliminates hidden characters or encoding issues.

## Prevention

Add to your CLAUDE.md:
```
All YAML frontmatter values containing special characters (colons, brackets, hashes) must be double-quoted. Use 2-space indentation only. Run yamllint on skill files before committing.
```
