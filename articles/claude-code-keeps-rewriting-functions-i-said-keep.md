---


layout: default
title: "Claude Code Keeps Rewriting Functions I Said Keep"
description: "Understand why Claude Code rewrites functions you've asked to preserve, and learn practical strategies to prevent unwanted refactoring during your."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-keeps-rewriting-functions-i-said-keep/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-code, claude-skills, debugging]
---


# Claude Code Keeps Rewriting Functions I Said Keep

One of the most frustrating experiences when working with Claude Code is watching it silently rewrite functions you explicitly asked to preserve. You carefully craft a prompt saying "keep this function exactly as is" or "don't touch the legacy code," only to find that Claude Code has somehow decided to refactor everything anyway. This behavior isn't malicious—it's trying to be helpful—but it can derail your workflow, especially when working with code that has specific requirements, legacy systems, or carefully tuned implementations.

## Why Claude Code Rewrites Functions

Understanding the root causes of this behavior helps you address them effectively. Claude Code has several tendencies that lead to unwanted rewrites.

**Code quality improvement impulses**: Claude Code is trained to improve code quality. When it sees what it perceives as suboptimal patterns, it naturally suggests improvements. Even explicit instructions to "keep this function" may be interpreted as "keep it functional but improve its implementation." The model balances your request against its training to produce better code, sometimes weighing the quality improvement more heavily than the preservation request.

**Context window interpretation**: Claude Code interprets instructions within its context window. If you mention a function in one message and then discuss refactoring in another, it may connect these and decide the function needs updating to fit the new pattern. This happens especially when working on large files where Claude Code sees multiple sections and tries to make them consistent.

**Skill and system prompt conflicts**: When Claude Code has an active skill loaded that includes coding standards or best practices, those guidelines may override your specific instructions. A security-focused skill might add input validation to functions you wanted untouched. A testing skill might restructure functions to be more testable.

## Practical Solutions

### Use Explicit Preservation Blocks

The most effective technique is using clear markers in your code and prompts that signal boundaries Claude Code should respect. You can create explicit preservation comments that act as fences around code that must remain unchanged.

For example, when working with a function you want preserved, structure your prompt to include specific directives:

```
# Keep the following function EXACTLY as-is. Do not modify, refactor, or add anything to it.
# START-PRESERVE
def calculate_discount(price, customer_tier):
    if customer_tier == 'gold':
        return price * 0.85
    elif customer_tier == 'silver':
        return price * 0.90
    return price
# END-PRESERVE
```

In your prompt, explicitly reference these markers: "Make changes to the rest of the file but leave the calculate_discount function exactly as marked with START-PRESERVE and END-PRESERVE comments."

### Leverage Claude.md for Persistent Instructions

Create a claude.md file in your project root that specifies functions and code sections that should never be modified. This file persists across sessions and provides constant context to Claude Code.

Your claude.md might include:

```markdown
# Code Preservation Rules

## Never Modify
- `src/legacy/calculations.py` - Contains mathematically verified implementations
- `calculate_discount()` function in `src/pricing.py` - Matches specific business contract
- Any function with "DO NOT MODIFY" comment

## Pattern Rules
- Don't refactor code older than 2 years without explicit permission
- Don't change naming conventions in existing modules
- Don't add type hints to untyped legacy functions
```

### Use the Read-Only Mode Strategy

When you need Claude Code to analyze code without modifying it, explicitly engage it in read-only mode. This changes its operational mindset from editing to understanding:

"Read and analyze the calculate_revenue function. Do not make any changes. I need you to identify potential issues and explain them, but preserve the function exactly as it exists."

This framing signals that modifications are explicitly forbidden, reducing the likelihood of unwanted rewrites.

### Be Specific About Scope

Vague instructions lead to unexpected results. Instead of "refactor this file but keep the old functions," specify exactly what should change and what should not:

"Replace all console.log statements with the logger.debug calls in utils.js, but do NOT modify the formatTimestamp function or any function in the legacy/ directory."

The more specific you are about boundaries, the better Claude Code respects them.

## Configuring Skills to Prevent Rewrites

Claude Code skills can be configured to be more conservative about modifications. Create a custom skill that emphasizes preservation:

```yaml
name: conservative-editor
description: Edit code while preserving existing functionality
instructions: |
  - Never refactor code unless explicitly asked
  - Preserve function signatures exactly
  - Don't add new dependencies or imports
  - Only modify what is explicitly requested
  - Ask for confirmation before any refactoring
```

Save this as `.claude/conservative-editor.md` and invoke it with `/conservative-editor` when working on sensitive code.

## Handling Rewrites When They Happen

When you catch Claude Code rewriting a function you wanted preserved, don't panic. The safest approach is immediate reversal:

1. Use `git diff` to see exactly what changed
2. If the changes are unwanted, `git checkout -- filename` restores the original
3. Prompt again with stronger preservation language
4. Add DO NOT MODIFY comments to the function

Claude Code typically respects these comments when they're prominent and clearly placed.

## Best Practices Summary

Preventing unwanted function rewrites comes down to clear communication and strategic structuring. Use explicit preservation markers in your code, maintain a claude.md with preservation rules, be specific about scope in every prompt, and configure skills appropriately when working with sensitive code. When Claude Code does rewrite something, catch it quickly through git status checks and revert immediately.

The key insight is that Claude Code wants to help by improving your code. Channel that energy by being extremely clear about what should improve and what should stay exactly as it is. With the right prompts and configuration, you can have both—helpful improvements where you want them and perfect preservation where you need it.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-skills-guide/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/)

