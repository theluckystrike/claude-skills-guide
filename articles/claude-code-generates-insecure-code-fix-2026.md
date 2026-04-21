---
title: "Fix Claude Code Generating Insecure Code (2026)"
description: "Prevent Claude Code from generating SQL injection, XSS, and auth vulnerabilities by adding security rules to your CLAUDE.md file."
permalink: /claude-code-generates-insecure-code-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Generating Insecure Code (2026)

Claude Code writes a database query using string concatenation. Or it stores a JWT in localStorage. Or it skips input sanitization on a form handler. These are not hypothetical — they happen when security rules are not explicitly configured.

## The Problem

Common security issues in Claude Code output:
- SQL injection via string interpolation in queries
- XSS vulnerabilities from unescaped user input
- Secrets hardcoded in source files
- Insecure authentication token storage
- Missing CSRF protection
- Overly permissive CORS configurations
- Insufficient input validation

## Root Cause

Claude Code generates code that works functionally but does not apply security best practices by default. The model learned from millions of code examples, including insecure tutorials, Stack Overflow answers, and quick-start guides that prioritize simplicity over safety.

Without explicit security requirements, Claude Code takes the shortest path to functional code.

## The Fix

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) (4K+ stars) includes a full threat modeling section with 271 quiz questions for testing security awareness. Use its security checklist as a starting point for your CLAUDE.md.

### Step 1: Add Security Rules

```markdown
## Security Rules — MANDATORY
### Database
- ALL queries use parameterized statements (never string concat)
- Use ORM methods (Prisma/Drizzle) for all database access
- Raw SQL requires explicit approval with justification

### Authentication
- JWTs stored in httpOnly cookies ONLY (never localStorage)
- All passwords hashed with bcrypt (cost factor 12+)
- Session tokens: 256-bit random, rotated on privilege changes

### Input Handling
- ALL user input validated with Zod schemas at the boundary
- HTML output escaped by default (React JSX handles this)
- File uploads: validate MIME type, enforce size limits, scan for malware

### Secrets
- NEVER hardcode API keys, passwords, or tokens in source code
- ALL secrets via environment variables (process.env)
- .env files in .gitignore — ALWAYS
```

### Step 2: Add Output Encoding Rules

```markdown
## Output Security
- API responses: strip internal IDs, timestamps, stack traces in production
- Error messages: generic for clients, detailed in server logs only
- CORS: explicit origin allowlist, never wildcard in production
- Headers: Helmet.js defaults applied to all responses
```

### Step 3: Add Dependency Security

```markdown
## Dependency Rules
- No packages with known CVEs (check npm audit before suggesting)
- Prefer well-maintained packages (100+ GitHub stars, recent commits)
- NEVER install packages that request filesystem or network access beyond their stated purpose
```

## CLAUDE.md Code to Add

```markdown
## Security Verification
Before completing any feature that handles user data:
1. List all user inputs and how each is validated
2. List all database queries and confirm parameterization
3. Check that no secrets are hardcoded
4. Verify error responses do not leak internal details
```

## Verification

1. Ask Claude Code to "add a search endpoint that queries users by name"
2. Check: Does it use parameterized queries or ORM methods?
3. Check: Is the search input validated before reaching the database?
4. Check: Does the response exclude sensitive fields like password hashes?

## Prevention

Add security linting to your CI pipeline. The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) index lists security-focused skills and MCP servers that can scan Claude Code output for vulnerabilities in real time.

For more on securing your Claude Code workflow, see the [security threat model guide](/claude-code-security-threat-model-2026/). Review [best security tools for Claude Code](/best-claude-code-security-tools-2026/) for automated scanning options. Learn about CI integration in our [CI/CD guide](/claude-code-ci-cd-integration-guide-2026/).
