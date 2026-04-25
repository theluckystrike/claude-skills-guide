---
title: "Goal-Driven Execution: Project Examples"
description: "Claude Code resource: four project scenarios showing Karpathy's Goal-Driven Execution in practice — API fixes, React features, CLI tools, and database..."
permalink: /karpathy-goal-driven-examples-2026/
last_tested: "2026-04-22"
---

# Goal-Driven Execution: Project Examples (2026)

Four scenarios demonstrating how Goal-Driven Execution keeps Claude Code on track across different project types.

## The Principle

Every action serves the stated goal. Report tangential findings, don't act on them. See the [full guide](/karpathy-goal-driven-execution-principle-2026/).

## Example 1: API Bug Fix

**User request:** "The /api/products endpoint returns 500 when the category filter is empty string"

### Without Goal-Driven Execution

Claude Code investigates, finds the bug (empty string isn't handled in the WHERE clause), and then:
- Fixes the bug
- Adds validation for all query parameters
- Refactors the SQL query to use a query builder
- Adds pagination (it wasn't paginated)
- Creates an integration test
- Updates the API documentation

Changed 5 files, 180 lines.

### With Goal-Driven Execution

```
**Goal:** Fix 500 error on /api/products when category filter is empty string.
**Success criteria:** GET /api/products?category= returns 200 with all products.

Root cause: Empty string passed directly to SQL WHERE clause:
WHERE category = '' matches nothing and triggers a type error downstream.

Fix: Treat empty string as "no filter."
```

```diff
  const category = req.query.category;
- const products = await db.query('SELECT * FROM products WHERE category = $1', [category]);
+ const products = category
+   ? await db.query('SELECT * FROM products WHERE category = $1', [category])
+   : await db.query('SELECT * FROM products');
```

```
**Goal complete.** 3 lines changed in src/routes/products.ts.

**Noticed but not fixed:**
- No pagination on this endpoint (all products returned)
- Other query params (price_min, price_max) also lack empty-string handling
- No integration tests for the products endpoint
- API docs don't mention the category filter parameter
```

## Example 2: React Feature Addition

**User request:** "Add a dark mode toggle to the settings page"

### Without Goal-Driven Execution

Claude Code adds the toggle but also:
- Creates a ThemeProvider context wrapping the entire app
- Adds CSS variables for 20 color tokens
- Updates every component to use the new color tokens
- Adds system-preference detection
- Persists the preference to localStorage
- Animates the transition between modes

Changed 14 files, 400+ lines.

### With Goal-Driven Execution

```
**Goal:** Add a dark mode toggle to the settings page.
**Files likely affected:** src/pages/Settings.tsx, src/styles/globals.css
**Out of scope:** theme propagation to other pages, system preference
detection, transition animations.

I'll add a toggle switch on the settings page that applies a
.dark class to the document root. The existing Tailwind dark: prefix
will handle the style changes.
```

```typescript
// src/pages/Settings.tsx — added toggle
function DarkModeToggle() {
  const [dark, setDark] = useState(
    document.documentElement.classList.contains('dark')
  );

  function toggle() {
    document.documentElement.classList.toggle('dark');
    setDark(!dark);
    localStorage.setItem('theme', !dark ? 'dark' : 'light');
  }

  return (
    <label className="flex items-center gap-2">
      <input type="checkbox" checked={dark} onChange={toggle} />
      Dark mode
    </label>
  );
}
```

```
**Goal complete.** Toggle added to settings page. Persists to localStorage.
**Changed:** src/pages/Settings.tsx (+18 lines)

**Noticed but not fixed:**
- No system preference detection (prefers-color-scheme)
- Other pages don't read the theme on initial load
- No transition animation between modes
- Color tokens could be extracted to CSS variables for consistency

**Suggested follow-ups:**
1. Add theme initialization in _app.tsx to read localStorage on page load
2. Add system preference detection as fallback
```

## Example 3: CLI Tool Enhancement

**User request:** "Add a --verbose flag to the build command"

### With Goal-Driven Execution

```
**Goal:** Add --verbose flag to the build command.
**Success criteria:** `mycli build --verbose` prints detailed output;
without flag, behavior unchanged.
**Files:** src/commands/build.ts, src/types.ts (add flag to BuildOptions)
```

```typescript
// src/commands/build.ts
program
  .command('build')
  .option('-v, --verbose', 'Print detailed build output')
  .action(async (options) => {
    const result = await runBuild({
      ...options,
      verbose: options.verbose ?? false,
    });
    if (options.verbose) {
      console.log(`Files processed: ${result.fileCount}`);
      console.log(`Duration: ${result.duration}ms`);
      console.log(`Output: ${result.outputDir}`);
    }
  });
```

```
**Goal complete.** --verbose flag added to build command.
**Changed:** src/commands/build.ts (+8 lines), src/types.ts (+1 line)

**Noticed but not fixed:**
- Other commands (test, lint) don't have a verbose flag either
- No --quiet flag for suppressing even normal output
- Build output directory isn't logged even in non-verbose mode
```

## Example 4: Database Migration

**User request:** "Add an `avatar_url` column to the users table"

### With Goal-Driven Execution

```
**Goal:** Add avatar_url column to users table.
**Success criteria:** Migration runs, column exists, nullable text type.
**Files:** migrations/new migration file, src/db/schema.ts
```

```sql
-- migrations/20260422_add_avatar_url.sql
ALTER TABLE users ADD COLUMN avatar_url TEXT;
```

```typescript
// src/db/schema.ts — add to existing users schema
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(),
  name: text('name').notNull(),
  avatarUrl: text('avatar_url'),  // <-- added
  createdAt: timestamp('created_at').defaultNow(),
});
```

```
**Goal complete.** Migration created, schema updated.
**Changed:** migrations/20260422_add_avatar_url.sql (new), src/db/schema.ts (+1 line)

**Noticed but not fixed:**
- No API endpoint for uploading/updating avatars
- No default avatar fallback in the frontend
- Users table lacks an updated_at column
```

## Common Mistakes

1. **Follow-up suggestions that become tasks** — "Suggested follow-ups" should not be acted on unless the user says so.

2. **Noticed-but-not-fixed as a guilt trip** — the list is informational, not pressuring. Claude Code shouldn't say "these really should be fixed."

3. **Over-declaring scope** — "Out of scope: everything I didn't mention" is too broad. List specific things the user might expect that aren't included.

## Related Principles

- [Implement Goal-Driven Execution](/karpathy-goal-driven-implementation-2026/) — CLAUDE.md rules
- [Fix Claude Code Losing Track](/karpathy-goal-driven-debugging-2026/) — debugging drift
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) — broader patterns


## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
