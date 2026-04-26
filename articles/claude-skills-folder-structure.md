---
layout: default
title: "Claude Skills Folder Structure (2026)"
description: "Exact directory layout for Claude Code skills including SKILL.md, scripts, templates, examples, and references with real file tree examples."
permalink: /claude-skills-folder-structure/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, directory-structure, file-organization]
last_updated: 2026-04-19
---

## The Specific Situation

You have built a skill that generates test files. The SKILL.md contains a 200-line template, a 50-line validation script, and three example outputs. Everything is crammed into one file. Claude loads all 400+ lines every time the skill triggers, consuming context window for content it may not need. The fix is progressive disclosure: split the skill into a directory with supporting files that Claude loads only on demand. We cover this further in [Claude Skills for Travel Booking Platforms — Automate GDS Parsing, Fare Rules, and PNR Validation — 2026](/claude-skills-for-travel-booking-platforms/).

## Technical Foundation

Each skill is a directory with SKILL.md as its required entrypoint. Claude Code discovers skills in three locations, each with a different scope:

| Scope | Path | Shared With |
|-------|------|-------------|
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | Just you, all projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | Team via version control |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |
| Enterprise | Managed settings | All org users |

Precedence order: enterprise > personal > project. Plugin skills use a `plugin-name:skill-name` namespace, so they never conflict with other levels.

Claude watches skill directories for changes. Editing a SKILL.md or adding a file takes effect within the current session. Creating a brand new `.claude/skills/` directory for the first time requires restarting Claude Code.

## The Working SKILL.md

Here is the recommended directory structure for a production skill:

```
generate-tests/
├── SKILL.md              # Main instructions (required, under 500 lines)
├── templates/
│   ├── unit-test.md       # Template for unit test output
│   └── integration-test.md # Template for integration test output
├── examples/
│   ├── react-component.md # Example: React component test
│   └── api-endpoint.md    # Example: API endpoint test
├── scripts/
│   └── validate-tests.sh  # Validation script Claude can execute
└── references/
    └── testing-patterns.md # Detailed reference (2,000-5,000 words)
```

The SKILL.md entrypoint should reference supporting files so Claude knows what to load and when:

```yaml
---
name: generate-tests
description: >
  Generate unit and integration tests for the current file. Use when
  the user asks to "write tests", "add test coverage", or "create
  test file".
allowed-tools: Bash(npx jest *) Bash(npx vitest *) Read
---

# Generate Tests

Write tests for the file specified by $ARGUMENTS or the most
recently discussed file.

## Steps

1. Read the source file and identify exported functions/components
2. Choose the correct template from this skill's templates/ directory:
   - Unit tests: Read templates/unit-test.md
   - Integration tests: Read templates/integration-test.md
3. Generate tests following the template structure
4. Run the validation script to verify:
   ```bash
   bash ${CLAUDE_SKILL_DIR}/scripts/validate-tests.sh
   ```
5. If tests fail validation, fix and re-run

## Reference

For complex testing patterns (mocking, async, snapshot testing),
read references/testing-patterns.md in this skill's directory.

## Examples

See examples/ directory for working test files that demonstrate
the expected output format.
```

## Progressive Disclosure Architecture

This is the core design principle from Anthropic's official skill development guidance:

**Level 1 -- Metadata (always in context)**: The `name` and `description` fields. Claude sees these for every skill at all times to decide which ones to invoke. Keep the combined text under 1,536 characters.

**Level 2 -- SKILL.md body (loaded on invocation)**: The markdown content below frontmatter. Target 1,500-2,000 words. Loads as a single message when the skill triggers. Stays in the conversation for the rest of the session.

**Level 3 -- Bundled resources (loaded on demand)**: Templates, examples, scripts, references. Claude reads these files only when the SKILL.md body instructs it to. This is where you put the 5,000+ word reference docs, large templates, and runnable scripts.

## Common Problems and Fixes

**Claude cannot find supporting files**: Use `${CLAUDE_SKILL_DIR}` to reference the skill's own directory. This variable resolves to the absolute path of the directory containing SKILL.md.

**SKILL.md too large**: The official guidance says under 500 lines. Move anything over 100 lines to `references/` or `templates/`. Claude reads them with the Read tool when needed.

**Nested skills not discovered**: Skills in subdirectory `.claude/skills/` are auto-discovered when Claude edits files in that subdirectory. This supports monorepo setups like `packages/frontend/.claude/skills/`.

**Scripts fail to execute**: Ensure scripts have execute permissions (`chmod +x`). Add the script's tool pattern to `allowed-tools`: `Bash(bash ${CLAUDE_SKILL_DIR}/scripts/*)`.

## Production Gotchas

The `--add-dir` flag grants file access to additional directories. Any `.claude/skills/` directory within an added directory is loaded automatically as a special exception. However, other `.claude/` config files (like CLAUDE.md) from `--add-dir` directories are NOT loaded by default.

After compaction, each skill gets at most 5,000 tokens re-attached, with a combined budget of 25,000 tokens across all active skills. Skills with large bodies effectively get truncated. The progressive disclosure pattern avoids this: keep SKILL.md concise and let Claude pull reference material from files only when needed. Learn more in [Polyglot Claude Skills — Building Skills That Work Across TypeScript, Python, Rust, and Go — 2026](/polyglot-claude-skills-multi-language/).

## Checklist

- [ ] SKILL.md is the only file at the directory root (required entrypoint)
- [ ] Supporting files organized into `templates/`, `examples/`, `scripts/`, `references/`
- [ ] SKILL.md references supporting files with clear "when to load" instructions
- [ ] Total SKILL.md body under 500 lines; detailed content in references/
- [ ] Scripts have execute permissions and are listed in `allowed-tools`



**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

## Related Guides

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

- [Build Your First Claude Code Skill](/building-your-first-claude-skill/)
- [Claude Skills with Embedded Scripts](/claude-skills-with-embedded-scripts/)
- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
