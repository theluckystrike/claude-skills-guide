---
layout: default
title: "Claude Code Duplicate Code Refactoring (2026)"
description: "Find and eliminate duplicate code with Claude Code. Automated detection, refactoring patterns, and extraction strategies for cleaner codebases."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, refactoring, duplicate-code, code-quality]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-code-duplicate-code-refactoring-guide/
last_tested: "2026-04-21"
geo_optimized: true
---

# Claude Code Duplicate Code Refactoring Guide

Duplicate code is one of the most common code smells that quietly undermines software maintainability. When the same logic appears in multiple places, you create maintenance nightmares: bug fixes require identical changes in several locations, and developers spend time understanding which version is the "correct" one. This guide shows you how to use Claude Code and its skill ecosystem to identify, analyze, and eliminate duplicate code systematically.

## Understanding Duplicate Code Patterns

Duplicate code manifests in several forms. The most obvious is exact duplication, identical blocks of code copied and pasted across files. More insidious are structural duplicates: different code that performs the same logical operation, or similar algorithms with minor variations. Both types create technical debt.

Martin Fowler's original taxonomy identifies three levels of code duplication, and understanding them shapes how you approach each fix:

| Duplication Type | Description | Example | Refactoring Approach |
|---|---|---|---|
| Type 1 (Exact) | Identical code blocks | Copy-pasted functions | Extract Method |
| Type 2 (Renamed) | Same structure, different variable names | Two loops doing the same work | Extract + Parameterize |
| Type 3 (Near-Miss) | Similar logic with small variations | Validation functions sharing 80% of logic | Template Method or Strategy |
| Type 4 (Semantic) | Different code, same business intent | Two formatters that produce equivalent output | Consolidate + Test |

Before refactoring, you need visibility into what you're dealing with. Claude Code provides several approaches to analyze your codebase. The most effective strategy combines pattern matching with semantic analysis, asking Claude not just "what looks the same" but "what does the same thing."

A common mistake is treating duplicate code purely as a text-matching problem. Two functions with different variable names and a swapped condition can still represent complete duplicates at the business logic level. Claude Code excels at this semantic layer because it reads intent, not just syntax.

## Using Claude Code Skills for Detection

Claude Code's skill system extends its capabilities for specific tasks. When working with duplicate detection, you can invoke skills directly within your development workflow.

## Pattern Analysis with Code Search

The frontend-design skill includes utilities for component pattern analysis. While primarily focused on UI development, its pattern-matching capabilities extend to identifying repeated component logic:

```
/frontend-design analyze components for duplicate rendering logic
```

For general codebases, use Claude Code's built-in analysis alongside community skills. The code-analysis skill (available from community repositories) provides cross-file duplicate detection:

```
/code-analysis find duplicate functions across the src/ directory
```

You can also use Claude Code directly in the terminal for targeted queries. This is especially useful when you suspect a specific module has grown with duplicated utilities:

```bash
claude -p "Read every file in src/utils/ and identify any functions that perform equivalent operations, even if they have different names or minor implementation differences. List them grouped by what they do."
```

This approach works well for medium-sized codebases. For very large codebases, narrow the scope to a subsystem first, then expand.

## Semantic Duplicate Detection

True duplicate detection goes beyond text matching. The tdd skill can help by analyzing test coverage patterns, if the same test logic appears across multiple test files, the code under test likely has duplication issues:

```
/tdd identify test patterns that suggest code duplication in the codebase
```

Another effective angle is prompting Claude Code to look for functions that are always called together or that share the same input/output shapes:

```bash
claude -p "Look at src/api/ and identify any response-formatting functions that take similar inputs and produce similar outputs. Show me which pairs is merged into a single parameterized function."
```

## Using the MEMORY Skill for Cross-Session Detection

If your refactoring spans multiple sessions, the supermemory skill lets you persist findings:

```
/supermemory store: Found duplicate date formatting logic in src/utils/dates.js (line 44) and src/components/EventCard.jsx (line 12). Both format ISO dates to "MMM D, YYYY". Plan to extract to shared formatDate() in src/utils/dates.js.
```

On your next session, you can retrieve the context:

```
/supermemory recall duplicate code findings from last session
```

This is especially valuable on team projects where refactoring spans multiple days and you need continuity between Claude Code sessions.

## Refactoring Strategies

Once you've identified duplicates, the refactoring approach depends on the duplication type and code context.

## Extract Method Pattern

The most common refactoring technique involves extracting repeated logic into a shared function:

