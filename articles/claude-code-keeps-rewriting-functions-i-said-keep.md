---
layout: default
title: "Claude Code Keeps Rewriting Functions I (2026)"
description: "Understand why Claude Code rewrites functions you've asked to preserve, and learn practical strategies to prevent unwanted refactoring during your."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-keeps-rewriting-functions-i-said-keep/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-code, claude-skills, debugging]
geo_optimized: true
---
One of the most frustrating experiences when working with Claude Code is watching it silently rewrite functions you explicitly asked to preserve. You carefully craft a prompt saying "keep this function exactly as is" or "don't touch the legacy code," only to find that Claude Code has somehow decided to refactor everything anyway. This behavior isn't malicious, it's trying to be helpful, but it can derail your workflow, especially when working with code that has specific requirements, legacy systems, or carefully tuned implementations.

This guide covers why it happens, how to prevent it with concrete prompt patterns and configuration, and what to do when a rewrite has already occurred.

## Why Claude Code Rewrites Functions

Understanding the root causes of this behavior helps you address them effectively. Claude Code has several distinct tendencies that lead to unwanted rewrites, and knowing which one is at play helps you pick the right countermeasure.

Code quality improvement impulses: Claude Code is trained to produce high-quality code. When it sees what it perceives as suboptimal patterns, no type annotations, long conditional chains, inconsistent naming, it naturally suggests improvements. Even explicit instructions to "keep this function" is interpreted as "keep it functional but improve its implementation." The model is always weighing your preservation request against its internalized quality standards, and sometimes quality wins when the instruction is ambiguous.

Context window interpretation: Claude Code interprets instructions within its entire context window holistically. If you mention a function in one message and then discuss refactoring in a follow-up, it may connect these signals and decide the function needs updating to fit the new pattern. This happens especially in large files where Claude Code sees multiple sections and tries to make them stylistically or structurally consistent. It is trying to be helpful, the side effect is that it applies consistency more broadly than you intended.

Skill and system prompt conflicts: When Claude Code has an active skill loaded that includes coding standards or best practices, those guidelines can override your specific in-session instructions. A security-focused skill might add input validation to functions you wanted untouched. A testing skill might restructure functions to be more easily unit-testable. If you loaded a skill earlier in the session and forgot about it, its rules are still active.

Implicit refactoring triggers: Certain phrasings trigger Claude Code's refactoring instincts even when you don't intend them to. Saying "clean this up" or "improve this file" gives it broad latitude. Asking it to "fix the bug in this file" can cause it to rewrite unrelated functions that it judges to be poorly structured, even though you only wanted the bug fixed.

## Prompt Patterns That Fail vs. Patterns That Work

Not all preservation instructions are created equal. The table below shows common weak phrasings alongside stronger alternatives that get better results.

| Weak instruction | Why it fails | Stronger alternative |
|---|---|---|
| "Keep the old functions" | "Old" is vague; Claude may judge which ones are old | "Do not modify any function that already exists in this file" |
| "Don't break anything" | Focuses on outcome, not preservation | "Only add new code. Do not change or delete any existing code." |
| "Preserve legacy code" | "Legacy" is subjective | "Do not touch any code in the `legacy/` directory or any file containing `# legacy` comment" |
| "Keep it clean" | Invites style rewrites | "Make the minimal change required. Leave all other code exactly as it is." |
| "Refactor this but keep the core" | "Core" is undefined | "Refactor only the `render()` method. Do not modify `calculate_discount()`, `applyTax()`, or any other function." |

The general principle: be explicit about what is off-limits, not just about what the outcome should be.

## Practical Solutions

## Use Explicit Preservation Blocks

The most effective technique is using clear markers in your code and prompts that signal boundaries Claude Code should respect. You can create explicit preservation comments that act as fences around code that must remain unchanged.

For example, when working with a function you want preserved, structure your prompt to include specific directives:

```python
Keep the following function EXACTLY as-is. Do not modify, refactor, or add anything to it.
START-PRESERVE
def calculate_discount(price, customer_tier):
 if customer_tier == 'gold':
 return price * 0.85
 elif customer_tier == 'silver':
 return price * 0.90
 return price
END-PRESERVE
```

In your prompt, explicitly reference these markers: "Make changes to the rest of the file but leave the calculate_discount function exactly as marked with START-PRESERVE and END-PRESERVE comments."

This works because Claude Code treats prominent, structured comments as instructions embedded in the codebase itself, not just suggestions in the chat. When it sees `START-PRESERVE` and `END-PRESERVE`, it treats that region more like read-only documentation than editable source.

You can adapt this pattern for any language:

