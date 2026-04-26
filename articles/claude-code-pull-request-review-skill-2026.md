---
layout: post
title: "Claude Code Pull Request Review Skill (2026)"
description: "Build a Claude Code skill for automated PR reviews. Code quality checks, security scanning, and review comment generation with examples."
permalink: /claude-code-pull-request-review-skill-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---
{% raw %}

## The Workflow

Create a reusable Claude Code skill that reviews pull requests for code quality, security issues, performance concerns, and style guide compliance. The skill generates structured review comments that can be posted directly to GitHub PRs.

Expected time: 20-30 minutes to build the skill
Prerequisites: Claude Code installed, GitHub CLI (gh) configured, repository with pull requests

## Setup

### 1. Create the Skill Directory

```bash
mkdir -p .claude/skills/pr-review
```

### 2. Write the PR Review Skill

```bash
cat > .claude/skills/pr-review/SKILL.md << 'EOF'
---
name: pr-review
description: >
  Reviews pull requests for code quality, security, performance,
  and style guide compliance. Generates structured feedback.
  Triggers on "review PR", "check PR", "review pull request".
---

# Pull Request Review Skill

When reviewing a pull request:

## Process
1. Get the PR diff using `gh pr diff <number>`
2. Get PR metadata using `gh pr view <number>`
3. Analyze changes against the checklist below
4. Generate structured review comments

## Review Checklist

### Security
- No hardcoded secrets, API keys, or credentials
- No SQL injection vectors (raw string concatenation in queries)
- No unsafe deserialization
- Input validation present on all user-facing endpoints
- Authentication/authorization checks not bypassed

### Code Quality
- Functions under 50 lines
- No deeply nested conditionals (max 3 levels)
- Error handling present (no swallowed errors)
- No console.log or print statements left in
- Dead code removed (commented-out blocks)
- DRY: no copy-pasted logic blocks

### Performance
- No N+1 query patterns
- Database queries use appropriate indexes
- Large lists paginated, not loaded entirely
- No synchronous blocking in async contexts
- Memoization used for expensive computations

### Testing
- New code has corresponding tests
- Edge cases covered (null, empty, boundary values)
- No flaky test patterns (timers, race conditions)
- Mocks cleaned up properly

### Style
- Follows project CLAUDE.md conventions
- Consistent naming patterns
- Imports organized and no unused imports
- TypeScript: no `any` types

## Output Format
For each issue found, output:
```
**[SEVERITY]** file:line - description
Suggestion: specific fix recommendation
```

Severity levels: CRITICAL, HIGH, MEDIUM, LOW, NIT
EOF
```

### 3. Verify the Skill Loads

```bash
claude --print "List available skills"
# Expected output:
# Should include "pr-review" in the list
```

## Usage Example

Use the skill to review a pull request:

```bash
# Review PR #42
claude --print "Review PR 42 using the pr-review skill"
```

Here is what the skill produces in practice. Given a PR that adds a new API endpoint:

```typescript
// The PR contains this new file: src/api/users/search.ts
import { Router } from 'express';
import { db } from '../../db';

const router = Router();

router.get('/search', async (req, res) => {
  const query = req.query.q;
  const results = await db.raw(`SELECT * FROM users WHERE name LIKE '%${query}%'`);
  console.log('Search results:', results);
  res.json(results);
});

export default router;
```

The skill generates this review:

```markdown
## PR Review: #42 — Add user search endpoint

### Issues Found: 4

**[CRITICAL]** src/api/users/search.ts:8 - SQL injection vulnerability
The query parameter is concatenated directly into a SQL string without
sanitization. An attacker can inject arbitrary SQL.
Suggestion: Use parameterized queries:
```sql
SELECT * FROM users WHERE name LIKE ?
```
```typescript
const results = await db.raw(
  'SELECT * FROM users WHERE name LIKE ?',
  [`%${query}%`]
);
```

**[HIGH]** src/api/users/search.ts:8 - No input validation
The `q` query parameter is used without validation. It could be
undefined, empty, or excessively long.
Suggestion: Add validation with a max length:
```typescript
const query = req.query.q;
if (!query || typeof query !== 'string' || query.length > 100) {
  return res.status(400).json({ error: 'Invalid search query' });
}
```

**[MEDIUM]** src/api/users/search.ts:9 - Console.log left in code
Debug logging should not ship to production.
Suggestion: Remove the console.log or replace with project logger:
```typescript
import { logger } from '../../lib/logger';
logger.debug('Search executed', { query, resultCount: results.length });
```

**[LOW]** src/api/users/search.ts:8 - SELECT * is inefficient
Fetching all columns is wasteful and may expose sensitive fields.
Suggestion: Select only needed columns:
```sql
SELECT id, name, email, avatar_url FROM users WHERE name LIKE ?
```

### Summary
- 1 CRITICAL (must fix before merge)
- 1 HIGH (should fix before merge)
- 1 MEDIUM (fix recommended)
- 1 LOW (improvement suggestion)

**Recommendation: REQUEST CHANGES**
```

Automate reviews with a Git hook or GitHub Action:

```bash
# Post review comments to GitHub
cat > .github/workflows/claude-review.yml << 'WORKFLOW'
name: Claude PR Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get PR diff
        run: gh pr diff ${{ github.event.number }} > /tmp/pr-diff.txt
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Run Claude review
        run: |
          claude --print "Review this diff for security, quality, and style issues. Output as GitHub review comments in JSON format: $(cat /tmp/pr-diff.txt)" > /tmp/review.json
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
WORKFLOW
```

## Common Issues

- **Skill triggers on unrelated prompts:** Add more specific trigger phrases in the skill description. The phrase "Triggers on" controls when the skill auto-activates.
- **Review misses project-specific patterns:** Add your project's conventions to the root CLAUDE.md. The PR review skill reads project context automatically and will flag violations of your specific rules.
- **Too many NITs overwhelming the review:** Add a severity filter to your prompt: "Only report CRITICAL and HIGH severity issues" for focused reviews on large PRs.

## Why This Matters

Automated PR reviews catch security vulnerabilities and code quality issues before human reviewers see the PR. This reduces review cycles from days to minutes for common issues.

## Related Guides

- [Best Claude Skills for Code Review Automation](/best-claude-skills-for-code-review-automation/)
- [AI-Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
- [Claude Code for GitHub Actions Workflows](/claude-code-skills-for-creating-github-actions-workflows/)

## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


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
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>

{% endraw %}
