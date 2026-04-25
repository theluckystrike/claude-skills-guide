---
layout: default
title: "Claude Skills in CI/CD (2026)"
description: "How to validate SKILL.md files in CI pipelines, lint frontmatter, run skill-driven automation in GitHub Actions, and prevent broken skills from merging."
permalink: /claude-skills-ci-cd-patterns/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, ci-cd, github-actions, automation]
last_updated: 2026-04-19
---

## The Specific Situation

A developer pushes a SKILL.md with a syntax error in the YAML frontmatter. The skill silently fails -- Claude treats the entire file as body text with no metadata. The description is missing, so the skill never auto-triggers. Nobody notices for two weeks until someone asks "why did our deploy skill stop working?" You need CI validation to catch this before merge.

## Technical Foundation

Claude Code is an interactive tool, not a CI runner. You cannot invoke Claude Code in a GitHub Actions pipeline to test skill behavior. What you can validate in CI:

- YAML frontmatter syntax (parsing)
- Field values (name format, description length, valid field names)
- File structure (SKILL.md exists, supporting files referenced)
- Script syntax (shellcheck for bash, python -m py_compile for Python)

Claude Code also supports scheduled recurring tasks called routines, running on Anthropic infrastructure. These can perform automated skill-driven workflows, but they are separate from CI/CD pipelines.

## The Working SKILL.md (CI Validator Skill)

A skill that validates other skills during development:

```yaml
---
name: validate-skills
description: >
  Validate all SKILL.md files in the project for frontmatter
  correctness and structure. Use when the user says "check skills"
  or "validate skill files".
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(python3 *)
---

# Validate Skills

Scan all SKILL.md files and report issues.

## Steps

1. Find all SKILL.md files:
   ```bash
   find .claude/skills -name "SKILL.md" 2>/dev/null
   ```

2. For each file, validate:
   - YAML frontmatter parses correctly
   - `name` field: lowercase, hyphens, numbers only, max 64 chars
   - `description` exists and is under 1,536 characters
   - `disable-model-invocation` is true for names containing
     deploy, commit, send, delete, migrate, push
   - Referenced files (scripts/, references/, templates/) exist

3. Report pass/fail for each skill with specific error messages
```

## GitHub Actions Validation Pipeline

Add this workflow to validate skills on every PR:

```yaml
# .github/workflows/validate-skills.yml
name: Validate Claude Skills
on:
  pull_request:
    paths:
      - '.claude/skills/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install PyYAML
        run: pip install pyyaml

      - name: Validate SKILL.md frontmatter
        run: |
          python3 << 'SCRIPT'
          import yaml
          import glob
          import sys
          import re

          errors = []
          for path in glob.glob('.claude/skills/*/SKILL.md'):
              with open(path) as f:
                  content = f.read()

              # Extract frontmatter
              if not content.startswith('---'):
                  errors.append(f"{path}: Missing YAML frontmatter")
                  continue

              parts = content.split('---', 2)
              if len(parts) < 3:
                  errors.append(f"{path}: Malformed frontmatter delimiters")
                  continue

              try:
                  meta = yaml.safe_load(parts[1])
              except yaml.YAMLError as e:
                  errors.append(f"{path}: YAML parse error: {e}")
                  continue

              if meta is None:
                  errors.append(f"{path}: Empty frontmatter")
                  continue

              # Validate name field
              name = meta.get('name', '')
              if name and not re.match(r'^[a-z0-9-]{1,64}$', name):
                  errors.append(f"{path}: Invalid name '{name}' "
                               f"(lowercase, numbers, hyphens, max 64)")

              # Validate description
              desc = meta.get('description', '')
              when = meta.get('when_to_use', '')
              if not desc:
                  errors.append(f"{path}: Missing description field")
              elif len(str(desc) + str(when)) > 1536:
                  errors.append(f"{path}: description+when_to_use "
                               f"exceeds 1536 chars")

          if errors:
              for e in errors:
                  print(f"ERROR: {e}")
              sys.exit(1)
          else:
              print(f"All skills validated successfully")
          SCRIPT

      - name: Check script syntax
        run: |
          for script in $(find .claude/skills -name "*.sh" 2>/dev/null); do
            bash -n "$script" || echo "Syntax error in $script"
          done
          for script in $(find .claude/skills -name "*.py" 2>/dev/null); do
            python3 -m py_compile "$script" || echo "Syntax error in $script"
          done
```

## Skill-Driven CI Automation

For teams using Claude Code in development workflows, skills can standardize what Claude does in response to CI failures:

```yaml
---
name: fix-ci
description: >
  Diagnose and fix CI pipeline failures. Use when the user says
  "CI failed", "fix the build", or "pipeline broken".
argument-hint: "[github-actions-run-url]"
allowed-tools: Bash(gh *) Read Grep Glob
---

# Fix CI Failure

Diagnose the CI failure and propose fixes.

## Steps

1. Get the failed run details:
   ```bash
   gh run view $ARGUMENTS --log-failed
   ```

2. Identify the failure category:
   - Test failure: Read the failing test and source code
   - Lint error: Read the file and fix the violation
   - Build error: Check for missing dependencies or type errors
   - Skill validation error: Fix the SKILL.md frontmatter

3. Propose a fix with specific file changes
4. Do NOT commit or push without explicit user approval
```

## Common Problems and Fixes

**CI cannot test skill behavior**: Correct -- Claude Code is interactive and cannot run in CI. Limit CI to structural validation (YAML parsing, file existence, script syntax).

**YAML validation passes but skill still fails**: Some field values are valid YAML but invalid for Claude Code (e.g., `name: "My Skill!"` parses as YAML but Claude rejects the exclamation mark). Add regex validation for the `name` field.

**Scripts pass syntax check but fail at runtime**: Syntax validation (`bash -n`, `python -m py_compile`) catches parse errors but not runtime errors like missing files or unset environment variables. Document runtime prerequisites in the skill.

**PR changes skill but CI does not run**: The workflow above uses `paths: ['.claude/skills/**']` to trigger only on skill changes. If the workflow file itself is missing, add it to your repository template.

## Production Gotchas

Claude Code cannot authenticate in CI environments the way it does locally. There is no `claude-code --validate-skills` CLI command. All CI validation must use external tools (Python YAML parser, shellcheck, custom scripts).

If your team uses the `version` field in frontmatter, CI can enforce version bumps. Check that the version changed when the skill content changed -- this prevents "forgot to bump version" situations.

The `allowed-tools` field accepts glob patterns (`Bash(git *)`) that CI cannot validate for security. A human reviewer must check that approved tools are appropriate. Consider adding a CODEOWNERS rule requiring senior engineer approval for `.claude/skills/` changes.

## Checklist

- [ ] GitHub Actions workflow validates SKILL.md on every PR
- [ ] YAML parsing catches syntax errors before merge
- [ ] Field validation checks name format and description length
- [ ] Bundled scripts validated with syntax checkers
- [ ] CODEOWNERS requires review for `.claude/skills/` changes

## Related Guides

- [Claude Skills Code Review Workflow](/claude-skills-code-review-workflow/)
- [Testing Claude Skills Before Production](/testing-claude-skills-before-production/)
- [Security Review Process for Claude Skills](/security-review-process-for-claude-skills/)

## Related Articles

- [Claude Skill State Machine Design Patterns](/claude-skill-state-machine-design-patterns/)
