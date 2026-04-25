---
layout: default
title: "Surgical Changes (2026)"
description: "Five diff-minimizing examples showing how Karpathy's Surgical Changes principle keeps Claude Code modifications focused and reviewable."
permalink: /karpathy-surgical-changes-examples-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Surgical Changes: Diff-Minimizing Examples (2026)

Five real scenarios where the Surgical Changes principle transforms Claude Code's output from sprawling diffs to focused, reviewable modifications.

## The Principle

Minimum necessary diff. See the [full guide](/karpathy-surgical-changes-principle-2026/) and [implementation rules](/karpathy-surgical-changes-implementation-2026/).

## Example 1: Fix a Typo in an Error Message

**Task:** Change "Authetication failed" to "Authentication failed"

### Unsurgical (Claude Code's Default)

```diff
- export function authenticate(req, res, next) {
+ export function authenticate(
+   req: Request,
+   res: Response,
+   next: NextFunction
+ ): void {
    const token = req.headers.authorization?.split(' ')[1];
-   if (!token) {
-     return res.status(401).json({ error: 'Authetication failed' });
-   }
+   if (!token) {
+     res.status(401).json({
+       error: 'Authentication failed',
+       code: 'NO_TOKEN',
+     });
+     return;
+   }
    // ... rest unchanged
  }
```

12 lines changed. Added types, restructured the return, added an error code.

### Surgical

```diff
-     return res.status(401).json({ error: 'Authetication failed' });
+     return res.status(401).json({ error: 'Authentication failed' });
```

1 line. The typo is fixed.

## Example 2: Add a New Field to a Database Query

**Task:** Include `created_at` in the user list response

### Unsurgical

```diff
  async function getUsers() {
-   const users = await db.users.findMany({
-     select: { id: true, name: true, email: true }
-   });
-   return users;
+   try {
+     const users = await db.users.findMany({
+       select: { id: true, name: true, email: true, createdAt: true },
+       orderBy: { createdAt: 'desc' },
+     });
+     return users.map(user => ({
+       ...user,
+       createdAt: user.createdAt.toISOString(),
+     }));
+   } catch (error) {
+     console.error('Failed to fetch users:', error);
+     throw new Error('Failed to fetch users');
+   }
  }
```

15 lines changed. Added error handling, ordering, and date formatting — none of which were requested.

### Surgical

```diff
-     select: { id: true, name: true, email: true }
+     select: { id: true, name: true, email: true, createdAt: true }
```

1 line. `createdAt` is now in the response.

## Example 3: Change a Default Configuration Value

**Task:** Change the default session timeout from 30 minutes to 60 minutes

### Unsurgical

```diff
- const SESSION_TIMEOUT = 30 * 60 * 1000; // 30 minutes in ms
+ // Session configuration
+ const SESSION_CONFIG = {
+   timeout: 60 * 60 * 1000,    // 60 minutes
+   renewalThreshold: 0.5,       // Renew when 50% expired
+   maxSessions: 5,              // Per user
+   cookieName: 'session_id',
+ } as const;
+
+ const SESSION_TIMEOUT = SESSION_CONFIG.timeout;
```

10 lines changed. Created a config object, added 3 unrelated config values.

### Surgical

```diff
- const SESSION_TIMEOUT = 30 * 60 * 1000; // 30 minutes in ms
+ const SESSION_TIMEOUT = 60 * 60 * 1000; // 60 minutes in ms
```

1 line. The value changed. The comment updated.

## Example 4: Add Validation to One Field

**Task:** Add email format validation to the registration endpoint

### Unsurgical

```diff
  app.post('/register', async (req, res) => {
-   const { email, password, name } = req.body;
+   const schema = z.object({
+     email: z.string().email('Invalid email format'),
+     password: z.string().min(8, 'Password must be at least 8 characters'),
+     name: z.string().min(1, 'Name is required').max(100),
+   });
+
+   const result = schema.safeParse(req.body);
+   if (!result.success) {
+     return res.status(400).json({ errors: result.error.flatten() });
+   }
+
+   const { email, password, name } = result.data;
    // ... rest of registration logic
  });
```

12 lines changed. Added validation for all 3 fields when only email was requested.

### Surgical

```diff
  app.post('/register', async (req, res) => {
    const { email, password, name } = req.body;
+
+   if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
+     return res.status(400).json({ error: 'Invalid email format' });
+   }
+
    // ... rest of registration logic
  });
```

4 lines added. Only email validation, as requested.

**Noticed but not fixed:**
- password and name fields lack validation (separate task)

## Example 5: Rename a Route Path

**Task:** Change `/api/users` to `/api/v2/users`

### Unsurgical

```diff
- app.get('/api/users', getUsers);
- app.post('/api/users', createUser);
- app.get('/api/users/:id', getUser);
- app.put('/api/users/:id', updateUser);
- app.delete('/api/users/:id', deleteUser);
+ const API_VERSION = 'v2';
+ const usersRouter = express.Router();
+
+ usersRouter.get('/', getUsers);
+ usersRouter.post('/', createUser);
+ usersRouter.get('/:id', getUser);
+ usersRouter.put('/:id', updateUser);
+ usersRouter.delete('/:id', deleteUser);
+
+ app.use(`/api/${API_VERSION}/users`, usersRouter);
```

12 lines changed. Extracted a router and version variable when the task was just changing a path.

### Surgical

```diff
- app.get('/api/users', getUsers);
- app.post('/api/users', createUser);
- app.get('/api/users/:id', getUser);
- app.put('/api/users/:id', updateUser);
- app.delete('/api/users/:id', deleteUser);
+ app.get('/api/v2/users', getUsers);
+ app.post('/api/v2/users', createUser);
+ app.get('/api/v2/users/:id', getUser);
+ app.put('/api/v2/users/:id', updateUser);
+ app.delete('/api/v2/users/:id', deleteUser);
```

5 string changes. The paths are updated. No structural refactoring.

## Common Mistakes

1. **Treating surgical as lazy** — surgical diffs require more discipline, not less. Claude Code must resist the urge to "improve" while it's in the file.

2. **Not distinguishing between changes and additions** — adding new code (a new endpoint, a new test) isn't subject to surgical constraints. Modifying existing code is.

3. **Over-applying to test files** — tests often need broader changes to cover new behavior. Surgical constraints apply mainly to production code modifications.

## Related Principles

- [Fix Claude Code Touching Unrelated Files](/karpathy-surgical-changes-debugging-2026/) — when surgical rules fail
- [Stop Claude Code Touching Unrelated Files](/claude-code-touches-unrelated-files-fix-2026/) — problem-specific fix
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) — broader patterns


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Related Guides

- [Claude Code Version History and Changes](/claude-code-version-history-changes-2026/)
- [Fix Claude Md Changes Not Taking Effect](/claude-md-changes-not-taking-effect-fix-guide/)
- [Make Claude Code Explain Its Changes](/claude-code-doesnt-explain-changes-fix-2026/)
- [Fix Claude API Timeout](/claude-api-timeout-error-handling-retry-guide/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json."
      }
    }
  ]
}
</script>
