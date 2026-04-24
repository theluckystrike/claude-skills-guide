---

layout: default
title: "Claude Code Cookbook (2026)"
description: "A practical collection of Claude Code cookbook recipes for developers and power users. Learn how to use Claude skills for PDF creation, frontend."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-cookbook-recipes-collection/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
# Claude Code Cookbook: Practical Recipes Collection

Claude Code transforms how developers approach coding tasks by providing specialized skills that handle complex workflows. This cookbook presents practical recipes you can implement immediately, covering document generation, frontend development, test-driven development, and knowledge management. Each recipe includes concrete examples, common pitfalls, and tips for integrating skills into real development pipelines.

## PDF Generation with the pdf Skill

The pdf skill streamlines document creation by converting markdown directly to formatted PDF files. This proves invaluable for generating reports, invoices, and technical documentation without leaving your development environment. Rather than exporting from Google Docs or wrestling with LaTeX, you stay in your terminal and produce polished output.

```yaml
---
name: pdf
description: Converts markdown documents to PDF files
---
```

To generate a PDF, invoke the pdf skill with your markdown content. The skill handles pagination, headers, and formatting automatically. This approach works particularly well for automated report generation in CI/CD pipelines.

```bash
Convert markdown to PDF
claude --print "/pdf --input report.md --output report.pdf"

With custom page size and margins
claude --print "/pdf --input report.md --output report.pdf --page-size A4 --margin 20mm"
```

The pdf skill supports custom styling through CSS, allowing you to match your organization's branding guidelines. You can specify page margins, font families, and header/footer templates within your skill configuration.

A realistic use case is generating weekly status reports. Imagine a `report.md` template that pulls from your project management tool's exported data:

```markdown
Sprint 24 Status Report. {{date}}

Completed This Sprint
- Feature: User authentication redesign
- Bug fix: Pagination offset on search results
- Infra: Migrated staging environment to Terraform

Blockers
None currently active.

Next Sprint Goals
1. Implement OAuth2 integration
2. Performance profiling on API endpoints
3. Update deployment runbooks
```

Running the pdf skill against this template produces a properly formatted PDF you can attach to an email or upload to a shared drive, without ever touching a word processor. In a CI/CD context, you might trigger this as part of a release job to auto-generate changelogs in PDF form for non-technical stakeholders.

## PDF Skill Comparison Table

| Approach | Setup Time | Formatting Control | Automation Friendly |
|---|---|---|---|
| Google Docs export | Low | Medium | No |
| LaTeX | High | Very High | Yes (complex) |
| Pandoc CLI | Medium | Medium | Yes |
| Claude pdf skill | Low | Medium-High | Yes |

The pdf skill wins on the combination of low setup friction and automation compatibility, making it the right default for most developer documentation pipelines.

## Frontend Design with frontend-design

Building user interfaces often requires iterating between design tools and code. The frontend-design skill bridges this gap by generating production-ready HTML, CSS, and JavaScript from design specifications.

```yaml
---
name: frontend-design
description: Generates responsive frontend components and layouts
---
```

A practical workflow involves describing your component requirements in plain language:

```
Create a responsive navigation bar with a hamburger menu for mobile.
The desktop view should show links: Home, About, Services, Contact.
Use a clean, modern aesthetic with a subtle shadow on scroll.
```

The frontend-design skill generates semantic HTML5 markup with scoped CSS, reducing the boilerplate typically required for responsive components. You can then refine the output using the edit_file tool for specific adjustments.

Here is an example of what the skill might produce for a card component:

```html
<article class="card">
 <img src="" alt="" class="card__image" />
 <div class="card__body">
 <h2 class="card__title"></h2>
 <p class="card__description"></p>
 <a href="#" class="card__cta">Learn more</a>
 </div>
</article>
```

```css
.card {
 border-radius: 8px;
 box-shadow: 0 2px 8px rgba(0,0,0,0.1);
 overflow: hidden;
 transition: box-shadow 0.2s ease;
}

.card:hover {
 box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.card__body {
 padding: 1.25rem;
}
```

