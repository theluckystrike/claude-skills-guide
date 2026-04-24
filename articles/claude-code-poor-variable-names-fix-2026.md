---
title: "Fix Claude Code Poor Variable Naming (2026)"
description: "Fix Claude Code generating vague variable names like 'data' and 'result' by adding naming rules and domain vocabulary to CLAUDE.md."
permalink: /claude-code-poor-variable-names-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Poor Variable Naming (2026)

Claude Code names a variable `data` when it holds a list of unpaid invoices. It calls a function `process` when it calculates sales tax. Vague names force every reader to trace the code to understand what things are.

## The Problem

Common naming issues in Claude Code output:
- Generic names: `data`, `result`, `response`, `item`, `temp`
- Single-letter variables beyond loop iterators: `x`, `d`, `r`
- Misleading names: `userList` for something that is actually a Map
- Inconsistent naming across related functions
- Abbreviations that are not project-standard: `usr`, `btn`, `msg`

## Root Cause

Claude Code generates names that are technically correct but lack domain specificity. It calls everything `data` because everything is data. The model does not know your domain vocabulary — whether a "user" is called a "member," "customer," "patient," or "tenant" in your system.

## The Fix

Use the domain vocabulary approach from [claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow), which demonstrates how to embed domain-specific terminology into Claude Code skills. For academic projects, it enforces terms like "estimator," "treatment effect," and "panel data" — you do the same for your domain.

### Step 1: Define Domain Vocabulary

```markdown
## Domain Vocabulary
This is a SaaS billing platform. Use these terms:

| Concept | Correct Term | WRONG Terms |
|---------|-------------|-------------|
| Person paying | customer | user, member, person |
| Monthly charge | subscription | plan, membership |
| One-time charge | invoice | bill, receipt, charge |
| Payment failure | dunning | retry, failure |
| Upgrade/downgrade | plan change | subscription update |
```

### Step 2: Add Naming Rules

```markdown
## Variable Naming Rules
- Name describes WHAT it holds, not WHERE it came from
  - YES: unpaidInvoices, activeCustomers, monthlyRevenue
  - NO: data, result, response, queryResult
- Boolean variables: is/has/can/should prefix
  - YES: isSubscriptionActive, hasPaymentMethod
  - NO: active, valid, found
- Collections: plural nouns describing contents
  - YES: failedPayments, expiredTrials
  - NO: list, items, arr
- Functions: verb + specific noun
  - YES: calculateProration, sendDunningEmail
  - NO: process, handle, doWork, run
```

### Step 3: Provide Examples

```markdown
## Naming Examples From This Codebase
// Good — from src/services/billing.ts
const overdueInvoices = await getInvoicesByStatus('overdue');
const dunningSchedule = buildDunningSchedule(overdueInvoices);
const emailsSent = await sendDunningEmails(dunningSchedule);

// Bad — what we want to avoid
const data = await getInvoices();
const result = process(data);
const sent = await send(result);
```

## CLAUDE.md Code to Add

```markdown
## Naming Quality Check
After writing any function, verify:
1. Could someone understand each variable without reading the assignment?
2. Does each function name say what it does AND what it acts on?
3. Are domain terms from the vocabulary table used consistently?
4. Are there zero instances of: data, result, temp, item, thing, stuff?
```

## Verification

1. Ask Claude Code to write a function for processing refunds
2. Check variable names: Are they specific (refundAmount, originalInvoice)?
3. Check function name: Does it say what it does (calculateRefundAmount)?
4. Check: Zero generic names like `data` or `result`?

## Prevention

Add an ESLint rule that flags overly generic names:

```js
// .eslintrc.js
rules: {
  'id-denylist': ['error', 'data', 'result', 'item', 'temp', 'val', 'cb']
}
```

The [claude-code-templates](https://github.com/davila7/claude-code-templates) library includes naming convention templates for different domains.

For broader code quality rules, see our [Claude Code best practices guide](/karpathy-skills-vs-claude-code-best-practices-2026/). For team-wide convention enforcement, read the [team conventions fix](/claude-code-doesnt-match-team-conventions-fix-2026/). Browse domain-specific skills in the [skills directory](/claude-skills-directory-where-to-find-skills/).
