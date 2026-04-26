---
layout: default
title: "How to Combine Multiple Claude Skills (2026)"
description: "Chain Claude Code skills in sequence, layer reference skills with task skills, and build multi-step workflows using skill composition patterns."
permalink: /how-to-combine-multiple-claude-skills/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, skill-composition, architecture]
last_updated: 2026-04-19
---

## The Specific Situation

You have a project with 8 skills: a code style enforcer, a test generator, a PR summary writer, a deployment checker, and four domain-specific reference skills. When you ask Claude to "review this PR and deploy," it should load the PR summary skill, apply the code style reference, run the test generator on changed files, then execute the deployment checker. Right now, each skill works in isolation and you invoke them manually one at a time.

Combining skills effectively means understanding which skills should layer (active simultaneously as reference context), which should chain (one's output feeds another's input), and which should sequence (run in order with gates between steps).

## Technical Foundation

Claude Code loads all auto-invocable skill descriptions into the context window at session start. Each description is capped at 1,536 characters and counts toward a budget scaled at 1% of the context window (fallback: 8,000 characters total). When Claude invokes a skill, the full SKILL.md body enters the conversation as a single message and stays for the rest of the session. After compaction, invoked skills are re-attached with a 5,000-token limit per skill and a 25,000-token combined budget, filled from most recently invoked first.

This means that combining skills has real token economics. Three simultaneously invoked skills consume up to 15,000 tokens of compaction budget. Four or more means the oldest skill's content may be dropped entirely after compaction.

## The Working SKILL.md

Create a composition orchestrator at `.claude/skills/workflow-orchestrator/SKILL.md`:

```yaml
---
name: workflow-orchestrator
description: >
  Orchestrate multi-skill workflows. Use when a task requires
  combining code review + testing + deployment or any sequence
  of skills. Defines chaining, layering, and gating patterns.
  Invoke with: /workflow-orchestrator [workflow-name]
disable-model-invocation: true
allowed-tools: Skill(code-style *) Skill(test-gen *) Skill(pr-summary *) Skill(deploy-check *)
---

# Workflow Orchestrator

## Available Workflows

### pr-review-deploy
Sequence: pr-summary → code-style check → test-gen → deploy-check

Steps:
1. Invoke /pr-summary to analyze the current PR diff
2. Apply /code-style rules to flag violations in changed files
3. Run /test-gen on any changed source file lacking test coverage
4. Gate: Stop if code-style violations > 0 or tests fail
5. If gate passes, invoke /deploy-check for pre-deployment validation

### full-review
Layers: code-style (reference) + pr-summary (task)
- Load code-style as background reference (it stays in context)
- Then invoke pr-summary which will naturally respect loaded style rules
- This is layering: one skill provides context, another performs the task

### test-and-fix
Chain: test-gen output → fix → re-test
1. Run /test-gen to identify untested functions
2. Write tests for identified gaps
3. Run tests via Bash
4. If tests fail, analyze failure and fix the implementation
5. Re-run tests to confirm

## Composition Patterns

### Pattern 1: Layering (Reference + Task)
Load a reference skill first, then invoke a task skill.
The task skill inherits the reference context.
Example: Load api-conventions, then invoke pr-summary.
The PR summary will check against API conventions automatically.

### Pattern 2: Chaining (Output → Input)
One skill's output becomes the next skill's input.
Use $ARGUMENTS to pass data between skills.
Example: /analyze-deps produces a JSON report,
then /security-audit reads that report as input.

### Pattern 3: Gating (Conditional Proceed)
A skill checks a condition before the next skill runs.
If the gate fails, stop the workflow and report why.
Example: /lint-check must pass before /deploy runs.

### Token Budget Awareness
- 2 concurrent skills: Safe (10,000 tokens post-compaction)
- 3 concurrent skills: Viable (15,000 tokens, budget holds)
- 4+ concurrent skills: Risk of oldest skill being dropped
- Mitigation: Use context: fork for heavy skills to isolate them
```

Example of a layered invocation sequence in practice:

```bash
# Step 1: Load reference context (auto-invoked via paths)
# Claude sees **/*.ts file -> loads code-style skill automatically

# Step 2: Invoke task skill manually
/pr-summary
# PR summary now executes with code-style rules in context

# Step 3: Gate check before deploy
/deploy-check staging
# Only proceeds if pr-summary and code-style found no issues
```

## Common Problems and Fixes

**Oldest skill forgotten after compaction.** When 4+ skills are active and compaction runs, the least recently invoked skill may lose its content. Re-invoke it with `/skill-name` to restore. Alternatively, design workflows so no more than 3 skills are active simultaneously.

**Reference skill not influencing task skill output.** If you invoke a task skill before loading the reference skill, the task skill runs without that context. Order matters: always load reference skills first, then invoke the task skill.

**Skill descriptions compete for budget.** With 8+ skills, the 1,536-character descriptions alone consume significant context. Set `user-invocable: false` on background-only skills and `disable-model-invocation: true` on manual-only workflows to keep descriptions out of the context window.

**Chained skills cannot read each other's output files.** Skills do not share state directly. Use the filesystem as the interface: first skill writes to `reports/step1-output.json`, second skill reads from that path. Document the expected file paths in both skills.

## Production Gotchas

The 25,000-token compaction budget is a hard limit shared across all invoked skills. If your workflow requires 5 skills each using 8,000 tokens, post-compaction only the 3 most recent fit. Design heavy skills as `context: fork` subagents that return a summary rather than persisting their full content in the main conversation.

Skill invocation order within a single turn is non-deterministic when Claude auto-invokes. If order matters (reference before task), explicitly invoke them in sequence rather than relying on automatic loading.

## Checklist

- [ ] No more than 3 skills active simultaneously in the main context
- [ ] Reference skills loaded before task skills in sequenced workflows
- [ ] Heavy skills (>3,000 tokens) use `context: fork` to avoid budget competition
- [ ] File-based interfaces documented between chained skills
- [ ] `disable-model-invocation: true` set on orchestrator skills

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- detailed pattern reference
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/) -- token budget management
- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/) -- sharing data between skills

## Related Articles

- [How to Combine Multiple Claude Skills in One Project](/how-to-combine-multiple-claude-skills-in-one-project/)
