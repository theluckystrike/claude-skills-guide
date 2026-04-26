---
layout: default
title: "How to Use Claude Md Conflicting (2026)"
description: "Learn how to resolve conflicting instructions when working with Claude Code and Claude desktop skills. Practical patterns for developers and power users."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, instruction-resolution, conflict-resolution, ai-agents]
author: "theluckystrike"
reviewed: true
score: 8
permalink: /claude-md-conflicting-instructions-resolution-guide/
geo_optimized: true
---
# Claude MD Conflicting Instructions Resolution Guide

When working with Claude Code or Claude desktop skills, you will inevitably encounter situations where multiple instructions conflict. This happens when different skills, system prompts, or user requests send mixed signals about what action to take. Understanding how to resolve these conflicts is essential for building reliable AI-assisted workflows.

This guide provides practical patterns for developers and power users dealing with conflicting instructions in Claude MD environments. For a deeper look at the skill format itself, see the [Claude skill .md format complete specification guide](/claude-skill-md-format-complete-specification-guide/).

## Understanding Instruction Conflicts

An instruction conflict occurs when two or more directives cannot all be satisfied simultaneously. In Claude's architecture, conflicts can arise at several levels:

- Skill-to-skill conflicts: Two loaded skills provide contradictory guidance
- User vs. system conflicts: Your explicit request contradicts the skill's defined behavior
- Priority conflicts: Multiple valid approaches exist, and Claude must choose one
- Scope conflicts: One skill defines behavior globally while another defines it narrowly for a specific context

For example, a `pdf` skill might instruct Claude to extract all table data, while a `tdd` skill simultaneously directs the model to validate every extracted value against a schema. When both skills are active, Claude needs a clear resolution mechanism.

Consider a more subtle conflict: a documentation skill tells Claude to always include code comments, while a brevity-focused skill says to keep outputs minimal. Neither instruction is wrong in isolation, but together they produce inconsistent output depending on which one Claude weights more heavily at any given moment. These quiet conflicts are often more damaging than obvious ones because they are harder to detect and reproduce.

## Why Conflicts Are More Common Than You Expect

Most developers start with a single skill and add more as their workflows grow. Each new skill is written in isolation, which means it carries implicit assumptions about what other skills are or are not doing. The `frontend-design` skill assumes it has full latitude over component structure. The `tdd` skill assumes it controls how functions are shaped to be testable. When both load together, they tug at the same decisions from different angles.

System prompts in `CLAUDE.md` add another layer. A project-level `CLAUDE.md` might declare naming conventions that conflict with a skill's preferred naming patterns. A user-level `CLAUDE.md` might set a tone or verbosity level that conflicts with a task-specific skill's output requirements. Claude resolves these by falling back to general judgment, which is unpredictable across sessions.

The cost of leaving conflicts unresolved is not just wrong output on a single run. It is variance. the same prompt producing different results in different sessions, making your workflows unreliable and harder to debug.

## Resolution Strategies

1. Explicit Priority Declaration

The most reliable approach is declaring instruction priority directly in your skill definition. [How to write a skill .md file for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/) covers the front matter fields available for precedence control. Front matter allows you to specify precedence:

```yaml
---
name: pdf-extraction
instructions: |
 Extract table data from PDF files.
 When conflicting with tdd skill, this takes precedence for extraction phase.
---
```

Higher priority values override lower ones. Reserve priority 1-3 for core system behaviors, 4-7 for framework skills like `frontend-design`, and 8-10 for domain-specific skills.

When writing priority declarations, be as specific as possible about the domain where the priority applies. A broad declaration like "this skill takes precedence over all others" is less useful than "this skill takes precedence over formatting decisions during extraction tasks." Narrow scope means Claude can satisfy both skills across their respective domains rather than suppressing one entirely.

2. Phase-Based Resolution

Break complex workflows into sequential phases where different skills dominate at each stage. The `tdd` skill works well in a validation phase after extraction:

```yaml
Phase 1: Extraction (pdf skill active)
Phase 2: Validation (tdd skill active)
Phase 3: Output (supermemory skill records results)
```

This pattern prevents conflicts by ensuring only one skill provides active guidance at any moment.

