---
layout: default
title: "Fix Claude Skill Infinite Loop (2026)"
description: "Diagnose and fix infinite loops caused by skill auto-invocation cycles, compaction re-triggering, and recursive script execution in Claude Code."
permalink: /fix-claude-skill-infinite-loop/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, infinite-loop, recursion, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

You invoke `/fix-lint`. The skill tells Claude to fix linting errors. Claude fixes them, then detects linting-related content in the conversation and re-invokes the skill. The skill runs again, produces more lint-related output, and Claude triggers it a third time. Each cycle consumes context window. Within minutes, Claude is compacting aggressively and the session becomes unresponsive. You have a skill triggering loop.

## Technical Foundation

Skills can trigger in two ways: manually (user types `/name`) and automatically (Claude matches the conversation against skill descriptions). Auto-invocation creates the possibility of loops: if a skill's output matches its own trigger conditions, Claude may re-invoke it. Learn more in [Fix ENOENT No Such File or Directory Error with Claude Skills — 2026](/fix-claude-code-enoent-skills/).

The content lifecycle matters here:
- Skill body enters as a single message and stays for the session
- Claude does not re-read the skill file on later turns
- After compaction, each skill retains at most 5,000 tokens
- Re-invocation loads the full content again

A skill that produces output matching its own `description` keywords creates a positive feedback loop. Each invocation generates more matching content, triggering another invocation.

## The Working SKILL.md (Loop-Safe Pattern)

A skill designed to prevent self-triggering:

```yaml
---
name: fix-lint
description: >
  Fix ESLint errors in the specified file. Invoked manually with
  /fix-lint [filename]. Does not auto-trigger.
disable-model-invocation: true
argument-hint: "[filename]"
allowed-tools: Bash(npx eslint *) Read
---

# Fix Lint Errors

Fix ESLint errors in $ARGUMENTS.

## Steps

1. Run ESLint to identify errors:
   ```bash
   npx eslint $ARGUMENTS --format json
   ```

2. Read each file with errors

3. Fix the errors in place

4. Run ESLint again to verify fixes:
   ```bash
   npx eslint $ARGUMENTS
   ```

5. Report results. Do NOT invoke this skill again.
   If errors remain after one pass, list them and stop.
```

Key loop-prevention elements:
- `disable-model-invocation: true` prevents auto-triggering
- Body explicitly says "Do NOT invoke this skill again"
- Single-pass design with explicit stop condition

## Loop Cause 1: Auto-Invocation Cycle

A skill with a broad description that matches its own output:

```yaml
# BROKEN: description matches any lint-related conversation
---
name: fix-lint
description: Fix linting errors and code quality issues
---
# Claude sees "linting errors" in output → re-invokes skill
```

Fix: Add `disable-model-invocation: true` for task skills. Auto-invocation should only be used for informational/reference skills that do not produce action-triggering output.

## Loop Cause 2: Skill Calls Another Skill That Calls Back

```
/generate-tests → output mentions "lint errors in test file"
→ /fix-lint auto-triggers → output mentions "test file updated"
→ /generate-tests auto-triggers → loop
```

Fix: Set `disable-model-invocation: true` on at least one skill in the chain. Or narrow descriptions so they do not match each other's output.

## Loop Cause 3: Script That Triggers Its Own Skill

A skill that runs a script whose output contains the skill's trigger keywords:

```yaml
---
name: check-quality
description: Check code quality and report issues
---

# Check Quality
Run: !`python3 ${CLAUDE_SKILL_DIR}/scripts/quality.py`
```

If `quality.py` outputs "Found 5 code quality issues", Claude may re-invoke `check-quality` because the output matches the description.

Fix: Use `disable-model-invocation: true` or make the description more specific: "Run the quality check script at /check-quality" instead of broad keywords.

## Loop Cause 4: Compaction Re-Triggering

After compaction, a skill's content is reduced to 5,000 tokens. Claude may lose the context that the skill already ran and re-invoke it based on the conversation topic.

Fix: Skills should produce a clear "DONE" marker in their output. Instruct Claude in the skill body: "After completing all steps, output 'SKILL COMPLETE: fix-lint' and do not re-invoke."

## Breaking a Loop in Progress

If you are in an active loop:

1. **Press Ctrl+C** to interrupt the current Claude operation
2. **Type a clear instruction**: "Stop. Do not invoke any skills. The fix-lint task is complete."
3. **If the session is unresponsive**: Close and restart Claude Code

After breaking the loop, fix the skill before the next invocation:

```yaml
# Add to frontmatter to prevent auto-triggering
disable-model-invocation: true
```

## Defensive SKILL.md Template

Use this template for any action skill (skills that modify files or run commands):

```yaml
---
name: [action-verb]-[target]
description: >
  [Specific action]. Invoked manually with /[name] [args].
disable-model-invocation: true
argument-hint: "[expected-input]"
allowed-tools: [specific tools]
---

# [Action Description]

[Steps]

## Exit Conditions

- After completing all steps, stop. Do not re-invoke this skill.
- If the task cannot be completed, report why and stop.
- Maximum one pass. Do not retry automatically.
```

## Common Problems and Fixes

**Skill runs 3-4 times before stopping**: Claude has some built-in loop detection but it is not always effective. Add explicit stop instructions in the skill body AND set `disable-model-invocation: true`.

**Two skills keep triggering each other**: Narrow both descriptions. If skill A mentions "tests" and skill B mentions "test errors", any test-related work bounces between them. Make descriptions specific: "Generate Jest unit tests for React components" vs "Fix ESLint errors in TypeScript files."

**Loop only happens in long sessions**: Compaction drops skill context, causing Claude to "forget" that the skill already ran. Add `disable-model-invocation: true` to prevent post-compaction re-triggering.

**Loop with the built-in /loop skill**: The `/loop` bundled skill intentionally runs repeatedly. If a custom skill auto-triggers during a `/loop` execution, it compounds. Disable auto-invocation on the custom skill.

## Production Gotchas

There is no global "max skill invocations per session" setting. Claude Code does not enforce limits on how many times a skill can be auto-invoked. The protection must come from skill design: either `disable-model-invocation: true` or narrow descriptions.

Skills with `context: fork` (subagent execution) are less prone to loops because the subagent runs in isolation. Its output is summarized before returning to the main conversation, which reduces the chance of matching trigger descriptions. Consider using `context: fork` for complex action skills.

The `/batch` bundled skill spawns parallel agents in worktrees. If those agents invoke auto-triggering skills, each agent runs independently and may create parallel loops. Ensure skills used in batch workflows have `disable-model-invocation: true`.

## Checklist

- [ ] Action skills have `disable-model-invocation: true`
- [ ] Skill body includes explicit "stop after completion" instruction
- [ ] Description does not match the skill's own output keywords
- [ ] No circular dependency between auto-triggered skills
- [ ] Exit condition defined for all execution paths

## Related Guides

- [Fix Claude Skill Timeout Errors](/fix-claude-skill-timeout-errors/)
- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
- [Testing Claude Skills Before Production](/testing-claude-skills-before-production/)
