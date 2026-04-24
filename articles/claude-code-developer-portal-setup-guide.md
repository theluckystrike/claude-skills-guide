---

layout: default
title: "Claude Code Developer Portal Setup (2026)"
description: "A practical guide to setting up Claude Code developer portals. Configure skills, customize workflows, and build your personalized AI development."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
author: theluckystrike
permalink: /claude-code-developer-portal-setup-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Developer portals in Claude Code serve as centralized hubs for managing skills, templates, and automation workflows. This guide walks through the process of setting up a functional developer portal tailored to your development needs.

Done right, a developer portal eliminates the friction of recreating context every session. Instead of typing long instructions every time you want Claude to follow your team's TDD conventions or generate code in your preferred style, you define those conventions once as skills, version them in a repository, and load them on demand. The portal is the infrastructure that makes that possible.

## Understanding Claude Code Skills Architecture

Claude Code uses a skill-based system stored in `~/.claude/skills/`. Each skill is a Markdown file containing instructions that Claude loads when you invoke it. The directory structure looks like this:

```
~/.claude/
 skills/
 _index.md
 frontend-design.md
 pdf.md
 tdd.md
 supermemory.md
 settings.json
```

The `_index.md` file acts as a skill registry, listing all available skills and their descriptions. This is what Claude reads when you press Tab to see available skills.

Skills are intentionally simple. They are plain Markdown files with a YAML front matter block and a body that contains whatever instructions you want Claude to follow when the skill is active. There is no binary to compile, no package to publish, and no API to register with. The simplicity is a feature. it means anyone on your team can write and maintain skills without specialized knowledge.

## Skills vs. System Prompts vs. CLAUDE.md

Before diving into setup, it helps to understand where skills fit relative to other Claude Code configuration mechanisms:

| Mechanism | Scope | Use Case |
|---|---|---|
| Skills (`~/.claude/skills/`) | On-demand, per-invocation | Specialized workflows you toggle manually |
| `CLAUDE.md` in repo root | Always active for that repo | Project-specific conventions, architecture notes |
| `~/.claude/CLAUDE.md` | Always active globally | Personal preferences, editor setup |
| `settings.json` | Global configuration | API keys, model selection, tool permissions |

Skills are the right tool when you want to opt in to a specific behavior for a specific task. Use `CLAUDE.md` for context that should always be present, and skills for workflows you invoke intentionally.

## Setting Up Your Skill Directory

Start by creating the skills directory if it does not exist:

```bash
mkdir -p ~/.claude/skills
```

Each skill file follows a specific format. Here is a basic template for creating a custom skill:

```markdown
---
name: my-custom-skill
description: A brief description of what this skill does
---

My Custom Skill

Your skill instructions go here. When you invoke this skill with /my-custom-skill, Claude will follow these guidelines.
```

The front matter defines the skill name and description, while the Markdown content provides the actual instructions Claude will follow.

A minimal but useful skill is more specific than a generic description. Compare these two skill bodies:

Too vague:
```markdown
Code Review Skill

Review code and give feedback.
```

Concrete and useful:
```markdown
Code Review Skill

When invoked, perform a structured code review of the file or diff provided:

1. Security: Check for injection risks, hardcoded secrets, missing input validation
2. Error handling: Verify errors are caught, logged, and surfaced appropriately
3. Test coverage: Identify untested paths or edge cases
4. Readability: Flag confusing variable names, overly complex logic, missing comments
5. Performance: Note obvious inefficiencies like N+1 queries or redundant loops

Format your output as a numbered list grouped by category. Use [BLOCKER], [SUGGESTION], or [NITPICK] prefixes for each item. End with a summary verdict: APPROVE, REQUEST CHANGES, or NEEDS DISCUSSION.
```

The second version gives Claude a consistent output format that your team can rely on across sessions.

## Configuring the Skills Index

The `_index.md` file is crucial for organizing your skills. Each skill should be listed with a brief description:

```markdown
---
layout: skills-index
title: Developer Skills
---

Available Skills

Development Skills
- tdd. Test-driven development workflow
- frontend-design. UI/UX and frontend guidance
- pdf. PDF manipulation and generation
- xlsx. Spreadsheet operations
- pptx. Presentation creation

Productivity Skills
- supermemory. Memory and context management
- webapp-testing. Browser testing with Playwright
- mcp-builder. MCP server creation
```

This index enables Tab completion in Claude Code, making skills discoverable during your sessions.

Keep your index descriptions accurate and current. If a skill's behavior changes, update both the skill file and its index entry. A stale index is confusing and erodes trust in the portal.

## Creating a Developer Portal Structure

A well-organized developer portal separates skills by domain. Here is a recommended structure:

```
developer-portal/
 skills/
 development/
 tdd.md
 frontend-design.md
 code-review.md
 automation/
 mcp-builder.md
 webapp-testing.md
 content/
 pdf.md
 docx.md
 pptx.md
 templates/
 readme-template.md
 pr-template.md
```

For teams, this repository structure is the source of truth. Individual developers clone it and run an install script to link the skills into their local `~/.claude/skills/` directory. Using symlinks rather than copies means pulling the latest changes from the repo immediately updates everyone's local skills:

```bash
#!/bin/bash
install-skills.sh
PORTAL_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

mkdir -p "$SKILLS_DIR"

for skill_file in "$PORTAL_DIR"/skills//*.md; do
 filename=$(basename "$skill_file")
 target="$SKILLS_DIR/$filename"
 if [ -L "$target" ]; then
 rm "$target"
 fi
 ln -s "$skill_file" "$target"
 echo "Linked: $filename"
done

Also link the index
ln -sf "$PORTAL_DIR/skills/_index.md" "$SKILLS_DIR/_index.md"
echo "Skills installed. Run 'ls ~/.claude/skills/' to verify."
```