Phase-based resolution is the most practical approach for multi-step pipelines. The mental model is straightforward: at each stage of a workflow, one skill is the authority. Other skills either wait their turn or apply only to their designated phase. You communicate the phase transition explicitly in your prompts:

```
Phase 1 - Extract all table data from the attached PDF. Apply pdf skill guidance.
Phase 2 - Validate the extracted data against the provided JSON schema. Apply tdd skill guidance.
Phase 3 - Record the validated results to the memory store. Apply supermemory guidance.
```

Explicit phase prompts eliminate ambiguity without requiring changes to skill definitions. This matters when you are using skills you did not write and cannot easily modify.

3. Contextual Fallback Chains

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

Fallback chains work best when the conflict is conditional. when the right skill to apply depends on the input rather than the task phase. For file processing workflows, matching on `file_type` is natural. For code generation workflows, you might match on whether the target directory already contains tests, or whether the task includes the word "validate" or "test."

A practical trick is to define a catch-all fallback at the end of your chain:

```yaml
resolution_order:
 - skill: domain-specific
 when: "task_domain == 'specific'"
 - skill: general-purpose
 when: "default == true"
```

The catch-all ensures Claude always has a clear instruction source even when none of the specific conditions match.

4. Conflict Detection Hooks

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

This approach requires integration with a Claude Code workflow that passes skill context programmatically. It is most appropriate when you are building a tool or platform on top of Claude Code rather than using it directly as an individual developer.

A complete hook implementation would also log the resolution decision, making it debuggable:

```javascript
// conflict-resolver.js
export function resolveConflict(context) {
 const activeSkills = context.activeSkills;
 const conflicting = findOverlappingDirectives(activeSkills);

 if (conflicting.length > 1) {
 const winner = selectHighestPriority(conflicting);
 console.log(`[conflict-resolver] Resolved: ${conflicting.map(s => s.name).join(' vs ')} → ${winner.name}`);
 return {
 resolved: true,
 skill: winner,
 reason: "priority-based resolution",
 losers: conflicting.filter(s => s !== winner),
 };
 }

 return { resolved: false };
}

function findOverlappingDirectives(skills) {
 const directiveMap = {};
 const overlapping = [];

 for (const skill of skills) {
 for (const directive of skill.directives) {
 if (directiveMap[directive.key]) {
 overlapping.push(directiveMap[directive.key], skill);
 }
 directiveMap[directive.key] = skill;
 }
 }

 return [...new Set(overlapping)];
}
```

The logging output becomes invaluable during debugging when you cannot tell why Claude followed one skill's guidance instead of another's.

## Practical Examples

## Example 1: PDF Extraction with Schema Validation

You want to extract data from a PDF while ensuring type consistency:

```yaml
---
name: pdf-with-validation
conflict_mode: sequential
skills:
 - pdf # Phase 1: extraction
 - tdd # Phase 2: validation
---
```

By setting `conflict_mode: sequential`, you tell Claude to apply each skill in order rather than trying to satisfy all simultaneously.

A complete prompt for this workflow would pair the skill configuration with an explicit instruction:

```
Using the pdf-with-validation skill configuration:
1. Extract all tables from the attached PDF as structured JSON
2. Validate each table's rows against this schema: { id: number, name: string, value: number }
3. Report any rows that fail validation separately from those that pass
```

The numbered steps reinforce the sequential structure defined in the skill configuration.

## Example 2: Frontend Design with Testing

When `frontend-design` and `tdd` both load, they may conflict on code structure preferences:

```yaml
---
name: frontend-with-tests
override:
 - skill: tdd
 conditions:
 - "test_files_present == true"
---
```

This declares that when test files exist, the `tdd` skill guidance overrides `frontend-design` preferences for code organization.

In practice, this resolves the most common friction between these two skills. The `frontend-design` skill might prefer colocation of styles and markup in a single component file, while `tdd` wants functions extracted so they can be unit tested independently. Giving `tdd` precedence when test files exist means Claude will structure new components with testing in mind. smaller functions, explicit prop interfaces, and separated logic. rather than optimizing purely for visual organization.

## Example 3: Memory and Documentation Conflicts

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

This pattern is particularly relevant for long-running workflows where indiscriminate logging creates noise that buries important decisions. By declaring what to record and what to ignore, you maintain a useful audit trail without filling memory with every file read and tool call.