```javascript
// =========================================
// DO NOT MODIFY - Contract-verified logic
// =========================================
function calculateFinalPrice(basePrice, taxRate, discount) {
 return (basePrice - discount) * (1 + taxRate);
}
// =========================================
// END DO NOT MODIFY
// =========================================
```

```java
/* PRESERVE-START: certified_algorithm */
public double computeHash(byte[] input) {
 // ... implementation
}
/* PRESERVE-END: certified_algorithm */
```

## Use Claude.md for Persistent Instructions

Create a `claude.md` file in your project root that specifies functions and code sections that should never be modified. This file persists across sessions and provides constant context to Claude Code, meaning you do not have to repeat preservation rules in every prompt.

A well-structured `claude.md` preservation section looks like this:

```markdown
Code Preservation Rules

Never Modify These Files
- `src/legacy/calculations.py`. Contains mathematically verified implementations, do not change
- `src/pricing/tax_engine.js`. Matches specific regulatory requirements, audited externally
- `lib/crypto/hash.go`. FIPS-certified implementation, any change invalidates certification

Never Modify These Functions (by name)
- `calculate_discount()` in `src/pricing.py`. Matches specific business contract language
- `formatTimestamp()` in `utils/time.js`. Output format is contractually required
- `applyRounding()` anywhere. Rounding behavior is legally specified

Pattern Rules
- Do not refactor code older than 2 years without explicit permission in the prompt
- Do not change naming conventions in existing modules
- Do not add type hints to untyped legacy functions
- Do not add logging to functions in `src/finance/` without explicit request
- Do not reorder function parameters, even for consistency

Safe to Modify
- Anything in `src/new/` or `src/experimental/`
- Test files in `tests/`
- Documentation in `docs/`
```

The specificity matters. A section that names files, functions, and directories gives Claude Code clear fences to work within. A vague rule like "respect legacy code" will be interpreted differently each session.

## Use the Read-Only Mode Strategy

When you need Claude Code to analyze code without modifying it, explicitly frame the task as analysis-only. This changes its operational mindset from editing to understanding:

"Read and analyze the `calculate_revenue` function. Do not make any changes. I need you to identify potential issues and explain them to me, but preserve the function exactly as it exists."

You can reinforce this by adding a final line to your analysis requests: "End your response with a confirmation that you did not modify any files." This creates an accountability check that nudges Claude Code toward compliance.

For longer analysis sessions where you want to ask multiple questions before committing to any changes, open with a clear frame-setting statement:

"For the rest of this conversation, I am in read-only investigation mode. Do not edit any files unless I explicitly say 'go ahead and make that change.' Acknowledge this before we begin."

This framing sets an expectation at the conversation level rather than repeating it each time.

## Be Specific About Scope

Vague instructions produce unpredictable results. Instead of "refactor this file but keep the old functions," specify exactly what should change and what should not, name names.

Vague (avoid):
```
Improve the error handling in utils.js.
```

Specific (use this):
```
In utils.js, add try/catch blocks to the fetchUserData() and saveUserPreferences()
functions only. Do not modify formatTimestamp(), parseQueryString(), or any other
function in the file. Add no new imports.
```

The more explicit the boundary, the less room there is for Claude Code to exercise its own judgment about what "improvement" means. Treat your prompts like surgical orders: state the procedure, the site, and everything that should remain untouched.

## Separate Concerns Across Multiple Prompts

One underused strategy is splitting tasks into smaller, scoped prompts rather than asking Claude Code to do many things at once in a single request. When you ask it to "refactor the file and fix the bug and improve the tests," it has broad latitude and is more likely to rewrite things you didn't intend to touch.

Instead:

1. First prompt: "Fix only the null pointer exception in `processOrder()`. Make no other changes."
2. Second prompt: "Now add JSDoc comments to `processOrder()` only. Do not touch the function body or any other function."
3. Third prompt: "Now update the test in `order.test.js` to cover the null case we just fixed. Do not touch any other test."

Each prompt is a narrow, reversible operation. If one goes wrong, you revert one change, not an entangled mass of edits.

## Configuring Skills to Prevent Rewrites

Claude Code skills can be configured to enforce conservative editing behavior. If you frequently work on codebases with preservation requirements, a custom skill file pays for itself quickly.

Create a `.claude/conservative-editor.md` skill file in your project:

```markdown
Conservative Editor Skill

Purpose
Edit code with minimal footprint. Preserve all existing code unless explicitly targeted.

Rules
- Make only the specific change requested in the user's prompt
- Do not refactor, rename, reformat, or restructure any code not explicitly mentioned
- Do not add type annotations, docstrings, or comments to existing code unless asked
- Do not reorder function definitions or class members
- Do not change import organization or grouping
- If you notice a code quality issue unrelated to the task, mention it in text but do not fix it
- Confirm at the end of each response which files were modified and which were not
```

