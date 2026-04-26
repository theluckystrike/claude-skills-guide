---
layout: default
title: "CLAUDE.md Best Practices (2026)"
description: "The definitive guide to CLAUDE.md files. Structure, rules, project configs, team standards, Karpathy principles, NASA P10, and real examples."
permalink: /claude-md-best-practices-definitive-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# CLAUDE.md Best Practices: Definitive Guide (2026)

CLAUDE.md is the most important file in any project that uses Claude Code. It tells Claude who your project is, what rules to follow, what patterns to use, and what mistakes to avoid. A good CLAUDE.md turns Claude from a generic assistant into a team member who understands your codebase.

This guide is the definitive reference. It covers structure, content strategy, real examples from five project types, team configuration, and advanced techniques including Karpathy's principles and NASA Power of 10 integration.

## Why CLAUDE.md Matters

Without a CLAUDE.md, Claude Code starts every session blind. It reads your files but has no context about:

- Your team's coding conventions
- Which patterns are preferred vs. forbidden
- How to run tests, build, and deploy
- What the project's architecture looks like
- Domain-specific rules (regulatory requirements, API constraints)

With a well-written CLAUDE.md, Claude Code produces code that looks like your team wrote it. First-draft quality goes from "needs significant revision" to "ready to merge with minor tweaks."

### The Compounding Effect

CLAUDE.md instructions apply to every interaction. A rule you write once saves you from repeating it hundreds of times:

- 5-minute CLAUDE.md setup saves 5 seconds per Claude Code interaction
- At 50 interactions per day, that is 4 minutes saved daily
- Over a month: 2 hours saved from a 5-minute investment
- Over a year: 24+ hours from typing a few paragraphs

But the real value is not time savings. It is consistency. Every function, every component, every test follows the same patterns without you having to remember to ask.

## File Location Hierarchy

Claude Code looks for CLAUDE.md files in multiple locations, with a priority order:

### 1. Project Root (Highest Priority)
```
my-project/
  CLAUDE.md          ← Project-specific rules
  src/
  package.json
```

### 2. Subdirectories
```
my-project/
  CLAUDE.md          ← Project-wide rules
  src/
    CLAUDE.md        ← Rules specific to src/
  tests/
    CLAUDE.md        ← Rules specific to tests/
```

Subdirectory CLAUDE.md files add to (not replace) the root file. Use them for directory-specific rules.

### 3. User Home Directory
```
~/.claude/CLAUDE.md  ← Personal rules across all projects
```

Personal preferences that apply everywhere: your name, preferred comment style, timezone.

### Priority Order

When rules conflict:
1. Subdirectory CLAUDE.md (most specific)
2. Project root CLAUDE.md
3. User home CLAUDE.md (most general)

More specific rules override more general ones.

## Anatomy of a Good CLAUDE.md

### Section 1: Project Identity

Tell Claude what the project is in 2-3 sentences. Include the tech stack.

```markdown
# Project: Acme Dashboard

Real-time analytics dashboard for e-commerce stores.
Built with Next.js 15, TypeScript, Tailwind CSS, Supabase (PostgreSQL + Auth + Edge Functions), deployed on Vercel.
```

Why this matters: Claude uses this context for every decision. "Supabase" tells it to use Supabase client libraries. "Vercel" tells it to use Vercel deployment patterns. "Next.js 15" tells it to use App Router conventions.

### Section 2: Commands

List the commands Claude needs to know. Be explicit about what works.

```markdown
## Commands
- Dev server: `pnpm dev` (port 3000)
- Build: `pnpm build`
- Tests: `pnpm test` (Jest + React Testing Library)
- Single test: `pnpm test -- --testPathPattern="filename"`
- Lint: `pnpm lint` (ESLint + Prettier)
- Type check: `pnpm typecheck` (tsc --noEmit)
- Database migrations: `supabase migration new <name>` then `supabase db push`
- Deploy: Automatic on push to main (Vercel)
```

### Section 3: Coding Standards

Be specific and actionable. Vague rules produce vague results.

