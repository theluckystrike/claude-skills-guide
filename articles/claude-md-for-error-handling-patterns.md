---
layout: default
title: "CLAUDE.md for Error Handling (2026)"
description: "Encode error handling rules in CLAUDE.md to stop Claude Code from generating try-catch-ignore blocks, untyped errors, and missing error boundaries."
permalink: /claude-md-error-handling-patterns/
date: 2026-04-20
categories: [claude-md, patterns]
tags: [claude-md, error-handling, patterns, result-type, claude-code]
last_updated: 2026-04-19
---

## The Default Error Handling Problem

Without explicit instructions, Claude Code defaults to generic try-catch blocks that catch `Error`, log a vague message, and re-throw or swallow the error. This produces code that compiles and passes basic tests but fails silently in production. You get log lines like "An error occurred" with no context about what failed, why, or what the user should do.

CLAUDE.md fixes this by specifying your project's error handling strategy as concrete rules Claude follows on every interaction.

## Error Handling Rules Template

Add these to your CLAUDE.md or a dedicated `.claude/rules/error-handling.md` file:

```markdown
## Error Handling Rules

### Error Types
- Use the AppError hierarchy from src/errors/
- AppError subtypes: ValidationError, NotFoundError, AuthError, ConflictError, ExternalServiceError
- Every error includes: message (user-safe), code (machine-readable), cause (original error)
- NEVER throw plain Error() or string literals

### Service Layer
- Return Result<T, AppError> from all service methods
- NEVER use try-catch for expected error cases (validation, not found, auth)
- Reserve try-catch for unexpected failures (network, database connection)
- Wrap external API errors in ExternalServiceError with the original error as cause

### Controller Layer
- Map AppError subtypes to HTTP status codes:
  - ValidationError → 400
  - AuthError → 401
  - NotFoundError → 404
  - ConflictError → 409
  - ExternalServiceError → 502
  - Unknown → 500
- Use the error middleware in src/middleware/error-handler.ts
- NEVER send stack traces in production responses

### Logging
- Log all errors through src/lib/logger.ts
- Include: error code, message, request ID, user ID (if authenticated), stack trace
- Log at ERROR level for 5xx, WARN level for 4xx
- NEVER use console.log or console.error for error logging
```

## The Result Type Pattern

If your project uses a Result type (common in TypeScript and Rust-influenced codebases), encode the pattern so Claude generates it consistently:

```typescript
// src/types/result.ts
type Result<T, E = AppError> =
  | { ok: true; value: T }
  | { ok: false; error: E };

// Usage in CLAUDE.md instruction:
// "Service methods return Result<T, AppError>. Check result.ok before accessing value."
```

The CLAUDE.md instruction for this pattern:

```markdown
## Result Type Usage
- Import Result from src/types/result.ts
- Service methods: return { ok: true, value: data } or { ok: false, error: new ValidationError(...) }
- Callers: always check result.ok before accessing result.value
- NEVER use type assertions to bypass Result checks
- Chain results with the pipe helper from src/utils/result-helpers.ts
```

## File-Specific Error Rules

Different parts of your codebase need different error handling. Use `.claude/rules/` with path patterns:

```markdown
# .claude/rules/api-errors.md
---
paths:
  - "src/routes/**/*.ts"
  - "src/middleware/**/*.ts"
---

## API Error Handling
- Every route handler is wrapped in asyncHandler from src/middleware/async-handler.ts
- Validation errors return the full list of field errors, not just the first one
- Rate limit errors include Retry-After header
- Authentication errors never reveal whether the user exists
```

This loads only when Claude works on API route files. Database error handling rules go in a separate file with paths matching repository files.

## Common Anti-Patterns to Block

Explicitly list what Claude should NOT generate:

```markdown
## Error Anti-Patterns (NEVER generate these)
- catch(e) { } — empty catch blocks that swallow errors
- catch(e) { console.log(e) } — logging without proper error handling
- catch(e: any) — untyped catch clauses
- throw new Error("Something went wrong") — generic messages without context
- return null — using null to signal errors instead of Result type
```

Negative instructions ("NEVER generate") work well for error handling because the anti-patterns are specific and Claude can check for them mechanically.

## Testing Error Paths

Add a rule that Claude includes error path tests:

```markdown
## Error Testing Requirements
- Every service method test file includes at least one test for each error case
- Test that the correct AppError subtype is returned
- Test that the error message contains actionable information
- Test that error logging occurs at the correct level
```

## Error Handling in Different Layers

Each layer of your application has different error handling responsibilities. Specify this clearly so Claude generates the right pattern in the right place:

```markdown
## Layer-Specific Error Handling
- Controllers: catch service errors, map to HTTP status codes, format response
- Services: return Result types for expected errors, throw for unexpected failures
- Repositories: catch ORM/database errors, wrap in domain-specific AppError subtypes
- Utilities: throw typed errors with descriptive messages, callers decide how to handle
```

Without layer-specific rules, Claude tends to put the same try-catch-log pattern everywhere. Making each layer's responsibility explicit produces code that handles errors at the appropriate level of abstraction.

## Monitoring and Alerting Integration

Your CLAUDE.md should also specify how error handling integrates with your monitoring stack:

```markdown
## Error Monitoring
- 5xx errors trigger PagerDuty alert via src/monitoring/alerts.ts
- 4xx errors above 10/minute trigger Slack notification
- All errors include correlation ID for distributed tracing
- Error context: include service name, operation name, and user ID (masked)
```

This ensures Claude generates code that participates in your observability pipeline rather than creating isolated error handling that monitoring systems cannot see.

For the complete CLAUDE.md writing guide, see the [best practices documentation](/claude-code-claude-md-best-practices/). If your error handling rules interact with architecture boundaries, see the [architecture decisions guide](/claude-md-for-architecture-decisions/). For database-specific error handling patterns, see the [database conventions guide](/claude-md-for-database-conventions-and-patterns/).

## Related Articles

- [Fix Claude Md For Error Handling Patterns — Quick Guide](/claude-md-for-error-handling-patterns-guide/)
- [Claude Code Prisma Error Handling Patterns (2026)](/claude-code-prisma-transactions-and-error-handling-patterns/)
- [Fix Claude Opus Prefill Not Supported Error — Quick Guide](/claude-opus-prefill-not-supported-error-fix/)
- [How to Use Claude Error Handling Patterns (2026)](/claude-code-for-claude-error-handling-patterns-workflow-guid/)
- [Error Handling Reference](/error-handling/). Complete error diagnosis and resolution guide

## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


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