## Example 4: Tone Conflicts Between Project and User Instructions

A `CLAUDE.md` at the user level might set Claude's communication style to "concise, no explanations," while a project-level `CLAUDE.md` requires verbose, documented output for audit purposes. Both are legitimate preferences in their respective contexts.

Resolve this by scoping the project instruction explicitly:

```markdown
<!-- project CLAUDE.md -->
For all code generation tasks in this project, produce verbose output with inline comments
explaining each decision. This overrides any user-level brevity settings for code output.
For conversational replies and status updates, follow user-level tone settings.
```

The key is separating code output (where verbosity has audit value) from conversational output (where brevity improves usability). Most tone conflicts can be resolved this way. by narrowing the scope of each instruction so they no longer overlap.

## Best Practices

Define a clear hierarchy before starting complex projects. Document which skills take precedence and under what conditions. A simple table in your project `CLAUDE.md` works well:

```markdown
Skill Priority (for this project)
| Skill | Priority | Overrides | Defers To |
|-------|----------|-----------|-----------|
| tdd | 9 | frontend-design (code structure) |. |
| frontend-design | 7 |. | tdd |
| supermemory | 5 |. | tdd, frontend-design |
```

Use sequential phases for tasks requiring multiple skill domains. Switching skills on/off based on workflow phase prevents ambiguous states.

Prefer explicit over implicit resolution. When conflicts arise, add front matter declarations rather than relying on Claude's default resolution. Implicit resolution produces different results across model versions and sessions.

Test conflict scenarios during skill development. Load multiple skills together and verify the resolution matches your expectations. The [Claude MD changes not taking effect fix guide](/claude-md-changes-not-taking-effect-fix-guide/) can help when resolution rules are not applying as expected.

Keep skill instruction scope narrow. Skills that define behavior for a broad surface area are more likely to conflict with everything. Skills that define behavior only within their specific domain compose cleanly.

Document resolution decisions. When you add a priority declaration or override to resolve a conflict, add a comment explaining why. Six months later, neither you nor another developer will remember what prompted the resolution, and removing it may reintroduce the original problem.

## Common Pitfalls

Avoid leaving conflicts unresolved. Unaddressed conflicts lead to unpredictable behavior where Claude may:

- Follow the last-loaded skill arbitrarily
- Attempt partial satisfaction of all directives
- Ask for clarification on every conflicting instruction

These outcomes reduce workflow reliability and increase cognitive load on users.

Overly broad priority declarations are a common overcorrection. Making one skill take absolute precedence over all others usually suppresses useful guidance from other skills entirely. Prefer narrow, scoped priority declarations.

Circular dependencies can emerge in fallback chains if you are not careful. If skill A defers to skill B, and skill B defers to skill A under overlapping conditions, Claude has no clear resolution path. Always ensure your fallback chains are acyclic.

Forgetting about `CLAUDE.md` as a conflict source. Developers focus on skill-to-skill conflicts but often overlook that project or user `CLAUDE.md` files can conflict with skill instructions just as easily. Audit your `CLAUDE.md` files when adding new skills to look for overlapping directives.

## Conclusion

Resolving conflicting instructions in Claude MD requires explicit strategy rather than hoping for implicit correctness. By declaring priority, using phase-based execution, implementing fallback chains, and using conflict detection hooks, you build reliable systems that handle ambiguity gracefully.

Whether you're combining `pdf` extraction with `tdd` validation, integrating `frontend-design` with testing frameworks, or orchestrating multiple skills through `supermemory` memory management, explicit conflict resolution transforms potential chaos into reliable automation. The investment in defining clear resolution rules pays dividends every time a workflow runs consistently instead of producing unpredictable output.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-conflicting-instructions-resolution-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skill .md Format: Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/). Reference the full front matter schema including priority and conflict-related fields
- [How to Write a Skill .md File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/). Build skills from scratch with clear instruction boundaries that reduce conflict likelihood
- [Claude MD Changes Not Taking Effect: Fix Guide](/claude-md-changes-not-taking-effect-fix-guide/). Troubleshoot why conflict resolution rules may not be applying as expected
- [Claude Skills Advanced Hub](/advanced-hub/). Explore advanced skill orchestration patterns beyond basic conflict resolution

Built by theluckystrike. More at [zovo.one](https://zovo.one)