```markdown
## Coding Standards

### TypeScript
- Strict mode enabled. No `any` types.
- Use `interface` for object shapes, `type` for unions and intersections.
- All function parameters and return types must be explicitly typed.
- Use `as const` for literal types instead of type assertions.
- Prefer `unknown` over `any` for untyped values.

### Functions
- Maximum 50 lines per function.
- Single responsibility: one function does one thing.
- Pure functions preferred. Side effects only in clearly labeled functions.
- Use early returns for guard clauses.
- Minimum 2 assertions per function for input validation.

### Error Handling
- All async functions use try/catch.
- Errors must be typed: `catch (error: unknown)` then narrow.
- Never swallow errors silently. Log or rethrow.
- User-facing errors use error codes (E001-E999) from src/errors/codes.ts.

### Naming
- Files: kebab-case (user-profile.ts, not UserProfile.ts or userProfile.ts)
- Components: PascalCase (UserProfile.tsx)
- Functions/variables: camelCase
- Constants: SCREAMING_SNAKE_CASE
- Database columns: snake_case
- Boolean variables: prefix with is/has/should (isActive, hasPermission)
```

### Section 4: Architecture Rules

Tell Claude where things go and how they connect.

```markdown
## Architecture

### Directory Structure
- `src/app/` - Next.js App Router pages and layouts
- `src/components/` - Reusable UI components (no business logic)
- `src/components/ui/` - Primitive components (Button, Input, Card)
- `src/features/` - Feature modules (auth, billing, analytics)
- `src/lib/` - Shared utilities and configurations
- `src/lib/supabase/` - Supabase client and helpers
- `src/types/` - Shared TypeScript type definitions
- `supabase/migrations/` - Database migration files

### Patterns
- Feature modules are self-contained: components, hooks, types, and tests together.
- Server components by default. Client components only when interactivity is needed.
- Data fetching in Server Components or Route Handlers. Never in client components directly.
- All database access goes through src/lib/supabase/queries.ts (not scattered across components).
```

### Section 5: Testing Rules

```markdown
## Testing
- Every new function gets a test file.
- Test file location: same directory as source, with .test.ts suffix.
- Test structure: describe("functionName", () => { it("should...") })
- Minimum coverage: 80% for new code.
- Mock external services (Supabase, Stripe). Never hit real APIs in tests.
- Use factories for test data (src/test/factories/).
- Integration tests for API routes. Unit tests for utilities.
- Run tests after every change: `pnpm test --changed`
```

### Section 6: What NOT to Do

Negative rules are as important as positive ones. Tell Claude what you have seen go wrong.

```markdown
## Do NOT
- Do not use default exports. Use named exports only.
- Do not import from barrel files (index.ts). Import from the specific file.
- Do not use `console.log` for debugging. Use the logger from src/lib/logger.ts.
- Do not store secrets in code. Use environment variables.
- Do not add dependencies without checking bundle size impact.
- Do not use `useEffect` for data fetching. Use React Server Components or SWR.
- Do not write SQL strings directly. Use the query builder or Supabase client.
- Do not modify migration files after they have been applied.
```

### Section 7: Context and Domain Knowledge

Information Claude cannot infer from code alone.

```markdown
## Domain Context
- We serve Shopify store owners. All analytics are e-commerce metrics.
- "Conversion rate" always means orders/sessions, not orders/visitors.
- Currency is always USD. Multi-currency is on the roadmap but not yet supported.
- GDPR compliance is required. PII must be encrypted at rest.
- Free trial is 14 days. Billing starts on day 15.
- Stripe handles all payment processing. We never store card numbers.
```

## Real Examples by Project Type

### Example 1: SaaS Web Application

```markdown
# Project: MetricsDash

SaaS analytics dashboard. Next.js 15, TypeScript, Supabase, Stripe, Vercel.

## Commands
- Dev: `pnpm dev`
- Build: `pnpm build`
- Test: `pnpm test`
- Lint: `pnpm lint`
- DB migrate: `supabase migration new <name> && supabase db push`

## Stack Rules
- Next.js App Router (not Pages Router)
- Server Components by default
- Supabase for auth, database, storage
- Stripe for billing (webhooks in src/app/api/webhooks/)
- Tailwind CSS for styling (no CSS modules, no styled-components)
- Zod for all input validation

## Code Standards
- TypeScript strict mode, no `any`
- Functions under 50 lines
- Named exports only
- Error codes from src/constants/errors.ts
- All API responses use ApiResponse<T> type from src/types/api.ts

## Do NOT
- Never use client-side data fetching for initial page loads
- Never store Stripe customer IDs in local storage
- Never skip webhook signature verification
- Never use `dangerouslySetInnerHTML`
```

### Example 2: CLI Tool

