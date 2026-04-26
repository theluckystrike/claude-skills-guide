---
layout: default
title: "Building Your Own Claude Code Skill: Step-by-Step (2026)"
description: "Step-by-step tutorial for building custom Claude Code skills. Covers skill file structure, CLAUDE.md format, testing, and team sharing with a complete example."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /building-custom-claude-code-skill-tutorial/
reviewed: true
categories: [skills]
tags: [claude, claude-code, custom-skills, tutorial, development]
---

# Building Your Own Claude Code Skill: Step-by-Step

Off-the-shelf skills cover common workflows, but your team has specific conventions, naming patterns, and architectural decisions that no generic skill captures. Building a custom skill takes 15-30 minutes and pays for itself the first time Claude Code follows your exact process instead of guessing. This tutorial walks through skill file structure, writing effective instructions, testing locally, and sharing with your team. Browse existing skills for inspiration with the [Skill Finder](/skill-finder/).

## What a Skill Actually Is

A Claude Code skill is a markdown document loaded into the system prompt at session start. It contains instructions, rules, examples, and sometimes templates that Claude Code follows during the session. There is no special syntax, no compilation, no API registration. It is plain markdown that tells Claude Code how to behave.

**Minimum viable skill:**

```markdown
# API Response Format

All API responses must follow this structure:
- Success: `{ "status": "ok", "data": <result> }`
- Error: `{ "status": "error", "code": <int>, "message": <string> }`
- Never return raw errors to the client
- Always include a `request_id` header in responses
```

That is a complete skill. 4 rules, ~60 words, ~80 tokens. Claude Code will follow these rules for every API-related task in the session.

## Step 1: Identify the Knowledge Gap

Before writing, ask: what does Claude Code get wrong repeatedly that I have to correct?

Common candidates:
- **Naming conventions:** Your team uses `snake_case` for Python but `camelCase` for API fields
- **Architecture patterns:** You use a specific repository pattern, CQRS, or service layer structure
- **Error handling:** Your app has a custom error hierarchy with specific retry logic
- **Testing conventions:** You require specific fixtures, mock patterns, or test file organization
- **Deployment rules:** Your CI expects specific commit formats, branch naming, or changelog entries

Write down 5-10 rules that you tell Claude Code (or new team members) in every session.

## Step 2: Write the Skill File

Create a markdown file with clear, imperative instructions. Avoid explanations -- Claude Code needs rules, not rationale.

**Bad skill writing (too explanatory):**

```markdown
We use a repository pattern because it abstracts the database layer
and makes testing easier. The repository should handle all database
interactions so that the service layer doesn't need to know about
the ORM or database technology being used.
```

**Good skill writing (imperative rules):**

```markdown
## Repository Pattern

- All database queries go through repository classes in `src/repos/`
- Repository methods return domain objects, never ORM models
- One repository per aggregate root
- Repository constructors accept a `Session` dependency
- Never import repository classes in route handlers -- inject via service layer
```

### Complete Example: Full-Stack Skill

Here is a production-grade skill for a Next.js + Prisma project:

```markdown
# Project Conventions: Acme Dashboard

## File Structure
- Pages: `app/[route]/page.tsx` (App Router, no Pages Router)
- Components: `components/[ComponentName]/index.tsx` + `styles.module.css`
- API routes: `app/api/[resource]/route.ts`
- Database: `prisma/schema.prisma` (single schema file)
- Utils: `lib/[domain].ts` (e.g., `lib/auth.ts`, `lib/billing.ts`)

## Coding Rules
- Server components by default. Add `"use client"` only for interactivity
- All database queries through Prisma client in `lib/db.ts`
- No raw SQL. Use Prisma's type-safe query builder
- Error boundaries in `app/error.tsx` per route segment
- Zod schemas for all API input validation in `lib/schemas/`

## API Route Pattern
Every API route handler must:
1. Validate input with Zod
2. Check authentication via `getServerSession()`
3. Call the service function (never query DB directly in route)
4. Return `NextResponse.json()` with consistent format
5. Catch errors and return appropriate HTTP status

## Testing
- Unit tests: `__tests__/[module].test.ts` colocated with source
- Integration tests: `tests/integration/[feature].test.ts`
- Use `@testing-library/react` for component tests
- Mock Prisma with `jest.mock("@/lib/db")`
- Test database: use Prisma's `$transaction` rollback pattern

## Git
- Branch naming: `feat/JIRA-123-short-description`
- Commit format: `type(scope): message` (conventional commits)
- PR title matches the primary commit message
- Squash merge to main
```

Save this as `.claude/skills/project-conventions.md` in your project root.

## Step 3: Choose the Right Location

| Location | When to Use |
|----------|-------------|
| `CLAUDE.md` (project root) | Short skills (under 500 words) that every developer needs |
| `.claude/skills/filename.md` | Longer skills or multiple skills that you want to organize |
| `~/.claude/CLAUDE.md` | Personal preferences that apply to all your projects |
| `~/.claude/skills/filename.md` | Personal skills that apply to all your projects |

For the example above, `.claude/skills/project-conventions.md` is the right choice because it is project-specific and long enough to warrant its own file.

