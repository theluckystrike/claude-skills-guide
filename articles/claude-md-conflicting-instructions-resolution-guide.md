---
layout: default
title: "Claude MD Conflicting Instructions Resolution Guide"
description: "Learn how to resolve conflicting instructions when working with Claude Code and Claude desktop skills. Practical patterns for developers and power users."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, instruction-resolution, conflict-resolution, ai-agents]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-md-conflicting-instructions-resolution-guide/
---

# Claude MD Conflicting Instructions Resolution Guide

When working with Claude Code or Claude desktop skills, you will inevitably encounter situations where multiple instructions conflict. This happens when different skills, system prompts, or user requests send mixed signals about what action to take. Understanding how to resolve these conflicts is essential for building reliable AI-assisted workflows.

This guide provides practical patterns for developers and power users dealing with conflicting instructions in Claude MD environments. For a deeper look at the skill format itself, see the [Claude skill .md format complete specification guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/).

## Understanding Instruction Conflicts

An instruction conflict occurs when two or more directives cannot all be satisfied simultaneously. In Claude's architecture, conflicts can arise at several levels:

- **Skill-to-skill conflicts**: Two loaded skills provide contradictory guidance
- **User vs. system conflicts**: Your explicit request contradicts the skill's defined behavior
- **Priority conflicts**: Multiple valid approaches exist, and Claude must choose one

For example, a `pdf` skill might instruct Claude to extract all table data, while a `tdd` skill simultaneously directs the model to validate every extracted value against a schema. When both skills are active, Claude needs a clear resolution mechanism.

## Resolution Strategies

### 1. Explicit Priority Declaration

The most reliable approach is declaring instruction priority directly in your skill definition. [How to write a skill .md file for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) covers the front matter fields available for precedence control. Front matter allows you to specify precedence:

```yaml
---
name: pdf-extraction
priority: 10
tools: [read_file, write_file]
instructions: |
  Extract table data from PDF files.
  When conflicting with tdd skill, this takes precedence for extraction phase.
---
```

Higher priority values override lower ones. Reserve priority 1-3 for core system behaviors, 4-7 for framework skills like `frontend-design`, and 8-10 for domain-specific skills.

### 2. Phase-Based Resolution

Break complex workflows into sequential phases where different skills dominate at each stage. The `tdd` skill works well in a validation phase after extraction:

```yaml
# Phase 1: Extraction (pdf skill active)
# Phase 2: Validation (tdd skill active)
# Phase 3: Output (supermemory skill records results)
```

This pattern prevents conflicts by ensuring only one skill provides active guidance at any moment.

### 3. Contextual Fallback Chains

Define explicit fallback behavior when conflicts occur. Create a resolution chain:

```yaml
resolution_order:
  - skill: pdf
    when: "file_type == 'pdf'"
  - skill: docx
    when: "file_type == 'docx'"
  - skill: tdd
    when: "validation_required == true"
```

Claude evaluates each condition in order and follows the first matching skill's instructions.

### 4. Conflict Detection Hooks

For advanced implementations, use hooks to detect and handle conflicts programmatically:

```javascript
// conflict-resolver.js
export function resolveConflict(context) {
  const activeSkills = context.activeSkills;
  const conflicting = findOverlappingDirectives(activeSkills);
  
  if (conflicting.length > 1) {
    return {
      resolved: true,
      skill: selectHighestPriority(conflicting),
      reason: "priority-based resolution"
    };
  }
  
  return { resolved: false };
}
```

## Practical Examples

### Example 1: PDF Extraction with Schema Validation

You want to extract data from a PDF while ensuring type consistency:

```yaml
---
name: pdf-with-validation
conflict_mode: sequential
skills:
  - pdf    # Phase 1: extraction
  - tdd    # Phase 2: validation
---
```

By setting `conflict_mode: sequential`, you tell Claude to apply each skill in order rather than trying to satisfy all simultaneously.

### Example 2: Frontend Design with Testing

When `frontend-design` and `tdd` both load, they may conflict on code structure preferences:

```yaml
---
name: frontend-with-tests
priority: 8
override:
  - skill: tdd
    conditions:
      - "test_files_present == true"
---
```

This declares that when test files exist, the `tdd` skill guidance overrides `frontend-design` preferences for code organization.

### Example 3: Memory and Documentation Conflicts

The `supermemory` skill might want to record every action, while you want selective logging:

```yaml
---
name: minimal-logging
supermemory:
  mode: selective
  record_only:
    - user_decisions
    - file_modifications
  ignore:
    - read_operations
    - failed_attempts
---
```

## Best Practices

**Define clear优先级 hierarchy** before starting complex projects. Document which skills take precedence and under what conditions.

**Use sequential phases** for tasks requiring multiple skill domains. Switching skills on/off based on workflow phase prevents ambiguous states.

**Prefer explicit over implicit resolution**. When conflicts arise, add front matter declarations rather than relying on Claude's default resolution.

**Test conflict scenarios** during skill development. Load multiple skills together and verify the resolution matches your expectations. The [Claude MD changes not taking effect fix guide](/claude-skills-guide/claude-md-changes-not-taking-effect-fix-guide/) can help when resolution rules are not applying as expected.

## Common Pitfalls

Avoid leaving conflicts unresolved. Unaddressed conflicts lead to unpredictable behavior where Claude may:

- Follow the last-loaded skill arbitrarily
- Attempt partial satisfaction of all directives
- Ask for clarification on every conflicting instruction

These outcomes reduce workflow reliability and increase cognitive load on users.

## Conclusion

Resolving conflicting instructions in Claude MD requires explicit strategy rather than hoping for implicit correctness. By declaring priority, using phase-based execution, implementing fallback chains, and using conflict detection hooks, you build reliable systems that handle ambiguity gracefully.

Whether you're combining `pdf` extraction with `tdd` validation, integrating `frontend-design` with testing frameworks, or orchestrating multiple skills through `supermemory` memory management, explicit conflict resolution transforms potential chaos into reliable automation.

## Related Reading

- [Claude Skill .md Format: Complete Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) — Reference the full front matter schema including priority and conflict-related fields
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) — Build skills from scratch with clear instruction boundaries that reduce conflict likelihood
- [Claude MD Changes Not Taking Effect: Fix Guide](/claude-skills-guide/claude-md-changes-not-taking-effect-fix-guide/) — Troubleshoot why conflict resolution rules may not be applying as expected
- [Claude Skills Advanced Hub](/claude-skills-guide/advanced-hub/) — Explore advanced skill orchestration patterns beyond basic conflict resolution

Built by theluckystrike — More at [zovo.one](https://zovo.one)
