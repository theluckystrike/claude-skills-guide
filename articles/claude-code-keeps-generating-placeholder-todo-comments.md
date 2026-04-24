---

layout: default
title: "Claude Code Keeps Generating (2026)"
description: "Why Claude Code keeps adding placeholder TODO comments and how to fix it. Practical solutions for controlling AI-generated code comments."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [troubleshooting]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-keeps-generating-placeholder-todo-comments/
reviewed: true
score: 7
geo_optimized: true
---


If you've been working with Claude Code, you've probably seen it, those familiar `// TODO: implement error handling` or `// TODO: add validation` comments scattered throughout generated code. While well-intentioned, these placeholder comments can accumulate quickly and become technical debt if not addressed properly. why Claude Code generates these comments and how you can control this behavior effectively.

## Why Claude Code Generates TODO Comments

Claude Code generates placeholder TODO comments for several reasons related to how Large Language Models approach code generation. Understanding these motivations helps you address the root cause rather than just treating symptoms.

Incomplete Context: When Claude Code doesn't have complete information about your requirements, it uses TODO comments as placeholders for functionality you're expected to fill in. This often happens when you ask for complex features without specifying all the implementation details.

Risk Mitigation: The AI sometimes adds TODO comments as a way to acknowledge uncertainty. Rather than guessing incorrectly, it marks areas where implementation decisions need human input.

Template Patterns: Claude Code has been trained on millions of codebases where TODO comments are common patterns. The model sometimes defaults to these patterns, especially when generating code in unfamiliar domains or languages.

Context Window Boundaries: When working on very large functions or multi-file generation tasks, Claude Code may hit logical complexity limits and resort to placeholders rather than generating incorrect code it's unsure about.

Scaffolding Ambiguity: Prompts that say "create a module for X" without specifying the full scope often trigger TODO generation because the model is producing a structural scaffold rather than a complete implementation.

## Real-World Example: What TODO Pollution Looks Like

Here's a realistic example of what Claude Code produces when given a vague prompt for a payment processing function:

```typescript
// Vague prompt: "Create a payment processing service"

class PaymentService {
 async processPayment(amount: number, cardToken: string) {
 // TODO: validate amount is positive
 // TODO: check rate limiting
 const result = await this.gateway.charge(cardToken, amount);
 // TODO: handle declined cards
 // TODO: implement retry logic
 // TODO: log to audit trail
 return result;
 }

 async refund(transactionId: string) {
 // TODO: implement refund logic
 }

 async getHistory(userId: string) {
 // TODO: implement history lookup
 }
}
```

This looks productive at a glance but is almost entirely unimplemented. In a large codebase, dozens of these functions create a false sense of progress, your IDE's TODO panel fills up, code reviews slow down, and the most important business logic never gets written.

## Practical Solutions

1. Provide Complete Specifications

The most effective fix is providing detailed context about what you want. Instead of:

```
Create a user authentication module
```

Try:

```
Create a user authentication module with:
- Email/password login (bcrypt hashing)
- JWT token refresh
- Password reset via email
- Rate limiting (5 attempts per minute)
- Return proper HTTP status codes
```

When you specify exact requirements, Claude Code has less reason to leave placeholders.

Here's what that same payment function looks like with a detailed prompt:

```typescript
// Detailed prompt: "Create a processPayment function that:
// - Validates amount is a positive number between 0.01 and 99999.99
// - Accepts a Stripe card token string
// - Charges the card using this.gateway.charge()
// - Handles Stripe errors (card_declined, insufficient_funds, generic)
// - Retries on network errors up to 3 times with exponential backoff
// - Logs each attempt to this.auditLogger
// - Returns { success, transactionId, error } object"

async processPayment(amount: number, cardToken: string): Promise<PaymentResult> {
 if (typeof amount !== 'number' || amount < 0.01 || amount > 99999.99) {
 return { success: false, transactionId: null, error: 'Invalid amount' };
 }

 let lastError: Error | null = null;
 for (let attempt = 1; attempt <= 3; attempt++) {
 try {
 this.auditLogger.log({ event: 'charge_attempt', attempt, amount });
 const result = await this.gateway.charge(cardToken, amount);
 this.auditLogger.log({ event: 'charge_success', transactionId: result.id });
 return { success: true, transactionId: result.id, error: null };
 } catch (err: any) {
 lastError = err;
 if (['card_declined', 'insufficient_funds'].includes(err.code)) {
 return { success: false, transactionId: null, error: err.message };
 }
 if (attempt < 3) {
 await new Promise(res => setTimeout(res, 200 * Math.pow(2, attempt)));
 }
 }
 }
 return { success: false, transactionId: null, error: lastError?.message ?? 'Unknown error' };
}
```

The difference is dramatic. The second prompt eliminates every TODO because there are no open questions left.

2. Use CLAUDE.md to Set Expectations

Create a `CLAUDE.md` file in your project root with clear instructions about TODO comments:

```markdown
Project Guidelines

Code Style
- Implement all functionality completely - do not leave TODO comments
- If something is unclear, ask the user before implementing
- Write production-ready code with proper error handling
- Include input validation for all user inputs
- Never scaffold functions with empty bodies or placeholder comments
- If a feature is out of scope for the current task, say so explicitly rather than leaving a TODO
```

This tells Claude Code upfront that placeholder comments aren't acceptable in your codebase. The CLAUDE.md file is loaded at the start of every session in that directory, so it reliably enforces this rule project-wide without you having to repeat it in every prompt.

3. Direct Prompt Modification

You can also address TODO generation directly in your prompts:

```
Write a function to process user data. Include all error handling,
input validation, and edge case handling. Do not leave any TODO
comments - implement everything completely or ask me clarifying
questions first.
```