```python
Before: Duplicate calculation logic
def calculate_order_total(items):
 subtotal = sum(item['price'] * item['quantity'] for item in items)
 tax = subtotal * 0.08
 shipping = 5.99 if subtotal < 50 else 0
 return subtotal + tax + shipping

def calculate_cart_total(cart_items):
 subtotal = sum(item['price'] * item['quantity'] for item in cart_items)
 tax = subtotal * 0.08
 shipping = 5.99 if subtotal < 50 else 0
 return subtotal + tax + shipping
```

Extract the common logic:

```python
def calculate_subtotal(items):
 return sum(item['price'] * item['quantity'] for item in items)

def apply_tax_and_shipping(subtotal, tax_rate=0.08, free_shipping_threshold=50, base_shipping=5.99):
 tax = subtotal * tax_rate
 shipping = base_shipping if subtotal < free_shipping_threshold else 0
 return subtotal + tax + shipping

def calculate_order_total(items):
 return apply_tax_and_shipping(calculate_subtotal(items))

def calculate_cart_total(cart_items):
 return apply_tax_and_shipping(calculate_subtotal(cart_items))
```

Note the second extraction: the tax and shipping logic is now also parameterized, which makes future business rule changes (different tax rates, different free-shipping thresholds) a single-location edit. Claude Code can suggest this second level of extraction if you prompt it:

```bash
claude -p "Review the extracted apply_tax_and_shipping function. Are there any hardcoded values that should be parameters to make this function more reusable?"
```

## Template Method Pattern

When duplicate code follows similar steps with variations, use the template method pattern:

```javascript
// Before: Similar but not identical validation logic
function validateUserRegistration(data) {
 if (!data.email.includes('@')) return false;
 if (data.password.length < 8) return false;
 if (!data.username) return false;
 return true;
}

function validateUserProfile(data) {
 if (!data.email.includes('@')) return false;
 if (data.password && data.password.length < 8) return false;
 if (!data.displayName) return false;
 return true;
}

// Refactored: Extract common validation rules into composable validators
const validators = {
 email: (value) => value && value.includes('@'),
 password: (value) => !value || value.length >= 8,
 requiredString: (value) => typeof value === 'string' && value.trim().length > 0
};

function runValidators(data, rules) {
 return Object.entries(rules).every(([field, validator]) => validator(data[field]));
}

function validateUserRegistration(data) {
 return runValidators(data, {
 email: validators.email,
 password: validators.password,
 username: validators.requiredString
 });
}

function validateUserProfile(data) {
 return runValidators(data, {
 email: validators.email,
 password: validators.password,
 displayName: validators.requiredString
 });
}
```

This pattern has an added benefit: you can now write a single test suite for `runValidators` and trust that both registration and profile validation share the same plumbing. Future validators (phone number, postal code, etc.) slot in without duplicating the validation loop.

## Extract Class Pattern for Stateful Duplication

Duplication isn't limited to functions. When you see two classes or modules that maintain similar state and expose similar methods, the Extract Class pattern applies:

```typescript
// Before: Two API clients with duplicated request handling
class UserApiClient {
 private baseUrl = '/api/users';

 async get(id: string) {
 const res = await fetch(`${this.baseUrl}/${id}`);
 if (!res.ok) throw new Error(`Request failed: ${res.status}`);
 return res.json();
 }

 async list() {
 const res = await fetch(this.baseUrl);
 if (!res.ok) throw new Error(`Request failed: ${res.status}`);
 return res.json();
 }
}

class OrderApiClient {
 private baseUrl = '/api/orders';

 async get(id: string) {
 const res = await fetch(`${this.baseUrl}/${id}`);
 if (!res.ok) throw new Error(`Request failed: ${res.status}`);
 return res.json();
 }

 async list() {
 const res = await fetch(this.baseUrl);
 if (!res.ok) throw new Error(`Request failed: ${res.status}`);
 return res.json();
 }
}

// After: Shared base client
class ApiClient {
 constructor(private baseUrl: string) {}

 async get(id: string) {
 const res = await fetch(`${this.baseUrl}/${id}`);
 if (!res.ok) throw new Error(`Request failed: ${res.status}`);
 return res.json();
 }

 async list() {
 const res = await fetch(this.baseUrl);
 if (!res.ok) throw new Error(`Request failed: ${res.status}`);
 return res.json();
 }
}

const userApi = new ApiClient('/api/users');
const orderApi = new ApiClient('/api/orders');
```

