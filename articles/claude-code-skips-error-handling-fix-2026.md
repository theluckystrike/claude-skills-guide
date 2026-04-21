---
title: "Make Claude Code Add Error Handling (2026)"
description: "Force Claude Code to include proper error handling with CLAUDE.md rules for boundary validation, error responses, and failure recovery patterns."
permalink: /claude-code-skips-error-handling-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Make Claude Code Add Error Handling (2026)

Claude Code generates the happy path and skips error handling. API endpoints return 500 on invalid input, async operations swallow errors, and edge cases crash the app.

## The Problem

- API endpoints with no input validation
- Async operations without catch blocks
- File operations that don't handle missing files
- Database queries that don't handle connection failures
- No null/undefined checks on external data

## Root Cause

Claude Code prioritizes completing the feature request. Error handling isn't part of "add a user endpoint" — it's an implicit requirement the model may skip, especially when focused on demonstrating the happy-path logic.

## The Fix

```markdown
## Error Handling (mandatory)

### API Endpoints
Every endpoint must handle:
- Invalid input (return 400 with specific field errors)
- Not found (return 404 with resource identifier)
- Unauthorized (return 401 with generic message)
- Server errors (return 500 with error ID, log full error)

### Async Operations
- Every await must be in a try/catch or use a Result type
- Never silently swallow errors (empty catch blocks)
- Log errors with context (what operation failed, what input caused it)

### External Dependencies
- Database queries: handle connection errors and query failures
- API calls: handle timeouts, 4xx, and 5xx responses
- File operations: handle missing files and permission errors

### Pattern
Follow the project's error handling pattern in [reference file].
When in doubt, fail loudly rather than silently.
```

## CLAUDE.md Rule to Add

```markdown
## Error Handling Checklist
After writing any function that:
- Accepts external input → add input validation
- Makes async calls → add error handling
- Reads files or environment → handle missing/invalid values
- Returns data to users → format errors consistently

No function that handles external data should assume the happy path.
```

## Verification

```
Create a POST /api/users endpoint
```

**Missing error handling:** only handles the success case, crashes on duplicate email, invalid input, or DB connection failure

**With error handling:**
```typescript
app.post('/api/users', async (req, res) => {
  const parsed = createUserSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ errors: parsed.error.flatten().fieldErrors });
  }

  try {
    const user = await db.users.create({ data: parsed.data });
    res.status(201).json(user);
  } catch (err) {
    if (err.code === '23505') { // unique violation
      return res.status(409).json({ error: 'Email already registered' });
    }
    console.error('Create user failed:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

Related: [Claude Code Best Practices](/claude-code-best-practices-2026/) | [CLAUDE.md Best Practices](/claude-md-file-best-practices-guide/) | [Fix Claude Code Wrong Abstraction](/claude-code-wrong-abstraction-level-fix-2026/)
