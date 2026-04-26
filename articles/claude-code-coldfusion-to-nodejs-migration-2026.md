---
layout: default
title: "Claude Code for ColdFusion to Node.js (2026)"
permalink: /claude-code-coldfusion-to-nodejs-migration-2026/
date: 2026-04-20
description: "Migrate Adobe ColdFusion CFML applications to Node.js with Claude Code. Convert CFCs, custom tags, and cfquery to modern Express APIs."
last_tested: "2026-04-22"
domain: "web migration"
---

## Why Claude Code for ColdFusion Migration

Adobe ColdFusion applications power thousands of government, education, and enterprise intranets built in the early 2000s. The CFML tag-based language, ColdFusion Components (CFCs), and cfquery inline SQL create a tightly coupled architecture that mixes presentation, logic, and data access on every page. ColdFusion's licensing costs and shrinking developer pool push organizations toward Node.js, but the implicit variable scoping (variables, session, application, request), struct/query types, and Application.cfc lifecycle have no direct Node.js equivalent.

Claude Code parses CFML templates, extracts cfquery SQL into parameterized prepared statements, converts CFCs to Express route handlers, and replaces ColdFusion's implicit type coercion with explicit JavaScript validation.

## The Workflow

### Step 1: Inventory the ColdFusion Application

```bash
# Catalog CFML files
mkdir -p ~/cf-migration/{source,output}
find /path/to/cfapp -type f \( \
  -name "*.cfm" -o -name "*.cfc" -o -name "*.cfr" \) \
  | sort > ~/cf-migration/inventory.txt

# Count patterns that need conversion
echo "cfquery tags: $(grep -rn '<cfquery' /path/to/cfapp --include='*.cfm' --include='*.cfc' | wc -l)"
echo "cfoutput blocks: $(grep -rn '<cfoutput' /path/to/cfapp --include='*.cfm' | wc -l)"
echo "cfinclude: $(grep -rn '<cfinclude' /path/to/cfapp --include='*.cfm' | wc -l)"
echo "CFC components: $(find /path/to/cfapp -name '*.cfc' | wc -l)"
echo "Custom tags: $(grep -rn '<cf_' /path/to/cfapp --include='*.cfm' | wc -l)"
```

### Step 2: Convert CFCs and cfquery to Express Routes

Original ColdFusion CFC:

```cfm
<!--- UserService.cfc --->
<cfcomponent displayname="UserService" output="false">

  <cffunction name="getUser" access="public" returntype="query" output="false">
    <cfargument name="userID" type="numeric" required="true">

    <cfquery name="qUser" datasource="myDSN">
      SELECT u.user_id, u.first_name, u.last_name, u.email,
             r.role_name
      FROM users u
      INNER JOIN roles r ON u.role_id = r.role_id
      WHERE u.user_id = <cfqueryparam value="#arguments.userID#"
                                       cfsqltype="cf_sql_integer">
        AND u.is_active = 1
    </cfquery>

    <cfreturn qUser>
  </cffunction>

  <cffunction name="searchUsers" access="public" returntype="query">
    <cfargument name="searchTerm" type="string" required="true">
    <cfargument name="maxRows" type="numeric" default="50">

    <cfquery name="qSearch" datasource="myDSN" maxrows="#arguments.maxRows#">
      SELECT user_id, first_name, last_name, email
      FROM users
      WHERE (first_name LIKE <cfqueryparam value="%#arguments.searchTerm#%"
                                            cfsqltype="cf_sql_varchar">
         OR last_name LIKE <cfqueryparam value="%#arguments.searchTerm#%"
                                          cfsqltype="cf_sql_varchar">)
        AND is_active = 1
      ORDER BY last_name, first_name
    </cfquery>

    <cfreturn qSearch>
  </cffunction>

  <cffunction name="createUser" access="public" returntype="numeric">
    <cfargument name="userData" type="struct" required="true">

    <cftransaction>
      <cfquery name="qInsert" datasource="myDSN" result="insertResult">
        INSERT INTO users (first_name, last_name, email, role_id, is_active)
        VALUES (
          <cfqueryparam value="#arguments.userData.firstName#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#arguments.userData.lastName#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#arguments.userData.email#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#arguments.userData.roleID#" cfsqltype="cf_sql_integer">,
          1
        )
      </cfquery>
    </cftransaction>

    <cfreturn insertResult.generatedKey>
  </cffunction>

</cfcomponent>
```

Claude Code converts to Express + node-postgres:

```javascript
// routes/users.js
const express = require('express');
const router = express.Router();
const { pool } = require('../db');
const { body, param, query, validationResult } = require('express-validator');

// GET /api/users/:id — replaces UserService.getUser()
router.get('/:id',
  param('id').isInt({ min: 1 }),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { rows } = await pool.query(`
        SELECT u.user_id, u.first_name, u.last_name, u.email,
               r.role_name
        FROM users u
        INNER JOIN roles r ON u.role_id = r.role_id
        WHERE u.user_id = $1 AND u.is_active = true
      `, [req.params.id]);

      if (rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }
      res.json(rows[0]);
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/users/search?q=term&limit=50 — replaces searchUsers()
router.get('/search',
  query('q').isString().isLength({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 200 }).toInt(),
  async (req, res, next) => {
    try {
      const limit = req.query.limit || 50;
      const searchTerm = `%${req.query.q}%`;

      const { rows } = await pool.query(`
        SELECT user_id, first_name, last_name, email
        FROM users
        WHERE (first_name ILIKE $1 OR last_name ILIKE $1)
          AND is_active = true
        ORDER BY last_name, first_name
        LIMIT $2
      `, [searchTerm, limit]);

      res.json({ users: rows, count: rows.length });
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/users — replaces createUser()
router.post('/',
  body('firstName').isString().trim().isLength({ min: 1, max: 100 }),
  body('lastName').isString().trim().isLength({ min: 1, max: 100 }),
  body('email').isEmail().normalizeEmail(),
  body('roleId').isInt({ min: 1 }),
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { firstName, lastName, email, roleId } = req.body;
      const { rows } = await pool.query(`
        INSERT INTO users (first_name, last_name, email, role_id, is_active)
        VALUES ($1, $2, $3, $4, true)
        RETURNING user_id
      `, [firstName, lastName, email, roleId]);

      res.status(201).json({ userId: rows[0].user_id });
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;
```

### Step 3: Convert Application.cfc Lifecycle

```javascript
// middleware/session.js — replaces Application.cfc session management
const session = require('express-session');
const PgSession = require('connect-pg-simple')(session);

// Application.cfc: sessionmanagement=true, sessiontimeout=#CreateTimeSpan(0,0,30,0)#
module.exports = session({
  store: new PgSession({ pool: require('../db').pool }),
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 30 * 60 * 1000 } // 30 minutes (was CreateTimeSpan)
});
```

### Step 4: Verify

```bash
# Initialize Node.js project
cd ~/cf-migration/output
npm init -y
npm install express pg express-validator express-session connect-pg-simple

# Run smoke tests
npm test

# Compare endpoint responses
curl -s http://localhost:8500/api/user.cfc?method=getUser&userID=1 | jq .
curl -s http://localhost:3000/api/users/1 | jq .
diff <(curl -s old-cf-app/api/users/1 | jq -S .) \
     <(curl -s localhost:3000/api/users/1 | jq -S .)
```

## CLAUDE.md for ColdFusion Migration

```markdown
# ColdFusion CFML to Node.js Migration Standards

## Domain Rules
- CFCs map to Express route modules (one CFC = one route file)
- cfquery maps to pg pool.query with parameterized $1, $2 placeholders
- cfqueryparam maps to query parameter array (prevents SQL injection)
- Application.cfc onSessionStart maps to express-session middleware
- cfinclude maps to Express middleware or router.use()
- ColdFusion structs map to plain JavaScript objects
- ColdFusion queries (recordsets) map to arrays of objects

## File Patterns
- Source: *.cfm (templates), *.cfc (components), Application.cfc
- Target: Express.js with node-postgres
- CFCs: src/routes/ (Express routers)
- Templates: src/views/ (EJS or Handlebars)
- Application.cfc: src/middleware/

## Common Commands
- npm install express pg express-validator helmet cors
- node --watch src/app.js
- npm test
- npx eslint src/
- psql -d app_db -f migrations/001_schema.sql
```

## Common Pitfalls in ColdFusion Migration

- **Implicit variable scoping:** ColdFusion's `variables`, `form`, `url`, `session`, `application` scopes have no Node.js parallel. Claude Code explicitly maps each scope to the correct Express source: `req.body` (form), `req.query` (url), `req.session`, `app.locals`.

- **cfqueryparam type coercion:** ColdFusion silently coerces types in SQL parameters. Claude Code adds express-validator chains that explicitly validate and cast types before query execution.

- **Session-scoped CFCs:** ColdFusion can store CFC instances in session scope. Claude Code replaces these with stateless services, storing only serializable data in Express sessions.

## Related

- [Claude Code for Classic ASP to Modern Web Migration](/claude-code-classic-asp-to-modern-web-migration-2026/)
- [Claude Code for Perl to Python Migration](/claude-code-perl-to-python-migration-2026/)
- [Claude Code for Lotus Notes Web Migration](/claude-code-lotus-notes-web-migration-2026/)
- [Claude Code for Natural/ADABAS Migration (2026)](/claude-code-natural-adabas-migration-2026/)
- [Claude Code for PL/SQL to PostgreSQL Migration (2026)](/claude-code-plsql-to-postgresql-migration-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Node.js Profiling Workflow](/claude-code-for-nodejs-profiling-workflow-tutorial/)
- [Claude Code For Node.js Event](/claude-code-for-nodejs-event-loop-workflow-guide/)
- [Claude Code For Node.js Worker](/claude-code-for-nodejs-worker-threads-workflow/)
- [Claude Code for Node.js Cluster Module](/claude-code-for-node-js-cluster-module-workflow/)


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
