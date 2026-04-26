---
layout: default
title: "Skills vs Hooks vs Commands in Claude (2026)"
description: "Understand the differences between Claude Code skills, hooks, and slash commands to choose the right extension type for your workflow."
permalink: /claude-code-skills-vs-hooks-vs-commands-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Skills vs Hooks vs Commands in Claude Code (2026)

Claude Code has three extension mechanisms: skills (CLAUDE.md rules), hooks (event-triggered scripts), and slash commands (interactive workflows). Each solves a different problem. Choosing wrong means either missing automation opportunities or burning tokens on unnecessary overhead.

## Quick Comparison

| Feature | Skills | Hooks | Commands |
|---------|--------|-------|----------|
| **What** | Behavioral instructions | Shell scripts | Workflow templates |
| **Where** | CLAUDE.md | .claude/settings.json | .claude/commands/*.md |
| **Trigger** | Always active | Event-based (auto) | Manual (type /name) |
| **Runs code** | No | Yes | No |
| **Token cost** | Constant (in every session) | Variable (only output) | On-demand |
| **Scope** | Project or user | Project or user | Project or user |

## Skills (CLAUDE.md Rules)

### What They Are
Skills are markdown instructions in your CLAUDE.md file that Claude Code follows in every session. They define behavior, conventions, and constraints.

### Example
```markdown
## Skill: TypeScript Strict Mode
- ALL code must pass tsc --strict
- NEVER use 'any' type
- ALL functions must have explicit return types
- Use Zod for runtime validation, derive types with z.infer
```

### When to Use
- Enforcing coding conventions across all sessions
- Defining architecture rules that never change
- Setting project vocabulary and terminology
- Establishing security policies

### Strengths
- Always active — no need to remember to invoke them
- Human-readable and version-controllable
- Easy to write and modify
- Work in both interactive and API mode

### Weaknesses
- Consume context window tokens in every session
- Cannot run code or validate output
- Cannot block or prevent actions (advisory only)
- No conditional logic

The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repo (72K+ stars) and [claude-code-templates](https://github.com/davila7/claude-code-templates) (25K+ stars) provide hundreds of pre-built skills.

## Hooks (Event-Triggered Scripts)

### What They Are
Hooks are shell commands in `.claude/settings.json` that execute automatically when Claude Code performs specific actions.

### Example
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "npx eslint --fix $FILE 2>&1 | tail -5"
    }]
  }
}
```

### When to Use
- Auto-linting after file writes
- Running type checks after edits
- Scanning for security issues
- Blocking writes to protected files
- Triggering external notifications

### Strengths
- Run real code — can lint, test, scan
- Automatic — no manual invocation
- Output feeds back to Claude Code (self-correcting)
- Zero constant token cost (only output counts)

### Weaknesses
- Add latency to every tool use (synchronous execution)
- Can break Claude Code flow if misconfigured
- Limited variable access ($FILE, $TOOL, $COMMAND)
- Require shell scripting knowledge

The [claude-code-docs](https://github.com/ericbuess/claude-code-docs) repo demonstrates hooks for auto-updating documentation, and the [claude-code-hooks-explained guide](/claude-code-hooks-explained-complete-guide-2026/) covers all event types.

## Slash Commands (Interactive Workflows)

### What They Are
Commands are markdown files in `.claude/commands/` that define multi-step workflows invoked by typing `/command-name`.

### Example
File: `.claude/commands/review.md`
```markdown
Review the recent code changes in this project.

1. Run git diff HEAD~1 to see changes
2. For each changed file, check:
   - Security issues
   - Performance concerns
   - Style violations
3. Output a structured review with severity ratings
```

### When to Use
- Complex multi-step workflows you run frequently
- Code review processes
- Project scaffolding
- Deployment checklists
- Data analysis workflows

### Strengths
- Reusable complex workflows
- On-demand (only invoked when needed)
- Support rich markdown instructions
- Can reference other commands and skills
- Zero token cost until invoked

### Weaknesses
- Require manual invocation
- Do not run in API mode
- Cannot enforce rules passively
- Limited to markdown instructions (no code execution)

The [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) (22K+ stars) provides 30 pre-built [Claude shortcuts](/claude-shortcuts-complete-guide/) covering project management, implementation, testing, deployment, and more.

## Decision Framework

### "I want Claude Code to always follow a rule"
Use a **skill** in CLAUDE.md.

Example: "Always use named exports" → CLAUDE.md rule

### "I want code validated after every write"
Use a **hook** in settings.json.

Example: "Run ESLint after writes" → post-tool-use hook

### "I want a complex workflow I can trigger on demand"
Use a **command** in .claude/commands/.

Example: "Full code review checklist" → /review command

### Combination Examples

Most real setups use all three:

```
CLAUDE.md (Skills):
- Naming conventions
- Framework rules
- Security policies

.claude/settings.json (Hooks):
- Auto-lint on write
- Type check on edit
- Secret scanner on write

.claude/commands/ (Commands):
- /review — Code review workflow
- /deploy — Deployment checklist
- /scaffold — New feature scaffolding
```

## Token Cost Analysis

For a typical session:

| Extension | Tokens per Session |
|-----------|-------------------|
| Skills (1,000 word CLAUDE.md) | ~1,300 constant |
| Hooks (5 hooks, avg 10 lines output each) | ~250 variable |
| Commands (invoked once) | ~500 on-demand |

Skills have the highest constant cost because they are included in every message. Hooks only cost tokens when their output is returned. Commands only cost tokens when invoked.

## FAQ

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

### Can I convert between types?
A skill can become a command if you only need it sometimes. A command can become a skill if you need it always. Hooks are unique — they run code, which the other types cannot do.

### Which type runs in API mode?
Skills (CLAUDE.md) and hooks work in API mode. Slash commands require interactive mode.

### Can they conflict?
A skill saying "use single quotes" and a hook that enforces double quotes will fight. Ensure your three extension types are aligned.

### How many of each should I have?
Start with 5-10 skills, 2-3 hooks, and 1-2 commands. Add more based on pain points. The [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) catalogs common configurations.

For building your own extensions, see the [skill building guide](/how-to-build-your-own-claude-code-skill-2026/). For hook recipes, read the [hooks guide](/claude-code-hooks-explained-complete-guide-2026/). For the full ecosystem, see the [tools map](/claude-code-ecosystem-complete-map-2026/).

