---
layout: default
title: "Start New Project with Claude Code (2026)"
description: "Step-by-step guide to starting a new project with Claude Code. From empty directory to running application in minutes."
permalink: /start-new-project-with-claude-code-2026/
date: 2026-04-26
---

# Start New Project with Claude Code (2026)

Starting a new project with Claude Code is fundamentally different from scaffolding one manually. Instead of running a CLI generator and then customizing the output for hours, you describe what you want and Claude builds it. The key is knowing how to describe what you want effectively.

This guide walks you through starting any project — from an empty directory to a running application. For a guided project setup experience, use the [Project Starter tool](/starter/).

## Step 1: Create the Project Directory

```bash
mkdir my-project
cd my-project
```

Start clean. Claude works best when it can see the project from the beginning rather than inheriting decisions from a template generator.

## Step 2: Initialize Claude Code

```bash
claude
```

Once inside Claude Code, run:

```
/init
```

This creates a `CLAUDE.md` file. For a brand new project, the generated file will be sparse since there is nothing to analyze yet. That is fine — you will populate it as the project takes shape.

## Step 3: Describe Your Project

Give Claude a comprehensive project description in your first message. Include:

1. **What it does** — The core functionality
2. **Tech stack** — Language, framework, database, etc.
3. **Architecture** — Monolith, microservices, serverless, etc.
4. **Key features** — The 3-5 most important features
5. **Constraints** — Performance requirements, deployment target, team standards

### Example: REST API project

```
Build a REST API for a task management app:
- TypeScript with Express
- PostgreSQL with Prisma ORM
- JWT authentication
- CRUD endpoints for tasks, projects, and users
- Input validation with Zod
- Deploy to Railway/Render
- Use pnpm as package manager

Start with the project scaffold: package.json, tsconfig, prisma schema,
and basic Express setup with health check endpoint.
```

### Example: Full-stack web app

```
Build a recipe sharing web app:
- Next.js 14 with App Router
- TypeScript strict mode
- Tailwind CSS for styling
- Supabase for auth and database
- File uploads for recipe images
- pnpm, deploy to Vercel

Start with project structure, auth flow, and one complete recipe CRUD feature.
```

The more specific you are, the fewer iterations you need. Vague requests produce generic scaffolds that require extensive customization. See the [prompt structure guide](/speed-up-claude-code-responses-with-better-prompt-structure/) for tips on writing effective prompts.

## Step 4: Review the Scaffold

Claude will create the initial project structure. Before continuing, review what it built:

```
Show me the file tree and explain each major file's purpose
```

Check for:
- Correct dependencies in package.json
- Proper TypeScript configuration
- Sensible directory structure
- Correct framework configuration

Fix any issues now. It is cheaper (in tokens and time) to correct the foundation than to build on a flawed scaffold. Use the [Token Estimator](/token-estimator/) to track costs as you iterate.

## Step 5: Update CLAUDE.md

Now that the project has structure, regenerate the context file:

```
/init
```

Or better yet, write it manually with project-specific information:

```markdown
# Recipe App

## Stack
- Next.js 14, App Router, TypeScript strict
- Supabase (auth + database)
- Tailwind CSS
- pnpm

## Commands
- `pnpm dev` — development server
- `pnpm build` — production build
- `pnpm test` — run vitest
- `pnpm lint` — eslint

## Conventions
- Use server components by default, client only when needed
- Zod for all input validation
- Error boundaries on every route
- kebab-case for file names
```

A good CLAUDE.md makes every subsequent interaction more efficient. See [CLAUDE.md templates](/10-claude-md-templates-project-types/) for project-type-specific examples.

## Step 6: Build Feature by Feature

Do not ask Claude to build the entire application at once. Work through features incrementally:

```
1. "Set up Supabase auth with login, signup, and logout"
2. "Create the recipe database schema and Prisma model"
3. "Build the recipe creation form with image upload"
4. "Add recipe listing page with search and filters"
5. "Implement user profiles with saved recipes"
```

Each feature builds on the last. Claude has context from previous steps, so each subsequent feature integrates naturally. Compact when context gets heavy (check with `/cost`).