This is semantic, accessible markup that follows BEM naming conventions. You are not starting from a blank file and you are not waiting on a designer handoff. For prototype-level work, the skill produces enough to hold a meeting or run a usability test.

The frontend-design skill is most effective when you give it enough constraints to work within. Specifying a design system (Bootstrap, Tailwind, Material) or a color palette produces more targeted output than asking for generic components.

## Test-Driven Development with tdd

The tdd skill implements test-driven development workflows by generating test files alongside your implementation code. This ensures your code remains testable and catches regressions early.

```yaml
---
name: tdd
description: Implements test-driven development workflows
---
```

The tdd skill follows the red-green-refactor cycle:

1. Red: Write a failing test describing the desired behavior
2. Green: Implement the minimum code to pass the test
3. Refactor: Improve code quality while maintaining test coverage

For JavaScript projects, the tdd skill generates Jest-compatible test files. For Python projects, it produces pytest configurations. This standardization means your test suite remains consistent across different modules.

```javascript
// Example test generated by tdd skill
describe('calculateTotal', () => {
 it('should sum all item prices correctly', () => {
 const items = [{ price: 10 }, { price: 20 }, { price: 15 }];
 expect(calculateTotal(items)).toBe(45);
 });

 it('should return 0 for empty array', () => {
 expect(calculateTotal([])).toBe(0);
 });

 it('should handle items with missing price field', () => {
 const items = [{ price: 10 }, { name: 'no price' }, { price: 15 }];
 expect(calculateTotal(items)).toBe(25);
 });
});
```

Notice the third test case. the one handling a missing `price` field. This is a class of edge case that developers frequently forget until a production bug surfaces. The tdd skill includes these boundary cases because it reasons about the contract of the function, not just the happy path.

The corresponding Python equivalent using pytest would look like:

```python
import pytest
from billing import calculate_total

def test_sums_all_item_prices():
 items = [{"price": 10}, {"price": 20}, {"price": 15}]
 assert calculate_total(items) == 45

def test_returns_zero_for_empty_list():
 assert calculate_total([]) == 0

def test_handles_missing_price_field():
 items = [{"price": 10}, {"name": "no price"}, {"price": 15}]
 assert calculate_total(items) == 25
```

One practical workflow is to describe a function's behavior in plain English to Claude, have the tdd skill generate the test file, then implement the function until all tests pass. This enforces a spec-first discipline without requiring you to write boilerplate test harnesses manually.

## When to Use tdd vs Writing Tests Manually

| Situation | Use tdd Skill | Write Manually |
|---|---|---|
| New utility functions | Yes | No |
| Complex business logic | Yes, as a starting point | Refine afterward |
| Integration tests | Partial help | Manual is often clearer |
| Tests for legacy undocumented code | Yes | Often necessary |
| Security-sensitive validation | Yes, but review carefully | Always review |

## Memory Management with supermemory

Long-running projects accumulate valuable context that you should not lose between sessions. The supermemory skill persists conversation context, code decisions, and project knowledge across sessions.

```yaml
---
name: supermemory
description: Manages persistent memory and context for projects
---
```

Using supermemory involves explicitly saving important context:

```
@superstore Save this decision: We chose PostgreSQL over MongoDB for the user database because of better ACID compliance requirements.
```

The skill organizes memories using tags and timestamps, making retrieval straightforward:

```
@superstore Retrieve all decisions related to database choices.
```

This proves particularly valuable when returning to a project after weeks or months, eliminating the need to re-explain architectural decisions to Claude.

A more complete example of what you might store:

```
@superstore Save: The checkout flow uses Stripe Elements, not the redirect-based Checkout. Reason: UX requirement to keep users on our domain during payment. Key files: src/components/CheckoutForm.tsx, server/routes/stripe.js.

@superstore Save: We use a job queue (BullMQ + Redis) for sending transactional emails. Do not use synchronous nodemailer calls in request handlers. See: src/workers/emailWorker.js.
```

When you return to this project, a single retrieval call surfaces all of this context immediately:

```
@superstore Retrieve all architectural decisions for the checkout and email systems.
```

