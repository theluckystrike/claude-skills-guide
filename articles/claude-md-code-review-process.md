---
layout: default
title: "CLAUDE.md Code Review Process (2026)"
description: "How to use CLAUDE.md as a code review checklist, automate rule verification, and build a review workflow for Claude Code output."
permalink: /claude-md-code-review-process/
date: 2026-04-20
categories: [claude-md, workflow]
tags: [claude-md, code-review, workflow, automation, quality]
last_updated: 2026-04-19
---

## CLAUDE.md as a Review Checklist

When Claude Code generates or modifies code, your CLAUDE.md is the reference against which you review that output. Every rule in your CLAUDE.md is a line item on your review checklist. If your CLAUDE.md says "no default exports" and Claude generates a default export, that is a review finding -- the same way a human-written PR that violates team standards is a finding.

This reframes CLAUDE.md from "instructions for Claude" to "automated review criteria for AI-generated code."

## Building Review Rules into CLAUDE.md

Structure your rules as verifiable assertions. Each rule should be something you can check with a yes/no answer:

```markdown
## Review Criteria (every Claude output must pass these)

### Structure
- [ ] Functions under 40 lines
- [ ] One responsibility per function
- [ ] Named exports only (no default exports)
- [ ] Imports sorted: builtins → external → internal → relative

### Types
- [ ] No any type
- [ ] Explicit return types on public functions
- [ ] Readonly for non-mutated collections

### Error Handling
- [ ] Errors use AppError hierarchy
- [ ] No empty catch blocks
- [ ] Error messages include context (what failed, why, what to do)

### Tests
- [ ] Happy path test for every public function
- [ ] Error path test for every function that can fail
- [ ] No toBeDefined() as sole assertion
```

When reviewing Claude's output, walk through this list. If any item fails, the code needs changes before merge.

## Using the /simplify Skill for Review

Claude Code includes a built-in `/simplify` skill that reviews recently changed files. It spawns three review agents in parallel that check for code reuse opportunities, quality issues, and efficiency improvements:

```
# In Claude Code
/simplify

# Claude reviews your recent changes and suggests:
# - Extracted helpers for duplicated logic
# - Simplified conditionals
# - Performance improvements
```

This is an automated first pass. Your CLAUDE.md rules provide the project-specific standards that `/simplify` does not cover.

## Reviewing CLAUDE.md Changes Themselves

Changes to CLAUDE.md need their own review process because they affect all future code generation. Set up CODEOWNERS to require approval:

```
# .github/CODEOWNERS
CLAUDE.md                    @team-lead
.claude/rules/*.md           @team-lead
.claude/skills/              @team-lead
```

When reviewing a CLAUDE.md change, check:

1. **Does the new rule contradict an existing rule?** Search all instruction files for conflicting guidance.
2. **Is the rule specific enough to verify?** Vague rules ("write clean code") are worse than no rules.
3. **Does it affect existing code?** Will Claude start rewriting working code to match the new rule?
4. **Is the file still under 200 lines?** Adding rules without removing outdated ones bloats the file.

## Automating Rule Checks in CI

Some CLAUDE.md rules can be enforced automatically in CI, complementing Claude's instruction-following:

```yaml
# .github/workflows/claude-md-rules.yml
name: CLAUDE.md Rule Enforcement
on: [pull_request]
jobs:
  check-rules:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check no default exports
        run: |
          if grep -r "export default" src/ --include="*.ts" --include="*.tsx"; then
            echo "FAIL: Default exports found. CLAUDE.md rule: named exports only."
            exit 1
          fi

      - name: Check function length
        run: |
          # Custom script that parses AST and checks function body length
          node scripts/check-function-length.js --max-lines 40

      - name: Check no any type
        run: |
          if grep -rn ": any" src/ --include="*.ts" --include="*.tsx" | grep -v "// any-ok"; then
            echo "FAIL: 'any' type found. CLAUDE.md rule: use unknown + type guards."
            exit 1
          fi
```

This catches violations that Claude might miss, especially in files Claude did not generate or modify.

## Review Workflow Summary

```
1. Claude generates code based on CLAUDE.md rules
2. Developer reviews output against CLAUDE.md checklist
3. /simplify runs automated quality checks
4. CI enforces automatable rules (no any, no default exports)
5. Human reviewer focuses on architectural and design decisions
6. Merge when all checks pass
```

The key insight: CLAUDE.md rules serve double duty. They guide Claude during generation and serve as review criteria afterward. This eliminates the gap between "what we told Claude to do" and "what we check in review."

## Tracking Review Findings

Keep a record of which CLAUDE.md rules are most frequently violated. This data tells you which rules need to be more specific or moved higher in the file:

```markdown
# Review log (team shared document)
| Date | File | Rule Violated | Fix Applied |
|------|------|---------------|-------------|
| 04-15 | user-service.ts | No any type | Changed to unknown |
| 04-15 | auth-controller.ts | Error envelope | Added response wrapper |
| 04-16 | order-repo.ts | Repository pattern | Moved query to repository |
```

If the same rule is violated repeatedly, the rule is either too vague, too far down in the CLAUDE.md, or contradicted by another instruction. Use the data to improve your CLAUDE.md rather than just fixing individual violations.

## Review Cadence for CLAUDE.md Itself

Schedule a monthly CLAUDE.md review with the team. During this review:

1. Check total line count (must stay under 200)
2. Remove rules that are no longer relevant
3. Sharpen rules that Claude frequently ignores
4. Add rules for new patterns the team has adopted
5. Verify no contradictions exist across all instruction files

This review takes 15 minutes and prevents gradual CLAUDE.md degradation. The instruction file is only as good as its last audit.

For structuring your CLAUDE.md rules for maximum verifiability, see the [coding standards enforcement guide](/claude-md-for-coding-standards-enforcement/). For handling team conflicts in CLAUDE.md changes, see the [conflict resolution guide](/claude-md-conflict-resolution/). For the complete CLAUDE.md file format, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