Adding the phrase "or ask me clarifying questions first" is especially useful. It gives Claude Code a legitimate alternative to leaving placeholders, instead of generating a TODO, it will stop and ask you what behavior you want.

4. Use Skills to Enforce Complete Code

Create a custom skill that specifically addresses code completeness. In `~/.claude/skills/complete-code.md`:

```markdown
Complete Implementation Skill

When writing code, always:
1. Implement all functionality fully - no TODO or FIXME placeholders
2. Add proper error handling for all functions
3. Include input validation
4. Write meaningful comments only - never use "TODO" as a placeholder
5. If requirements are unclear, ask the user before guessing

If you find yourself wanting to add a TODO comment, instead either:
- Ask the user for clarification
- Implement a reasonable default behavior
- Write a comment explaining what needs to be decided, not as a placeholder
```

Invoke this skill with `/complete-code` when generating new code.

5. Break Large Tasks into Smaller Chunks

One underappreciated cause of TODO generation is task scope. When you ask Claude Code to "generate the entire user management module," it may produce dozens of functions and resort to placeholders to maintain forward momentum. Splitting the work prevents this:

```
Instead of:
"Generate the entire user management module"

Do this in sequence:
"Implement the createUser function with email validation,
 password hashing with bcrypt, and duplicate email checking"

"Now implement the updateUser function that accepts partial
 user fields, validates them, and updates the database"

"Implement the deleteUser function with soft-delete using
 a deletedAt timestamp"
```

Each function gets full attention, and there's no pressure to scaffold over gaps.

## Finding and Fixing Existing TODO Comments

If you already have TODO comments scattered throughout your codebase, you can use Claude Code to find and address them:

```bash
Search for TODO comments in your codebase
grep -r "TODO" --include="*.ts" --include="*.js" src/

Count them by file to prioritize
grep -r "TODO" --include="*.ts" --include="*.js" src/ -l | \
 xargs -I{} sh -c 'echo "$(grep -c TODO {}) {}"' | sort -rn
```

Then ask Claude Code to review each one systematically:

```
Review all the TODO comments in the codebase and either:
1. Implement them if you have enough context
2. Prioritize them by importance (critical, normal, low)
3. Remove them if they're no longer relevant
4. Convert them to GitHub issues if they require separate planning
```

You can also use Claude Code to do a bulk audit pass:

```
Read src/services/payment.ts. For each TODO comment:
- If it describes something trivially implementable, implement it now
- If it requires a business decision, add a comment saying "Decision needed: [description]"
- If the code already handles it implicitly, delete the TODO
```

## Comparison: Vague vs. Specific Prompts

| Scenario | Vague Prompt Result | Specific Prompt Result |
|---|---|---|
| Auth function | 5 TODOs for validation, tokens, errors | Fully implemented with all cases |
| API handler | TODO: handle errors, TODO: add logging | Try/catch with structured logging |
| Database query | TODO: add pagination | Offset/limit pagination included |
| Background job | TODO: implement retry | Exponential backoff with max attempts |
| Form parser | TODO: sanitize inputs | DOMPurify + allowlist validation |

The pattern is consistent: every TODO corresponds to something the model would have implemented if the prompt had specified it.

## Configuring Claude Code Behavior

While there's no global setting to disable TODO comments, you can influence behavior through:

- System prompts: Add instructions about TODO avoidance in your ~/.claude/settings.json using the `systemPrompt` field
- Project-specific CLAUDE.md files: Enforce standards per project, useful when different projects have different norms
- Custom skills: Create reusable rules for different project types (e.g., a `no-placeholders` skill for production code, a separate `scaffold` skill for early prototyping)
- Prompt templates: Keep a library of prompt templates that always include the "no TODOs" directive so you never forget

A practical ~/.claude/settings.json addition:

```json
{
 "systemPrompt": "When generating code, implement all functionality completely. Do not leave TODO comments as placeholders. If a requirement is ambiguous, ask clarifying questions before writing code."
}
```

## When TODO Comments Are Acceptable

Not all TODO comments are problematic. They're appropriate when:

- Tracking external API changes that are not yet released
- Marking deprecated functionality with a specific removal timeline (`// TODO: remove after v3.0 migration`)
- Noting technical debt with a linked issue number (`// TODO: #482 - optimize this query`)
- Documenting known limitations in third-party integrations that are outside your control
- Intentional scaffolding during early prototyping where you explicitly want placeholders

The issue arises when TODO becomes a default placeholder instead of a deliberate tracking mechanism. A good test: if you can't write a GitHub issue number next to the TODO within 24 hours of creating it, the comment shouldn't exist.

## Spotting the Pattern Before It Embeds

The fastest way to catch TODO inflation early is to add a pre-commit check:

```bash
#!/bin/sh
.git/hooks/pre-commit

TODO_COUNT=$(git diff --cached | grep "^+" | grep -c "TODO:")
if [ "$TODO_COUNT" -gt 0 ]; then
 echo "Warning: $TODO_COUNT new TODO comment(s) in staged changes."
 echo "Implement or remove them before committing."
 exit 1
fi
```

This is aggressive but effective. If your team prefers a softer approach, use a warning without `exit 1` so it surfaces during review without blocking the commit.

## Conclusion

Claude Code generating placeholder TODO comments typically indicates a gap between your expectations and the information provided. By improving context, using CLAUDE.md files, and creating custom skills, you can dramatically reduce or eliminate these placeholders. The goal is always production-ready code, and with the right prompting strategies, Claude Code can deliver exactly that.

The most reliable mental model: every TODO Claude Code generates represents a question it didn't know how to answer. Give it better inputs, and it won't need to ask.

Remember: TODO comments should be deliberate tracking tools, not AI-generated placeholders for unimplemented features.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-keeps-generating-placeholder-todo-comments)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



