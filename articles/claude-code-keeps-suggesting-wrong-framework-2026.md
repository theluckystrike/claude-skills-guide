---
layout: default
title: "Fix Claude Code Suggesting Wrong (2026)"
description: "Stop Claude Code from suggesting Express when you use Fastify, or React when you use Vue, by pinning frameworks in CLAUDE.md."
permalink: /claude-code-keeps-suggesting-wrong-framework-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Fix Claude Code Suggesting the Wrong Framework (2026)

You ask Claude Code to add a route handler and it generates Express middleware. Your project runs Fastify. This mismatch burns time reverting suggestions and re-explaining your stack.

## The Problem

Claude Code defaults to the most common framework in its training data. Express beats Fastify. React beats Svelte. Jest beats Vitest. Without explicit instructions, the model falls back to the statistically popular choice, not your actual choice.

## Root Cause

Claude Code picks up framework signals from your code but weighs its training distribution heavily. If your project has 200 files using Fastify but the training data has millions of Express examples, the model's prior wins unless you override it.

The problem compounds when your project uses multiple frameworks that share similar APIs. Koa and Express route handlers look similar enough that Claude Code conflates them.

## The Fix

Use the framework-pinning pattern from [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills). The "Don't Assume" principle means you tell Claude Code exactly what to use and what to avoid.

The [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) also provides pre-built skill definitions for framework-specific coding that you can drop into your project.

### Step 1: Pin Your Stack Explicitly

Add to your `CLAUDE.md`:

```markdown
## Tech Stack — AUTHORITATIVE
- Runtime: Node.js 22 LTS
- Server: Fastify 5.x (NOT Express, NOT Koa, NOT Hapi)
- Frontend: Vue 3 Composition API (NOT React, NOT Svelte)
- ORM: Drizzle (NOT Prisma, NOT TypeORM, NOT Sequelize)
- Test runner: Vitest (NOT Jest, NOT Mocha)
- Package manager: pnpm (NOT npm, NOT yarn)
```

### Step 2: Include Pattern Examples

```markdown
## Route Pattern (Fastify)
Routes follow this exact pattern:

app.get('/users/:id', {
  schema: {
    params: Type.Object({ id: Type.String() }),
    response: { 200: UserSchema }
  }
}, async (request, reply) => {
  const user = await userService.findById(request.params.id);
  return reply.send(user);
});

DO NOT use Express-style (req, res, next) middleware chains.
```

### Step 3: Add Import Patterns

```markdown
## Import Rules
- Fastify plugins: import fp from 'fastify-plugin'
- Type definitions: import { FastifyInstance } from 'fastify'
- NEVER import from 'express' or '@types/express'
```

## CLAUDE.md Code to Add

```markdown
## Framework Enforcement
When generating code for this project:
1. Check existing files in the same directory for import patterns
2. Match the exact framework APIs used in neighboring files
3. If unsure which framework API to use, ask — do not guess
4. All server code uses Fastify decorators, not Express middleware
```

## Verification

Test with these prompts after updating your `CLAUDE.md`:

1. "Add a POST endpoint for creating comments" — should use Fastify schema validation, not Express body-parser
2. "Add a unit test for the user service" — should use `describe`/`it` from Vitest, not Jest globals
3. "Install a logging library" — should suggest pino (Fastify's default), not morgan (Express)

## Prevention

When you upgrade frameworks (e.g., Fastify 4 to 5), update your `CLAUDE.md` immediately. Outdated version numbers cause Claude Code to suggest deprecated APIs.

Use the [claude-code-templates](https://github.com/davila7/claude-code-templates) CLI to generate framework-specific CLAUDE.md sections:

```bash
npx claude-code-templates@latest
```

Select your framework from the menu to get a pre-built configuration block.

For more on structuring your CLAUDE.md, see the [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/). If you want Claude Code to automatically validate framework usage, explore [hooks](/understanding-claude-code-hooks-system-complete-guide/) that can lint generated code against your stack.

## See Also

- [Fix Claude Code Misunderstanding Requirements (2026)](/claude-code-misunderstands-requirements-fix-2026/)


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Claude Code Keeps Suggesting The Same](/claude-code-keeps-suggesting-the-same-broken-solution/)
- [Claude Code Wrong Environment Deploy](/claude-code-deploying-wrong-environment-prevent-mistakes/)
- [Fix Claude Code Wrong File Context](/claude-code-keeps-switching-to-wrong-file-context/)
- [Wrong Node.js Version in PATH Fix](/claude-code-wrong-node-version-in-path-fix-2026/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
