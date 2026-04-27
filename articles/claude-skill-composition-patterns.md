---
sitemap: false
layout: default
title: "Claude Skill Composition Patterns (2026)"
description: "Master five skill composition patterns: layering, delegation, pipeline, fan-out, and fallback. With complete SKILL.md examples and token budget analysis."
permalink: /claude-skill-composition-patterns/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, composition-patterns, architecture]
last_updated: 2026-04-19
---

## The Specific Situation

Your project has grown from 2 skills to 12. Some are reference skills (coding standards, API conventions), some are task skills (deploy, test, review), and some are research skills (deep-dive, dependency audit). You need a mental model for how these skills interact. When should one skill call another? When should they share context? When should they run in isolation?

Five composition patterns cover every multi-skill scenario: layering, delegation, pipeline, fan-out, and fallback. Each pattern has different token cost characteristics and different failure modes.

## Technical Foundation

Claude Code skills interact through three mechanisms. First, **context sharing**: when multiple skills are invoked in the same session, they share the conversation context. Second, **file-based interfaces**: skills write output to files that other skills read. Third, **subagent delegation**: a skill with `context: fork` runs in an isolated context and returns a summary.

The compaction lifecycle governs what survives long sessions. Invoked skills share a 25,000-token budget during compaction, with each skill capped at 5,000 tokens. The most recently invoked skill fills the budget first. Skills can also use `allowed-tools: Skill(other-skill *)` to grant permission to invoke other skills.

## The Working SKILL.md

Create at `.claude/skills/composition-guide/SKILL.md`:

```yaml
---
name: composition-guide
description: >
  Reference guide for skill composition patterns. Use when designing
  multi-skill workflows, debugging skill interaction issues, or
  choosing between layering, delegation, pipeline, fan-out, and
  fallback architectures. Not a task skill — provides design guidance.
user-invocable: false
---

# Skill Composition Patterns Reference

## Pattern 1: Layering
Multiple skills active in the same context simultaneously.
One provides reference knowledge, another performs the task.

Structure:
- Reference skill: auto-invocable, user-invocable: false
- Task skill: manually invoked by user
- Reference skill loads first (via path activation or auto-invocation)
- Task skill benefits from reference context already present

Token cost: Both skills share the main context budget.
Use when: Reference knowledge must influence task execution.
Avoid when: Combined token usage exceeds 10,000 tokens.

Example: api-conventions (reference) + pr-summary (task)

## Pattern 2: Delegation
One skill invokes another via context: fork.
The delegated skill runs in isolation and returns results.

Structure:
- Orchestrator skill: runs in main context
- Worker skill: context: fork, runs in subagent
- Orchestrator reads worker's summary output

Token cost: Worker uses separate context (no budget competition).
Use when: Worker needs full context isolation (sensitive data, heavy processing).
Avoid when: Worker needs access to main conversation history.

Example: security-audit delegates to dependency-scanner

## Pattern 3: Pipeline
Skills run in sequence. Each writes output that the next reads.

Structure:
- Skill A writes to reports/step1.json
- Skill B reads reports/step1.json, writes to reports/step2.json
- Skill C reads reports/step2.json, produces final output

Token cost: Only one skill needs to be active at a time.
Use when: Steps are independent and outputs are structured.
Avoid when: Later steps need to reference earlier steps' reasoning.

## Pattern 4: Fan-Out
One orchestrator invokes multiple skills in parallel.
Claude's /batch skill uses this pattern internally.

Structure:
- Orchestrator decomposes work into N independent units
- Each unit runs as a separate context: fork subagent
- Orchestrator collects and merges results

Token cost: Each worker uses independent context.
Use when: Work is embarrassingly parallel (file-per-file review).
Avoid when: Units need to coordinate with each other.

## Pattern 5: Fallback
Primary skill attempts a task; if it fails or produces
low-confidence output, a fallback skill takes over.

Structure:
- Primary skill: fast, specific, handles 80% of cases
- Fallback skill: slower, more thorough, handles edge cases
- Gate condition: check primary output for confidence markers

Token cost: Usually only primary loads. Fallback is conditional.
Use when: You want speed for common cases, thoroughness for rare ones.
Avoid when: Every case requires the thorough approach.

## Delegation Example (context: fork)

```yaml
---
name: security-audit
description: Scan codebase for security vulnerabilities.
context: fork
agent: Explore
allowed-tools: Read Grep Glob
---

Scan all source files for:
1. Hardcoded secrets (API keys, passwords, tokens)
2. SQL injection vectors (string concatenation in queries)
3. XSS vulnerabilities (unsanitized user input in templates)

Return findings as JSON with file, line, and severity.
```

## Anti-Patterns
- Loading 5+ skills simultaneously (compaction drops oldest)
- Circular delegation (Skill A forks Skill B which forks Skill A)
- Pipeline without file interfaces (relying on conversation memory)
- Fan-out without result merging (orphaned subagent output)
```

## Common Problems and Fixes

**Pipeline breaks when intermediate file is missing.** Skill B expects `reports/step1.json` but Skill A failed silently. Add existence checks at the start of each pipeline skill: "Before proceeding, verify that reports/step1.json exists and contains valid JSON. If missing, report the error and stop."

**Layered reference skill gets dropped after compaction.** The reference skill was loaded early in the session and gets evicted when newer skills fill the budget. Set `user-invocable: false` on reference skills so their description stays in context permanently, and re-invoke the reference skill after compaction if detailed content is needed.

**Delegation returns empty result.** A `context: fork` skill with only guidelines and no explicit task instruction produces nothing. The subagent needs a clear task: "Analyze X and return Y." Guidelines alone give the subagent nothing to do.

**Fan-out workers produce inconsistent output formats.** Each worker subagent may format results differently. Define a strict output schema in the worker skill and validate each result against the schema before merging.

## Production Gotchas

The `allowed-tools: Skill(name *)` field grants permission to invoke another skill but does not guarantee that skill exists. If the referenced skill is deleted or renamed, the invocation silently fails. Add a sanity check: "Verify /skill-name is available before attempting invocation."

Composition patterns compound token usage. A pipeline of 4 skills where each uses 4,000 tokens means 16,000 tokens total -- but only 5,000 tokens of each survive compaction. Design pipeline skills to front-load their most critical instructions in the first 5,000 tokens.

## Checklist

- [ ] Each multi-skill workflow documented as a named pattern
- [ ] Pipeline skills define file-based input/output interfaces
- [ ] Delegation targets have explicit task instructions (not just guidelines)
- [ ] No skill references another skill that does not exist
- [ ] Total active skill token usage tracked against 25,000-token budget



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [How to Combine Multiple Claude Skills](/how-to-combine-multiple-claude-skills/) -- practical workflow examples
- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/) -- managing shared resources
- [Claude Skills Data Flow Patterns](/claude-skills-data-flow-patterns/) -- data movement between skills
