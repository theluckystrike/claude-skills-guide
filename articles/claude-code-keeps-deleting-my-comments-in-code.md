---
layout: default
title: "Fix Claude Code Deleting Code Comments (2026)"
description: "Stop Claude Code from removing your code comments during edits. Configure comment preservation rules and use skill patterns to protect documentation."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
categories: [troubleshooting]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-keeps-deleting-my-comments-in-code/
reviewed: true
score: 7
geo_optimized: true
---
## Claude Code Keeps Deleting My Comments in Code: Causes and Solutions

If you've been working with Claude Code and noticed that your carefully crafted code comments mysteriously disappear after AI-assisted edits, you're not alone. This is one of the most common frustrations developers face when using AI coding assistants. Understanding why this happens and how to prevent it can significantly improve your experience with Claude Code.

## Why Claude Code Removes Comments

Claude Code's primary goal is to improve code quality and maintainability. Sometimes, in its efforts to clean up and refactor code, it may interpret comments as unnecessary or redundant. Several factors contribute to this behavior:

1. Context Window Limitations: Claude Code works within a limited context window. When the conversation becomes lengthy, the AI may prioritize keeping code functionality over preserving every comment, especially if it perceives them as verbose or obvious.

2. Refactoring Priorities: When you ask Claude Code to refactor, clean up, or optimize code, it may view comments as clutter that can be removed to make the code "cleaner." The AI sometimes assumes that well-written code should be self-explanatory.

3. Implicit vs. Explicit Instructions: If you don't explicitly tell Claude Code to preserve comments, it may make its own judgment about their necessity based on the context of your request.

4. Rewrite vs. Edit Mode: When Claude Code rewrites an entire function or file rather than making targeted edits, any comment not directly referenced in the prompt is at risk. Rewrites start from Claude's interpretation of what the code should do, not from what was there before.

5. "Clean Code" Heuristics: Claude is trained on vast amounts of code where minimal comments are common. In some codebases and style guides, the prevailing philosophy is that clean code explains itself. Claude absorbs those heuristics and can apply them even when your project takes the opposite approach.

Understanding these triggers helps you write prompts that sidestep the problem rather than fighting Claude's default tendencies.

## How to Prevent Comment Deletion

The good news is that you have several strategies to ensure your comments remain intact while working with Claude Code.

1. Be Explicit About Preserving Comments

The most straightforward solution is to explicitly instruct Claude Code to preserve your comments in every interaction. Make this part of your standard prompting:

```
Please refactor this function but preserve all existing comments.
```

For more emphasis, you can be even clearer:

```
Make any changes you deem necessary, but do NOT remove any comments from the code. All existing comments must remain exactly as they are.
```

When the task is purely additive, adding a feature or fixing a bug, frame it that way so Claude knows it should not touch anything outside the scope of the change:

```
Add error handling for the null case only. Do not modify any other part of this function, and do not remove any comments.
```

The more specific your scope, the less room Claude has to make judgment calls about what to keep.

2. Use CLAUDE.md for Persistent Instructions

Create a `CLAUDE.md` file in your project root to give Claude Code persistent instructions about your preferences:

```markdown
Project Guidelines

Code Comments
- Always preserve existing code comments
- Do not remove or modify comments unless explicitly asked
- When adding new code, add helpful comments explaining complex logic
```

This file is automatically read by Claude Code at the start of each conversation, ensuring your comment preservation preferences are always respected. The `CLAUDE.md` approach is particularly valuable on teams, you write the rule once and everyone benefits from it, regardless of whether they remember to include comment-preservation instructions in their individual prompts.

You can be even more specific in `CLAUDE.md` about comment categories that matter most:

```markdown
Code Comments

- Never remove block comments (/* ... */)
- Never remove JSDoc / docstring blocks
- Never remove TODO, FIXME, HACK, or NOTE markers
- Inline comments is updated only if the code they describe has changed
- License headers at the top of files must always be preserved
```

3. Configure Skill-Level Preferences

If you're using Claude Code skills, you can configure them to respect comment preservation. Add specific instructions in the skill description:

```markdown
---
name: refactor
description: Refactor code while preserving all comments and documentation
---
```

For skills that operate on entire files or directories, add an explicit constraint in the skill body:

```markdown
---
name: refactor
description: >
 Refactor code for clarity and performance. Preserve all existing comments,
 docstrings, TODO markers, and license headers. Only modify code logic, not
 documentation.
---
```

This constraint travels with the skill, so any invocation of it carries the preservation rule automatically.

4. Use Block-Level Comment Protection

For particularly important comments that you absolutely cannot lose, consider using multiple comment styles or adding metadata comments that signal importance:

```python
This comment must be preserved during any refactoring
It contains critical business logic explanation
def calculate_revenue():
 ...
```

The word "IMPORTANT" in a comment is not a magic keyword that Claude recognizes, but it shifts the weight of evidence. When Claude is deciding whether a comment adds value, an explicit signal like "IMPORTANT" or "DO NOT REMOVE" makes it significantly less likely to treat the comment as disposable.

For code that lives at the intersection of compliance or legal requirements, this is especially worth doing:

```javascript
// LICENSE: This file is subject to the terms of the Mozilla Public License 2.0.
// DO NOT REMOVE OR MODIFY THIS HEADER.

// COMPLIANCE: Per SOC 2 requirement CC6.1, all authentication events must be logged.
// Removing this logging violates our compliance posture. See docs/compliance.md.
function authenticateUser(credentials) {
 ...
}
```

5. Prefer Targeted Edits Over Full Rewrites

One of the most effective tactics is to structure your requests so Claude makes surgical edits rather than rewriting whole blocks. When Claude rewrites a function from scratch, it reconstructs it based on what it thinks the function should do, and comments that were there before may not appear in the reconstruction.

Instead of:

```
Rewrite this function to be more efficient.
```

Try:

```
Without rewriting the function, identify the specific lines that are inefficient
and suggest targeted replacements for those lines only.
```

Or even more directly:

```
Change only lines 14 through 19 to use array.reduce() instead of the manual loop.
Leave everything else in the function exactly as-is.
```

This approach keeps the edit scope narrow and gives comments no reason to be touched.

6. Review Changes Before Applying

Always review Claude Code's proposed changes before accepting them. Use the diff view to see exactly what will be modified:

```bash
When Claude Code shows edits, carefully review comment sections
If comments are marked for removal, reject and re-prompt
```

When reviewing a diff, scan specifically for lines that begin with `#`, `//`, `/*`, `"""`, or `*` depending on your language. These are comment lines. If any appear in the "removed" section of the diff without a corresponding update in the "added" section, reject the change and re-prompt with an explicit instruction to keep comments.

Building this habit is cheap insurance. It takes about ten seconds to scan a diff for comment deletions, and catching them before accepting the change is far less disruptive than recovering them from version control after the fact.

## Understanding Claude Code's Editing Behavior

To effectively work with Claude Code, it helps to understand how its editing decisions are made:

Automatic Refinement: When you ask for improvements, Claude Code may proactively remove what it considers "redundant" comments. Always specify your intent clearly.

Code Simplification: In pursuit of cleaner code, comments are sometimes seen as extra lines that can be condensed or removed.

Context Summarization: In long conversations, Claude Code may summarize or omit comments to fit within context limits.

Regeneration vs. Preservation: Claude Code generates text, it does not copy-paste. When it produces a modified version of your code, it is generating new text that represents the modified file. This means anything not explicitly preserved in its generation is subject to omission. The mental model of "Claude is editing my file" is less accurate than "Claude is writing a new version of my file." That shift in mental model explains why persistent rules (in `CLAUDE.md`) and explicit per-prompt instructions are both necessary.

## Comparison: Prompt Strategies by Effectiveness

Different prompt strategies produce different results when it comes to comment preservation. Here is a practical comparison:

| Strategy | Reliability | Effort | Best For |
|---|---|---|---|
| No instruction given | Low. comments often removed | None | Not recommended |
| "Preserve all comments" in prompt | Medium | Low | Quick one-off tasks |
| CLAUDE.md project rule | High | One-time setup | Team projects, repeated workflows |
| Skill-level constraint | High | One-time per skill | Automated or recurring skill use |
| Targeted edit request | High | Per-request | Complex refactors in sensitive files |
| Comment markers (IMPORTANT/DO NOT REMOVE) | Medium-high | Per-comment | Critical individual comments |

For most developers, the right answer is to combine CLAUDE.md rules with targeted edit requests. The CLAUDE.md rule catches the common case; targeted edit framing handles the edge cases where you're asking Claude to restructure something substantial.

## Best Practices for Working with Comments

1. Add explicit instructions: "Preserve all comments" should be part of your standard prompt vocabulary.

2. Use TODO and FIXME markers: These are harder for AI to justify removing since they indicate actionable items:

 ```javascript
 // TODO: Implement caching for improved performance
 // FIXME: Handle edge case when user is null
 ```

3. Document in separate files: For extensive documentation, maintain a separate `docs/` folder rather than relying solely on inline comments.

4. Check git diffs: Always review changes in your version control system before committing.

5. Treat CLAUDE.md as living documentation: Update your project's `CLAUDE.md` whenever you discover a new category of comments that Claude is inclined to remove. Build the rule set incrementally from real experience rather than trying to anticipate everything upfront.

6. Use docstrings for critical explanations: In Python, JavaScript (JSDoc), and similar languages, formal docstring formats are harder for Claude to remove because they carry structural meaning. If an explanation is important enough that losing it would cause harm, move it from a loose inline comment into a docstring that documents the function's behavior, parameters, or return value.

## Conclusion

While Claude Code's comment deletion behavior can be frustrating, it's entirely preventable with the right approach. By being explicit about your preferences, using configuration files like `CLAUDE.md`, and carefully reviewing changes before applying them, you can maintain your code's documentation while still benefiting from AI-assisted development.

Remember: Claude Code is a tool that follows your instructions. The key is to make your intentions about comments crystal clear in every interaction. With these strategies in place, you'll never have to worry about losing those important comments again.

---

*Have you found other effective ways to preserve comments while working with Claude Code? The solution that works best often depends on your specific workflow and project requirements.*

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-keeps-deleting-my-comments-in-code)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