```markdown
# Project: deploy-tool

CLI tool for deploying containerized applications. Node.js, TypeScript, Commander.js.

## Commands
- Build: `pnpm build` (outputs to dist/)
- Test: `pnpm test` (Vitest)
- Run locally: `node dist/index.js`
- Link for testing: `pnpm link --global`

## CLI Rules
- All commands use Commander.js patterns from src/commands/
- Output uses chalk for colors: green=success, red=error, yellow=warning, cyan=info
- Progress indicators use ora spinners
- User input uses inquirer prompts
- Exit codes: 0=success, 1=general error, 2=config error, 3=network error

## Code Standards
- All async operations have timeout (30 seconds default)
- File operations use fs/promises (not fs sync methods)
- Config file: ~/.deploy-tool/config.json
- Logs go to ~/.deploy-tool/logs/
- No interactive prompts when --yes flag is set (CI mode)

## Do NOT
- Never use process.exit() directly. Throw typed errors.
- Never print secrets to stdout
- Never modify files outside the project directory without explicit --force flag
```

### Example 3: API Backend

```markdown
# Project: order-service

Microservice for order processing. Go 1.22, Chi router, PostgreSQL, gRPC.

## Commands
- Run: `go run cmd/server/main.go`
- Test: `go test ./...`
- Lint: `golangci-lint run`
- Generate protos: `buf generate`
- Migrate: `goose -dir migrations postgres "$DATABASE_URL" up`

## Go Standards
- Follow Effective Go and Go Code Review Comments
- Errors: wrap with fmt.Errorf("operation: %w", err)
- Context: pass context.Context as first param to all functions that do I/O
- Interfaces: define at the consumer, not the implementer
- Package names: short, lowercase, no underscores

## Architecture
- cmd/ - Entry points
- internal/domain/ - Business logic (no external dependencies)
- internal/handler/ - HTTP and gRPC handlers
- internal/repository/ - Database access (implements domain interfaces)
- internal/service/ - Application services (orchestrates domain + repository)
- pkg/ - Shared libraries (only if truly reusable)

## Do NOT
- Never use init() functions
- Never use global variables (except for package-level loggers)
- Never return nil errors with nil values
- Never use panic for recoverable errors
```

### Example 4: Mobile App (React Native)

```markdown
# Project: FitTrack

Fitness tracking app. React Native 0.76, Expo, TypeScript, Supabase.

## Commands
- Dev: `npx expo start`
- iOS: `npx expo run:ios`
- Android: `npx expo run:android`
- Test: `pnpm test`
- Lint: `pnpm lint`

## Mobile-Specific Rules
- Use React Navigation v7 for routing
- Screens go in src/screens/, components in src/components/
- Platform-specific code uses .ios.tsx / .android.tsx suffixes
- Animations use react-native-reanimated (not Animated API)
- All text must use the Text component from src/components/ui/Text.tsx (handles font scaling)

## Performance Rules
- FlatList for all lists (never ScrollView with .map())
- Memoize expensive components with React.memo
- Images must specify width and height (no layout shifts)
- Avoid inline styles in render (use StyleSheet.create)

## Do NOT
- Never use pixel values. Use the spacing scale from src/theme.ts
- Never use setTimeout for animations. Use Reanimated.
- Never store auth tokens in AsyncStorage (use expo-secure-store)
```

### Example 5: Data Pipeline

```markdown
# Project: etl-pipeline

ETL pipeline for processing customer event data. Python 3.12, Polars, DuckDB, Prefect.

## Commands
- Run pipeline: `python -m pipeline.main`
- Test: `pytest`
- Lint: `ruff check .`
- Format: `ruff format .`
- Type check: `mypy .`

## Python Standards
- Type hints on all functions (PEP 484)
- Docstrings on all public functions (Google style)
- dataclasses for data containers
- Pydantic for external data validation
- pathlib.Path instead of os.path

## Pipeline Rules
- Each transform is a pure function: DataFrame in, DataFrame out
- Side effects (file I/O, API calls) only in pipeline orchestration layer
- Schema validation at every pipeline stage boundary
- Logging at INFO level for stage start/complete, DEBUG for row counts
- All SQL queries in sql/ directory, loaded at runtime

## Do NOT
- Never use pandas (we use Polars for performance)
- Never hardcode file paths. Use config from pipeline/config.py
- Never catch broad exceptions (except at pipeline top level)
- Never use mutable default arguments
```

