---
layout: default
title: "Initialize Claude Code in Existing Project (2026)"
description: "Add Claude Code to an existing codebase. Setup CLAUDE.md, configure permissions, and get productive in an established project."
permalink: /initialize-claude-code-existing-project-2026/
date: 2026-04-26
---

# Initialize Claude Code in Existing Project (2026)

Starting Claude Code in a new project is straightforward — there is no existing context to understand. Starting in an existing project with thousands of files, established conventions, and years of history is a different challenge. You need to give Claude enough context to be useful without overwhelming it or wasting tokens on irrelevant information.

This guide covers the process of integrating Claude Code into a project that already exists. For a guided setup experience, use the [Project Starter tool](/starter/).

## Step 1: Run /init

Start Claude Code in your project root and generate the initial context:

```bash
cd /path/to/your/project
claude
/init
```

Claude scans your project structure and generates a `CLAUDE.md` file. For existing projects, this file will be more detailed than for new ones because Claude has real code to analyze.

Review the generated file immediately. `/init` makes reasonable guesses, but it might:
- Miss custom build commands
- Misidentify the framework version
- Overlook important conventions
- Include irrelevant details about generated files

## Step 2: Customize CLAUDE.md

Edit the generated `CLAUDE.md` to reflect reality, not guesses. Focus on these sections:

### Project description (2-3 sentences)

```markdown
# Payment Processing Service

Handles Stripe payment flows for the main web app.
Express API with PostgreSQL, deployed on AWS ECS.
Processes ~50K transactions/day in production.
```

### Build and test commands

List the exact commands your team uses:

```markdown
## Commands
- pnpm dev — start development server
- pnpm test — run jest tests
- pnpm test:e2e — run Playwright E2E tests
- pnpm build — production build
- pnpm lint — ESLint check
- pnpm db:migrate — run migrations
- pnpm db:seed — seed development data
```

### Architecture decisions

Document the decisions Claude cannot infer from code:

```markdown
## Architecture
- Hexagonal architecture: domain/ has no external imports
- Events published to SQS, consumed by Lambda handlers
- Feature flags via LaunchDarkly (check before adding conditional logic)
- No ORM — raw SQL with pg-typed for type safety
```

### Conventions

Capture the rules that your team follows but may not be written anywhere:

```markdown
## Conventions
- Error codes: E1xxx for auth, E2xxx for payments, E3xxx for inventory
- All API responses follow { data, error, meta } envelope
- Database columns: snake_case. TypeScript types: camelCase
- Never modify migration files after merge to main
- Feature branches: feature/TICKET-123-description
```

Keep the total under 400 words. See [CLAUDE.md templates](/10-claude-md-templates-project-types/) for examples by project type.

## Step 3: Configure Permissions

Create `.claude/settings.json` with permissions that match your project's tools:

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git *)",
      "Bash(pnpm *)",
      "Bash(jest *)",
      "Bash(tsc --noEmit)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force*)",
      "Bash(pnpm publish*)"
    ]
  }
}
```

Adapt the allow list to your specific build tools. Use the [Permissions Configurator](/permissions/) to generate this configuration interactively.

## Step 4: Orient Claude to the Codebase

In your first working session, give Claude a guided tour. Do not ask it to "understand the entire codebase" — that wastes tokens reading irrelevant files. Instead, orient it to the area you are working on:

```
I'm working on the payment processing module.
Key files:
- src/services/payment.service.ts (main logic)
- src/routes/payment.routes.ts (API endpoints)
- src/models/payment.model.ts (database schema)
- tests/payment.test.ts (existing tests)