## Step 4: Test the Skill

Testing a skill means verifying that Claude Code follows its rules in practice.

**Test 1: Direct rule test**

```
Create a new API route for /api/products. Follow our project conventions.
```

Check that the output:
- Uses the App Router pattern (`route.ts`, not a Pages Router handler)
- Includes Zod validation
- Checks authentication
- Uses the service layer instead of direct Prisma calls
- Returns `NextResponse.json()`

**Test 2: Conflict test**

```
Create a quick database query in the API route handler.
```

If the skill works, Claude Code should push back: "Per our project conventions, database queries should go through the service layer, not directly in the route handler."

**Test 3: Edge case test**

```
Create a component that needs client-side state.
```

Check that Claude Code adds `"use client"` and explains why (interactivity), confirming it understood the "server by default" rule.

## Step 5: Iterate on the Instructions

After testing, you will find gaps. Common issues:

**Too vague:** "Use good error handling" -- Claude Code interprets this differently each time. Be specific: "Wrap all async operations in try/catch. Catch specific error types. Log errors with `logger.error()`. Return HTTP 500 with a generic message."

**Too rigid:** "Always use exactly 4 spaces for indentation" -- This conflicts with some file types. Add context: "Use 4 spaces for Python files. Use 2 spaces for YAML and JSON."

**Missing examples:** Abstract rules are harder to follow than concrete examples. Add a code snippet showing the expected pattern:

```markdown
## Example API Route

```typescript
export async function POST(req: Request) {
  const body = await req.json();
  const parsed = CreateProductSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
  }
  const product = await productService.create(parsed.data);
  return NextResponse.json(product, { status: 201 });
}
```​
```

## Step 6: Share with Your Team

Commit the skill file to git:

```bash
git add .claude/skills/project-conventions.md
git commit -m "feat(skills): add project conventions skill for Claude Code"
git push
```

Every team member who pulls this change gets the skill automatically. No installation step, no configuration. Claude Code loads it from `.claude/skills/` at session start.

For cross-project skills, create a shared repository:

```bash
# In your shared skills repo
git clone git@github.com:your-org/claude-skills.git
cd claude-skills
ls
# python-conventions.md
# react-patterns.md
# api-design.md

# In your project, reference it
ln -s ~/repos/claude-skills/python-conventions.md .claude/skills/python-conventions.md
```

Check the [CLAUDE.md generator](/generator/) for automated setup of project-specific configurations alongside your skills.

## Try It Yourself

Before building from scratch, check if a similar skill already exists. The **[Skill Finder](/skill-finder/)** has 150+ community skills that you can fork and customize. Start with an existing skill and modify it to match your project's conventions.

**[Try the Skill Finder -->](/skill-finder/)**

## Common Questions

<details><summary>How long should a skill be?</summary>
Keep individual skills under 500 words (roughly 650 tokens). Longer skills work but consume more context per message. If your skill exceeds 500 words, consider splitting it into multiple focused skills (e.g., separate "testing conventions" and "API conventions").
</details>

<details><summary>Can a skill include code templates?</summary>
Yes, and you should. Code templates are the most effective form of skill instruction because they show Claude Code the exact output format you expect. Include 1-2 representative examples per major pattern.
</details>

<details><summary>What happens if two skills contradict each other?</summary>
Claude Code follows the higher-priority skill (project-level beats user-level). If two project-level skills conflict, behavior is unpredictable. Review your skills for contradictions and consolidate overlapping instructions.
</details>

<details><summary>Can skills call tools or execute commands?</summary>
Skills cannot execute code directly. They are instructions that influence how Claude Code uses its existing tools (Bash, Read, Write, etc.). A skill can say "always run tests after editing" and Claude Code will use the Bash tool to execute the test command, but the skill itself does not run anything.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"How long should a skill be?","acceptedAnswer":{"@type":"Answer","text":"Keep individual skills under 500 words. Longer skills work but consume more context per message. Split skills over 500 words into multiple focused skills."}},
{"@type":"Question","name":"Can a skill include code templates?","acceptedAnswer":{"@type":"Answer","text":"Yes. Code templates are the most effective form of instruction because they show Claude Code the exact output format expected. Include 1-2 examples per pattern."}},
{"@type":"Question","name":"What happens if two skills contradict each other?","acceptedAnswer":{"@type":"Answer","text":"Claude Code follows the higher-priority skill. If two project-level skills conflict, behavior is unpredictable. Review skills for contradictions."}},
{"@type":"Question","name":"Can skills call tools or execute commands?","acceptedAnswer":{"@type":"Answer","text":"Skills cannot execute code directly. They influence how Claude Code uses its existing tools. A skill can say 'always run tests after editing' and Claude Code will use the Bash tool."}}
]}
</script>

## Related Guides

- [Best Claude Code Skills Ranked](/best-claude-code-skills-2026-ranked/)
- [How to Install Skills Guide](/how-to-install-claude-code-skills-guide/)
- [CLAUDE.md Generator](/generator/)
- [Advanced Usage Guide](/advanced-usage/)
- [Skill Finder](/skill-finder/) -- browse existing skills for inspiration
