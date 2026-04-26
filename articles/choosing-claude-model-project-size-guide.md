---
layout: default
title: "Choosing the Right Claude Model for Your Project Size (2026)"
description: "Small projects under 10K lines need different Claude models than 100K+ monorepos. Decision trees for Haiku, Sonnet, and Opus based on codebase size."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /choosing-claude-model-project-size-guide/
reviewed: true
categories: [model-selection]
tags: [claude, claude-code, model-selection, project-size, sonnet, opus, haiku]
---

# Choosing the Right Claude Model for Your Project Size

A 500-line CLI tool and a 200,000-line monorepo are different worlds for Claude Code. The CLI tool fits entirely in context -- any model can reason about the whole thing. The monorepo forces Claude to work with fragments, making model choice critical for whether it sees enough context to make correct decisions. Use the [Model Selector](/model-selector/) for instant recommendations, or follow the decision framework below.

## Small Projects (Under 10K Lines)

**Characteristics**: Single-purpose apps, CLI tools, libraries, small APIs. The entire codebase fits within Claude's context window with room to spare.

**Default model**: Sonnet 4.6

At this scale, the entire codebase consumes 15,000-30,000 tokens. Claude can hold the complete project in context while still having 170K+ tokens for conversation. Sonnet handles every task type well because it can see everything at once.

```
# Small project model allocation
Daily tasks (15-20 interactions):
├── Sonnet: 80% — feature work, bug fixes, tests, refactoring
├── Haiku: 15% — boilerplate, type stubs, simple renames
└── Opus: 5% — initial architecture decisions, complex algorithms
```

**When to use Opus on small projects**: Only for the initial architecture setup and for algorithmic problems where correctness matters more than speed. Once the architecture is set, Sonnet handles day-to-day work.

**Cost profile**: $1.50-3.00/day with Sonnet-primary strategy.

### Small Project Example

Building a Node.js CLI tool for parsing CSV files:

```bash
# Session 1: Architecture (Opus — 1 interaction, $0.45)
claude --model opus "Design the module structure for a CLI tool that
parses CSV files, validates schemas, and outputs JSON. Include error
handling strategy and config file format."

# Session 2-20: Implementation (Sonnet — 18 interactions, $1.62)
claude "Implement the CSV parser module with streaming support"
claude "Add Zod schema validation for column types"
claude "Write tests for the parser with edge cases"

# Session 21-25: Polish (Haiku — 5 interactions, $0.015)
claude --model haiku "Add JSDoc comments to all exported functions"
claude --model haiku "Generate the --help text for all subcommands"
```

Total daily cost: ~$2.10 with high-quality output across all tasks.

## Medium Projects (10K-100K Lines)

**Characteristics**: Full-stack applications, multi-package libraries, established APIs with 20+ endpoints. Too large for Claude to hold the entire codebase, but most tasks stay within 2-3 related files.

**Default model**: Sonnet 4.6 with tactical Opus upgrades

At this scale, Claude works with file subsets. A well-structured CLAUDE.md becomes essential -- it provides the architectural context that Claude can't infer from the few files it sees.

```
# Medium project model allocation
Daily tasks (25-35 interactions):
├── Sonnet: 65% — standard features, bug fixes, tests
├── Haiku: 20% — boilerplate, migrations, type updates
├── Opus: 15% — cross-cutting features, complex debugging
```

**When to use Opus on medium projects**: Cross-cutting features that touch 5+ files, bugs where the symptom is far from the cause, and data model changes that affect multiple services.

**Cost profile**: $4.00-8.00/day with the blended strategy.

### Medium Project CLAUDE.md Requirements

At this scale, your CLAUDE.md needs architecture mapping so Claude can navigate without seeing every file:

```markdown
# Architecture Map (CLAUDE.md section)
## Data Flow
Request → middleware/auth.ts → routes/{resource}.ts
        → services/{resource}.ts → repositories/{resource}.ts → DB

## Key Conventions
- Services never import from other services (use events)
- Repositories are the only files that import from drizzle
- All API responses follow: { data: T, meta: { page, total } }
- Error responses follow: { error: string, code: string }

## High-Traffic Paths (be careful here)
- /api/analytics/events — 10K req/min, batched writes
- /api/auth/session — called on every request, heavily cached
- /api/search — Elasticsearch, not PostgreSQL
```

This map costs 200 tokens per session but saves 2,000+ tokens of Claude asking "where is X?" or making wrong assumptions about architecture.

## Large Projects (100K+ Lines)

**Characteristics**: Monorepos, enterprise applications, platforms with 50+ modules. Claude can only see a small fraction of the codebase at once.

**Default model**: Sonnet 4.6 with frequent Opus escalation

Large projects are where model choice matters most. Claude operates with limited visibility, so the model's ability to reason about unseen code from context clues becomes critical.