## Team Configuration

### Shared CLAUDE.md in Git

Commit your project CLAUDE.md to version control. Every team member gets the same rules:

```
my-project/
  CLAUDE.md              ← Committed to git
  .claude/
    settings.json        ← Committed (shared hooks config)
    settings.local.json  ← .gitignored (personal settings)
```

Add `.claude/settings.local.json` to `.gitignore` for personal overrides.

### Personal CLAUDE.md

Each developer can add personal preferences in `~/.claude/CLAUDE.md`:

```markdown
# Personal Preferences

## Identity
My name is Sarah. I work on the billing team.

## Style
- I prefer detailed explanations with code
- Show me the full function, not just the diff
- Always run tests after making changes
- Remind me to update CHANGELOG.md for user-facing changes

## Context
- My timezone is US/Pacific
- I use VS Code with Vim keybindings
- I prefer pnpm over npm
```

### Onboarding New Team Members

A good CLAUDE.md doubles as onboarding documentation. New developers learn:
- How to run the project
- What patterns to follow
- What mistakes to avoid
- Where code goes

Include a "Getting Started" section:

```markdown
## Getting Started (New Developers)
1. Clone the repo
2. Copy .env.example to .env and fill in values (ask #team-channel for secrets)
3. Run `pnpm install`
4. Run `supabase start` for local database
5. Run `pnpm dev` to start dev server
6. Read src/features/README.md for feature module conventions
```

## Advanced Techniques

### Karpathy's Principles

Andrej Karpathy shared principles for working with AI coding assistants that translate well to CLAUDE.md rules:

```markdown
## AI Collaboration Rules (Karpathy-Inspired)
- Keep files under 300 lines. Split large files proactively.
- Every function should be understandable without reading other functions.
- Tests serve as documentation. Write tests that explain behavior.
- Comments explain WHY, not WHAT. The code explains what.
- When refactoring, change structure OR behavior, never both at once.
- Verify every change with a test run before considering it done.
```

### NASA Power of 10 Integration

The [NASA Power of 10 rules](https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code) for safety-critical code adapt well for high-reliability projects:

```markdown
## Reliability Rules (NASA Power of 10 Adapted)
1. No recursion. Use iterative solutions.
2. All loops must have a fixed upper bound.
3. No dynamic memory allocation after initialization (where applicable).
4. Functions must not exceed 60 lines (including comments).
5. Minimum 2 assertions per function for precondition validation.
6. Data objects declared at the smallest possible scope.
7. Return values of all non-void functions must be checked.
8. Preprocessor/macro use limited to file includes and simple constants.
9. Pointer use restricted (TypeScript: no `any`, no type assertions).
10. All code must compile with zero warnings at the highest warning level.
```

### Conditional Rules

Use sections that only apply in certain contexts:

```markdown
## When Working on API Routes
- Validate all inputs with Zod schemas
- Return structured errors with { code, message, details }
- Add rate limiting headers
- Log request metadata (method, path, status, duration)

## When Working on Components
- Use Storybook for isolated development
- Include at least 3 states: default, loading, error
- Support dark mode through CSS variables
- Test with screen reader (VoiceOver)

## When Working on Database
- Always use migrations (never manual SQL)
- Include rollback migration (down)
- Test migration on a copy before applying to staging
- Update TypeScript types after schema changes
```

### Dynamic CLAUDE.md

For monorepos with multiple services, generate CLAUDE.md dynamically:

```bash
#!/bin/bash
# generate-claude-md.sh
# Run: ./generate-claude-md.sh > CLAUDE.md

cat base-claude.md

echo ""
echo "## Services"
for dir in services/*/; do
  service=$(basename "$dir")
  echo "### $service"
  cat "$dir/CLAUDE_SECTION.md" 2>/dev/null || echo "No specific rules."
  echo ""
done
```

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Common Mistakes

### Mistake 1: Too Vague

```markdown
# Bad
Write good code.

# Good
Functions must be under 50 lines, use TypeScript strict mode,
handle errors with typed catch blocks, and include JSDoc comments.
```

### Mistake 2: Too Verbose

A 10-page CLAUDE.md wastes tokens on every interaction. Keep it under 500 lines. Move detailed documentation to separate files and reference them:

```markdown
## API Conventions
See docs/api-conventions.md for full API design guidelines.
Key rules: REST naming, JSON:API format, pagination via cursor.
```