## Step 7: Add Testing

After the core features work, add tests:

```
Add comprehensive tests for the recipe CRUD operations.
Use vitest with React Testing Library for components
and supertest for API endpoints.
```

Claude writes tests that match your actual implementation because it has the full context of what it built. This is significantly faster than writing tests for code someone else wrote.

## Step 8: Production Preparation

Before deploying, ask Claude to review for production readiness:

```
Review this project for production readiness:
1. Environment variable handling
2. Error handling and logging
3. Security (auth, input validation, CORS)
4. Performance (database queries, caching)
5. Missing edge cases
```

## Try It Yourself

The [Project Starter](/starter/) tool guides you through this process interactively. Select your tech stack, describe your project, and it generates a customized starting point with all the configuration done correctly.

It is the fastest way to go from idea to working project because it handles the boilerplate decisions (TypeScript config, linting setup, testing framework, CI/CD) based on proven patterns for your chosen stack.

## Project Start Checklist

Use this for every new project:

- [ ] Empty directory created
- [ ] Claude Code initialized with `/init`
- [ ] Project description sent with stack, features, and constraints
- [ ] Scaffold reviewed and approved
- [ ] CLAUDE.md updated with project-specific conventions
- [ ] First feature built and tested
- [ ] Git initialized with meaningful first commit
- [ ] `.gitignore` includes `node_modules`, `.env`, and build artifacts

## Common Mistakes When Starting Projects

| Mistake | Problem | Fix |
|---------|---------|-----|
| Vague project description | Generic scaffold that needs heavy customization | Be specific about stack, features, and constraints |
| Asking for everything at once | Overwhelming context, mediocre results | Build one feature at a time |
| Skipping CLAUDE.md | Claude makes inconsistent technology choices | Write CLAUDE.md after scaffold |
| Not reviewing the scaffold | Building on a flawed foundation | Review before adding features |
| Ignoring tests | Technical debt from day one | Add tests alongside each feature |

## Frequently Asked Questions

**Should I use a framework starter template or let Claude build from scratch?**

For well-known frameworks (Next.js, Express, Django), it is often faster to use the official starter (`create-next-app`) and then bring Claude in to customize it. For custom architectures, Claude from scratch is better.

**How do I handle secrets and environment variables?**

Ask Claude to create a `.env.example` file with placeholder values and add `.env` to `.gitignore`. Never commit real secrets. See the [security best practices guide](/claude-code-security-best-practices-2026/).

**What if Claude chooses the wrong library or approach?**

Correct it immediately. Say "Use X instead of Y because [reason]." Claude will refactor accordingly. The longer you wait to correct, the more code needs changing.

**How much does it cost to scaffold a new project?**

A typical project scaffold (structure, config, first feature) costs $1-3 with Opus or $0.20-0.60 with Sonnet. Use the Token Estimator to plan your budget.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Should I use a framework starter template or let Claude build from scratch?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For well-known frameworks like Next.js or Express, use the official starter and bring Claude in to customize. For custom architectures, Claude from scratch is better."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle secrets and environment variables?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Ask Claude to create a .env.example with placeholder values and add .env to .gitignore. Never commit real secrets."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude chooses the wrong library or approach?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Correct it immediately. Say 'Use X instead of Y because [reason].' Claude will refactor accordingly. The longer you wait, the more code needs changing."
      }
    },
    {
      "@type": "Question",
      "name": "How much does it cost to scaffold a new project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A typical project scaffold costs $1-3 with Opus or $0.20-0.60 with Sonnet. Use the Token Estimator to plan your budget."
      }
    }
  ]
}
</script>



**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

## Related Guides

- [Project Starter](/starter/) — Interactive project scaffolding tool
- [CLAUDE.md Templates](/10-claude-md-templates-project-types/) — Templates for every project type
- [Project Templates Quick Setup](/claude-code-project-templates-quick-setup/) — Template-based project creation
- [Claude Code Configuration](/claude-code-configuration-hierarchy-explained-2026/) — Configuration setup guide
- [Token Estimator](/token-estimator/) — Plan project costs in advance