The practical effect is that you spend less time re-reading code to remember why decisions were made. For teams, this also creates lightweight decision documentation that lives alongside the code rather than buried in a wiki that nobody updates.

## What Is Worth Storing in supermemory

Not every decision needs to be persisted. Here is a simple heuristic:

- Store decisions that would take more than five minutes to reconstruct from code reading alone.
- Store the *why*, not just the *what*. the what is already in source control.
- Store pointers to the key files affected by a decision so retrieval includes actionable context.
- Do not store things that change frequently or that are self-evident from the code.

## Combining Skills for Complex Workflows

Individual skills become powerful when combined. Consider a workflow where supermemory remembers project context, tdd ensures test coverage, and pdf generates documentation:

1. Start with supermemory to load previous architectural decisions
2. Use tdd to implement a new feature with tests
3. Generate API documentation with the docx skill
4. Export user guides as PDF using the pdf skill

This chain eliminates context-switching and maintains consistency across deliverables. Each skill handles its domain while passing results to the next tool in your workflow.

A concrete example: you are building a billing module. Before writing a single line of code, you invoke supermemory to retrieve past decisions about payment processing. You discover the team previously decided against storing card numbers locally. This context shapes the tests you write with tdd. your test suite will include tests that verify no raw card data touches your database layer. Once the module is shipped, you use pdf to generate a compliance summary for your security team.

Without supermemory, that prior decision is rediscovered only after writing code that needs to be ripped out. The skill chain prevents that regression before it happens.

## Skill Composition Patterns

Advanced users compose skills using the sequential tool calling pattern. Instead of invoking skills individually, you can specify a sequence:

```yaml
---
name: feature-pipeline
description: Implements a complete feature workflow
---
```

A feature pipeline might look like this in practice:

1. Load context: `@superstore Retrieve decisions for the orders module`
2. Scaffold tests: `/tdd Create tests for the cancelOrder function given these requirements: ...`
3. Implement: Claude writes the implementation until tests pass
4. Document: `/pdf Generate an API reference for the cancelOrder endpoint`
5. Save decision: `@superstore Save: cancelOrder uses soft deletes, not hard deletes. Reason: audit requirements.`

Each step feeds into the next. The pattern becomes a repeatable template for any feature, reducing the cognitive overhead of context-switching between tasks.

This approach standardizes your development process while allowing flexibility for project-specific requirements. Teams can codify their own pipeline variations without modifying the underlying skills.

## Performance Optimization Tips

When using multiple skills in a session, consider these optimization strategies:

Declare tool requirements explicitly: Each skill should specify only the tools it needs. This reduces token consumption and improves response times. A pdf skill does not need bash access; a tdd skill does not need file system access beyond reading and writing test files.

Batch related operations: Rather than invoking a skill repeatedly for similar tasks, combine operations into a single invocation when possible. Generating five test files in one tdd invocation is more efficient than five separate calls.

Use memory strategically: Save context only when it provides future value. Not every decision needs persistence. The overhead of querying supermemory for trivial details outweighs the benefit; reserve it for decisions that have a multi-week or multi-month shelf life.

Profile before optimizing: If skill chains feel slow, identify which step consumes the most time before restructuring. Often the bottleneck is a single verbose skill invocation, not the chain architecture itself.

## Conclusion

These recipes represent starting points for integrating Claude skills into your development workflow. The combination of specialized skills like pdf, frontend-design, tdd, and supermemory creates a flexible toolkit adaptable to various project requirements. Start with the recipes that address your immediate needs, then explore skill composition as your workflow matures.

The most durable habit is consistent use of supermemory across every project. Once you establish the practice of recording architectural decisions and their rationale, the other skills become more effective because Claude always has the context it needs to make good recommendations. The cookbook grows richer the more deliberately you feed it.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-cookbook-recipes-collection)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

---

Related Reading

- [Agentic AI Coding Tools Comparison 2026: A Practical.](/agentic-ai-coding-tools-comparison-2026/)
- [AI Code Assistant Chrome Extension: Practical Guide for.](/ai-code-assistant-chrome-extension/)
- [AI Tab Organizer Chrome Extension: A Practical Guide for.](/ai-tab-organizer-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


