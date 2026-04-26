---
layout: default
title: "Claude Skills vs Subagents: Comparison Guide (2026)"
description: "Compare inline Claude Code skills with context-forked subagents. When to keep instructions in the main context vs delegate to isolated agents."
permalink: /claude-skills-vs-subagents-comparison/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, subagents, comparison]
last_updated: 2026-04-19
---

## The Specific Situation

You are deciding between two architectures for a code analysis workflow. Option A: an inline skill that loads analysis instructions into the main conversation, reads files, and reports findings directly. Option B: a subagent skill that uses `context: fork` to run the analysis in isolation and returns a summary. Both analyze code. But they differ in context cost, conversation pollution, and result persistence.

## Technical Foundation

**Inline skills** load their SKILL.md content into the main conversation as a message. The content stays in context for the session and survives compaction (up to 5,000 tokens per skill, 25,000 total budget). The skill shares context with the full conversation history, which means it can reference earlier messages but also means its output adds to the conversation's token count.

**Subagents** (via `context: fork`) create an isolated context window. The subagent receives the skill content as its prompt, loads the project's CLAUDE.md, and has access to tools specified by the `agent` type and `allowed-tools` field. Results are summarized and returned to the main conversation. The subagent's full context is discarded after it finishes. Agent types include Explore (read-only), Plan (read + plan), general-purpose (full access), and custom agents defined in `.claude/agents/`.

These are not competing alternatives -- they are different execution environments within the same skills system. A SKILL.md becomes a subagent skill simply by adding `context: fork` to its frontmatter.

## The Working SKILL.md

Inline version:

```yaml
---
name: quick-lint
description: >
  Quick code lint check on the current file. Reports style
  violations and simple bug patterns. Use for fast feedback
  during development.
allowed-tools: Read Grep
---

# Quick Lint

Read $ARGUMENTS[0] and check for:
1. Unused imports (imported but not referenced in file body)
2. Console.log statements (should use logger instead)
3. TODO comments without ticket numbers
4. Functions exceeding 50 lines
5. Magic numbers (numeric literals not assigned to constants)

Report findings inline with line numbers.
```

Subagent version:

```yaml
---
name: deep-analysis
description: >
  Deep codebase analysis across all source files. Reads
  the entire codebase, identifies patterns, and generates
  a structured report. Use for periodic health checks.
context: fork
agent: Explore
allowed-tools: Read Grep Glob
---

# Deep Codebase Analysis

## Task
Analyze the entire codebase for:

1. **Dead code**: Functions/exports not imported anywhere
2. **Circular dependencies**: A imports B imports A patterns
3. **Inconsistent patterns**: Mixed async/callback styles, inconsistent error handling
4. **Security concerns**: Hardcoded secrets, SQL injection, XSS vectors
5. **Complexity hotspots**: Files with cyclomatic complexity > 15

## Process
1. Use Glob to find all source files (`**/*.{ts,py,go}`)
2. Read each file and analyze against the criteria above
3. Track findings with file path, line number, and severity

## Output
Return a structured summary:
- Total files analyzed
- Findings grouped by category
- Top 5 highest-priority issues with specific file:line references
- Overall health score (A/B/C/D/F based on finding density)
```

## Where Subagents Win

**1. Large-scale file scanning.** Reading 100+ files fills the main context quickly. A subagent has its own context window and returns only a summary. The main conversation stays clean and focused.

**2. Sensitive data isolation.** Processing contracts, medical records, or credentials in a forked context means the data does not persist in the main conversation. After the subagent finishes, its full context is discarded.

**3. Parallel execution.** Multiple subagents can run simultaneously (fan-out pattern). The built-in `/batch` skill uses this pattern to process work in parallel across git worktrees.

## Where Inline Skills Win

**1. Conversational interaction.** Inline skills can reference the conversation history -- the user's previous messages, earlier tool outputs, and established context. Subagents start with a clean context and cannot see what you discussed earlier.

**2. Result persistence.** Inline skill output stays in the conversation and can be referenced in future turns. Subagent output is a compressed summary -- details are lost after the summary is generated.

**3. File modification.** Inline skills with general-purpose access can edit files directly as part of the conversation flow. Subagents with `agent: Explore` are read-only. Even `agent: general-purpose` subagents modify files without the user seeing intermediate steps.

**4. Lower latency.** Inline skills are already in context. Subagents have startup overhead: spinning up a new context, loading CLAUDE.md, and processing the full skill content before beginning work.

## Hybrid Use Case

The most common pattern: an inline orchestrator skill delegates specific tasks to subagent workers.

```yaml
---
name: pr-prep
description: >
  Prepare a PR by running analysis, generating summary, and
  checking style. Delegates heavy analysis to subagents.
allowed-tools: Skill(deep-analysis *) Skill(quick-lint *)
---

# PR Preparation

1. Run /deep-analysis on changed files (subagent, returns summary)
2. Run /quick-lint on each changed file (inline, shows results)
3. Based on findings, suggest PR description
4. If deep-analysis found critical issues, recommend blocking the PR
```

## Common Problems and Fixes

**Subagent returns empty result.** The skill content has guidelines but no explicit task. Add a clear "## Task" section with specific deliverables: "Analyze X, find Y, return Z in this format."

**Inline skill causes compaction mid-analysis.** A large inline skill combined with a long conversation triggers compaction, which may trim skill content. Either reduce the skill size (move details to references/) or switch to `context: fork` for the analysis.

**Subagent modifies wrong files.** A `general-purpose` subagent has full write access but no conversation context about which files the user intended. Constrain write access with `agent: Explore` for read-only analysis, or pass explicit file paths via `$ARGUMENTS`.

## Production Gotchas

Subagents load CLAUDE.md from the project root but do not load other invoked skills from the main session. If the main session had 3 skills loaded and one of them is needed by the subagent, it will not be available unless explicitly referenced via the `skills` field in a custom agent definition (`.claude/agents/my-agent.md`).

The summary returned from a subagent is generated by the subagent itself. If the subagent's analysis is poor, the summary is poor. There is no separate quality gate on the summary. For critical workflows, have the main context validate the subagent's summary against expectations.

## Checklist

- [ ] Single-file, quick checks → inline skill
- [ ] Multi-file, heavy scanning → subagent with `context: fork`
- [ ] Sensitive data processing → subagent (context discarded after)
- [ ] Interactive, multi-turn workflow → inline skill
- [ ] Subagent skills have explicit task instructions, not just guidelines



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Skills vs Subagents: When to Use Each](/claude-skills-vs-subagents-when-to-use/) -- decision framework
- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- delegation and fan-out patterns
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/) -- context budget management
