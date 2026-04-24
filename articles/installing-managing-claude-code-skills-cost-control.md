---
title: "Installing and Managing Claude Code (2026)"
description: "Install and manage Claude Code skills for cost control with setup instructions, directory structure, and maintenance patterns that save $50-150/month."
permalink: /installing-managing-claude-code-skills-cost-control/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Installing and Managing Claude Code Skills for Cost Control

## What It Does

Claude Code skills are markdown files that pre-load domain knowledge into agent context, eliminating expensive file exploration. Properly installed and maintained skills reduce token consumption by 50-80% on knowledge-heavy tasks. This guide covers the practical setup, directory structure, version management, and maintenance cadence that keeps skills effective as a cost control mechanism.

## Installation / Setup

### Step 1: Create the Skills Directory

```bash
# In your project root
mkdir -p .claude/skills

# Verify Claude Code recognizes the directory
ls -la .claude/skills/
```

### Step 2: Create Foundational Skills

Every project benefits from three foundational skills:

```bash
# Skill 1: Project structure
cat > .claude/skills/project-structure.md << 'SKILL'
## Project Structure
- src/api/ -- REST endpoints (Express)
- src/services/ -- business logic
- src/repositories/ -- database queries (Prisma)
- src/types/ -- TypeScript interfaces
- __tests__/ -- mirrors src/ structure
- prisma/schema.prisma -- database schema
SKILL

# Skill 2: Common commands
cat > .claude/skills/commands.md << 'SKILL'
## Commands
- Dev: npm run dev (port 3000)
- Test: npm test -- --testPathPattern="<file>"
- Build: npm run build
- Lint: npm run lint
- Migrate: npx prisma migrate dev --name <desc>
- Types: npx prisma generate
SKILL

# Skill 3: Conventions
cat > .claude/skills/conventions.md << 'SKILL'
## Conventions
- TS strict, no any
- Repository pattern for DB access
- Zod for input validation
- JWT auth (src/auth/)
- Error format: { error: { code, message } }
- Soft deletes (deleted_at column)
SKILL
```

### Step 3: Reference from CLAUDE.md

```markdown
# CLAUDE.md

## Skills
Domain knowledge is in .claude/skills/:
- project-structure.md -- directory layout
- commands.md -- build/test/deploy commands
- conventions.md -- coding standards
```

## Configuration for Cost Optimization

### Directory Structure for Multi-Module Projects

```
.claude/
  skills/
    project-structure.md    # 150 tokens -- always relevant
    commands.md             # 120 tokens -- always relevant
    conventions.md          # 100 tokens -- always relevant
    database-schema.md      # 300 tokens -- DB tasks only
    api-routes.md           # 250 tokens -- API tasks only
    auth-patterns.md        # 180 tokens -- auth tasks only
    deploy-process.md       # 150 tokens -- deploy tasks only
```

**Total skill library:** ~1,250 tokens if all loaded. Average task loads 2-3 skills: ~350-500 tokens. Without skills, average file exploration: 30K-60K tokens. **Savings: 98-99%** per knowledge-acquisition phase.

### Version Control for Skills

```bash
# Add skills to git
git add .claude/skills/
git commit -m "Add Claude Code skills for cost optimization"

# Track skill changes in git log
git log --oneline -- .claude/skills/
```

Skills should be version-controlled alongside the codebase. When the database schema changes, update `database-schema.md` in the same commit. This prevents skill drift -- stale skills that provide incorrect context, which causes Claude to make wrong decisions and waste tokens on corrections.

## Usage Examples

### Basic Usage

```bash
# Claude automatically loads relevant skills based on task context
claude "Add a new API endpoint for user preferences"
# Claude loads: project-structure.md + api-routes.md + conventions.md
# Total skill context: ~500 tokens
# Without skills: ~40K tokens of file exploration
```

### Advanced: Cost-Saving Pattern with Skill Auditing

```bash
#!/bin/bash
# audit-skills.sh -- check skill freshness
set -euo pipefail

SKILLS_DIR=".claude/skills"
STALE_DAYS=30

echo "=== Skill Freshness Audit ==="
for skill in "$SKILLS_DIR"/*.md; do
    if [ ! -f "$skill" ]; then
        continue
    fi
    mod_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$skill" 2>/dev/null || stat -c "%y" "$skill" 2>/dev/null | cut -d' ' -f1)
    days_old=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d" "$mod_date" +%s 2>/dev/null || date -d "$mod_date" +%s)) / 86400 ))
    status="OK"
    if [ "$days_old" -gt "$STALE_DAYS" ]; then
        status="STALE"
    fi
    word_count=$(wc -w < "$skill" | tr -d ' ')
    echo "$status | $days_old days | $word_count words | $(basename "$skill")"
done
```

Run this monthly. Stale skills provide outdated context, leading to incorrect edits and costly corrections.

## Token Usage Measurements

