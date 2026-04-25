---
layout: default
title: "Claude Skills Shared Dependencies (2026)"
description: "Structure shared scripts, templates, and config files across multiple Claude Code skills without duplication using symlinks, references, and plugin patterns."
permalink: /claude-skills-shared-dependencies/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, shared-dependencies, architecture]
last_updated: 2026-04-19
---

## The Specific Situation

You have 6 skills that all need access to the same validation script (`validate-output.sh`), the same error code reference (`error-codes.json`), and the same output template (`report-template.md`). Copying these files into each skill's directory means maintaining 6 copies. When you update the validation logic, you must update it in 6 places. Missing one copy creates inconsistent behavior that is difficult to debug.

You need a shared dependency strategy that gives multiple skills access to common resources without duplication, while respecting Claude Code's skill directory structure.

## Technical Foundation

Each Claude Code skill is a directory with `SKILL.md` as the entrypoint. Skills can reference supporting files from within their directory using relative paths. Claude reads these files on demand when the SKILL.md references them. Skills stored at different scopes (personal `~/.claude/skills/`, project `.claude/skills/`, plugin `plugin/skills/`) are discovered independently.

The key insight: skills reference files by path, and Claude resolves those paths relative to the project root (for project skills) or the skill directory. This means multiple skills can reference the same file if they use absolute or project-root-relative paths.

## The Working SKILL.md

Create a shared resources directory and reference it from multiple skills:

```
.claude/
  skills/
    _shared/                    # Shared resources (not a skill itself)
      scripts/
        validate-output.sh
      references/
        error-codes.json
      templates/
        report-template.md
    skill-a/
      SKILL.md                  # References ../_shared/scripts/
    skill-b/
      SKILL.md                  # References ../_shared/scripts/
    skill-c/
      SKILL.md                  # References ../_shared/scripts/
```

Example `skill-a/SKILL.md`:

```yaml
---
name: skill-a
description: >
  Processes data files and generates validated reports.
  Uses shared validation scripts and report templates.
allowed-tools: Bash(bash *) Read
---

# Skill A — Data Processor

## Shared Resources
The following resources are shared across multiple skills:

- Validation script: `.claude/skills/_shared/scripts/validate-output.sh`
  Run after generating any output file to verify format compliance.
- Error codes: `.claude/skills/_shared/references/error-codes.json`
  Reference when mapping error conditions to user-facing messages.
- Report template: `.claude/skills/_shared/templates/report-template.md`
  Use as the base structure for all generated reports.

## Workflow
1. Process input data from $ARGUMENTS[0]
2. Generate output to `reports/skill-a-output.json`
3. Validate: `bash .claude/skills/_shared/scripts/validate-output.sh reports/skill-a-output.json`
4. If validation fails, read error code from error-codes.json and fix
5. Apply report template to generate final report

## Output Conventions
All output must pass the shared validation script before being considered complete.
Error handling must use codes from the shared error-codes.json.
```

An alternative using symlinks:

```bash
# Create symlinks in each skill directory pointing to shared resources
cd .claude/skills/skill-a
ln -s ../_shared/scripts scripts
ln -s ../_shared/references references

cd .claude/skills/skill-b
ln -s ../_shared/scripts scripts
ln -s ../_shared/references references
```

With symlinks, each skill can reference `scripts/validate-output.sh` using a local relative path. Claude Code follows symlinks when reading files.

## Common Problems and Fixes

**Shared directory discovered as a skill.** If `_shared/` contains a `SKILL.md`, Claude treats it as a skill. Avoid this by not putting a `SKILL.md` in the shared directory. Use the underscore prefix (`_shared`) as a naming convention to signal "not a skill."

**Symlinks break on Windows.** Git on Windows requires `core.symlinks = true` in git config, and the user may need developer mode enabled. For cross-platform teams, use explicit path references in SKILL.md instead of filesystem symlinks.

**Shared script updated but skill uses cached version.** Claude Code watches skill directories for file changes and picks up edits within the current session. However, if the shared directory is outside the skill directory and not a symlinked child, changes may not trigger re-reads. Restart the session or explicitly reference the updated file.

**Plugin skills cannot reference project-level shared resources.** Plugin skills live in a separate directory tree. They cannot use `../_shared/` relative paths because the plugin directory is not inside `.claude/skills/`. For plugins, bundle required resources within the plugin or use absolute paths.

## Production Gotchas

The `_shared` directory pattern works within a single project. For sharing resources across projects (personal skills at `~/.claude/skills/`), use the personal-scope shared directory at `~/.claude/skills/_shared/` and reference with absolute paths like `~/.claude/skills/_shared/scripts/validate.sh`. Claude resolves `~` to the home directory.

When multiple skills reference the same large reference file (e.g., a 5,000-word error code database), Claude reads it each time a skill requests it. This does not duplicate in context -- Claude's file reading is content-addressed -- but the read operation happens each time. For very large shared references, consider having a single "loader" skill that reads the file once and summarizes it.

## Checklist

- [ ] Shared resources in `_shared/` directory without SKILL.md
- [ ] All skills reference shared resources using consistent relative paths
- [ ] Shared scripts are executable (`chmod +x`)
- [ ] Cross-platform compatibility documented (symlinks vs explicit paths)
- [ ] Shared resource changes tested across all dependent skills

## Related Guides

- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- how skills interact architecturally
- [Claude Skills for Monorepo Projects](/claude-skills-for-monorepo-projects/) -- shared dependencies across packages
- [Claude Skill Registry Pattern for Teams](/claude-skill-registry-pattern-for-teams/) -- team-wide shared skill management

## Related Articles

- [Update Shared Claude Skills Without Breaking Team Workflows — 2026](/updating-shared-claude-skills-without-breaking-workflows/)