When you find this pattern in a large codebase, ask Claude Code to find all similar client classes in one pass:

```bash
claude -p "Search src/api/ for any class that has get() and list() methods calling fetch(). List them with file paths and line numbers so I can evaluate which ones should extend a shared base class."
```

## Consolidating Duplicate React Components

Frontend codebases are especially prone to near-duplicate components. Two card components that render the same structure with different titles and colors are a clear Extract pattern target:

```jsx
// Before: ProductCard and ServiceCard share 90% of markup
function ProductCard({ title, price, image, onBuy }) {
 return (
 <div className="card card--product">
 <img src={image} alt={title} />
 <h3>{title}</h3>
 <p className="price">${price}</p>
 <button onClick={onBuy}>Buy Now</button>
 </div>
 );
}

function ServiceCard({ title, rate, image, onBook }) {
 return (
 <div className="card card--service">
 <img src={image} alt={title} />
 <h3>{title}</h3>
 <p className="price">${rate}/hr</p>
 <button onClick={onBook}>Book Now</button>
 </div>
 );
}

// After: Single configurable Card component
function Card({ title, image, priceLabel, actionLabel, onAction, variant }) {
 return (
 <div className={`card card--${variant}`}>
 <img src={image} alt={title} />
 <h3>{title}</h3>
 <p className="price">{priceLabel}</p>
 <button onClick={onAction}>{actionLabel}</button>
 </div>
 );
}

// Usage stays expressive
function ProductCard({ title, price, image, onBuy }) {
 return <Card title={title} image={image} priceLabel={`$${price}`} actionLabel="Buy Now" onAction={onBuy} variant="product" />;
}

function ServiceCard({ title, rate, image, onBook }) {
 return <Card title={title} image={image} priceLabel={`$${rate}/hr`} actionLabel="Book Now" onAction={onBook} variant="service" />;
}
```

The frontend-design skill can suggest this pattern automatically when you describe the component structure:

```
/frontend-design I have ProductCard and ServiceCard that share the same HTML structure. Suggest how to consolidate them into a single configurable component while preserving the existing API.
```

## Automating the Workflow

The real power comes from integrating duplicate detection into your development workflow. Here's a practical approach:

## Pre-Commit Checks

Create a workflow that runs before commits to catch duplication before it gets merged:

```bash
Run duplicate detection against recently changed files
git diff --name-only HEAD | xargs -I{} claude -p "Review {} for any code that duplicates logic already present elsewhere in the src/ directory. If you find duplicates, describe the location and suggest an extraction."
```

You can also build a dedicated script that runs on every pull request:

```bash
#!/bin/bash
check-duplicates.sh
CHANGED=$(git diff --name-only origin/main...HEAD)

claude -p "Review the following changed files for duplicate code:
$CHANGED

For each file, check whether any functions or logic blocks duplicate something already present in the codebase. Output a summary with: file path, duplicate description, suggested fix."
```

## Documentation Generation

After refactoring, use the pdf skill to generate documentation of changes:

```
/pdf create refactoring report showing removed duplicates and extracted methods
```

This creates an audit trail for future maintainers. The report is especially useful when onboarding new developers who need to understand why a shared utility exists and which previously separate functions it replaced.

## Knowledge Management

The supermemory skill helps maintain institutional knowledge about refactoring decisions:

```
/supermemory store: Refactored calculate_* functions to use shared calculate_subtotal in utils/pricing.js. Before: 3 duplicate implementations across orders.py, cart.py, invoice.py. After: single source of truth with parameterized tax and shipping rates.
```

This ensures team members understand why refactoring occurred. Without this context, future developers sometimes re-introduce duplication because they don't realize the shared utility exists.

## Generating a Refactoring Checklist

Use the docx skill to maintain a living refactoring checklist for the project:

```
/docx create refactoring decision log with sections: identified duplicates, extraction plan, files affected, test status, completion date
```

## Comparing Approaches: When to Refactor vs. Accept Duplication

Not all duplication should be eliminated. The rule of three is a useful heuristic: tolerate the first copy, note the second, remove the third. But context matters:

| Scenario | Refactor? | Reason |
|---|---|---|
| Same calculation in 3+ files | Yes | Clear Extract Method candidate |
| Similar logic with diverging business rules | No | Accidental similarity; they will diverge further |
| Two test files with identical setup | Yes | Extract shared fixture or factory |
| Two API clients with same retry logic | Yes | Extract shared HTTP utility |
| Two UI components that look similar but serve different domains | Maybe | Evaluate how often they change together |
| Two parsers for similar but distinct data formats | No | Merging may introduce fragility |

