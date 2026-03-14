---
layout: default
title: "Claude Code Keeps Deleting My Comments in Code: Causes and Solutions"
description: "Understanding why Claude Code removes code comments and how to prevent it. Practical solutions to preserve comments during AI-assisted code editing."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-keeps-deleting-my-comments-in-code/
---

# Claude Code Keeps Deleting My Comments in Code: Causes and Solutions

If you've been working with Claude Code and noticed that your carefully crafted code comments mysteriously disappear after AI-assisted edits, you're not alone. This is one of the most common frustrations developers face when using AI coding assistants. Understanding why this happens and how to prevent it can significantly improve your experience with Claude Code.

## Why Claude Code Removes Comments

Claude Code's primary goal is to improve code quality and maintainability. Sometimes, in its efforts to clean up and refactor code, it may interpret comments as unnecessary or redundant. Several factors contribute to this behavior:

**1. Context Window Limitations**: Claude Code works within a limited context window. When the conversation becomes lengthy, the AI may prioritize keeping code functionality over preserving every comment, especially if it perceives them as verbose or obvious.

**2. Refactoring Priorities**: When you ask Claude Code to refactor, clean up, or optimize code, it may view comments as clutter that can be removed to make the code "cleaner." The AI sometimes assumes that well-written code should be self-explanatory.

**3. Implicit vs. Explicit Instructions**: If you don't explicitly tell Claude Code to preserve comments, it may make its own judgment about their necessity based on the context of your request.

## How to Prevent Comment Deletion

The good news is that you have several strategies to ensure your comments remain intact while working with Claude Code.

### 1. Be Explicit About Preserving Comments

The most straightforward solution is to explicitly instruct Claude Code to preserve your comments in every interaction. Make this part of your standard prompting:

```
Please refactor this function but preserve all existing comments.
```

For more emphasis, you can be even clearer:

```
Make any changes you deem necessary, but do NOT remove any comments from the code. All existing comments must remain exactly as they are.
```

### 2. Use CLAUDE.md for Persistent Instructions

Create a `CLAUDE.md` file in your project root to give Claude Code persistent instructions about your preferences:

```markdown
# Project Guidelines

## Code Comments
- Always preserve existing code comments
- Do not remove or modify comments unless explicitly asked
- When adding new code, add helpful comments explaining complex logic
```

This file is automatically read by Claude Code at the start of each conversation, ensuring your comment preservation preferences are always respected.

### 3. Configure Skill-Level Preferences

If you're using Claude Code skills, you can configure them to respect comment preservation. Add specific instructions in the skill description:

```markdown
---
name: refactor
description: Refactor code while preserving all comments and documentation
---
```

### 4. Use Block-Level Comment Protection

For particularly important comments that you absolutely cannot lose, consider using multiple comment styles or adding metadata comments that signal importance:

```python
# IMPORTANT: This comment must be preserved during any refactoring
# It contains critical business logic explanation
def calculate_revenue():
    ...
```

### 5. Review Changes Before Applying

Always review Claude Code's proposed changes before accepting them. Use the diff view to see exactly what will be modified:

```bash
# When Claude Code shows edits, carefully review comment sections
# If comments are marked for removal, reject and re-prompt
```

## Understanding Claude Code's Editing Behavior

To effectively work with Claude Code, it helps to understand how its editing decisions are made:

**Automatic Refinement**: When you ask for improvements, Claude Code may proactively remove what it considers "redundant" comments. Always specify your intent clearly.

**Code Simplification**: In pursuit of cleaner code, comments are sometimes seen as extra lines that can be condensed or removed.

**Context Summarization**: In long conversations, Claude Code may summarize or omit comments to fit within context limits.

## Best Practices for Working with Comments

1. **Add explicit instructions**: "Preserve all comments" should be part of your standard prompt vocabulary.

2. **Use TODO and FIXME markers**: These are harder for AI to justify removing since they indicate actionable items:

   ```javascript
   // TODO: Implement caching for improved performance
   // FIXME: Handle edge case when user is null
   ```

3. **Document in separate files**: For extensive documentation, maintain a separate `docs/` folder rather than relying solely on inline comments.

4. **Check git diffs**: Always review changes in your version control system before committing.

## Conclusion

While Claude Code's comment deletion behavior can be frustrating, it's entirely preventable with the right approach. By being explicit about your preferences, using configuration files like `CLAUDE.md`, and carefully reviewing changes before applying them, you can maintain your code's documentation while still benefiting from AI-assisted development.

Remember: Claude Code is a tool that follows your instructions. The key is to make your intentions about comments crystal clear in every interaction. With these strategies in place, you'll never have to worry about losing those important comments again.

---

*Have you found other effective ways to preserve comments while working with Claude Code? The solution that works best often depends on your specific workflow and project requirements.*
