---
title: "RLS Policy Debugging with Claude Code"
description: "Debug Supabase RLS policies with Claude Code using a structured approach that reduces debugging token cost from 50K to 10K tokens per incident."
permalink: /rls-policy-debugging-claude-code-structured-approach/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# RLS Policy Debugging with Claude Code: Structured Approach

## The Pattern

Structured RLS debugging provides Claude Code with a systematic policy verification workflow that eliminates trial-and-error debugging, reducing token consumption from 50K-100K tokens per RLS incident to 8K-15K tokens.

## Why It Matters for Token Cost

Row Level Security (RLS) policy errors in Supabase are among the most expensive errors to debug with Claude Code. The errors are opaque ("new row violates row-level security policy"), the policies are SQL-based and spread across migrations, and the interaction between multiple policies is non-obvious.

Without a structured approach, Claude Code typically:
1. Reads the error message (500 tokens)
2. Reads the migration files to find policies (5K-15K tokens)
3. Reads the client code to understand the request context (3K-8K tokens)
4. Attempts a fix (5K-10K tokens)
5. Tests the fix, fails, repeats steps 2-4 (another 13K-33K tokens)

Total per incident: 26K-66K tokens ($0.08-$0.20 Sonnet, $0.39-$0.99 Opus). With retries: 50K-100K tokens.

The structured approach provides Claude with the policy map, common patterns, and a diagnostic checklist upfront, resolving most issues in a single pass.

## The Anti-Pattern (What NOT to Do)

```markdown
# No RLS context in CLAUDE.md or skills -- Claude must discover everything

# Claude's investigation (expensive):
# Step 1: Read supabase/migrations/ directory listing (~500 tokens)
# Step 2: Read 5-10 migration files looking for policies (~10K-30K tokens)
# Step 3: Read the failing client code (~3K tokens)
# Step 4: Attempt fix in wrong migration file (~5K tokens)
# Step 5: Realize policies are cumulative, re-read all migrations (~10K tokens)
# Step 6: Write correct policy (~5K tokens)
# Total: 33K-53K tokens minimum
```

## The Pattern in Action

### Step 1: Create an RLS Policy Map

```markdown
# .claude/skills/rls-policies.md

## Active RLS Policies (updated 2026-04-22)

### users table
| Policy | Operation | Check | Notes |
|--------|-----------|-------|-------|
| users_select_own | SELECT | auth.uid() = id | Users read own profile |
| users_update_own | UPDATE | auth.uid() = id | Users edit own profile |
| users_admin_all | ALL | is_admin(auth.uid()) | Admins have full access |

### posts table
| Policy | Operation | Check | Notes |
|--------|-----------|-------|-------|
| posts_select_published | SELECT | status = 'published' | Public read |
| posts_select_own | SELECT | auth.uid() = user_id | Authors read own drafts |
| posts_insert_auth | INSERT | auth.uid() IS NOT NULL | Auth users create |
| posts_update_own | UPDATE | auth.uid() = user_id | Authors edit own |
| posts_delete_admin | DELETE | is_admin(auth.uid()) | Admin only delete |

### comments table
| Policy | Operation | Check | Notes |
|--------|-----------|-------|-------|
| comments_select_all | SELECT | true | Public read |
| comments_insert_auth | INSERT | auth.uid() IS NOT NULL | Auth users comment |
| comments_delete_own | DELETE | auth.uid() = user_id | Delete own comments |

## Helper Functions
- is_admin(uid): checks users.role = 'admin'
- auth.uid(): current JWT sub claim
- auth.role(): current JWT role claim
```

Loading this skill costs ~400 tokens. It replaces 10K-30K tokens of migration file reading.

### Step 2: Create a Diagnostic Checklist

```markdown
# .claude/skills/rls-debug-checklist.md

## RLS Debug Steps (follow in order)
1. Identify the table and operation (SELECT/INSERT/UPDATE/DELETE)
2. Look up the applicable policy in rls-policies.md
3. Check: does the auth context match the policy condition?
4. Common failures:
   - INSERT fails: user not authenticated (auth.uid() IS NULL)
   - SELECT returns empty: no policy for this role/condition combo
   - UPDATE fails: user_id doesn't match auth.uid()
   - "violates RLS policy": check WITH CHECK clause, not just USING
5. Test with SQL:
   ```sql
   SET LOCAL role = 'authenticated';
   SET LOCAL request.jwt.claims = '{"sub":"<user-id>","role":"user"}';
   -- Then run the failing query
   ```
6. Fix: modify policy in a NEW migration (never edit existing migrations)
```

### Step 3: Register in CLAUDE.md

```markdown
# CLAUDE.md

## RLS Debugging
- Policy map: .claude/skills/rls-policies.md
- Debug checklist: .claude/skills/rls-debug-checklist.md
- ALWAYS follow the debug checklist for RLS errors
- NEVER modify existing migration files
- After fixing, update rls-policies.md to reflect the change
```

## Before and After

| Metric | Unstructured Debugging | Structured Approach | Savings |
|--------|----------------------|---------------------|---------|
| Token cost per incident | 50K-100K | 8K-15K | 80-85% |
| Migration files read | 5-10 | 0-1 | 90%+ |
| Fix attempts | 2-4 | 1-1.5 | 50-63% |
| Time to resolution | 10-20 min | 3-5 min | 70% |
| Monthly cost (3 incidents/week, Sonnet) | $7.80-$15.60 | $1.25-$2.34 | $6.55-$13.26 |

