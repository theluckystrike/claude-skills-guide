---
layout: default
title: "Claude Code Skill Circular Dependency"
description: "Resolve the circular dependency detected error in Claude Code skills with practical solutions, code examples, and prevention strategies. Updated for 2026."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [troubleshooting]
tags: [claude-code, claude-skills]
reviewed: true
score: 9
permalink: /claude-code-skill-circular-dependency-detected-error-fix/
geo_optimized: true
last_tested: "2026-04-22"
---

# Claude Code Skill Circular Dependency Detected Error Fix

The circular dependency detected error in Claude Code skills halts execution abruptly, leaving developers frustrated and workflows broken. [This error occurs when skills form an interdependent loop](/claude-skill-md-format-complete-specification-guide/) import loop. skill A loads skill B, which loads skill A again, creating an infinite recursion that Claude's runtime terminates. Understanding the root causes and applying the right fixes restores your workflow within minutes.

## Recognizing the Circular Dependency Error

When this error triggers, Claude Code displays a message similar to:

```
Circular dependency detected while loading skill: pdf -> tdd -> pdf
Skill loading failed: maximum call stack size exceeded
Error: Circular dependency in skill chain: frontend-design imports itself
```

The error message usually contains the names of the skills involved in the loop. This diagnostic information points directly to where you need to investigate.

The path notation in the error. for example `pdf -> tdd -> pdf`. is your most important debugging artifact. Read it left to right: `pdf` loaded `tdd`, `tdd` attempted to load `pdf` again, and the runtime detected the cycle. Longer chains are also possible:

```
Circular dependency detected: auth -> user -> permissions -> auth
```

In this three-node cycle, `auth` loads `user`, `user` loads `permissions`, and `permissions` loops back to `auth`. The fix is the same regardless of chain length. you need to remove at least one edge in the cycle.

## Why Circular Dependencies Break Skill Loading

When Claude Code initializes a skill, it walks the dependency tree before executing any code. The loader maintains a "currently loading" set. If it encounters a skill that is already in that set, it knows a cycle exists and raises the error immediately rather than entering an infinite loop.

This eager detection is intentional: a circular dependency that is not caught at load time would cause unbounded recursion at runtime, consuming all available stack space and crashing the process. The load-time check produces a clear, actionable error message instead of an obscure stack overflow.

Understanding this loading model also explains why lazy loading (covered below in Fix 2) resolves the problem: if you defer the import until the function body executes rather than the module top level, the skill is fully initialized before the second import is attempted, and the loader's "currently loading" set is empty again.

## Common Causes in Claude Code Skills

1. Direct Skill-to-Skill Imports

The most frequent cause involves one skill directly importing another skill that eventually imports the first skill back. For example, if the pdf skill references functionality from the tdd skill, and the tdd skill has any dependency chain that circles back to pdf, the circular dependency triggers.

This often happens when developers add a convenience import without checking whether the target skill already depends on theirs. A quick audit of the target skill's front matter and any `require` statements reveals the issue.

2. Shared Helper Modules

When multiple skills import a common helper module that indirectly references one of the importing skills, a circular chain forms silently. This scenario commonly occurs with skills that share utilities for file handling, logging, or API communication.

The silent nature of this cause makes it the hardest to spot. The helper module does not appear in the error message's cycle path because it is not itself a skill. but it holds the import that closes the loop. When you see a cycle involving two seemingly unrelated skills, check their shared dependencies first.

3. Metadata Header Dependencies

Some skills declare dependencies in their YAML front matter using the `dependencies` or `requires` field. If two skills list each other as dependencies, the circular dependency manifests during the skill loading phase rather than at runtime.

```yaml
skill-a.md front matter. problematic
---
name: skill-a
requires: [skill-b]
---
```

```yaml
skill-b.md front matter. problematic
---
name: skill-b
requires: [skill-a] # creates the cycle
---
```

Because the loader resolves front matter `requires` declarations before executing any code, you will see this error even if neither skill's code actually calls the other.

4. Plugin and Extension Chains

Advanced skill configurations using the supermemory skill for context management or custom plugin systems often create circular references when plugins depend on the main skill and vice versa.

5. Alias and Symlink Confusion

If your skills directory contains symlinks or alias files that point back to parent directories, the module resolver can follow a path that looks different on disk but resolves to the same skill. This produces a circular dependency that is invisible when reading the source code directly. Check for symlinks with `ls -la` in your skills directory if conventional debugging yields no results.

## Diagnosing the Full Dependency Chain

Before applying any fix, map the full dependency graph of the skills involved. Three approaches help:

Read the error path carefully. The runtime prints the full cycle, not just the two endpoints. Write it out on paper if needed:

```
auth -> user -> permissions -> auth
```

This tells you there are three skills to inspect, not two.

Search for cross-skill imports. In your skills directory, search for every place a skill name appears as an import target:

```bash
grep -r "require.*skill-a\|import.*skill-a" ./skills/
```

