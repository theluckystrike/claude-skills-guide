---
layout: default
title: "CLAUDE.md Advanced Patterns (2026)"
description: "Conditional rules, project-specific overrides, multi-repo patterns, and dynamic CLAUDE.md configuration for complex projects. Updated 2026."
date: 2026-04-26
permalink: /claudemd-advanced-patterns-2026/
categories: [guides, claude-code]
tags: [CLAUDE.md, advanced, configuration, monorepo, patterns]
last_modified_at: 2026-04-26
---

# CLAUDE.md Advanced Patterns (2026)

Once you have a working CLAUDE.md, the next step is handling the complexity that real projects demand: monorepos with different rules per package, conditional behavior based on file type, environment-specific overrides, and team-scale configuration management. These advanced patterns let you scale CLAUDE.md from a single-developer project to an organization-wide standard. Need a starting template first? Use the [CLAUDE.md Generator](/generator/).

## Pattern 1: Scoped Rules with Subdirectory Files

Claude Code loads CLAUDE.md files hierarchically. A CLAUDE.md in a subdirectory supplements (and can override) the root file. This is the foundation for monorepo support:

```
project/
  CLAUDE.md                    # Shared: TypeScript, linting, commits
  packages/
    api/
      CLAUDE.md                # API-specific: Express, DB patterns
    web/
      CLAUDE.md                # Web-specific: React, Tailwind
    shared/
      CLAUDE.md                # Shared lib: no external deps allowed
    mobile/
      CLAUDE.md                # React Native: platform patterns
```

The root CLAUDE.md contains universal rules:

```markdown
# CLAUDE.md (root)
## Universal Rules
- TypeScript strict mode in all packages
- Conventional commits required
- Run affected tests before committing
- Named exports only, no default exports
```

Each package CLAUDE.md contains only package-specific rules:

```markdown
# packages/api/CLAUDE.md
## API Package Rules
- Framework: Express 5 with async handlers
- Database: Drizzle ORM (never raw SQL)
- Validation: Zod schemas in src/schemas/
- Routes: src/routes/[resource].ts
- Middleware: src/middleware/[concern].ts
- Error responses: use ApiError class from @shared/errors
```

When Claude works in `packages/api/`, it sees both the root rules and the API-specific rules. When it works in `packages/web/`, it sees root plus web rules. This prevents rule bloat while maintaining package-specific precision.

## Pattern 2: Conditional Rules by File Type

Sometimes different rules apply to different file types within the same directory. Use explicit section headers to create conditional scoping:

```markdown
# CLAUDE.md

## TypeScript Files (.ts, .tsx)
- Strict mode, no any types
- Prefer interfaces for object shapes
- Use branded types for IDs: type UserId = string & { __brand: 'UserId' }

## CSS/SCSS Files
- BEM naming: block__element--modifier
- Variables in src/styles/variables.scss
- No !important (refactor specificity instead)
- Mobile-first media queries

## SQL Migration Files
- Always include both UP and DOWN migrations
- Use explicit column types, no implicit defaults
- Add comments explaining why the migration exists
- Name: YYYYMMDD_HHMMSS_descriptive_name.sql

## Markdown Files
- Use ATX headers (# not underlines)
- One sentence per line for clean diffs
- Code blocks must specify language
```

Claude applies the relevant section based on the file it is working on. This is more efficient than separate CLAUDE.md files per file type, which would require deep directory nesting.

## Pattern 3: Environment-Specific Overrides

Use CLAUDE.local.md for developer-specific overrides that should not be committed to version control:

```markdown
# CLAUDE.local.md (gitignored)

## My Environment
- I use nvim, not VS Code
- My terminal is Wezterm with zsh
- Run tests with: pnpm test --watch (I like watch mode)
- Database: local Docker Postgres on port 5433 (not default 5432)
- API runs on port 3001 (3000 is used by another project)
```

This pattern is essential for teams where developers have different local setups. The project CLAUDE.md specifies conventions. The local file specifies environment details.

For CI/CD environments, you can create a CLAUDE.md that references environment variables:

```markdown
# CLAUDE.md

## Environment Detection
- If running in CI (CI=true), use --no-watch for tests
- Production database: use DATABASE_URL env var
- Local database: use .env.local file
- Never hardcode connection strings
```

## Pattern 4: Role-Based Sections

When different team roles work on the same codebase, organize rules by role:

```markdown
# CLAUDE.md

## For All Developers
- Run pnpm lint before committing
- Branch naming: type/TICKET-description

## For Frontend Work
- Components in src/components/
- Use design system tokens from @acme/tokens
- Accessibility: every interactive element needs aria-label
- Test with React Testing Library

## For Backend Work
- API handlers in src/api/
- Every endpoint needs OpenAPI annotations
- Rate limiting on all public endpoints
- Log all errors with request context

## For DevOps Work
- Infrastructure in terraform/
- Secrets via AWS Parameter Store
- No hardcoded AWS account IDs
- Tag all resources with team and environment
```

Claude uses context clues from your conversation and the files being edited to determine which role sections apply. If you ask Claude to create a React component, it follows the Frontend section. If you ask it to write a Terraform module, it follows the DevOps section.

## Pattern 5: Architectural Decision Records in CLAUDE.md

Encode key architectural decisions directly so Claude understands not just what to do, but why:

```markdown
# CLAUDE.md

## Architecture Decisions
- ADR-001: We use event sourcing for order state. Never mutate
  order records directly. Append events to the order_events table.
- ADR-002: API versioning via URL path (/v1/, /v2/), not headers.
  All new endpoints go in the latest version directory.
- ADR-003: No ORM for read models. Use raw SQL views for
  query performance. ORM only for write operations.
- ADR-004: Feature flags via LaunchDarkly. Never use environment
  variables for feature toggles. Check flags at the handler level.
```

This is powerful because it prevents Claude from accidentally violating architectural decisions. Without ADR context, Claude might suggest mutating an order record directly because that is the simpler approach. With the ADR, Claude knows to use event sourcing.

## Pattern 6: Progressive Disclosure

For large projects, organize CLAUDE.md sections from most-frequently-needed to least:

```markdown
# CLAUDE.md

## Quick Reference (Always Read)
- pnpm for packages, vitest for tests
- src/ for code, __tests__/ for tests
- Named exports, strict TypeScript

## Code Patterns (Read When Writing Code)
[Detailed patterns here]

## Architecture (Read When Making Design Decisions)
[Architecture context here]

## Deployment (Read When Touching CI/CD)
[Deployment specifics here]

## Historical Context (Read When Confused by Legacy Code)
[Why things are the way they are]
```

Claude processes the quick reference section every time. Deeper sections are processed when relevant to the current task. This structure keeps the most important rules in the highest-attention position.

## Try It Yourself

These advanced patterns build on a solid foundation. If you do not have a base CLAUDE.md yet, the [CLAUDE.md Generator](/generator/) creates one tailored to your project in under a minute. Start there, then layer on the advanced patterns from this guide as your project complexity grows. The generator handles the fundamentals so you can focus on the project-specific patterns that matter most.

## Anti-Patterns to Avoid

**Overly nested CLAUDE.md files.** More than 3 levels of directory-scoped CLAUDE.md files becomes hard to maintain and debug. If Claude is not following a rule, finding which CLAUDE.md file to update should not require a search.

**Duplicating rules across files.** If a rule applies to multiple packages, put it in the root CLAUDE.md. Duplication leads to drift where one file gets updated and others do not.

**Using CLAUDE.md for documentation.** CLAUDE.md is configuration, not documentation. Long explanations dilute the rules. Keep explanations in your wiki or README and keep CLAUDE.md focused on actionable instructions.

**Contradicting upstream rules.** If your org's managed policy says "use jest" and your project CLAUDE.md says "use vitest," Claude gets confused. Coordinate with your organization's managed policy before overriding.

## Related Guides

- [Perfect CLAUDE.md File Template](/perfect-claudemd-file-template-2026/) — Start with the base template
- [CLAUDE.md for React Projects](/claudemd-for-react-projects-2026/) — React-specific configuration
- [CLAUDE.md for Python Projects](/claudemd-for-python-projects-2026/) — Python-specific configuration
- [CLAUDE.md Best Practices for Teams](/claude-code-claude-md-best-practices-teams-2026/) — Team-scale management
- [Best CLAUDE.md Templates for Enterprise](/best-claude-md-templates-enterprise-2026/) — Enterprise patterns
- [CLAUDE.md Generator](/generator/) — Generate your starting template

## Frequently Asked Questions

### How many CLAUDE.md files can a project have?
There is no hard limit. Claude Code loads the root file plus the file in the current working directory and any directories in between. Practically, keep it under 5 scoped files. More than that becomes difficult to maintain and debug.

### Do subdirectory CLAUDE.md files override or supplement root rules?
They supplement by default. Claude sees all applicable CLAUDE.md files as additive context. If a subdirectory file contradicts the root, the more specific subdirectory rule takes precedence in practice, but this is implicit and can be unreliable. Avoid contradictions.

### Can I use CLAUDE.md in a CI pipeline?
Yes. Claude Code in CI mode reads CLAUDE.md the same way it does interactively. Some teams maintain a separate CI-focused CLAUDE.md with stricter rules like no interactive prompts and always run full test suite.

### How do I debug which CLAUDE.md rules Claude is following?
Ask Claude directly: "What CLAUDE.md rules are you following for this project?" Claude will list the instructions it loaded. Compare this against your actual files to find gaps or misinterpretations.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How many CLAUDE.md files can a project have?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "There is no hard limit. Claude Code loads the root file plus the file in the current working directory. Practically keep it under 5 scoped files as more becomes difficult to maintain."
      }
    },
    {
      "@type": "Question",
      "name": "Do subdirectory CLAUDE.md files override or supplement root rules?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "They supplement by default. Claude sees all applicable files as additive context. If a subdirectory contradicts the root the more specific rule takes precedence but avoid contradictions."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use CLAUDE.md in a CI pipeline?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code in CI mode reads CLAUDE.md the same way as interactive mode. Some teams maintain a CI-focused CLAUDE.md with stricter rules like no interactive prompts."
      }
    },
    {
      "@type": "Question",
      "name": "How do I debug which CLAUDE.md rules Claude is following?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Ask Claude directly what CLAUDE.md rules it is following. Claude will list loaded instructions. Compare against your actual files to find gaps or misinterpretations."
      }
    }
  ]
}
</script>
