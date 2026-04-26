---
layout: default
title: "SuperClaude Framework Guide (2026)"
description: "Master the SuperClaude framework with all 30 slash commands, installation steps, configuration options, and when to use it over alternatives."
permalink: /super-claude-code-framework-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Super Claude Code (SuperClaude): Complete Guide (2026)

SuperClaude is a framework that extends Claude Code with 30 structured slash commands, personality modes, and opinionated workflows. It transforms Claude Code from a general-purpose AI coding assistant into a specialized development environment with predefined patterns for architecture, debugging, testing, and deployment.

This guide covers everything you need to know: what SuperClaude is, how to install it, every available command, configuration options, and when it makes sense to use versus rolling your own [CLAUDE.md](/claude-md-best-practices-definitive-guide/) setup.

## What Is SuperClaude?

SuperClaude is an open-source framework (MIT license) that layers on top of Claude Code. It provides:

- **30 slash commands** covering the full development lifecycle
- **Personality modes** that change Claude's behavior (mentor, architect, debugger, reviewer)
- **Structured prompts** that enforce consistent output formats
- **Project templates** for different tech stacks
- **Guardrails** that prevent common Claude Code mistakes

Think of it as a curated set of [best practices](/claude-code-claude-md-best-practices/) packaged into an installable framework rather than a separate tool. SuperClaude does not replace Claude Code. It configures Claude Code with specialized instructions through CLAUDE.md files and skill definitions.

## Why SuperClaude Exists

When developers use Claude Code without guidance, results vary widely. One session produces clean, tested code. The next session produces sprawling functions with no error handling. SuperClaude solves this consistency problem by:

1. **Standardizing prompts**: Each command includes a structured prompt that tells Claude exactly what output format to use
2. **Enforcing quality gates**: Commands include built-in checks (e.g., the `/test` command verifies coverage thresholds)
3. **Reducing context waste**: Pre-written system instructions mean you spend fewer tokens explaining what you want
4. **Codifying team standards**: Everyone on the team uses the same commands, getting the same output structure

## Installation

### Prerequisites