This surfaces all inbound edges to `skill-a`, not just the ones visible in its own file.

Check front matter `requires` fields. If you use metadata-based dependencies, list all `requires` declarations and build the graph manually:

```bash
grep -r "^requires:" ./skills/
```

Once the full graph is on paper (or a whiteboard), the cycle is usually obvious and the best place to cut it becomes clear.

## Fix Strategies

## Fix 1: Break the Import Chain

Identify the cycle using the error message. Open each skill file involved and locate the import statement creating the loop. Refactor the code to extract shared functionality into a separate, neutral module that neither skill depends on.

Example before (circular):

```javascript
// tdd-skill/index.md
const pdfUtils = require('./pdf-helper');

module.exports = {
 run: (context) => {
 return pdfUtils.generateReport(context);
 }
};
```

Example after (fixed):

```javascript
// shared/report-generator.js - neutral module
module.exports = {
 generateReport: (context) => {
 // Report generation logic here
 }
};

// tdd-skill/index.md - now imports neutral module
const reportGen = require('../shared/report-generator');

module.exports = {
 run: (context) => {
 return reportGen.generateReport(context);
 }
};
```

The key principle is that the shared module lives outside the skills directory and has no dependency on any skill. Both `pdf` and `tdd` can import it freely without creating a cycle because the shared module does not import either of them.

When extracting shared code, resist the temptation to put "just a little bit of logic" back in a skill and call it from the shared module. Any path from the shared module back to a skill recreates the cycle.

## Fix 2: Use Lazy Loading

Instead of importing modules at the top of your skill file, import them inside the function that needs them. This defers the import until execution time, avoiding the circular reference during skill loading.

```javascript
// Instead of top-level import:
const frontendDesign = require('./frontend-design');

// Use lazy import inside your function:
module.exports = {
 run: async (context) => {
 // Delay the import until we actually need it
 const { analyze } = await import('./frontend-design.mjs');
 return analyze(context);
 }
};
```

Lazy loading works because by the time the function body executes, all skills have already been registered. The "currently loading" set is empty, so the import proceeds without triggering the cycle detection.

The trade-off is a small performance cost: the first call to the function pays the import overhead that would otherwise occur at startup. For most skill use cases this is negligible. Avoid lazy loading in hot code paths that run thousands of times per session.

You can also use conditional lazy loading to import a skill only when a specific feature is needed:

```javascript
module.exports = {
 run: async (context) => {
 if (context.flags.pdfOutput) {
 const { renderPdf } = await import('./pdf-skill.mjs');
 return renderPdf(context);
 }
 return renderText(context);
 }
};
```

This pattern both resolves the circular dependency and improves startup time by deferring expensive imports until they are actually required.

## Fix 3: Remove or Refactor Metadata Dependencies

Check the front matter of each skill involved in the circular dependency. If you find mutual dependency declarations, remove them or restructure to a one-way dependency.

```yaml
---
name: my-skill
description: "Skill that previously had circular references. now reorganized to avoid overlap"
---
```

When two skills genuinely need to reference each other's capabilities, the right solution is usually to introduce a third skill that contains the shared logic and depends on neither of the two originals. Both original skills then depend on this new foundational skill, and the mutual dependency disappears.

```
Before: skill-a <-> skill-b (mutual dependency. broken)

After: skill-a -> skill-base
 skill-b -> skill-base
 (skill-base has no skill dependencies)
```

## Fix 4: Check Parent Skill Configurations

If you're using skill orchestration with the super-agent or orchestrator patterns, verify that parent skills don't inadvertently create circular chains through their child skill configurations.

Orchestrator skills that dynamically load child skills at runtime can create cycles that are invisible in any single file. The pattern to watch for is an orchestrator that loads skill A, skill A sends a message back to the orchestrator requesting skill B, and skill B is configured to load skill A on initialization. Trace the full runtime message flow, not just the static import graph, to catch these dynamic cycles.

A safe pattern for orchestration is to pass the orchestrator's API reference downward to child skills rather than having child skills import the orchestrator directly:

```javascript
// orchestrator.js
const childSkill = require('./child-skill');

childSkill.init({
 requestSkill: (name) => orchestrator.loadSkill(name) // pass reference down
});

// child-skill.js. receives orchestrator API, does NOT import it
module.exports = {
 init: ({ requestSkill }) => {
 // Store the reference; never require('./orchestrator')
 _requestSkill = requestSkill;
 },
 run: async (context) => {
 const helper = await _requestSkill('helper-skill');
 return helper.process(context);
 }
};
```

This dependency-injection approach eliminates the import cycle entirely while still giving child skills access to orchestration capabilities.

## Preventing Circular Dependencies

Adopt practices that prevent this error from recurring:

Maintain a dependency graph. Document which skills import which others. Before adding a new import, verify it doesn't create a cycle. A simple text file or diagram updated alongside code changes catches issues before they reach the runtime.

Use neutral shared modules. Extract commonly needed functionality into standalone packages that have no dependency on specific skills. Place these in a `shared/` or `lib/` directory outside the skills tree to make their neutral status obvious.

