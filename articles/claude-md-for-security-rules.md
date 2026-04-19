---
title: "CLAUDE.md for Security Rules — Prevent Vulnerabilities at Generation Time (2026)"
description: "Encode security rules in CLAUDE.md to prevent Claude Code from generating SQL injection, XSS, insecure authentication, and other common vulnerabilities."
permalink: /claude-md-security-rules/
render_with_liquid: false
categories: [claude-md, patterns]
tags: [claude-md, security, vulnerabilities, authentication, claude-code]
last_updated: 2026-04-19
---

## Shift Security Left to Generation Time

Most security vulnerabilities enter codebases through code generation and copy-paste. Claude Code generates significant amounts of code, which makes your CLAUDE.md the first line of defense. When Claude follows explicit security rules, it produces code that is secure by default rather than requiring security reviews to catch problems after the fact.

This works because security rules are overwhelmingly concrete and verifiable -- exactly the type of instruction Claude follows most reliably.

## Core Security Rules Template

```markdown
## Security Rules (MANDATORY — violations are production bugs)

### Input Validation
- ALL user input validated with zod schemas before processing
- Validate on the server, never trust client-side validation alone
- Reject unexpected fields — use zod .strict() mode
- File uploads: validate MIME type, enforce size limit (10MB default), scan filename for path traversal

### SQL and Database
- NEVER construct SQL strings with template literals or concatenation
- Use parameterized queries exclusively (Prisma handles this — never bypass with $queryRawUnsafe)
- Database credentials in environment variables, never in code or CLAUDE.md

### Authentication
- Passwords hashed with bcrypt, cost factor 12 minimum
- JWT tokens: RS256 signing, 15-minute access token, 7-day refresh token
- Session tokens: 256-bit random, stored server-side
- NEVER log authentication tokens, passwords, or session IDs
- Failed login responses: same message for wrong email and wrong password

### Output Encoding
- HTML output: escape with DOMPurify before rendering user content
- JSON responses: no raw user input in error messages
- Headers: set Content-Type explicitly, never rely on browser sniffing

### Secrets Management
- Environment variables for all secrets — loaded from src/config/env.ts
- NEVER hardcode API keys, database URLs, or signing keys
- NEVER commit .env files — .env.example with placeholder values only
- Rotate secrets: document rotation procedure in docs/security/
```

## Path-Specific Security Rules

Different areas of your codebase have different security concerns. Use `.claude/rules/` to scope them:

```markdown
# .claude/rules/api-security.md
---
paths:
  - "src/routes/**/*.ts"
  - "src/middleware/**/*.ts"
---

## API Security Rules
- Rate limiting on all public endpoints: 100 req/min per IP default
- CORS: explicit allowlist of origins, never wildcard (*) in production
- CSRF: validate tokens on all state-changing requests
- Request size limit: 1MB default, 10MB for file upload endpoints only
- Authentication middleware on all routes except /health and /auth/login
- Authorization check on every route — verify user has required role/permission
```

```markdown
# .claude/rules/frontend-security.md
---
paths:
  - "src/components/**/*.tsx"
  - "src/pages/**/*.tsx"
---

## Frontend Security Rules
- NEVER use dangerouslySetInnerHTML without DOMPurify.sanitize()
- Links with user-provided URLs: validate protocol is http or https
- Form submissions: include CSRF token from meta tag
- Local storage: no sensitive data (tokens, PII). Use httpOnly cookies.
- Third-party scripts: load with integrity hash (SRI)
```

## Handling Sensitive Data

```markdown
## Data Classification
- PII (names, emails, addresses): encrypt at rest, mask in logs
- Financial data: never log, never cache, always encrypt in transit
- Health data: separate database schema, additional access logging
- Credentials: never in code, never in logs, never in error messages

## Logging Security
- Log: request ID, user ID, action, timestamp, IP address
- NEVER log: request bodies containing passwords, tokens, or PII
- Mask: show first and last character only for emails in logs (j***n@e***e.com)
- Retention: 90 days for access logs, 1 year for security audit logs
```

## Enterprise Managed CLAUDE.md for Security

Organizations deploying Claude Code across teams can use managed CLAUDE.md to enforce security rules that individual developers cannot disable:

```markdown
# Deployed to: /Library/Application Support/ClaudeCode/CLAUDE.md (macOS)
# This file cannot be excluded by claudeMdExcludes

## Organization Security Policy
- All code must pass OWASP Top 10 checks
- No new dependencies without security audit
- All API endpoints require authentication except /health
- Data retention limits apply to all log statements
```

Managed CLAUDE.md files deploy through MDM on macOS, Group Policy on Windows, or configuration management tools like Ansible on Linux. They load before project-level CLAUDE.md and cannot be overridden.

## Testing Security Rules

Verify Claude follows your security rules by asking it to generate code in a known-vulnerable pattern:

```
Ask: "Add an endpoint that takes a username from the query string
      and looks it up in the database"

Expected: Claude uses parameterized query through repository layer,
          validates input with zod, rate-limits the endpoint

Red flag: Claude constructs SQL with string interpolation
```

If Claude generates insecure code despite your rules, run `/memory` to verify the security rules file is loaded. Check for contradictions with other instruction files.

For the full CLAUDE.md structure including security sections, see the [senior engineer template](/senior-engineer-claude-md-template/). For error handling patterns that complement security rules, see the [error handling guide](/claude-md-error-handling-patterns/). For team-wide security policy deployment, see the [team collaboration guide](/claude-md-team-collaboration-best-practices/).
