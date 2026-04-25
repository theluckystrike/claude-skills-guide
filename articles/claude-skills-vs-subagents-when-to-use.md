---
title: "Claude Skills vs Subagents: When to"
description: "Understand when a SKILL.md solves the problem, when context: fork subagent delegation is needed, and how to combine both for complex workflows."
permalink: /claude-skills-vs-subagents-when-to-use/
categories: [skills, 2026]
tags: [claude-code, claude-skills, subagents, architecture]
last_updated: 2026-04-19
---

## The Specific Situation

You need Claude to perform a deep code audit that reads 50+ files, checks each against security patterns, and generates a report. If you write this as a regular skill, the audit content fills the main context window and crowds out everything else. If you use a subagent with `context: fork`, the audit runs in isolation but loses access to the conversation history. You need to decide: skill, subagent, or both?

The answer depends on three factors: whether the task needs main conversation context, whether the output should persist in the session, and whether the task involves sensitive data that should not contaminate the main context.

## Technical Foundation

**Skills** are SKILL.md files that load instructions into the current conversation. Once invoked, the content stays in context for the session and survives compaction (up to 5,000 tokens per skill, 25,000 total budget). Skills share the main context window with the conversation.

**Subagents** are spawned via `context: fork` in a skill's frontmatter or through [Claude Agent SDK guide](/claude-agent-sdk-complete-guide/)'s full context is discarded after it finishes.

**Combined pattern**: A skill uses `context: fork` and `agent: Explore` (or `Plan`, or a custom agent) to run in isolation. The skill provides the instructions; the subagent provides the execution environment.

## The Working SKILL.md

Decision framework skill at `.claude/skills/task-router/SKILL.md`:

```yaml
---
name: task-router
description: >
  Routes tasks to the right execution pattern: inline skill,
  forked subagent, or combined. Use when deciding how to
  structure a new skill or debug why a skill is not performing
  as expected.
user-invocable: false
---

# Task Routing Decision Framework

## Use an Inline Skill When:
- Task needs access to conversation history (previous messages, user preferences)
- Output should persist and influence future turns
- Instructions are under 3,000 tokens
- Task modifies the current codebase (writing files, running commands)
- Examples: code-style, api-conventions, commit-message

## Use context: fork (Subagent) When:
- Task is read-heavy (scanning 50+ files)
- Task processes sensitive data that should not persist
- Task could fill the main context with noise
- You want parallel execution (multiple forks)
- Examples: deep-research, security-audit, dependency-scan

## Use Combined (Skill + Subagent) When:
- You need skill instructions (the "what to do") +
  subagent isolation (the "where to do it")
- The skill provides the procedure; the subagent executes it
- Results summarized and returned to main context
- Example structure:

```yaml
---
context: fork
agent: Explore
allowed-tools: Read Grep Glob
---
# Instructions for the subagent
Analyze $ARGUMENTS and return findings.
```

## Agent Type Selection:
- **Explore**: Read-only. File searching, code reading, analysis. Cannot modify files.
- **Plan**: Creates structured plans. Can read files. Cannot modify.
- **general-purpose**: Full access. Can read, write, and execute.
- **Custom agent**: Define in .claude/agents/ for specialized configurations.

## Token Economics:
| Pattern | Context cost | Post-compaction |
|---------|-------------|-----------------|
| Inline skill | Full body in main context | 5,000 tokens |
| Forked subagent | Zero (runs in isolation) | Summary only |
| Combined | Zero main + full in fork | Summary only |
| Multiple forks | Zero per fork | Summary per fork |

## Warning:
- context: fork with only guidelines (no task) = empty output
- Subagents cannot access main conversation history
- Subagents DO load CLAUDE.md from the project
- Subagents with `skills` field preload those skills at startup
```

## Common Problems and Fixes

**Subagent returns empty output.** The most common mistake. A `context: fork` skill with guidelines like "follow these coding standards" gives the subagent no actionable task. The skill content becomes the subagent's prompt -- it needs explicit instructions: "Read files in src/auth/, check for SQL injection vulnerabilities, return a list of findings."

**Forked skill cannot write files.** If using `agent: Explore`, the subagent has read-only access. Switch to `agent: general-purpose` or a custom agent if the task needs to create or modify files. But consider whether file modification should happen in the main context instead, with only the analysis delegated.

**Subagent ignores project CLAUDE.md rules.** Subagents do load CLAUDE.md, but if the CLAUDE.md content is large (near 200 lines), it competes with the skill content for context space. Keep both concise. If the subagent needs specific CLAUDE.md rules, reference them explicitly in the skill content.

**Inline skill crowds out conversation.** A skill with 8,000 tokens of content reduces available context for the conversation itself. If you notice Claude "forgetting" earlier messages, the skill is too large for inline use. Refactor: move detailed reference material to `references/` files and read on demand, or switch to `context: fork`.

## Production Gotchas

The `agent` field accepts four values: `Explore`, `Plan`, `general-purpose`, and any custom agent name defined in `.claude/agents/`. If you specify a custom agent name that does not exist, Claude falls back silently to the default agent behavior. Verify your custom agent file exists before relying on it.

Subagents spawned via `context: fork` cannot invoke other skills from the main project's skill directory. If the subagent needs another skill's knowledge, either include that content directly in the fork skill or use the `skills` field in a custom agent definition to preload specific skills into the subagent.

## Checklist

- [ ] Tasks requiring conversation context use inline skills
- [ ] Read-heavy analysis tasks use `context: fork` with `agent: Explore`
- [ ] Forked skills contain explicit task instructions, not just guidelines
- [ ] Custom agents verified to exist in `.claude/agents/` before referencing
- [ ] Skill token size under 3,000 for inline, unlimited for forked

## Related Guides

- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- layering and delegation patterns
- [How to Combine Multiple Claude Skills](/how-to-combine-multiple-claude-skills/) -- multi-skill workflows
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/) -- token budget management

- [Claude Flow tool guide](/claude-flow-tool-guide/) — How to use Claude Flow for multi-agent orchestration
## Related Articles

- [Claude Skills vs Subagents — Inline Instructions vs Isolated Execution — 2026](/claude-skills-vs-subagents-comparison/)
- [What Are Claude Skills And How — Complete Developer Guide](/what-are-claude-skills-and-how-to-use-them/)
- [Claude Code Permission Denied: Fix Skill Commands (2026)](/claude-code-permission-denied-when-executing-skill-commands/)
- [Claude Skills vs LangChain Agents Compared (2026)](/claude-skills-vs-langchain-agents-comparison-2026/)