## When to Use This Pattern

- Any project using Supabase with RLS enabled (which should be all projects)
- Teams with more than 5 tables under RLS
- Projects where RLS errors occur weekly or more frequently
- Multi-developer teams where policy knowledge is not shared equally

## When NOT to Use This Pattern

- Projects with only 1-2 simple tables
- Projects not using RLS (though RLS should always be enabled in production)
- Projects where database access is handled entirely through edge functions with service role key

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md

## Database Security
- All tables have RLS enabled -- NEVER disable RLS
- Policy reference: .claude/skills/rls-policies.md
- Debug protocol: .claude/skills/rls-debug-checklist.md

## Policy Change Protocol
1. Create new migration: supabase migration new <name>
2. Write policy change in the migration
3. Test locally: supabase db reset && run tests
4. Update .claude/skills/rls-policies.md with the change
5. Never ALTER or DROP a policy in an existing migration
```

## Advanced: Multi-Table RLS Debugging

The most expensive RLS debugging scenarios involve queries that join multiple tables, each with their own RLS policies. Claude must understand the policy on each table to diagnose why a join query fails.

### The Problem with Joined Queries

```sql
-- This query fails with "permission denied" but the error
-- does not specify which table's RLS policy blocked it
SELECT posts.*, users.email
FROM posts
JOIN users ON posts.user_id = users.id
WHERE posts.status = 'published';
```

Without the policy map, Claude must read RLS policies for both `posts` and `users`, then test each independently. Cost: 30K-50K tokens.

### The Structured Debug Approach

```markdown
# .claude/skills/rls-debug-joins.md

## Join Debugging Protocol
1. Test each table independently:
   - Can the user SELECT from posts? (check posts policies)
   - Can the user SELECT from users? (check users policies)
2. The failing table is the one with the restrictive policy
3. Common fix: add a policy for the join scenario

## Common Join Issues
| Join | Likely Blocker | Fix |
|------|---------------|-----|
| posts + users | users_select_own | Add: users_select_for_posts (select email where id in post.user_id) |
| comments + users | users_select_own | Add: users_select_public_profile |
| posts + tags | None (both public) | Check if junction table post_tags has RLS |
```

With this skill, Claude diagnoses join-related RLS issues in 5K-10K tokens instead of 30K-50K. **Savings: 67-80%.**

### Preventing RLS Issues at Design Time

Add RLS design rules to CLAUDE.md to prevent issues before they occur:

```markdown
# CLAUDE.md

## RLS Design Rules
- Every new table MUST have at least one SELECT policy
- Join-friendly policies: if table A joins table B, B must have a policy
  that allows reading rows referenced by A
- Service role bypass: edge functions use service role (bypasses RLS)
  Client code NEVER uses service role
- Test all policies after creation: run scripts/test-rls.sh
```

### Automated RLS Policy Verification

```bash
#!/bin/bash
# scripts/test-rls.sh -- verify RLS policies
set -uo pipefail

echo "=== RLS Policy Verification ==="

# Test as authenticated user
supabase db reset > /dev/null 2>&1

# Test each critical query
tests_passed=0
tests_failed=0

# Test 1: User can read own profile
result=$(psql "$DATABASE_URL" -c "
SET LOCAL role = 'authenticated';
SET LOCAL request.jwt.claims = '{\"sub\":\"test-user-id\"}';
SELECT count(*) FROM users WHERE id = 'test-user-id';
" --csv --quiet 2>&1)
if echo "$result" | grep -q "1"; then
    echo "PASS: User reads own profile"
    ((tests_passed++))
else
    echo "FAIL: User cannot read own profile"
    ((tests_failed++))
fi

# Test 2: User can read published posts
result=$(psql "$DATABASE_URL" -c "
SET LOCAL role = 'authenticated';
SELECT count(*) FROM posts WHERE status = 'published';
" --csv --quiet 2>&1)
if echo "$result" | grep -qP "[1-9]"; then
    echo "PASS: User reads published posts"
    ((tests_passed++))
else
    echo "FAIL: User cannot read published posts"
    ((tests_failed++))
fi

echo ""
echo "Results: $tests_passed passed, $tests_failed failed"
exit $tests_failed
```

Running this verification after every RLS policy change costs approximately 500 tokens per run in Claude Code. Without verification, a broken policy may trigger a debugging session costing 20K-50K tokens. The verification script pays for itself on the first use.

## Keeping the Policy Map Current

The policy map skill is only valuable if it reflects the actual database state. Add a post-migration hook that reminds developers to update the map:

```bash
# In package.json scripts or a git hook
# After running: supabase migration new <name>
echo "REMINDER: Update .claude/skills/rls-policies.md with any new or changed policies"
```

A stale policy map is worse than no map at all, because Claude trusts the skill content and will propose fixes based on outdated policy information. Budget 5 minutes per migration to keep the skill synchronized, which prevents 15-30 minutes of misdirected debugging per incident.

## Related Guides

- [Reducing Claude Code Token Usage for Database Operations](/reducing-claude-code-token-usage-database-operations/) -- broader database optimization
- [Structured Error Returns](/structured-error-returns-format-affects-agent-tokens/) -- making Supabase errors agent-friendly
- [Cost Optimization Hub](/cost-optimization/) -- all cost optimization guides