```
# Large project model allocation
Daily tasks (30-50 interactions):
├── Sonnet: 55% — scoped features, tests, package-level work
├── Opus: 25% — cross-package changes, API design, debugging
├── Haiku: 20% — boilerplate, config updates, type generation
```

**When to use Opus on large projects**: Any task that spans multiple packages, API contract changes, database schema migrations, dependency upgrades that affect multiple consumers, and incident debugging.

**Cost profile**: $8.00-18.00/day with the blended strategy. Pure Opus would cost $30-50/day.

### Large Project Context Strategy

With 100K+ lines, you can't load the whole project. Use CLAUDE.md to give Claude a map:

```markdown
# Monorepo Map (CLAUDE.md section)
## Packages (dependency order)
1. @app/types — shared TypeScript types (no dependencies)
2. @app/config — shared configuration (depends: types)
3. @app/db — database client + migrations (depends: config)
4. @app/auth — authentication service (depends: db, config)
5. @app/api — REST API server (depends: auth, db)
6. @app/web — Next.js frontend (depends: types, config)
7. @app/admin — Admin dashboard (depends: types, config)
8. @app/workers — Background job processors (depends: db, config)

## Cross-Package Rules
- Changes to @app/types require checking ALL downstream consumers
- Changes to @app/db/schema require a migration file
- @app/web and @app/admin never import from each other
- @app/workers runs in a separate process — no shared state with api
```

This 20-line map gives Opus the system-level view it needs to make correct cross-package decisions.

## Decision Tree by Project Size

```
What's your project size?
├── Under 10K lines
│   ├── Architecture phase → Opus (1-2 sessions)
│   └── Everything else → Sonnet (occasional Haiku for boilerplate)
├── 10K-100K lines
│   ├── Cross-cutting feature → Opus
│   ├── Bug spanning 3+ files → Opus
│   ├── Standard feature/bug → Sonnet
│   └── Boilerplate/types → Haiku
└── 100K+ lines
    ├── Cross-package change → Opus
    ├── Schema/API change → Opus
    ├── Package-scoped work → Sonnet
    └── Config/types/stubs → Haiku
```

## Try It Yourself

Enter your project details into the [Model Selector](/model-selector/) to get a personalized model recommendation. It factors in project size, task type, and budget constraints to suggest the optimal model and estimate costs for your specific workflow.

<details>
<summary>Does project age matter for model selection?</summary>
Yes. New projects benefit more from Opus during the architecture phase (first 2-4 weeks). Mature projects with established patterns need Opus less because conventions are already set in the CLAUDE.md, and Sonnet can follow them reliably.
</details>

<details>
<summary>What if I can only afford one model?</summary>
Use Sonnet. It covers 80% of coding tasks well across all project sizes. The gap between Sonnet and Opus matters most for architectural decisions and complex debugging, which you can handle by writing more detailed prompts instead of switching models.
</details>

<details>
<summary>Should I use different models in CI/CD pipelines?</summary>
Use Haiku for automated tasks in CI -- code review comments, changelog generation, test generation. These are well-defined, repetitive tasks where Haiku's speed and cost advantages matter more than Opus's reasoning depth.
</details>

<details>
<summary>How does project language affect model choice?</summary>
Strongly-typed languages (TypeScript, Rust, Go) get more value from Sonnet because the type system constrains Claude's output. Dynamically-typed languages (Python, JavaScript) benefit more from Opus because there are fewer guardrails and more room for subtle bugs.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does project age matter for Claude model selection?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. New projects benefit more from Opus during the architecture phase (first 2-4 weeks). Mature projects with established patterns need Opus less because conventions are already set in the CLAUDE.md, and Sonnet can follow them reliably."
      }
    },
    {
      "@type": "Question",
      "name": "What if I can only afford one Claude model?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use Sonnet. It covers 80% of coding tasks well across all project sizes. The gap between Sonnet and Opus matters most for architectural decisions and complex debugging, which you can handle by writing more detailed prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Should I use different Claude models in CI/CD pipelines?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use Haiku for automated tasks in CI -- code review comments, changelog generation, test generation. These are well-defined, repetitive tasks where Haiku's speed and cost advantages matter more than Opus's reasoning depth."
      }
    },
    {
      "@type": "Question",
      "name": "How does programming language affect Claude model choice?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Strongly-typed languages (TypeScript, Rust, Go) get more value from Sonnet because the type system constrains Claude's output. Dynamically-typed languages (Python, JavaScript) benefit more from Opus because there are fewer guardrails and more room for subtle bugs."
      }
    }
  ]
}
</script>

## Related Guides

- [Model Selector](/model-selector/) -- Get personalized model recommendations
- [Token Estimator](/token-estimator/) -- Estimate context usage for your project
- [Claude Code Cost Calculator](/calculator/) -- Calculate monthly costs by model mix
- [Claude Code Starter Guide](/starter/) -- Initial setup for any project size
- [Claude Code Configuration Guide](/configuration/) -- Configure Claude Code for your project