### Mistake 3: Contradictory Rules

```markdown
# Contradictory (Claude gets confused)
- Use CSS Modules for styling
- Use Tailwind for all styling

# Clear
- Use Tailwind for all styling. No CSS Modules, no styled-components.
```

### Mistake 4: Rules Without Rationale

Claude follows rules better when it understands why:

```markdown
# Without rationale
- No barrel exports

# With rationale (Claude follows this more consistently)
- No barrel exports (index.ts re-exports).
  Reason: They break tree-shaking and make imports ambiguous.
  Import from the specific file: import { Button } from './Button'
```

### Mistake 5: Never Updating

Your CLAUDE.md should evolve with your project. When you find yourself correcting Claude repeatedly, add the correction to CLAUDE.md. Schedule a monthly review to prune outdated rules.

## Measuring CLAUDE.md Effectiveness

Track these metrics before and after implementing a CLAUDE.md:

1. **First-draft acceptance rate**: What percentage of Claude's code goes to production without edits?
2. **Correction frequency**: How often do you tell Claude to change something it should have known?
3. **Style consistency**: Does Claude-generated code match your existing codebase style?
4. **Onboarding time**: How quickly do new team members understand the project through CLAUDE.md?

A good CLAUDE.md achieves 70%+ first-draft acceptance rate. An excellent one hits 85%+.

## Frequently Asked Questions

### How long should CLAUDE.md be?
Aim for 100-300 lines. Under 100 is too sparse; over 500 wastes tokens. Every line should pull its weight.

### Should I commit CLAUDE.md to git?
Yes. It is a project configuration file. Team members need it. Treat it like .eslintrc or tsconfig.json.

### Can I have multiple CLAUDE.md files?
Yes. Root-level for project-wide rules, subdirectory-level for module-specific rules. Claude merges them with subdirectory rules taking priority.

### Does CLAUDE.md work with Claude.ai (web)?
CLAUDE.md is specifically for Claude Code (the terminal tool). On claude.ai, use the Projects feature to set persistent instructions.

### How do I know if Claude is following my CLAUDE.md?
Review its first few outputs carefully. If Claude violates a rule, remind it. If it keeps violating the same rule, the rule may be unclear. Rewrite it with an example.

### Should I include examples in CLAUDE.md?
Yes, for complex or ambiguous rules. A before/after example communicates more clearly than a paragraph of description.

### Can CLAUDE.md reference other files?
Yes. Use phrases like "See docs/api-guide.md for API conventions." Claude will read the referenced file when the rule is relevant.

### How does CLAUDE.md interact with hooks?
[Hooks](/claude-code-hooks-complete-guide/) enforce rules mechanically (block dangerous commands, auto-format). CLAUDE.md teaches Claude behavioral rules (code style, architecture). Use both together for maximum effectiveness.

### Does CLAUDE.md affect token costs?
Yes. The CLAUDE.md content is included in every request as context tokens. A 300-line CLAUDE.md adds roughly 1,000-2,000 tokens per request. Monitor impact with [token usage auditing](/audit-claude-code-token-usage-step-by-step/) and see [cost optimization strategies](/best-claude-code-cost-saving-tools-2026/) for balancing quality vs cost.

### Can I use CLAUDE.md with the spec workflow?
Yes. CLAUDE.md defines project-wide rules while [spec files](/claude-code-spec-workflow-guide/) define feature-specific requirements. They complement each other: CLAUDE.md says "how we code" and specs say "what to build." Add a rule to CLAUDE.md like "Always read the relevant spec from specs/ before implementing."

### How does CLAUDE.md work with MCP servers?
CLAUDE.md can reference [MCP server](/claude-code-mcp-server-setup/) capabilities. For example: "Use the Supabase MCP server for all database queries. Do not write raw SQL through Bash." This guides Claude to use the right tools. See our [Supabase MCP guide](/claude-code-mcp-supabase-setup-guide/) for integration details.

### Can I use CLAUDE.md with SuperClaude?
Yes. [SuperClaude](/super-claude-code-framework-guide/) generates a CLAUDE.md during installation. You can customize it or merge SuperClaude's generated file with your existing CLAUDE.md. Project-specific rules in your CLAUDE.md take precedence over SuperClaude's defaults.

