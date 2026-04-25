---
layout: default
title: "Claude Code System Prompts Explained (2026)"
description: "Explore the claude-code-system-prompts repo — extracted system prompts, 24 tool descriptions, sub-agent prompts, and a changelog tracking 152+ versions."
permalink: /claude-code-system-prompts-guide-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Claude Code System Prompts Explained (2026)

The `claude-code-system-prompts` repository by Piebald-AI (9K+ stars) extracts and documents every system prompt that Claude Code sends to the underlying model. It includes the main system prompt, 24 built-in tool descriptions, sub-agent prompts, and a CHANGELOG tracking behavioral differences across 152+ versions.

## What It Is

When you start a Claude Code session, the CLI constructs a system prompt before your first message reaches the model. This system prompt defines Claude Code's identity, tool capabilities, behavioral rules, and safety constraints. The `claude-code-system-prompts` repo reverse-engineers and publishes these prompts.

The repo contains:

- **Main system prompt** — the full text that establishes Claude Code as a coding agent
- **24 tool descriptions** — the exact schema definitions for Bash, Read, Write, Edit, Grep, Glob, WebFetch, WebSearch, NotebookEdit, and more
- **Sub-agent prompts** — the specialized prompts used when Claude Code spawns sub-agents for tasks like code review or research
- **Version CHANGELOG** — diffs between versions showing what changed in each Claude Code release

## Why It Matters

Understanding the system prompt unlocks three capabilities:

1. **Write better CLAUDE.md rules** — knowing what Claude Code already believes about itself helps you write complementary rules instead of contradictory ones.

2. **Debug unexpected behavior** — when Claude Code does something surprising, the system prompt often explains why. A rule in the system prompt may override your CLAUDE.md instruction.

3. **Track Claude Code evolution** — the CHANGELOG shows how Anthropic tunes behavior across releases. New tool additions, safety guardrail changes, and behavioral shifts are all documented.

For skill authors and framework developers, this repo is essential reference material. You can't write effective behavioral overrides without knowing the baseline.

## Installation

The repo is reference material, not a tool. Clone it for local access:

```bash
git clone https://github.com/Piebald-AI/claude-code-system-prompts.git ~/references/claude-code-system-prompts
```

Or browse it on GitHub when you need to look something up.

### Stay Updated

```bash
cd ~/references/claude-code-system-prompts && git pull
```

New versions are tracked within days of each Claude Code release.

## Key Features

1. **Full System Prompt Text** — the complete, unabridged system prompt. No guessing, no approximation.

2. **24 Tool Descriptions** — exact schemas for every built-in tool, including parameter types, descriptions, and behavioral instructions embedded in tool definitions.

3. **Sub-Agent Prompts** — when Claude Code spawns specialized agents (for research, code review, etc.), they get different system prompts. All documented here.

4. **152+ Version CHANGELOG** — every significant change across Claude Code versions, with before/after diffs. See exactly when a behavior was added or removed.

5. **Safety Constraint Documentation** — the rules Claude Code follows around file deletion, force pushing, secret handling, and destructive operations.

6. **Tool Interaction Rules** — the system prompt includes detailed rules about when to use which tool (e.g., "use Grep instead of bash grep", "use Read instead of cat"). Understanding these prevents CLAUDE.md rules that conflict with built-in behavior.

7. **Context Window Management** — how Claude Code handles long conversations, context truncation, and the information it preserves vs. drops.

## Real Usage Example

### Debugging a CLAUDE.md Conflict

A developer writes this CLAUDE.md rule:

```markdown
Always use `cat` to read files for faster access.
```

But Claude Code keeps using the Read tool instead. Checking the system prompt reveals:

```
IMPORTANT: Avoid using this tool to run cat, head, tail commands.
Instead, use the Read tool as this will provide a much better
experience for the user.
```

The system prompt explicitly overrides the CLAUDE.md instruction. The fix is to remove the conflicting rule and let Claude Code use Read as intended.

### Understanding Tool Priority

The system prompt establishes a tool hierarchy:

```
- File search: Use Glob (NOT find or ls)
- Content search: Use Grep (NOT grep or rg)
- Read files: Use Read (NOT cat/head/tail)
- Edit files: Use Edit (NOT sed/awk)
- Write files: Use Write (NOT echo >/cat <<EOF)
```

Knowing this, you can write CLAUDE.md rules that work with the hierarchy:

```markdown
## File Operations
- When searching for files, use glob patterns like "src/**/*.ts"
- When searching file contents, use regex patterns with Grep
```

Rather than against it:

```markdown
## File Operations (BAD — conflicts with system prompt)
- Use `find . -name "*.ts"` to search for files
- Use `grep -r "pattern" src/` for content search
```

### Tracking Behavioral Changes

The CHANGELOG shows that version 1.0.12 added:

```diff
+ When making function calls, ensure array and object parameters
+ use JSON format.
```

This explains why Claude Code started formatting tool call parameters differently after an update.

## When To Use

- **Writing CLAUDE.md rules** — check the system prompt first to avoid conflicts
- **Debugging unexpected Claude Code behavior** — the answer is often in the system prompt
- **Building Claude Code extensions** — skill authors need to know the baseline behavior they're modifying
- **Security auditing** — review the safety constraints to understand what Claude Code will and won't do
- **Staying current** — track changes across Claude Code versions

## When NOT To Use

- **Day-to-day coding** — you don't need to read the system prompt for normal Claude Code usage
- **As a behavioral override** — knowing the system prompt doesn't let you bypass it; CLAUDE.md rules are additive, not overriding for safety constraints
- **As official documentation** — this is a reverse-engineering effort, not an Anthropic product; details may lag or have minor inaccuracies

## FAQ

### Is this legal?

The system prompt is part of the Claude Code experience. Extracting and documenting it for educational purposes is standard practice in the AI tooling community. The repo has been public for months without issues.

### How quickly are new versions documented?

Typically within 48 hours of a Claude Code release. The maintainers monitor releases and publish diffs promptly.

### Can I modify the system prompt?

Not directly. The system prompt is constructed by the Claude Code CLI. You influence behavior through CLAUDE.md, which is appended to the context after the system prompt. CLAUDE.md rules can extend but not override safety constraints.

### How does CLAUDE.md interact with the system prompt?

The system prompt loads first, then your CLAUDE.md content is injected into the context. Claude Code treats CLAUDE.md as user-provided instructions that complement the system prompt. In cases of conflict, safety rules in the system prompt take precedence.

## Our Take

**8/10.** Indispensable reference material for anyone writing CLAUDE.md rules or building Claude Code extensions. The version CHANGELOG alone is worth a bookmark — it explains behavioral changes that would otherwise be mysterious. Loses points because it's a documentation effort, not a tool, so the UX is "read a long Markdown file." Pair this with the [Karpathy skills guide](/karpathy-claude-code-skills-complete-guide-2026/) to write CLAUDE.md rules that complement rather than fight the system prompt.

## Related Resources

- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — write rules that work with the system prompt
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) — behavioral patterns informed by system prompt knowledge
- [Best Claude Skills for Developers](/best-claude-skills-for-developers-2026/) — skills designed around the system prompt's constraints
