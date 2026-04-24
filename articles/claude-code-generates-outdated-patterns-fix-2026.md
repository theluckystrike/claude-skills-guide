---
title: "Fix Claude Code Using Outdated Patterns (2026)"
description: "Stop Claude Code from generating deprecated APIs, old React patterns, and outdated library usage — add version pinning and pattern rules to CLAUDE.md."
permalink: /claude-code-generates-outdated-patterns-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Using Outdated Patterns (2026)

Claude Code generates code with deprecated APIs, old framework patterns, and outdated library syntax. Here's how to pin it to current practices.

## The Problem

Common outdated patterns Claude Code generates:
- React class components instead of functional components
- `getServerSideProps` in a Next.js App Router project
- `useEffect` for data fetching instead of Server Components
- `var` instead of `const`/`let`
- CommonJS `require()` in ES module projects
- Deprecated library APIs

## Root Cause

Claude Code's training data spans years of code. Older patterns appear more frequently in the training set (more Stack Overflow answers, more tutorials, more repos). Without explicit guidance, statistical likelihood favors older patterns.

## The Fix

```markdown
## Modern Patterns (enforced)

### JavaScript/TypeScript
- ES modules only (import/export, never require/module.exports)
- const/let only, never var
- async/await, never callback chains
- Optional chaining (?.) and nullish coalescing (??) over verbose null checks
- TypeScript strict mode patterns

### React (if applicable)
- Functional components ONLY, never class components
- Hooks for state and effects, never lifecycle methods
- Server Components by default (Next.js App Router)
- Server Actions for mutations, not API routes

### Node.js
- Node 20+ APIs (native fetch, node:test, etc.)
- ESM imports for built-in modules (node:fs, node:path)
```

## CLAUDE.md Rule to Add

```markdown
## Version Awareness
- Check package.json for library versions before using their APIs
- Use the API for the installed version, not the latest or oldest version
- When uncertain about the current API, reference the [local docs mirror](/claude-code-docs-offline-mirror-guide-2026/) or ask
- NEVER use deprecated APIs. If you're unsure if an API is deprecated, check first.
```

## Verification

```
Create a new page that fetches and displays user data
```

**Outdated:** uses `getServerSideProps`, `useEffect(() => fetch(...))`, class component
**Current:** uses async Server Component, `await` data fetching, functional component

Related: [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) | [Claude Code Docs Mirror](/claude-code-docs-offline-mirror-guide-2026/)