Read these files and confirm you understand the payment flow.
```

This focused orientation costs 2,000-5,000 tokens instead of the 50,000+ tokens that broad exploration would require. For token awareness, use the [Token Estimator](/token-estimator/).

## Step 5: Create Custom Commands

For tasks specific to your project, create custom slash commands in `.claude/commands/`:

`.claude/commands/pr-review.md`:
```markdown
Review the staged changes for:
1. Our error code convention (E1xxx/E2xxx/E3xxx)
2. API response envelope format
3. Missing tests for new code paths
4. Database migration safety (no column drops, no data loss)
```

`.claude/commands/debug-payment.md`:
```markdown
Read the last 50 lines of logs from the payment service.
Identify the error, trace it to the source code, and suggest a fix.
Check if this error pattern has a known resolution in our error handling guide.
```

Commit these to the repository so the whole team benefits. See the [hidden commands guide](/claude-code-hidden-commands-2026/) for more patterns.

## Step 6: Add to .gitignore

Ensure personal settings are not committed:

```
# .gitignore additions
.claude/settings.local.json
```

The shared settings (`.claude/settings.json` and `.claude/commands/`) should be committed. The local settings file is for personal preferences.

## Try It Yourself

The [Project Starter](/starter/) has an "existing project" mode that analyzes your codebase and generates optimized configuration. It produces:

- A customized CLAUDE.md based on actual project structure
- Permission settings matched to your detected tools
- Suggested custom commands based on your build scripts
- A .gitignore update with Claude-specific exclusions

This automated analysis catches details you might miss when writing CLAUDE.md manually.

## Common Pitfalls

### Over-documenting CLAUDE.md

A 2,000-word CLAUDE.md file costs ~2,600 tokens on every API call. Over a 50-message session, that is 130,000 tokens just for project context. Be terse. Every word should be information Claude cannot get from reading code.

### Not updating CLAUDE.md

The initial CLAUDE.md becomes stale as the project evolves. Review it monthly. Remove references to deleted files, update changed commands, and add new conventions as they emerge.

### Letting Claude explore freely

In a large existing project, Claude will try to read dozens of files to understand context. Each file costs 1,000-3,000 tokens. Guide it to specific files to control costs and keep context relevant.

### Ignoring existing team conventions

Claude follows conventions documented in CLAUDE.md. If your team has undocumented conventions (code review norms, commit message format, deployment procedures), document them. Claude cannot follow rules it does not know about.

## Integration Checklist

- [ ] `/init` run and CLAUDE.md reviewed
- [ ] CLAUDE.md customized with actual commands and conventions
- [ ] `.claude/settings.json` created with project permissions
- [ ] `.claude/settings.local.json` added to `.gitignore`
- [ ] Custom commands created for project-specific tasks
- [ ] Team informed about Claude Code integration
- [ ] First working session completed successfully

## Frequently Asked Questions

**Will /init overwrite my existing CLAUDE.md?**

Yes. If you already have a customized CLAUDE.md, back it up before running `/init`. Alternatively, skip `/init` and write CLAUDE.md manually from the start.

**How long does it take to set up Claude Code in an existing project?**

Initial setup takes 15-30 minutes: running /init, customizing CLAUDE.md, configuring permissions, and creating custom commands. The investment pays back immediately in faster Claude Code sessions.

**Should the whole team switch to Claude Code at once?**

No. Start with one or two developers as a pilot. They refine the CLAUDE.md and permissions configuration, then the rest of the team adopts the proven setup.

**What if my project uses tools not in the standard set?**

Add them to the allow list in settings.json with appropriate Bash patterns. If you use MCP servers for specialized tools, configure them in the mcpServers section. See the [settings.json guide](/claude-code-settings-json-explained-2026/).

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Will /init overwrite my existing CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. If you already have a customized CLAUDE.md, back it up before running /init. Alternatively, skip /init and write CLAUDE.md manually."
      }
    },
    {
      "@type": "Question",
      "name": "How long does it take to set up Claude Code in an existing project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Initial setup takes 15-30 minutes: running /init, customizing CLAUDE.md, configuring permissions, and creating custom commands. The investment pays back immediately."
      }
    },
    {
      "@type": "Question",
      "name": "Should the whole team switch to Claude Code at once?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Start with one or two developers as a pilot. They refine CLAUDE.md and permissions, then the team adopts the proven setup."
      }
    },
    {
      "@type": "Question",
      "name": "What if my project uses tools not in the standard set?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add them to the allow list in settings.json with appropriate Bash patterns. For specialized tools, configure MCP servers in the mcpServers section."
      }
    }
  ]
}
</script>



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

- [Project Starter](/starter/) — Guided project setup for existing codebases
- [CLAUDE.md Templates](/10-claude-md-templates-project-types/) — Templates by project type
- [settings.json Explained](/claude-code-settings-json-explained-2026/) — Configuration reference
- [Permissions Configurator](/permissions/) — Interactive permission setup
- [Onboarding Developers with Claude Code](/best-way-to-onboard-new-developers-using-claude-code/) — Team adoption guide
