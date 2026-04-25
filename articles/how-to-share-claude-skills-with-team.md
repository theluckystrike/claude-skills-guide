---
title: "How to Share Claude Code Skills Across"
description: "Three methods to distribute SKILL.md files to teammates: project-level git, plugin packaging, and enterprise managed settings with precedence rules."
permalink: /how-to-share-claude-skills-with-team/
categories: [skills, 2026]
tags: [claude-code, claude-skills, team, sharing, distribution]
last_updated: 2026-04-19
---

## The Specific Situation

Your five-person backend team writes API endpoints. Each developer manually tells Claude "use RESTful naming, return consistent error formats, validate request bodies." You write this once as a skill and share it. Now every team member gets the same API guidance without repeating themselves. The question is where to put the skill so everyone gets it automatically.

## Technical Foundation

Claude Code discovers skills from four locations, each with a different scope and sharing behavior:

| Scope | Path | Shared With | Method |
|-------|------|-------------|--------|
| Enterprise | Managed settings | All org users | MDM / Group Policy / Ansible |
| Personal | `~/.claude/skills/` | Just you | Not shared |
| Project | `.claude/skills/` | Team | Git commit |
| Plugin | `<plugin>/skills/` | Where enabled | Plugin install |

Precedence order: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespacing, so they never conflict with other scopes.

## The Working SKILL.md

Here is a team API conventions skill shared via project-level git:

```yaml
---
name: api-conventions
description: >
  API design patterns for this codebase. Use when writing new
  API endpoints, reviewing API code, or adding route handlers.
  Triggers on "API", "endpoint", "route handler", "REST".
paths: "src/api/**/*.ts"
---

# API Conventions

When writing or modifying API endpoints in this project:

## Request Handling
- Validate all request parameters with zod schemas
- Return 400 with field-level error details for validation failures
- Use path parameters for resource identity: `/users/:id`
- Use query parameters for filtering: `/users?status=active`

## Response Format
All responses follow this structure:
```json
{
  "data": {},
  "meta": { "requestId": "uuid", "timestamp": "iso8601" },
  "errors": []
}
```

## Error Codes
- 400: Validation error (include field details)
- 401: Missing or invalid auth token
- 403: Valid auth but insufficient permissions
- 404: Resource not found
- 409: Conflict (duplicate resource)
- 500: Internal error (log full trace, return generic message)

## Naming
- Route files: `src/api/handlers/<resource>.ts`
- Handler functions: `get<Resource>`, `create<Resource>`, `update<Resource>`
- Schema files: `src/api/schemas/<resource>.schema.ts`
```

## Method 1: Project-Level Git (Recommended for Teams)

Place the skill in your repository:

```
your-project/
├── .claude/
│   └── skills/
│       └── api-conventions/
│           └── SKILL.md
├── src/
└── package.json
```

Commit and push:

```bash
git add .claude/skills/api-conventions/SKILL.md
git commit -m "feat: add api-conventions skill for team"
git push
```

Every team member gets the skill on their next `git pull`. Claude watches for file changes and loads new skills immediately. No configuration needed on their end.

The `paths: "src/api/**/*.ts"` field means Claude auto-loads this skill only when working with API files. It stays out of context when developers are working on frontend or infrastructure code.

## Method 2: Plugin Distribution

For skills that span multiple repositories:

```
your-claude-plugin/
├── skills/
│   └── api-conventions/
│       └── SKILL.md
└── README.md
```

Team members install the plugin in their Claude Code configuration. The skill appears as `your-claude-plugin:api-conventions` in the `/` menu. The namespace prevents conflicts with any project-level skill.

Plugin skills are ideal for organization-wide standards that should be consistent across every project.

## Method 3: Enterprise Managed Settings

For company-wide enforcement:

- **macOS**: `/Library/Application Support/ClaudeCode/CLAUDE.md`
- **Linux**: `/etc/claude-code/CLAUDE.md`
- **Windows**: `C:\Program Files\ClaudeCode\CLAUDE.md`

Deploy via MDM, Group Policy, or Ansible. Managed settings cannot be overridden or excluded by individual developers. This is the right choice for compliance requirements, security policies, or coding standards that must apply to every employee.

## Common Problems and Fixes

**Teammate does not see the skill**: They need to `git pull` to get the files. If the `.claude/skills/` directory was just created for the first time, they must restart Claude Code (new top-level directory detection requires a restart).

**Personal skill overrides project skill**: Precedence is enterprise > personal > project. If a developer has `~/.claude/skills/api-conventions/SKILL.md`, their personal version always wins. Have them rename or remove their personal copy.

**Skill fires too broadly**: Add the `paths` field to limit auto-activation to specific file patterns. Without `paths`, the skill can trigger on any file.

**Too many skills clutter the /menu**: Use `user-invocable: false` for background knowledge skills that Claude should load automatically but developers should not invoke directly. These stay in Claude's context but are hidden from the `/` menu.

## Production Gotchas

Live change detection means that when one developer pushes a skill update and another developer pulls, the change takes effect immediately in any active Claude Code session. This is instant and silent. There is no "restart required" notification.

In monorepo setups, nested `.claude/skills/` directories are auto-discovered when Claude works with files in that subdirectory. A skill at `packages/frontend/.claude/skills/` is only visible when editing frontend files. Use this for package-specific conventions.

The `claudeMdExcludes` setting can skip specific CLAUDE.md files, but it does not exclude skills. There is no equivalent `skillExcludes` setting. If a skill exists in the repository, it is discovered.

## Checklist

- [ ] Skill committed to `.claude/skills/` in project repository
- [ ] Team notified to `git pull` and restart Claude Code if new directory
- [ ] No personal skills with conflicting names across team members
- [ ] `paths` field set to limit activation scope
- [ ] Skill tested by at least two team members before merging

## Related Guides

- [Claude Skills Distribution Methods](/claude-skills-distribution-methods/)
- [Managing Claude Skills Across Team Members](/managing-claude-skills-across-team-members/)
- [Team SKILL.md Conventions Style Guide](/team-skill-md-conventions-style-guide/)