Test skill loading in isolation. Run individual skills separately after making changes to catch circular references early. If a skill cannot load on its own, it certainly will not load correctly when combined with others.

Stick to unidirectional dependencies. Design skill hierarchies that flow in one direction only, from generic to specific. High-level orchestration skills depend on low-level capability skills; capability skills never depend on orchestration skills.

Enforce a no-cross-skill-imports rule at the lower layers. Primitive skills (those handling a single, well-defined task like formatting output or reading a file) should have zero dependencies on other skills. Reserve cross-skill dependencies for higher-level composition skills that explicitly coordinate multiple primitives.

Use CI checks. Add a script to your CI pipeline that loads each skill independently and confirms no circular dependency errors appear. A five-line shell script that iterates over skills files and calls a loader is enough to catch regressions before merge.

## When the Error Persists

If you continue seeing the circular dependency error after applying these fixes, consider these additional causes:

Skill file caching: Claude Code may have cached stale skill definitions from before your fix. Restart Claude Code to clear cached definitions and force a fresh load.

Nested dependencies beyond the immediate chain: The error message shows only the cycle, not the full dependency tree. A longer chain may exist that your fix did not fully address. Re-run the grep-based dependency audit described in the diagnosis section to confirm all edges of the cycle are gone.

Symlinks and aliases: As noted above, symlinks in the skills directory can make two apparently distinct import paths resolve to the same file. Verify with `ls -la` and eliminate any symlinks that point back into the skills tree.

Incorrect file paths after refactoring: After extracting shared logic to a neutral module, double-check that no skill file still references the old path. A leftover `require('./old-location')` that coincidentally matches another skill's path will recreate the cycle.

To debug the full dependency chain, inspect the skill's front matter `tools` field and trace which skills it references against your skills directory. Building a quick visualization. even a hand-drawn graph. often reveals the cycle path faster than reading code.

## Comparison of Fix Strategies

| Strategy | Best used when | Effort | Risk of regression |
|---|---|---|---|
| Extract shared module | Shared logic genuinely exists between two skills | Medium | Low if neutral module has no skill imports |
| Lazy loading | Circular import is used infrequently | Low | Low |
| Remove metadata dependency | Cycle is declared only in front matter | Very low | None |
| Dependency injection | Orchestrator/child skill cycles | Medium | Low with clear conventions |
| Restructure skill hierarchy | Fundamental design problem | High | Low. the correct long-term fix |

For most cases, extracting a neutral shared module is the cleanest solution and the easiest to explain to other developers. Lazy loading is the fastest fix when you need to unblock yourself immediately and refactor properly later.

## Conclusion

The circular dependency detected error in Claude Code skills stems from import loops that break the skill loading process. By identifying the skills involved, breaking the import chain through refactoring or lazy loading, and removing circular metadata declarations, you restore full functionality. Prevent future occurrences by maintaining clear dependency boundaries and testing skill loading after any configuration changes. With these strategies, skills like pdf, tdd, frontend-design, supermemory, and any other skill combination work without conflicts. For broader skill composition patterns that avoid these issues by design, see [Claude skill inheritance and composition patterns](/claude-skill-inheritance-and-composition-patterns/).

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skill-circular-dependency-detected-error-fix)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skill Inheritance and Composition Patterns](/claude-skill-inheritance-and-composition-patterns/). Design skills with clean dependency boundaries to prevent circular imports
- [Claude Code Skill Conflicts with MCP Server Resolution Guide](/claude-code-skill-conflicts-with-mcp-server-resolution-guide/). Resolve conflicts when skills and MCP servers share overlapping tool names
- [How Do I Debug a Claude Skill That Silently Fails](/how-do-i-debug-a-claude-skill-that-silently-fails/). Diagnose other types of skill failures alongside circular dependency errors
- [Claude Skills Troubleshooting Hub](/troubleshooting-hub/). More troubleshooting guides for common Claude skill errors
- [Claude Code Keeps Producing Slightly — Developer Guide](/claude-code-keeps-producing-slightly-different-code-each-tim/)
- [Claude Code For War Room — Complete Developer Guide](/claude-code-for-war-room-workflow-tutorial-guide/)
- [Fix Claude Code Crashing in VS Code](/claude-code-crashing-vscode/)
- [Claude Code for Flaky Test Detection and Fix Guide](/claude-code-for-flaky-test-detection-and-fix-guide/)
- [How to Choose the Cheapest Claude Model](/cheapest-claude-model-for-your-task/)
- [Fix Claude Code 'Bun Has Crashed' Error](/claude-code-bun-has-crashed/)
- [Fix Claude Code Windows Requires Git Bash](/claude-code-windows-git-bash-required-fix/)
- [Claude Code Crash Course with GitHub](/claude-code-crash-course-github/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Circular Dependency Detected in Build — Fix (2026)](/claude-code-circular-dependency-detected-build-fix-2026/)