### How do I handle CLAUDE.md for different environments?
Use conditional sections. For example, add "When running in CI mode (--print flag), skip interactive prompts and always run tests." For environment-specific configuration, reference separate config files rather than embedding environment details directly.

### Does CLAUDE.md work with OpenRouter?
Yes. CLAUDE.md is a local configuration file that Claude Code loads regardless of the API provider. Whether you use the direct Anthropic API, [OpenRouter](/claude-code-openrouter-setup-guide/), or another compatible endpoint, CLAUDE.md instructions apply identically.


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### How long should CLAUDE.md be?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Aim for 100-300 lines. Under 100 is too sparse; over 500 wastes tokens. Every line should pull its weight."
      }
    },
    {
      "@type": "Question",
      "name": "Should I commit CLAUDE.md to git?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. It is a project configuration file. Team members need it. Treat it like .eslintrc or tsconfig.json."
      }
    },
    {
      "@type": "Question",
      "name": "Can I have multiple CLAUDE.md files?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Root-level for project-wide rules, subdirectory-level for module-specific rules. Claude merges them with subdirectory rules taking priority."
      }
    },
    {
      "@type": "Question",
      "name": "Does CLAUDE.md work with Claude.ai (web)?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "CLAUDE.md is specifically for Claude Code (the terminal tool). On claude.ai, use the Projects feature to set persistent instructions."
      }
    },
    {
      "@type": "Question",
      "name": "How do I know if Claude is following my CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Review its first few outputs carefully. If Claude violates a rule, remind it. If it keeps violating the same rule, the rule may be unclear. Rewrite it with an example."
      }
    },
    {
      "@type": "Question",
      "name": "Should I include examples in CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, for complex or ambiguous rules. A before/after example communicates more clearly than a paragraph of description."
      }
    },
    {
      "@type": "Question",
      "name": "Can CLAUDE.md reference other files?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Use phrases like \\\"See docs/api-guide.md for API conventions.\\\" Claude will read the referenced file when the rule is relevant."
      }
    },
    {
      "@type": "Question",
      "name": "How does CLAUDE.md interact with hooks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Hooks enforce rules mechanically (block dangerous commands, auto-format). CLAUDE.md teaches Claude behavioral rules (code style, architecture). Use both together for maximum effectiveness."
      }
    },
    {
      "@type": "Question",
      "name": "Does CLAUDE.md affect token costs?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. The CLAUDE.md content is included in every request as context tokens. A 300-line CLAUDE.md adds roughly 1,000-2,000 tokens per request. Monitor impact with token usage auditing and see cost optimization strategies for balancing quality vs cost."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use CLAUDE.md with the spec workflow?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. CLAUDE.md defines project-wide rules while spec files define feature-specific requirements. They complement each other: CLAUDE.md says \\\"how we code\\\" and specs say \\\"what to build.\\\" Add a rule to CLAUDE.md like \\\"Always read the relevant spec from specs/ before implementing.\\\""
      }
    },
    {
      "@type": "Question",
      "name": "How does CLAUDE.md work with MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "CLAUDE.md can reference MCP server capabilities. For example: \\\"Use the Supabase MCP server for all database queries. Do not write raw SQL through Bash.\\\" This guides Claude to use the right tools. See our Supabase MCP guide for integration details."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use CLAUDE.md with SuperClaude?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. SuperClaude generates a CLAUDE.md during installation. You can customize it or merge SuperClaude's generated file with your existing CLAUDE.md. Project-specific rules in your CLAUDE.md take precedence over SuperClaude's defaults."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle CLAUDE.md for different environments?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use conditional sections. For example, add \\\"When running in CI mode (--print flag), skip interactive prompts and always run tests.\\\" For environment-specific configuration, reference separate config files rather than embedding environment details directly."
      }
    },
    {
      "@type": "Question",
      "name": "Does CLAUDE.md work with OpenRouter?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. CLAUDE.md is a local configuration file that Claude Code loads regardless of the API provider. Whether you use the direct Anthropic API, OpenRouter, or another compatible endpoint, CLAUDE.md instructions apply identically."
      }
    }
  ]
}
</script>

## See Also

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Hooks Complete Guide](/claude-code-hooks-complete-guide/)
- [Claude Code Spec Workflow Guide](/claude-code-spec-workflow-guide/)
- [Super Claude Code Framework Guide](/super-claude-code-framework-guide/)
- [Configuration Reference](/configuration/). Complete Claude Code settings and configuration guide

{% endraw %}