A useful prompt for borderline cases:

```bash
claude -p "I have two functions that look similar: [paste both]. Evaluate whether they represent genuine duplication (same business logic, will change together) or accidental similarity (happen to look alike but serve different purposes and might diverge). Recommend refactor or leave separate."
```

Claude Code is particularly good at this kind of nuanced evaluation because it can reason about the business context embedded in variable names, comments, and surrounding code.

## Measuring Success

Track your refactoring progress with concrete metrics:

- Lines of code duplicated: Measure before and after using tools like `jscpd` or `pylint --duplicate-code`
- Change propagation frequency: How often do you make identical changes in multiple places?
- Test coverage: After extraction, verify tests still pass and coverage hasn't dropped
- Code review time: Does maintenance become faster? Ask reviewers to note when they spot duplication risk
- Bug recurrence rate: Bugs that appear in one place and then reappear in another are a sign of unaddressed duplication

The xlsx skill can generate tracking spreadsheets:

```
/xlsx create refactoring metrics tracker with columns: file, duplication type, lines before, lines after, lines saved, extraction target, status, date
```

Review this tracker weekly during active cleanup phases. A visual drop in "lines duplicated" is satisfying and keeps the effort visible to stakeholders who might otherwise see refactoring as invisible work.

## Best Practices

1. Start small: Focus on obvious duplicates first before tackling semantic duplicates. A 10-line exact duplicate is a quick win; a subtle structural duplicate across three services takes careful analysis.

2. Test first: Ensure existing tests pass before and after refactoring. If tests don't exist for the duplicated code, write characterization tests before extracting. These tests lock down current behavior so you can safely consolidate.

3. Commit frequently: Small, atomic commits make rollback easier if issues arise. A good commit sequence: (1) add tests for duplicated behavior, (2) extract shared function, (3) update all call sites, (4) remove old implementations.

4. Document intent: Use the docx skill to maintain refactoring documentation.

 ```
 /docx create refactoring decision log documenting why each extraction was made
 ```

5. Communicate with your team: Duplicate code that's been in the codebase for years is referenced in documentation, linked from tickets, or expected by other developers. Announce extractions in your team channel before merging.

6. Don't over-generalize: The goal is removing duplication, not creating abstract frameworks. An extracted function with 8 parameters to handle every edge case often becomes harder to maintain than the original duplicates. If you're adding lots of flags and conditionals, step back and reconsider whether the duplication is actually meaningful.

7. Use Claude Code iteratively: Paste your extracted function back into Claude Code and ask it to suggest further simplifications:

 ```bash
 claude -p "Here is a function I just extracted from duplicate code: [paste function]. Is it doing too much? Could it be split further? Are there any remaining hardcoded values that should be parameters?"
 ```

## Conclusion

Duplicate code doesn't have to be a maintenance burden. By using Claude Code's skill ecosystem, combining detection capabilities with systematic refactoring, you can progressively improve code quality. The key is building detection into your workflow, choosing the right refactoring pattern for the type of duplication you're dealing with, and documenting decisions so future maintainers understand the intent behind every shared utility.

The comparison table approach is worth building into your team's workflow: when you find potential duplication, evaluate whether it's genuine duplication or accidental similarity before reaching for the Extract Method. The rule of three gives you a practical threshold. And the iterative prompting approach with Claude Code, detect, extract, simplify, verify, turns what used to be a tedious manual audit into a disciplined, repeatable process.

Start with one duplicated function today. Extract it, test it, and notice how much easier subsequent changes become. That's the compounding benefit of eliminating duplicate code: each refactoring makes the next one simpler.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-duplicate-code-refactoring-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Code Smell Identification Guide](/claude-code-for-code-smell-detection-workflow-guide/). Duplicate code is a classic code smell
- [How to Make Claude Code Follow DRY and SOLID Principles](/how-to-make-claude-code-follow-dry-solid-principles/). DRY principle directly addresses duplicate code
- [Claude Code Test Driven Refactoring Guide](/claude-code-test-driven-refactoring-guide/). Tests protect duplicate code refactors
- [Claude Code Technical Debt Tracking Workflow](/claude-code-technical-debt-tracking-workflow/). Duplicate code is a measurable debt source

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Stop Claude Code Creating Duplicate Code (2026)](/claude-code-creates-duplicate-code-fix-2026/)
