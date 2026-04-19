---
title: "Build Your First Claude Code Skill in 5 Minutes — 2026"
description: "Create a working SKILL.md file from scratch with frontmatter, description, and body instructions that Claude loads automatically."
permalink: /building-your-first-claude-skill/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, skill-creation, tutorial]
last_updated: 2026-04-19
---

## The Specific Situation

You have a Rust project. Every time you ask Claude Code to explain a module, you paste the same instructions: "show me the ownership flow, highlight unsafe blocks, draw a dependency diagram." You do this three times a day. A skill eliminates that repetition permanently. You create one SKILL.md file, and Claude applies those instructions whenever you ask about code structure -- without you pasting anything.

This works for any language or workflow. The Rust example here targets a real search demand pattern (developers searching "claude rust skills" get zero useful results right now), but the technique applies identically to TypeScript, Python, Go, or anything else.

## Technical Foundation

Claude Code skills follow the Agent Skills open standard (agentskills.io). Each skill is a directory containing a SKILL.md file as its entrypoint. The SKILL.md uses YAML frontmatter for metadata and markdown for instructions.

Skills live in one of three locations:

- **Personal**: `~/.claude/skills/<skill-name>/SKILL.md` -- available in all your projects
- **Project**: `.claude/skills/<skill-name>/SKILL.md` -- shared with your team via git
- **Enterprise**: Managed settings path -- deployed organization-wide

Unlike CLAUDE.md content that loads at session start, a skill's body loads only when invoked. This means long reference material costs almost nothing until you need it. Claude watches skill directories for file changes, so edits take effect immediately without restarting your session.

## The Working SKILL.md

Create the directory and file:

```bash
mkdir -p .claude/skills/explain-rust
```

Write this SKILL.md:

```yaml
---
name: explain-rust
description: Explains Rust code with ownership diagrams and safety analysis. Use when the user asks to explain a Rust module, understand ownership flow, or review unsafe code.
---

When explaining Rust code, follow this structure:

1. **Ownership diagram**: Draw an ASCII diagram showing ownership transfers,
   borrows, and lifetimes for the key types in the module.

2. **Safety audit**: Identify any `unsafe` blocks. For each one, state:
   - What invariant it relies on
   - Whether that invariant is documented
   - Whether a safe alternative exists

3. **Dependency map**: List which other modules this code depends on and
   what it exports. Use a simple tree format.

4. **One gotcha**: Name the most likely mistake a new contributor would
   make when modifying this code.

Keep explanations concrete. Reference specific line numbers and function
names from the actual code Claude has read.
```

Now invoke it by typing `/explain-rust` in Claude Code, or just ask "explain this Rust module" and Claude will match the description automatically.

## Adapting for Other Languages

The same pattern works for any language. Swap the domain-specific instructions:

```yaml
---
name: explain-python
description: Explains Python code with type flow analysis and import mapping. Use when explaining Python modules or reviewing type safety.
---

When explaining Python code:

1. **Type flow**: Trace the types through the function signatures.
   Flag any `Any` types or missing annotations.
2. **Import map**: Show what this module imports and what depends on it.
3. **Mutation audit**: Identify mutable state and shared references.
4. **One gotcha**: The most likely runtime error from modifying this code.
```

## Common Problems and Fixes

**Skill does not trigger automatically**: Your `description` field must include keywords users naturally say. "Explain this code" matches `description: Explains code`. "Analyze my module" does not match unless you add those words.

**Skill not found after creation**: If you created the `.claude/skills/` directory for the first time in this session, restart Claude Code. Edits to existing skill directories are detected live, but a new top-level skills directory requires a restart.

**Description gets truncated**: The combined `description` and `when_to_use` text is capped at 1,536 characters. Front-load the most important trigger phrases.

**Skill fires when you do not want it**: Add `disable-model-invocation: true` to the frontmatter. This makes the skill manual-only, invoked exclusively with `/skill-name`.

**Body too long**: Keep SKILL.md under 500 lines. Move detailed reference material to separate files in the skill directory and reference them from SKILL.md.

## Production Gotchas

The skill body enters the conversation as a single message and stays for the rest of the session. Claude does not re-read it on later turns. After auto-compaction, each skill gets at most 5,000 tokens (with a combined budget of 25,000 tokens across all active skills). If your skill seems to stop working mid-session, re-invoke it with `/explain-rust` to restore the full content.

The `$ARGUMENTS` substitution lets you pass context: `/explain-rust src/parser.rs` replaces `$ARGUMENTS` with `src/parser.rs` in the skill body.

## Checklist

- [ ] SKILL.md exists at `.claude/skills/<name>/SKILL.md`
- [ ] Frontmatter has a `description` with natural trigger phrases
- [ ] Body is under 500 lines with concrete instructions
- [ ] Tested with both `/skill-name` and a natural language request
- [ ] Confirmed skill appears when asking "What skills are available?"

## Related Guides

- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
- [Claude Skills Folder Structure](/claude-skills-folder-structure/)
- [Testing Claude Skills Before Production](/testing-claude-skills-before-production/)