- Claude Code CLI installed and authenticated ([installation guide](/how-to-use-claude-code-beginner-guide/))
- Node.js 18+ or Bun 1.0+
- Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/nicbarajas/superClaude.git
cd superClaude
```

### Step 2: Run the Installer

```bash
chmod +x install.sh
./install.sh
```

The installer does three things:

1. Creates a `.claude/` directory in your project root
2. Copies all skill files (`.md` definitions) into `.claude/skills/`
3. Generates a `CLAUDE.md` file that references the skills

### Step 3: Verify Installation

```bash
ls .claude/skills/
```

You should see 30+ markdown files, one per slash command.

### Manual Installation (Alternative)

If you prefer not to run the install script:

```bash
mkdir -p .claude/skills
cp superClaude/skills/*.md .claude/skills/
cp superClaude/CLAUDE.md ./CLAUDE.md
```

Then edit `CLAUDE.md` to adjust paths if needed.

### Per-Project vs Global Installation

SuperClaude is designed for per-project installation. Each project gets its own `.claude/skills/` directory, which means you can customize commands per project.

For global installation (applying to all projects), place the files in `~/.claude/`:

```bash
mkdir -p ~/.claude/skills
cp superClaude/skills/*.md ~/.claude/skills/
```

Note that project-level files override global ones, so you can have a global baseline with per-project overrides.

## All 30 Slash Commands

Here is every SuperClaude command organized by category.

### Architecture & Planning

#### `/architect`
Generates system architecture documents. Produces diagrams (Mermaid), component breakdowns, data flow descriptions, and technology recommendations.

```
/architect "Design a multi-tenant SaaS billing system"
```

Output includes: system diagram, component list, API surface, data model, deployment topology.

#### `/design`
Creates detailed technical designs for specific features. More focused than `/architect`; covers a single feature rather than an entire system.

```
/design "User permission system with RBAC"
```

#### `/plan`
Breaks work into numbered, ordered tasks. Each task includes estimated effort, dependencies, and acceptance criteria.

```
/plan "Migrate from REST to GraphQL"
```

#### `/scaffold`
Generates project scaffolding: directory structure, config files, CI pipeline, Docker setup.

```
/scaffold "Next.js 15 app with Supabase and Stripe"
```

### Code Generation

#### `/build`
Writes production-ready code from a specification. Includes error handling, logging, types, and tests.

```
/build "Webhook handler for Stripe subscription events"
```

#### `/codegen`
Generates code from schemas, specs, or examples. Focused on mechanical code generation (e.g., types from a JSON schema).

```
/codegen "Generate TypeScript types from this OpenAPI spec"
```

#### `/implement`
Takes an existing design document and implements it. Pairs with `/design` output.

```
/implement "Build the RBAC system from design-doc.md"
```

#### `/proto`
Creates quick prototypes. Sacrifices production quality for speed. No tests, minimal error handling.

```
/proto "Chat interface with WebSocket backend"
```

### Quality & Testing

#### `/test`
Generates test suites. Supports unit, integration, and e2e tests. Includes coverage targets.

```
/test "Write tests for the payment service"
```

#### `/review`
Performs code review on specified files or diffs. Checks for bugs, security issues, performance problems, and style violations.

```
/review "Review src/auth/*.ts"
```

#### `/audit`
Deep security and performance audit. More thorough than `/review`. Checks for OWASP Top 10, N+1 queries, memory leaks.

```
/audit "Audit the authentication module"
```

#### `/lint`
Applies linting rules and suggests fixes. Integrates with project ESLint/Prettier config if present.

```
/lint "Fix all TypeScript strict mode errors"
```

### Debugging

#### `/debug`
Systematic debugging workflow. Reproduces the issue, identifies root cause, proposes fix, verifies fix.

```
/debug "Users see 500 error on checkout page"
```

#### `/trace`
Traces execution flow through the codebase. Shows call chain, data transformations, and side effects.

```
/trace "Follow a request from API endpoint to database"
```

#### `/diagnose`
Diagnoses system-level issues: performance bottlenecks, resource exhaustion, configuration problems.

```
/diagnose "App response time increased 3x after deployment"
```

### Documentation

#### `/doc`
Generates documentation: README, API docs, architecture decision records, runbooks.

```
/doc "Write API documentation for the billing service"
```

#### `/explain`
Explains existing code in plain language. Adjusts complexity based on the personality mode.

```
/explain "What does src/core/scheduler.ts do?"
```

#### `/annotate`
Adds inline comments to existing code. Does not modify logic; only adds explanatory comments.

```
/annotate "Add comments to the state machine implementation"
```

### Refactoring

#### `/refactor`
Restructures code without changing behavior. Includes before/after comparisons and migration steps.

```
/refactor "Extract the validation logic into a separate module"
```

#### `/optimize`
Performance optimization. Profiles, identifies bottlenecks, applies fixes, benchmarks results.

```
/optimize "Reduce API response time for /users endpoint"
```

#### `/modernize`
Updates code to use current language features, library versions, and patterns.

```
/modernize "Update from Express 4 to Express 5"
```

### DevOps & Deployment

#### `/deploy`
Generates deployment configurations: Dockerfiles, Kubernetes manifests, CI/CD pipelines, Terraform.

```
/deploy "Create production deployment for AWS ECS"
```

#### `/monitor`
Sets up monitoring: health checks, alerts, dashboards, logging configuration.

```
/monitor "Add monitoring for the payment processing pipeline"
```

#### `/incident`
Incident response workflow. Captures timeline, root cause analysis, remediation steps.

```
/incident "Database connection pool exhaustion at 2AM"
```

### Data & Database

#### `/migrate`
Generates database migrations with up/down scripts, data backups, and rollback plans.

```
/migrate "Add multi-currency support to the orders table"
```

#### `/seed`
Creates realistic seed data for development and testing.

```
/seed "Generate 1000 users with orders and reviews"
```

### Utilities

#### `/convert`
Converts between formats: JSON to YAML, REST to GraphQL, JavaScript to TypeScript.

```
/convert "Convert this Express app to Fastify"
```

#### `/compare`
Compares two approaches, libraries, or implementations. Produces a structured comparison table.

```
/compare "Redis vs Memcached for session storage"
```

#### `/estimate`
Estimates effort, cost, or resource requirements for a task.

```
/estimate "How long to add real-time notifications?"
```

#### `/changelog`
Generates changelogs from git history. Groups by feature, fix, breaking change.

```
/changelog "Generate changelog for v2.0 release"
```

## Personality Modes

SuperClaude includes personality modes that modify Claude's behavior across all commands.

### Mentor Mode
Explains decisions in detail. Includes learning notes. Points out patterns and anti-patterns. Best for junior developers or learning new technologies.

### Architect Mode
Thinks at system level. Prioritizes scalability, maintainability, and separation of concerns. Produces more diagrams and less code.

### Debugger Mode
Methodical and systematic. Follows strict reproduce-diagnose-fix-verify workflow. Never guesses.

### Reviewer Mode
Critical and thorough. Checks every edge case. Flags anything that could break in production.

### Speed Mode
Minimal explanation. Maximum code output. Skips non-essential documentation. Best for experienced developers who know what they want.

To activate a mode, set it in your CLAUDE.md:

```markdown
## Personality
Use ARCHITECT mode for all interactions.
```

Or switch mid-session:

```
Switch to DEBUGGER mode for the rest of this session.
```

## Configuration

### CLAUDE.md Integration

SuperClaude generates a `CLAUDE.md` file during installation. You can customize it:

```markdown
# Project Configuration

## Stack
- Runtime: Node.js 22
- Framework: Next.js 15
- Database: Supabase (PostgreSQL)
- Deployment: Vercel

## Standards
- All functions < 60 lines
- Minimum 80% test coverage
- No any types in TypeScript
- Every public function has JSDoc

## Personality
Use REVIEWER mode by default.

## Skills
Load all skills from .claude/skills/
```

### Customizing Individual Commands

Each command is a markdown file in `.claude/skills/`. To customize the `/build` command:

```bash
vim .claude/skills/build.md
```

Add project-specific rules:

```markdown
## Additional Rules
- Always use Zod for input validation
- Include OpenTelemetry spans in every function
- Error messages must include error codes (E001-E999)
```

### Disabling Commands

Remove the skill file to disable a command:

```bash
rm .claude/skills/proto.md  # Disable /proto if you don't want quick prototypes
```

### Creating Custom Commands

Add a new markdown file to `.claude/skills/`:

```markdown
# /mycommand

## Purpose
Describe what this command does.

## Input
What the user provides.

## Output Format
What Claude should produce.

## Rules
1. Rule one
2. Rule two

## Example
Show an example interaction.
```

## SuperClaude vs Rolling Your Own CLAUDE.md

| Factor | SuperClaude | Custom CLAUDE.md |
|--------|-------------|------------------|
| Setup time | 5 minutes | Hours to days |
| Consistency | High (pre-built) | Depends on effort |
| Flexibility | Moderate (can customize) | Full control |
| Learning curve | Low | Medium |
| Team adoption | Easy (just install) | Requires documentation |
| Token overhead | Higher (loads skills) | You control token budget |
| Updates | Pull from repo | Manual maintenance |

### When to Use SuperClaude

- **New to Claude Code**: SuperClaude gives you structured workflows immediately
- **Team standardization**: Everyone uses the same commands and output formats
- **Rapid prototyping**: `/scaffold` and `/proto` save significant setup time
- **Code review workflows**: `/review` and `/audit` provide consistent review formats

### When to Roll Your Own

- **Token-sensitive projects**: SuperClaude loads skill definitions that consume [context window tokens](/claude-code-high-token-usage/)
- **Highly specialized domains**: Medical, financial, or legal code needs domain-specific rules
- **Minimal setups**: If you only need 3-4 commands, 30 skill files are overhead
- **Performance-critical**: Loading 30 skill files adds latency to [Claude Code startup](/claude-code-slow-on-large-repos-fix-2026/)

## Real-World Usage Patterns

### Pattern 1: Feature Development Workflow

```
/plan "Add Stripe subscription management"
/design "Subscription lifecycle with webhooks"
/build "Implement the subscription service"
/test "Write tests for subscription service"
/review "Review src/services/subscription.ts"
/doc "Document the subscription API"
```

### Pattern 2: Bug Fix Workflow

```
/debug "Payments failing for annual plans"
/trace "Follow the annual plan payment flow"
/build "Fix: Apply annual discount before tax calculation"
/test "Add regression test for annual plan pricing"
```

### Pattern 3: Architecture Review

```
/architect "Review current microservices architecture"
/audit "Security audit of service-to-service communication"
/optimize "Reduce inter-service latency"
/doc "Write architecture decision record for changes"
```

### Pattern 4: Legacy Modernization

```
/modernize "Identify deprecated patterns in src/"
/refactor "Extract business logic from controllers"
/migrate "Update database schema for new data model"
/test "Ensure no regressions after refactoring"
```

## Token Usage Considerations

SuperClaude loads skill definitions into Claude's context, which counts against your [token budget](/audit-claude-code-token-usage-step-by-step/). Measured token costs:

- **Base CLAUDE.md**: ~500 tokens
- **Each skill file**: 200-800 tokens
- **All 30 skills loaded**: ~12,000-15,000 tokens
- **With personality mode**: +300-500 tokens

To reduce token usage:

1. Only install skills you actually use
2. Trim skill file descriptions to essentials
3. Use the `skills_on_demand` option if your version supports lazy loading
4. Monitor with `/cost` or [token tracking tools](/best-claude-code-cost-saving-tools-2026/)

## Troubleshooting

### Commands Not Recognized

If Claude Code does not recognize SuperClaude commands:

1. Verify `.claude/skills/` directory exists in your project root
2. Check that `CLAUDE.md` references the skills directory
3. Restart Claude Code (skill files are loaded at session start)

### Output Quality Issues

If command output does not match expected format:

1. Check that the personality mode is appropriate for the task
2. Verify the skill file has not been accidentally modified
3. Try adding more context to your command prompt
4. Check if your project `CLAUDE.md` has conflicting instructions

### Conflicts with Project CLAUDE.md

If you have an existing `CLAUDE.md`, SuperClaude's installer may overwrite it. Back up your file first:

```bash
cp CLAUDE.md CLAUDE.md.backup
./install.sh
# Then merge your custom rules back in
```

### Performance Degradation

If Claude Code responds slowly after installing SuperClaude:

1. Reduce the number of installed skills
2. Move rarely-used skills to a separate directory
3. Consider [lazy loading configurations](/claude-code-mcp-configuration-guide/)

## Updates and Community

SuperClaude is actively maintained. To update:

```bash
cd superClaude
git pull origin main
./install.sh --update
```

The update flag preserves your customizations while adding new skills and fixing existing ones.

Community resources:
- GitHub Issues for bug reports and feature requests
- Discord server for discussions
- [Claude Code community](/best-claude-code-repos-github-2026/) for shared configurations

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Alternatives to SuperClaude

### Aider
Aider is a terminal-based coding assistant that works with multiple LLMs. It focuses on git-integrated editing rather than structured commands. See our [aider comparison](/codex-vs-claude-code-comparison-2026/) for details.

### Custom Skills Framework
Build your own framework by creating individual [Claude Code skills](/best-claude-code-skills-ranked-2026/) without SuperClaude's full structure. This gives you maximum control at the cost of setup time.

### Cursor Rules
If you use Cursor IDE, `.cursorrules` files serve a similar purpose to SuperClaude's skill files but work within the Cursor environment rather than Claude Code's terminal.

### Claude Code Native Commands
Claude Code now includes built-in commands that overlap with some SuperClaude features. Check the [commands reference](/best-claude-code-commands-you-are-not-using-2026/) to see what ships natively.

## Frequently Asked Questions

### Does SuperClaude work with Claude Code Max plans?
Yes. SuperClaude works with any Claude Code authentication method: API key, Pro subscription, or [Max plan](/claude-pro-subscription-price-guide/). The framework only modifies local configuration files.

### Can I use SuperClaude with MCP servers?
Yes. SuperClaude and [MCP servers](/claude-code-mcp-server-setup/) are independent features. You can run Supabase MCP, GitHub MCP, or any other server alongside SuperClaude commands.

### Does SuperClaude send data to third parties?
No. SuperClaude is entirely local. It consists of markdown files that configure Claude Code's behavior. No data leaves your machine beyond normal Claude Code API calls.

### How do I uninstall SuperClaude?
Delete the `.claude/skills/` directory and remove SuperClaude references from your `CLAUDE.md`:
```bash
rm -rf .claude/skills/
# Edit CLAUDE.md to remove skill references
```

### Can I use only specific commands?
Yes. Delete the skill files you do not need from `.claude/skills/`. Only installed skill files are loaded.

### Does SuperClaude work with Claude Code hooks?
Yes. SuperClaude commands and [Claude Code hooks](/claude-code-hooks-complete-guide/) work independently. Hooks trigger on tool use events; SuperClaude commands are prompt-level instructions.

### Is SuperClaude free?
Yes. SuperClaude is open-source under the MIT license. No paid tiers or premium features.

### How often is SuperClaude updated?
The project publishes updates approximately monthly. Major Claude Code releases usually trigger a SuperClaude update within a week to add support for new features.


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### Does SuperClaude work with Claude Code Max plans?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. SuperClaude works with any Claude Code authentication method: API key, Pro subscription, or Max plan. The framework only modifies local configuration files."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use SuperClaude with MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. SuperClaude and MCP servers are independent features. You can run Supabase MCP, GitHub MCP, or any other server alongside SuperClaude commands."
      }
    },
    {
      "@type": "Question",
      "name": "Does SuperClaude send data to third parties?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. SuperClaude is entirely local. It consists of markdown files that configure Claude Code's behavior. No data leaves your machine beyond normal Claude Code API calls."
      }
    },
    {
      "@type": "Question",
      "name": "How do I uninstall SuperClaude?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Delete the .claude/skills/ directory and remove SuperClaude references from your CLAUDE.md: bash rm -rf .claude/skills/ # Edit CLAUDE.md to remove skill references "
      }
    },
    {
      "@type": "Question",
      "name": "Can I use only specific commands?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Delete the skill files you do not need from .claude/skills/. Only installed skill files are loaded."
      }
    },
    {
      "@type": "Question",
      "name": "Does SuperClaude work with Claude Code hooks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. SuperClaude commands and Claude Code hooks work independently. Hooks trigger on tool use events; SuperClaude commands are prompt-level instructions."
      }
    },
    {
      "@type": "Question",
      "name": "Is SuperClaude free?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. SuperClaude is open-source under the MIT license. No paid tiers or premium features."
      }
    },
    {
      "@type": "Question",
      "name": "How often is SuperClaude updated?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The project publishes updates approximately monthly. Major Claude Code releases usually trigger a SuperClaude update within a week to add support for new features."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## See Also

**Find commands →** Search all commands in our [Command Reference](/commands/).

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [CLAUDE.md Best Practices Definitive Guide](/claude-md-best-practices-definitive-guide/)
- [Claude Code Hooks Complete Guide](/claude-code-hooks-complete-guide/)
- [Claude Code Spec Workflow Guide](/claude-code-spec-workflow-guide/)


{% endraw %}