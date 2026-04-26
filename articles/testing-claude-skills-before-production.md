---
layout: default
title: "How to Test Claude Code Skills Before (2026)"
description: "Step-by-step testing workflow for SKILL.md files including trigger testing, permission validation, compaction survival, and edge case checks."
permalink: /testing-claude-skills-before-production/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, testing, debugging, quality-assurance]
last_updated: 2026-04-19
---

## The Specific Situation

You wrote a skill that generates database migration files. It works when you invoke it with `/generate-migration`. But when a teammate says "create a migration for the users table," nothing happens. When another teammate says "help me with database stuff," the skill fires unexpectedly and generates an unwanted migration file. You shipped it without testing the trigger boundaries, and now the team does not trust the skill. Here is the testing workflow that prevents this.

## Technical Foundation

Claude Code skills have three testable layers: trigger matching (does the description match the right requests?), execution (does the body produce the correct output?), and lifecycle (does the skill survive compaction and work across long sessions?).

Skills load their body once on invocation. The content enters the conversation as a single message and stays for the session. After auto-compaction, each skill retains at most 5,000 tokens from a shared 25,000-token budget. Testing must verify behavior both immediately after invocation and after compaction has occurred.

Claude watches skill directories for changes, so you can edit SKILL.md during a session and see updates immediately. This makes iterative testing fast.

## The Working SKILL.md (Test Harness Skill)

Create a skill that validates other skills:

```yaml
---
name: test-skill
description: >
  Test another skill by running trigger matching and execution checks.
  Use when the user says "test my skill" or "validate skill".
disable-model-invocation: true
argument-hint: "[skill-name]"
allowed-tools: Read Grep Glob
---

# Skill Test Harness

Test the skill specified by $ARGUMENTS.

## Test Sequence

1. **Locate the skill**: Find SKILL.md at
   `.claude/skills/$ARGUMENTS/SKILL.md` or
   `~/.claude/skills/$ARGUMENTS/SKILL.md`

2. **Validate frontmatter**: Read the file and check:
   - YAML parses without errors
   - `description` is present and under 1,536 characters
   - `name` uses only lowercase, numbers, hyphens (max 64 chars)
   - `allowed-tools` patterns use valid syntax if present

3. **Check trigger phrases**: List 5 natural language requests that
   SHOULD trigger this skill and 5 that SHOULD NOT. Ask the user
   to confirm the boundary is correct.

4. **Verify file references**: If the body references supporting
   files (templates/, scripts/, references/), confirm each file
   exists.

5. **Report**: Summarize pass/fail for each check.
```

## The 5-Step Testing Workflow

### Step 1: Trigger Boundary Testing

Ask Claude "What skills are available?" to confirm your skill appears in the list. Then test with five phrases:

```
# Should trigger:
"generate a migration for the users table"
"create database migration"
"write a migration file"

# Should NOT trigger:
"help me with the database"
"what tables exist?"
```

If the wrong phrases trigger the skill, refine the `description` field. Add specific keywords that match intended use. Remove vague terms.

### Step 2: Argument Passing

Test `$ARGUMENTS` substitution by invoking with different inputs:

```
/generate-migration users           # Single arg
/generate-migration users status    # Multiple args
/generate-migration                 # No args (should handle gracefully)
/generate-migration "user sessions" # Quoted multi-word arg
```

Verify that `$0`, `$1`, and `$ARGUMENTS` resolve correctly in the skill body.

### Step 3: Permission Validation

If the skill uses `allowed-tools`, verify Claude does not prompt for those tools during execution. Test that tools NOT in the allowed list still require permission. Check that deny rules in `/permissions` override `allowed-tools`.

### Step 4: Compaction Survival

Run a long session with 20+ messages after invoking the skill. Then test the skill's instructions again. If behavior degrades, re-invoke with `/skill-name` and verify it recovers. Skills get at most 5,000 tokens after compaction from a shared 25,000-token budget.

### Step 5: Edge Cases

- Invoke the skill twice in one session (should work, re-loads content)
- Test with `--add-dir` pointing to a directory with the skill
- Create a conflicting skill name at personal and project levels (project should lose to personal)

## Common Problems and Fixes

**Skill triggers on unrelated requests**: The description is too broad. Replace "helps with database tasks" with "generates SQL migration files for schema changes."

**Skill works manually but not automatically**: Check that `disable-model-invocation` is not set to `true`. Also verify the description contains words the user would naturally say.

**Scripts fail in the skill**: Verify execute permissions with `ls -la scripts/`. Ensure `allowed-tools` includes the correct pattern like `Bash(bash ${CLAUDE_SKILL_DIR}/scripts/*)`.

**Skill works in first session but fails after restart**: The skill directory might have been moved or renamed. Run `find ~/.claude/skills .claude/skills -name "SKILL.md"` to confirm paths.

## Production Gotchas

There is no built-in eval framework for skills in the open-source Claude Code. Anthropic's official `skill-creator` plugin includes an eval system with test cases, grading agents, and benchmark comparisons. If you need rigorous testing, consider using it as a template.

The live change detection watches for file modifications, not just saves. Some editors write to a temp file and rename (atomic save), which the watcher may miss on certain filesystems. If edits do not take effect, try deleting and recreating the file.

When testing in CI environments, skills in `.claude/skills/` are discovered normally. But `~/.claude/skills/` personal skills may not exist in CI containers. Test project-level skills separately from personal ones.

## Checklist

- [ ] Tested 5 trigger phrases (3 should match, 2 should not)
- [ ] Tested `$ARGUMENTS` with zero, one, and multiple arguments
- [ ] Verified `allowed-tools` permissions work without prompts
- [ ] Confirmed skill survives compaction after 20+ messages
- [ ] Validated all referenced supporting files exist

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Build Your First Claude Code Skill](/building-your-first-claude-skill/)
- [Fix Claude Code Skills Not Showing Up](/fix-claude-code-skills-not-showing-up/)
- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)

## Related Articles

- [Claude Skills for Git, Docker, and Testing Workflows — 2026](/claude-skills-for-git-docker-testing/)