Invoke it at the start of a sensitive session with `/conservative-editor`. The skill's rules stack on top of your per-prompt instructions, giving you two layers of enforcement.

## Handling Rewrites When They Happen

When you catch Claude Code rewriting a function you wanted preserved, act quickly before the context accumulates more changes.

## Step 1: Assess the damage with git

```bash
git diff
```

This shows exactly what changed. Read the diff before deciding whether to revert or keep the changes, sometimes Claude Code's rewrite is actually an improvement even if it was unwanted, and it is worth a quick review before discarding.

## Step 2: Revert if needed

To revert a single file:
```bash
git checkout -- path/to/file.py
```

To revert all unstaged changes:
```bash
git checkout -- .
```

If you staged the changes already:
```bash
git restore --staged path/to/file.py
git checkout -- path/to/file.py
```

## Step 3: Add hard-stop comments and re-prompt

Before re-prompting, add prominent preservation markers to the functions that were rewritten:

```python
!!!! DO NOT MODIFY THIS FUNCTION. see claude.md for policy !!!!
def calculate_discount(price, customer_tier):
 ...
```

Then re-issue your original request with explicit preservation language: "The previous attempt incorrectly modified `calculate_discount`. Do not touch that function. Make only [the specific change you wanted]."

## Step 4: Use git commits as checkpoints

For any session where you are making multiple incremental changes, commit after each successful step:

```bash
git add -p # stage only what you intended
git commit -m "chore: add logging to fetchUser only"
```

This keeps your recovery options clean. Each revert is a single commit undo rather than a tangled undo of multiple mixed changes.

## Comparing Preservation Strategies

Each of the approaches covered above has different strengths depending on your situation. Here is a quick reference:

| Strategy | Best for | Effort | Persistence |
|---|---|---|---|
| Preservation block comments | Single-session, specific functions | Low | Until removed from code |
| claude.md rules | Ongoing projects with stable preservation requirements | Medium (one-time setup) | Persistent across all sessions |
| Read-only mode framing | Analysis tasks, audits, investigation | Low (per-prompt) | Single conversation |
| Narrow scoped prompts | Any refactoring where precision matters | Medium (discipline required) | Single task |
| Conservative editor skill | Repeated work on sensitive codebases | Medium (one-time setup) | Active when skill is loaded |
| Git checkpoints | Recovery and rollback | Low | Permanent history |

For most developers, the most impactful combination is: a `claude.md` with preservation rules (set once, always active) plus narrow scoped prompts (per-task discipline) plus frequent git commits (recovery safety net). The other strategies are supplements for specific situations.

## Common Mistakes That Invite Rewrites

A few habits that developers often don't realize are triggering unwanted rewrites:

Asking for "cleanup": The word cleanup implies style changes. Use "fix" or "add" when you want a targeted change.

Showing Claude Code the whole file when you only need it to touch one function: If you paste a 400-line file and ask it to change one line, it sees 399 lines it could improve. Paste only the relevant function when possible, or use file references with explicit boundaries.

Not using git before starting a session: If you haven't committed your current state, you have no clean recovery point. Always `git commit` or at least `git stash` before a Claude Code session that touches sensitive code.

Assuming a previous instruction carries forward: Each new prompt is an opportunity for Claude Code to re-evaluate its approach. Instructions given three messages ago is underweighted compared to newer context. Re-state preservation requirements when starting a new task within the same conversation.

## Best Practices Summary

Preventing unwanted function rewrites comes down to clear communication and strategic structuring. The combination that works best for most developers:

1. Maintain a `claude.md` with explicit preservation rules for your project, name files, functions, and patterns
2. Use `START-PRESERVE` / `END-PRESERVE` comments around code that must never change
3. Write narrow, specific prompts that name exactly what to change and what to leave alone
4. Split large tasks into multiple smaller prompts, each with a single clear scope
5. Commit to git before each session so you always have a clean recovery point
6. Run `git diff` after every Claude Code edit before accepting the result

The key insight is that Claude Code wants to help by improving your code. Channel that energy by being extremely clear about what should improve and what should stay exactly as it is. With the right prompts and configuration, you can have both, helpful improvements where you want them and perfect preservation where you need it.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-keeps-rewriting-functions-i-said-keep)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix Claude Code Making Assumptions (2026)](/claude-code-keeps-making-assumptions-karpathy-fix-2026/)