## Writing Effective Skill Files

The quality of your skills directly affects Claude's output. A few patterns consistently produce better results.

Be explicit about output format. Claude will produce better, more consistent results when you specify exactly what you want back:

```markdown
Sprint Planning Skill

When invoked, help plan a development sprint:

1. Ask for the epic or feature description if not provided
2. Break the feature into tasks of 1-3 days each
3. For each task, output a JSON object:
 {"title": "...", "estimate_days": N, "dependencies": [], "acceptance_criteria": "..."}
4. Output all tasks as a JSON array
5. After the array, write a 2-sentence summary of the overall approach
```

Include decision rules. Tell Claude what to do when it encounters ambiguity:

```markdown
Database Migration Skill

When writing database migrations:
- Default to non-destructive changes (add columns, create tables)
- If a destructive change is needed, output a WARNING block before the SQL
- Always include a rollback migration alongside the forward migration
- For Postgres: use CONCURRENTLY for index creation on large tables
- If the table has more than 1M rows, add a comment noting the migration may lock the table
```

Reference your tech stack explicitly. A generic skill works, but a skill that knows your stack works better:

```markdown
API Endpoint Skill

This project uses:
- Express 4.x with TypeScript
- Zod for request validation
- Prisma for database access
- Jest for tests

When adding a new endpoint:
1. Define the Zod schema first
2. Implement the handler using async/await with try/catch
3. Add a Jest test covering the happy path and one error case
4. Update the OpenAPI spec in docs/openapi.yaml
```

## Integrating Skills with Your Workflow

Skills become powerful when integrated into your daily workflow. The tdd skill, for example, transforms how you approach coding tasks. Invoke it with `/tdd` and describe your implementation goal. The skill guides Claude to generate tests first, then implement against those tests.

The frontend-design skill helps with UI components. When working on a new interface element, invoke `/frontend-design` and provide details about your design requirements. The skill offers guidance on layout, accessibility, and responsive patterns.

For documentation workflows, the pdf and docx skills enable programmatic document generation. Create a skill that defines your documentation standards:

```markdown
---
name: docs-generator
description: Generate project documentation from templates
---

Documentation Generator Skill

When invoked, follow these guidelines:

1. Check for existing documentation structure
2. Use the pdf skill for PDF outputs
3. Apply consistent formatting
4. Include code examples where appropriate
5. Generate a table of contents
```

A practical workflow integration is to invoke skills at the start of specific tasks rather than leaving a general skill active all session. Start a coding session by opening Claude Code normally, then invoke `/tdd` only when you sit down to write a new feature. This keeps the skill context focused and prevents conflicts between instructions.

## Automating Portal Tasks

You can combine skills with shell commands for automation. Create a script that updates your portal skills from a git repository:

```bash
#!/bin/bash
Update developer portal skills

SKILLS_DIR="$HOME/.claude/skills"
PORTAL_REPO="git@github.com:your-org/claude-skills.git"

if [ -d "$PORTAL_REPO" ]; then
 cd "$PORTAL_REPO"
 git pull origin main
 cp -r skills/* "$SKILLS_DIR/"
 echo "Skills updated successfully"
else
 git clone "$PORTAL_REPO" /tmp/claude-skills
 cp -r /tmp/claude-skills/skills/* "$SKILLS_DIR/"
 echo "Skills cloned and installed"
fi
```

Schedule this with cron or run it manually before starting your development sessions.

For teams using dotfiles managers like `chezmoi` or `stow`, skills fit naturally into the managed dotfiles tree. Add `~/.claude/` to your dotfiles configuration alongside `.zshrc`, `.gitconfig`, and your editor config. This means a new team member or a new machine gets the full skill suite as part of the standard onboarding script.

## Testing Your Setup

After configuring your developer portal, verify everything works:

1. Open Claude Code
2. Press Tab to see your skill list
3. Invoke each skill with its command
4. Confirm the skills load correctly

You can also check skill loading with:

```bash
ls -la ~/.claude/skills/
cat ~/.claude/skills/_index.md
```

A useful sanity check is to invoke a skill with a simple, known input and verify the output format matches what the skill file specifies. If the output looks inconsistent, re-read the skill file. often the issue is ambiguous instructions rather than a configuration problem.

When a skill is not behaving as expected, add a brief diagnostic line to the skill body:

```markdown
At the start of your response, print: "Skill loaded: [skill-name] v[version]"
```

This confirms the skill loaded and tells you which version is active, which is useful when you have multiple copies of a skill installed.

## Extending Your Portal

Once your basic portal is running, extend it with specialized skills. The mcp-builder skill helps you create Model Context Protocol servers for external service integration. The webapp-testing skill enables automated browser testing directly from Claude Code.

A practical extension for most teams is a set of project-specific skills stored in the repository itself rather than (or in addition to) the shared portal. Place them in a `.claude/skills/` directory at the repo root:

```
your-project/
 .claude/
 skills/
 api-endpoint.md
 db-migration.md
 release-checklist.md
 src/
 package.json
```

Project-local skills get loaded automatically when you open Claude Code in that directory, without requiring any manual installation step. They are versioned with the codebase, reviewed in pull requests, and accessible to every contributor who clones the repo.

For team environments, consider sharing skill configurations through a dotfiles repository or internal wiki. The goal is that any developer on your team can reproduce the exact same Claude Code environment in under five minutes, with no tribal knowledge required.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-developer-portal-setup-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Building Your First MCP Tool Integration Guide 2026](/building-your-first-mcp-tool-integration-guide-2026/)
- [Claude Code Local Development Setup Guide](/claude-code-local-development-setup-guide/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


