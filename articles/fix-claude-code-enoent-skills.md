---
title: "Fix ENOENT No Such File or Directory"
description: "Resolve ENOENT errors when Claude Code skills reference missing files, scripts, templates, or directories that do not exist at the expected path."
permalink: /fix-claude-code-enoent-skills/
categories: [skills, 2026]
tags: [claude-code, claude-skills, enoent, file-not-found, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

Your skill tells Claude to run a validation script at `scripts/validate.sh`. Claude executes the command and gets "ENOENT: no such file or directory." The script exists in your skill directory, but Claude is running the command from the project root, not from the skill directory. The path resolves incorrectly. This is the most common cause of ENOENT errors in skills.

## Technical Foundation

When Claude executes commands via the Bash tool, the working directory is the project root -- not the skill's directory. A relative path like `scripts/validate.sh` resolves to `<project-root>/scripts/validate.sh`, not `<skill-directory>/scripts/validate.sh`.

The `${CLAUDE_SKILL_DIR}` substitution variable solves this. It resolves to the absolute path of the directory containing the SKILL.md file. Using it makes skill paths portable across installations (personal, project, plugin).

ENOENT errors in skills fall into four categories:
1. Relative paths that resolve to the wrong location
2. Missing files that were not committed to git
3. Files referenced in SKILL.md but never created
4. Dynamic context injection referencing files that do not exist yet

## The Working SKILL.md

Correct path usage with `${CLAUDE_SKILL_DIR}`:

```yaml
---
name: validate-code
description: >
  Run validation checks on the codebase. Use when the user says
  "validate", "check code quality", or "run checks".
allowed-tools: Bash(bash *) Bash(python3 *) Read
---

# Validate Code

Run validation checks using bundled scripts.

## Steps

1. Run the linting check:
   ```bash
   bash ${CLAUDE_SKILL_DIR}/scripts/lint-check.sh
   ```

2. Run the type check:
   ```bash
   python3 ${CLAUDE_SKILL_DIR}/scripts/type-check.py
   ```

3. Read the validation reference for interpreting results:
   Read the file at ${CLAUDE_SKILL_DIR}/references/validation-rules.md

## Output

Report pass/fail for each check with specific file:line references.
```

Directory structure:

```
validate-code/
├── SKILL.md
├── scripts/
│   ├── lint-check.sh
│   └── type-check.py
└── references/
    └── validation-rules.md
```

## ENOENT Cause 1: Relative Paths Without ${CLAUDE_SKILL_DIR}

```yaml
# BROKEN: resolves to <project-root>/scripts/validate.sh
bash scripts/validate.sh

# FIXED: resolves to <skill-directory>/scripts/validate.sh
bash ${CLAUDE_SKILL_DIR}/scripts/validate.sh
```

This is the most common cause. Always use `${CLAUDE_SKILL_DIR}` for files inside the skill directory.

## ENOENT Cause 2: Files Not Committed to Git

The script exists on your machine but was never committed. When a teammate pulls, the file is missing.

```bash
# Check if skill files are tracked by git
git ls-files .claude/skills/validate-code/

# Expected output:
# .claude/skills/validate-code/SKILL.md
# .claude/skills/validate-code/scripts/lint-check.sh
# .claude/skills/validate-code/scripts/type-check.py
# .claude/skills/validate-code/references/validation-rules.md

# If scripts are missing, add them:
git add .claude/skills/validate-code/scripts/
```

Common reason: `.gitignore` excludes `*.sh` or `scripts/`. Check your gitignore rules.

## ENOENT Cause 3: Missing Execute Permissions

Not technically ENOENT, but often reported as the same error. The file exists but cannot be executed.

```bash
# Check permissions
ls -la .claude/skills/validate-code/scripts/

# Fix permissions
chmod +x .claude/skills/validate-code/scripts/lint-check.sh
chmod +x .claude/skills/validate-code/scripts/type-check.py
```

Git preserves execute permissions, but only if set before commit.

## ENOENT Cause 4: Dynamic Context Injection File Missing

The `!`command`` syntax executes before Claude sees the content. If the command references a file that does not exist:

```yaml
# BROKEN if the file doesn't exist yet:
- Config: !`cat config/app.json`

# FIXED with error handling:
- Config: !`cat config/app.json 2>/dev/null || echo "No config file found"`
```

Dynamic injection commands should always handle the missing file case.

## ENOENT Cause 5: Personal vs Project Path Differences

A skill installed personally has a different `${CLAUDE_SKILL_DIR}` than the same skill installed at project level:

```
Personal: ~/.claude/skills/validate-code/
Project:  /path/to/project/.claude/skills/validate-code/
```

If the skill references files using hardcoded paths instead of `${CLAUDE_SKILL_DIR}`, it breaks when moved between scopes.

```yaml
# BROKEN: hardcoded personal path
bash ~/.claude/skills/validate-code/scripts/lint-check.sh

# FIXED: portable path
bash ${CLAUDE_SKILL_DIR}/scripts/lint-check.sh
```

## Diagnostic Steps

```bash
# 1. Find the skill's actual directory
find ~/.claude/skills .claude/skills -name "SKILL.md" \
  -path "*validate-code*" 2>/dev/null

# 2. List all files in the skill directory
ls -laR .claude/skills/validate-code/

# 3. Check if referenced files exist
# (Read the SKILL.md and check each file path mentioned)

# 4. Test the script directly from the project root
bash .claude/skills/validate-code/scripts/lint-check.sh
# If this fails with ENOENT, the script has its own
# relative path issues internally
```

## Common Problems and Fixes

**Script runs locally but fails in the skill**: The script itself may contain relative paths. Use `cd "$(dirname "$0")"` at the top of bash scripts to ensure they run from their own directory.

**Template file not found**: SKILL.md says "Read templates/output.md" but the file is at `${CLAUDE_SKILL_DIR}/templates/output.md`. Claude interprets "templates/output.md" relative to the project root.

**Python script cannot import local modules**: Python's import system uses the current directory. Add the skill directory to the Python path: `PYTHONPATH=${CLAUDE_SKILL_DIR} python3 ${CLAUDE_SKILL_DIR}/scripts/main.py`.

**File exists but inaccessible in WSL**: Windows Subsystem for Linux has known issues with file watchers and path resolution across the Windows/Linux boundary. Use native Linux paths within WSL.

## Production Gotchas

The `${CLAUDE_SKILL_DIR}` variable is replaced at render time, before Claude sees the content. This means Claude receives the full absolute path. If you inspect the skill content during a session, you see the resolved path, not the variable name.

When skills are distributed via plugins, `${CLAUDE_SKILL_DIR}` resolves to the plugin's installation directory. This works correctly as long as all referenced files are within the skill directory. External paths (outside the skill directory) must be absolute or project-relative.

Scripts that create output files should write to the project directory, not to `${CLAUDE_SKILL_DIR}`. The skill directory may be read-only (managed settings, plugin installations) and writing there modifies the skill itself.

## Checklist

- [ ] All file paths in SKILL.md use `${CLAUDE_SKILL_DIR}` prefix
- [ ] All referenced files exist and are committed to git
- [ ] Scripts have execute permissions set before commit
- [ ] Dynamic injection commands have error handling for missing files
- [ ] Scripts work when run from the project root directory

## Related Guides

- [Claude Skills Folder Structure](/claude-skills-folder-structure/)
- [Claude Skills with Embedded Scripts](/claude-skills-with-embedded-scripts/)
- [Fix Claude Code Spawn Unknown Error Skills](/fix-claude-code-spawn-unknown-error-skills/)
