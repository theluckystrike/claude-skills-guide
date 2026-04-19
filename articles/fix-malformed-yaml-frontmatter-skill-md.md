---
title: "Fix Malformed YAML Frontmatter in SKILL.md Files — 2026"
description: "Debug and fix YAML parse errors in SKILL.md frontmatter including tabs vs spaces, unquoted colons, missing delimiters, and encoding issues."
permalink: /fix-malformed-yaml-frontmatter-skill-md/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, yaml, frontmatter, parse-error, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

Your SKILL.md file has what looks like valid frontmatter, but Claude treats the entire file as body text. The description is missing from "What skills are available?" The skill never auto-triggers. It still works when invoked manually with `/name`, but only because Claude reads the markdown body -- all frontmatter metadata is lost. The file has a silent YAML parse error.

## Technical Foundation

SKILL.md frontmatter follows standard YAML between `---` delimiters. When the YAML fails to parse, Claude Code silently falls back to treating the entire file as body content. There is no error message, no warning, no log entry. The skill still "works" but without any metadata: no `description` (no auto-triggering), no `allowed-tools` (permission prompts for every tool), no `disable-model-invocation` (may auto-trigger unexpectedly or not at all).

All frontmatter fields are optional, so Claude Code cannot distinguish between "no frontmatter" and "broken frontmatter." Both look the same: a skill with no metadata.

## The Working SKILL.md

A correctly formatted frontmatter:

```yaml
---
name: deploy-staging
description: >
  Deploy the application to the staging environment. Use when
  the user says "deploy to staging" or "push to stage".
disable-model-invocation: true
allowed-tools: Bash(npm run build *) Bash(npm test *)
argument-hint: "[branch-name]"
---

# Deploy to Staging

Deploy $ARGUMENTS to the staging environment.
```

Key formatting rules:
- `---` delimiters must be on their own line, no extra characters
- Use spaces, never tabs
- Strings with colons need quoting
- Multi-line strings use `>` (folded) or `|` (literal)

## Error 1: Tabs Instead of Spaces

YAML requires spaces for indentation. A single tab causes a parse failure.

```yaml
# BROKEN (tab character before "Deploy"):
---
name: deploy
description:	Deploy the application    # TAB before "Deploy"
---

# FIXED (spaces only):
---
name: deploy
description: Deploy the application
---
```

Diagnostic: Many editors show tabs vs spaces. In VS Code, enable "Render Whitespace" (`editor.renderWhitespace: all`). In the terminal:

```bash
cat -A .claude/skills/deploy/SKILL.md | head -5
# Tabs show as ^I
```

## Error 2: Unquoted Special Characters

YAML interprets colons, brackets, and other characters specially.

```yaml
# BROKEN (colon in description triggers YAML mapping):
---
description: Deploy to staging: run tests first
---

# FIXED (wrap in quotes or use folded scalar):
---
description: "Deploy to staging: run tests first"
---

# Also FIXED (folded scalar):
---
description: >
  Deploy to staging: run tests first
---
```

Characters that need quoting when they appear in values: `: { } [ ] , & * # ? | - < > = ! % @`

## Error 3: Missing or Malformed Delimiters

The frontmatter must start on line 1 with exactly `---` and end with exactly `---`.

```yaml
# BROKEN (space before delimiter):
 ---
name: deploy
---

# BROKEN (extra characters):
--- yaml
name: deploy
---

# BROKEN (missing closing delimiter):
---
name: deploy
# No closing ---

# CORRECT:
---
name: deploy
---
```

## Error 4: Boolean Values as Strings

YAML auto-converts `true`, `false`, `yes`, `no`, `on`, `off` to booleans. This usually works correctly for SKILL.md fields, but can cause issues with unexpected values.

```yaml
# This works (boolean intended):
disable-model-invocation: true

# This might not work (string "yes" auto-converted to boolean):
disable-model-invocation: yes  # Parsed as true (usually OK)

# Potential issue with description containing boolean-like words:
description: yes, this skill deploys  # "yes" may be parsed as boolean
# FIXED:
description: "yes, this skill deploys"
```