| Scenario | Without Skills | With Skills | Savings |
|----------|---------------|-------------|---------|
| Project orientation | 30K-60K tokens | 300-500 tokens | 98-99% |
| API task context | 15K-25K tokens | 250 tokens | 98% |
| DB task context | 20K-40K tokens | 300 tokens | 98-99% |
| Auth debugging | 10K-20K tokens | 180 tokens | 98-99% |

Monthly cost impact (solo developer, Sonnet 4.6, 15 tasks/day):
- Without skills: 15 tasks x 25K exploration x 22 days = 8.25M tokens = $24.75 input
- With skills: 15 tasks x 400 skill load x 22 days = 132K tokens = $0.40 input
- **Monthly savings: $24.35 in exploration tokens alone**

For a team of 5 on Opus 4.6: savings scale to **$609/month**.

## Comparison with Alternatives

| Approach | Setup Time | Token Cost | Maintenance |
|----------|-----------|-----------|-------------|
| No context pre-loading | 0 min | High ($25+/month) | None |
| CLAUDE.md only | 10 min | Medium ($15/month) | Low |
| Skills library | 30 min | Low ($0.40/month) | Monthly audit |
| MCP context server | 2 hrs | Low ($1-2/month) | Tool updates |

## Troubleshooting

**Claude not using skills:** Check that `.claude/skills/` exists in the project root (not a subdirectory). Verify files have `.md` extension. Add explicit references in CLAUDE.md.

**Skills growing too large:** Split any skill over 500 words into two focused skills. Use the `wc -w .claude/skills/*.md` command to check sizes.

**Team members have different skills:** Store skills in version control. Add a `.claude/skills/README` (text, not .md) noting the update protocol.

## Team Skills Management

For teams, skills require coordination to prevent duplication and ensure freshness.

### Shared Skills Repository Pattern

```bash
# Create a shared skills directory in the repo
mkdir -p .claude/skills

# Add to .gitignore: NOTHING -- skills should be version controlled
# Skills are code artifacts that affect behavior

# In package.json, add a validation script
# "validate-skills": "node scripts/validate-skills.js"
```

```javascript
// scripts/validate-skills.js
const fs = require('fs');
const path = require('path');

const SKILLS_DIR = '.claude/skills';
const MAX_WORDS = 500;
const MAX_AGE_DAYS = 60;

const files = fs.readdirSync(SKILLS_DIR).filter(f => f.endsWith('.md'));

let issues = 0;
for (const file of files) {
    const content = fs.readFileSync(path.join(SKILLS_DIR, file), 'utf8');
    const words = content.split(/\s+/).length;

    if (words > MAX_WORDS) {
        console.log(`WARNING: ${file} has ${words} words (max: ${MAX_WORDS})`);
        issues++;
    }

    const stat = fs.statSync(path.join(SKILLS_DIR, file));
    const age = (Date.now() - stat.mtimeMs) / (1000 * 60 * 60 * 24);
    if (age > MAX_AGE_DAYS) {
        console.log(`STALE: ${file} last modified ${Math.floor(age)} days ago`);
        issues++;
    }
}

console.log(`\n${files.length} skills checked, ${issues} issues found`);
process.exit(issues > 0 ? 1 : 0);
```

### Skills Review Protocol

Add skills review to the PR process:

```markdown
## PR Checklist (add to PR template)
- [ ] If schema changed: updated .claude/skills/database.md
- [ ] If routes changed: updated .claude/skills/api-routes.md
- [ ] If deploy process changed: updated .claude/skills/deploy.md
- [ ] Skills validation passes: npm run validate-skills
```

### Per-Developer Skills

In addition to shared project skills, developers can maintain personal skills in their home directory:

```bash
# Personal skills (not version controlled with project)
mkdir -p ~/.claude/skills

# Example: personal workflow preferences
cat > ~/.claude/skills/my-preferences.md << 'EOF'
## My Preferences
- Always run lint before suggesting changes are complete
- Prefer functional components over class components
- Use early returns instead of nested if/else
EOF
```

Personal skills load alongside project skills, allowing individual customization without affecting the team.

## Skill Migration from CLAUDE.md

Many projects have an overgrown CLAUDE.md that should be refactored into skills. The migration process:

```bash
# Step 1: Measure current CLAUDE.md size
wc -w CLAUDE.md
# Example: 800 words (too large, target is 250)

# Step 2: Identify skill candidates (sections not needed every session)
# - Database details -> .claude/skills/database.md
# - API route details -> .claude/skills/api-routes.md
# - Deploy process -> .claude/skills/deploy.md

# Step 3: Move sections to skill files
# Step 4: Replace in CLAUDE.md with references:
# "Database: see .claude/skills/database.md"

# Step 5: Verify new CLAUDE.md size
wc -w CLAUDE.md
# Target: under 250 words
```

## Related Guides

- [How to Write Token-Efficient Claude Code Skills](/write-token-efficient-claude-code-skills/) -- authoring best practices
- [Claude Code Skills Guide](/skills/) -- complete skills reference
- [Cost Optimization Hub](/cost-optimization/) -- all cost optimization guides


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\")."
      }
    }
  ]
}
</script>
