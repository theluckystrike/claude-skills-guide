---
title: "Every SKILL.md Frontmatter Field"
description: "Complete reference for all 14 SKILL.md YAML frontmatter fields including name, description, allowed-tools, paths, effort, and context."
permalink: /skill-md-file-frontmatter-fields-explained/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, frontmatter, yaml, reference]
last_updated: 2026-04-19
---

## The Specific Situation

You have written a SKILL.md file with `name` and `description`, but Claude ignores it half the time, triggers it when you do not want it, or asks for tool permissions you thought you already granted. The problem is almost always in the frontmatter. There are 14 fields available as of 2026, and most developers only use two of them. Knowing the full set gives you precise control over when, how, and with what permissions your skill runs.

## Technical Foundation

SKILL.md uses standard YAML frontmatter between `---` delimiters at the top of the file. All fields are optional, though `description` is strongly recommended. Claude reads the frontmatter to decide when to auto-invoke a skill, what tools to pre-approve, and how to execute it. The markdown body below the frontmatter contains the actual instructions.

Frontmatter parsing follows standard YAML rules. A single tab character instead of spaces, a missing colon, or an unquoted special character will cause a silent parse failure -- Claude will treat the entire file as body text with no metadata.

## The Complete Field Reference

Here is every field with a working example:

```yaml
---
name: lint-fix
description: >
  Fix linting errors in TypeScript files. Use when the user says
  "fix lint errors", "clean up warnings", or "run the linter".
when_to_use: >
  Also trigger when Claude detects ESLint or TSLint errors in
  tool output.
argument-hint: "[file-or-directory]"
disable-model-invocation: false
user-invocable: true
allowed-tools: Bash(npx eslint *) Bash(npx prettier *) Read Grep
model: claude-opus-4-6
effort: high
context: fork
agent: general-purpose
paths: "**/*.ts"
shell: bash
hooks:
  post-invoke: "echo 'Lint fix complete'"
---
```

### Field-by-Field Breakdown

**name** -- Display name. Lowercase letters, numbers, and hyphens only. Max 64 characters. Defaults to the directory name if omitted. This is what appears in the `/` menu.

**description** -- What the skill does and when Claude should use it. Claude matches user requests against this text to decide on auto-invocation. Combined with `when_to_use`, truncated at 1,536 characters. Front-load trigger phrases.

**when_to_use** -- Additional trigger context appended to `description`. Shares the 1,536-character cap. Use for secondary trigger conditions that would clutter the main description.

**argument-hint** -- Shown during autocomplete. Examples: `[issue-number]`, `[filename] [format]`. Purely cosmetic -- does not validate input.

**disable-model-invocation** -- Set `true` to prevent Claude from auto-loading this skill. The skill can only be triggered by typing `/name`. Use for side-effect skills like deploy, commit, or database migrations. When true, the description is not included in Claude's context at all.

**user-invocable** -- Set `false` to hide from the `/` menu. The skill becomes background knowledge Claude loads automatically but users cannot invoke directly. The description stays in context permanently.

**allowed-tools** -- Tools Claude can use without asking permission while this skill is active. Accepts a space-separated string or YAML list. Pattern syntax: `Bash(git add *)` uses glob matching. `Read` and `Grep` are common additions.

**model** -- Override the model for this skill's execution. Useful for routing simple tasks to faster models.

**effort** -- Override the session effort level. Options: `low`, `medium`, `high`, `xhigh`, `max`. Use `max` for complex multi-file refactoring skills.

**context** -- Set to `fork` to run in an isolated subagent context. The skill content becomes the prompt for the subagent. Only makes sense for skills with explicit task instructions, not guidelines.

**agent** -- Which subagent type to use with `context: fork`. Options: `Explore` (read-only), `Plan` (planning), `general-purpose`, or any custom subagent name from `.claude/agents/`.

**paths** -- Glob patterns that limit when auto-activation happens. When set, Claude loads the skill only when working with files matching the pattern. Example: `"**/*.ts"` activates only for TypeScript files.

**shell** -- Shell for `!`command`` and `` ```! `` blocks. Accepts `bash` (default) or `powershell`.

**hooks** -- Lifecycle hooks scoped to this skill. Runs shell commands at specific points in the skill's execution.

## Minimal vs Full Frontmatter

A minimal skill needs only a description:

```yaml
---
description: Runs the full test suite and reports failures
---

Run `pnpm test` and report any failures with file paths and line numbers.
```

A full production skill uses multiple fields for fine-grained control:

```yaml
---
name: deploy-staging
description: Deploy to staging environment with safety checks
disable-model-invocation: true
allowed-tools: Bash(command *)
effort: high
---
```

Start minimal and add fields as you need more control.

## Common Problems and Fixes

**YAML parse failure**: Use spaces, not tabs. Verify with `python3 -c "import yaml; yaml.safe_load(open('SKILL.md'))"` (after stripping the `---` delimiters).

**Description too long**: The combined `description` + `when_to_use` caps at 1,536 characters. The overall budget for all skill descriptions scales at 1% of context window with an 8,000-character fallback. Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var to increase.

**allowed-tools not working**: Tool permissions in `allowed-tools` grant access, they do not restrict. If a deny rule exists in your permission settings, it overrides `allowed-tools`.

**context: fork produces empty output**: Subagent skills need explicit task instructions in the body. A skill with only guidelines and no concrete task will return nothing from the subagent.

## Production Gotchas

The `paths` field only affects auto-invocation. You can still manually invoke any skill with `/name` regardless of path patterns. If you combine `paths` with `disable-model-invocation: true`, the skill effectively cannot auto-activate at all -- the paths filter becomes useless.

The `effort` field overrides the session-level effort setting. A skill with `effort: max` will use maximum reasoning even if the session is set to `low`. This can significantly increase response time and token usage.

Including the word "ultrathink" anywhere in skill content enables extended thinking, independent of the `effort` field.

## Checklist

- [ ] YAML uses spaces (not tabs) for indentation
- [ ] `description` front-loads trigger phrases within 1,536 chars
- [ ] Side-effect skills have `disable-model-invocation: true`
- [ ] `allowed-tools` uses correct glob syntax: `Bash(command *)`
- [ ] Tested both auto-invocation and manual `/name` invocation

## Related Guides

- [Build Your First Claude Code Skill](/building-your-first-claude-skill/)
- [Claude Skills Folder Structure](/claude-skills-folder-structure/)
- [Fix Malformed YAML Frontmatter in SKILL.md](/fix-malformed-yaml-frontmatter-skill-md/)