## Error 5: Invalid Field Names

Field names must match exactly. A typo means the field is ignored (not an error, but behavior is wrong).

```yaml
# WRONG field names (silently ignored):
---
descriptions: Deploy the app          # Should be: description
disable_model_invocation: true         # Should be: disable-model-invocation
allowedTools: Bash(git *)              # Should be: allowed-tools
when-to-use: trigger phrases           # Should be: when_to_use
---

# CORRECT field names:
---
description: Deploy the app
disable-model-invocation: true
allowed-tools: Bash(git *)
when_to_use: trigger phrases
---
```

Note the inconsistency: some fields use hyphens (`disable-model-invocation`, `allowed-tools`), others use underscores (`when_to_use`). This matches the official specification.

## Validation Script

Validate your SKILL.md frontmatter from the terminal:

```bash
python3 << 'SCRIPT'
import yaml
import sys

path = ".claude/skills/deploy/SKILL.md"
with open(path) as f:
    content = f.read()

if not content.startswith("---"):
    print(f"ERROR: {path} missing opening --- delimiter")
    sys.exit(1)

parts = content.split("---", 2)
if len(parts) < 3:
    print(f"ERROR: {path} missing closing --- delimiter")
    sys.exit(1)

try:
    meta = yaml.safe_load(parts[1])
    if meta is None:
        print(f"WARNING: {path} has empty frontmatter")
    else:
        print(f"OK: Parsed {len(meta)} fields: {list(meta.keys())}")
        valid_fields = {
            "name", "description", "when_to_use", "argument-hint",
            "disable-model-invocation", "user-invocable", "allowed-tools",
            "model", "effort", "context", "agent", "hooks", "paths",
            "shell", "version", "compatibility"
        }
        unknown = set(meta.keys()) - valid_fields
        if unknown:
            print(f"WARNING: Unknown fields: {unknown}")
except yaml.YAMLError as e:
    print(f"ERROR: YAML parse failed: {e}")
    sys.exit(1)
SCRIPT
```

## Common Problems and Fixes

**Frontmatter looks correct but still fails**: Check for invisible characters (zero-width spaces, BOM markers). Re-type the file from scratch or convert encoding: `iconv -f utf-8 -t utf-8 -c SKILL.md > SKILL.md.clean`.

**Field value wraps to next line unexpectedly**: Long values need proper multi-line syntax. Use `>` for folded (newlines become spaces) or `|` for literal (newlines preserved).

**allowed-tools field not working**: Space-separated syntax (`Bash(git *) Read Grep`) and YAML list syntax both work. If using a list, indent properly under the field name.

**Validation passes but skill still has no metadata**: Double-check the file path. You may be validating a different file than the one Claude Code reads.

## Production Gotchas

Claude Code provides no YAML validation feedback. The only way to confirm frontmatter parsed correctly is to check behavior: ask "What skills are available?" and verify the description appears exactly as written. If it shows the first paragraph of the body instead of the frontmatter description, the frontmatter failed to parse.

Some editors auto-insert BOM (Byte Order Mark) characters at the beginning of UTF-8 files. This invisible character before `---` breaks frontmatter parsing. Use `file SKILL.md` to check: it should say "UTF-8 Unicode text" not "UTF-8 Unicode (with BOM) text."

## Checklist

- [ ] Frontmatter starts on line 1 with exactly `---`
- [ ] Only spaces used for indentation (no tabs)
- [ ] Values with colons are quoted or use folded scalar (`>`)
- [ ] Field names match specification exactly (hyphens and underscores)
- [ ] Validation script confirms parse success

## Related Guides

- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
- [Fix Unknown Skill Error in Claude Code](/fix-unknown-skill-error-claude-code/)
- [Claude Skills CI/CD Patterns](/claude-skills-ci-cd-patterns/)
