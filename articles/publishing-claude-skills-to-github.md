---
title: "Publish Claude Code Skills to GitHub"
description: "Step-by-step guide to publishing SKILL.md files to GitHub as project skills, plugins, or standalone repos with proper structure."
permalink: /publishing-claude-skills-to-github/
categories: [skills, 2026]
tags: [claude-code, claude-skills, github, publishing, open-source]
last_updated: 2026-04-19
---

## The Specific Situation

You built a skill that generates API documentation from code comments. It works well in your project. Three other teams in your company want it. An open-source maintainer in your community asked if they could use it too. You need to publish this skill so others can install it -- either as a project-level skill they commit to their repo, a plugin they can enable, or a standalone repository they clone. Each distribution method has different tradeoffs.

## Technical Foundation

Claude Code skills are just directories with a SKILL.md file and optional supporting files. There is no package registry, no build step, no compilation. Publishing a skill means making that directory available to others in a location Claude Code can discover.

Three distribution paths exist:

- **Project skills**: Copy the skill directory into `.claude/skills/` in any repository. Commit to version control. Team members get it on `git pull`.
- **Plugin skills**: Place skills in a `skills/` directory within a Claude Code plugin. Users enable the plugin. Skills are namespaced as `plugin-name:skill-name`.
- **Standalone repository**: Create a GitHub repo with the skill. Users clone or copy the skill directory to their personal `~/.claude/skills/` or project `.claude/skills/`.

## The Working SKILL.md

Here is a publishable API documentation skill with proper structure:

```yaml
---
name: generate-api-docs
description: >
  Generate API documentation from code comments and type signatures.
  Use when the user says "document this API", "generate API docs",
  or "write endpoint documentation".
argument-hint: "[file-or-directory]"
allowed-tools: Read Grep Glob
---

# Generate API Documentation

Generate structured API documentation for $ARGUMENTS.

## Steps

1. Scan the target file/directory for exported functions,
   classes, and route handlers
2. Extract JSDoc/docstring comments and type signatures
3. Generate markdown documentation with:
   - Endpoint URL and HTTP method
   - Request parameters with types
   - Response format with example
   - Error codes and descriptions
4. Write to `docs/api/` in the project root

## Format Reference

For detailed output format specifications, read
${CLAUDE_SKILL_DIR}/references/output-format.md

## Templates

Use ${CLAUDE_SKILL_DIR}/templates/endpoint.md as the
template for each endpoint's documentation.
```

## Publishing as a Project Skill

The simplest distribution: include the skill in your repository.

```
your-project/
├── .claude/
│   └── skills/
│       └── generate-api-docs/
│           ├── SKILL.md
│           ├── references/
│           │   └── output-format.md
│           └── templates/
│               └── endpoint.md
├── src/
└── package.json
```

Add a note to your project README:

```markdown
## Claude Code Skills

This project includes custom Claude Code skills in `.claude/skills/`.
They are available automatically when using Claude Code in this repo.

- `/generate-api-docs [path]` - Generate API docs from code comments
```

Commit and push. Every team member gets the skill on their next pull.

## Publishing as a Plugin

For distribution across multiple projects:

```
my-claude-plugin/
├── skills/
│   └── generate-api-docs/
│       ├── SKILL.md
│       ├── references/
│       │   └── output-format.md
│       └── templates/
│           └── endpoint.md
└── README.md
```

Users enable the plugin in their Claude Code configuration. The skill appears namespaced as `my-claude-plugin:generate-api-docs` in the `/` menu. Namespace prevents conflicts with any project-level skill of the same name.

## Publishing as a Standalone GitHub Repo

For public or community distribution:

```
claude-skill-api-docs/
├── generate-api-docs/
│   ├── SKILL.md
│   ├── references/
│   │   └── output-format.md
│   └── templates/
│       └── endpoint.md
├── README.md
└── LICENSE
```

Installation instructions in the README:

```markdown
## Install

Copy the skill to your project:
```bash
cp -r generate-api-docs/ .claude/skills/generate-api-docs/
```

Or install personally (available in all projects):
```bash
cp -r generate-api-docs/ ~/.claude/skills/generate-api-docs/
```
```

## Common Problems and Fixes

**Skill references hardcoded paths**: Replace absolute paths with `${CLAUDE_SKILL_DIR}`. This variable resolves to the skill's actual directory, wherever it is installed.

**Plugin skill name conflicts**: Plugin skills are automatically namespaced as `plugin-name:skill-name`. If users also have a project skill with the same base name, both coexist without conflict.

**Skill works locally but not after cloning**: Check that supporting files are not in `.gitignore`. Common mistake: `.claude/` is sometimes gitignored. Add an exception: `!.claude/skills/`.

**Large skill files bloat the repo**: Keep SKILL.md under 500 lines. If reference files exceed 5,000 words, consider linking to external documentation instead of bundling.

**Scripts need execute permissions after clone**: Git preserves execute permissions, but only if they were set before commit. Run `chmod +x scripts/*.sh` before committing.

## Production Gotchas

The Agent Skills open standard (agentskills.io) means SKILL.md files work across multiple AI tools, not just Claude Code. When publishing publicly, mention agentskills.io compatibility in your README for broader reach.

There is no skill dependency system. If your skill references another skill, both must be installed independently. Document dependencies clearly in the README.

GitHub Actions cannot easily test skill behavior because Claude Code is interactive. For CI validation, limit testing to YAML frontmatter parsing, file existence checks, and script syntax validation.

When publishing skills that use `allowed-tools` with shell commands, document what CLI tools must be installed. A skill with `allowed-tools: Bash(docker *)` fails silently on machines without Docker.

## Checklist

- [ ] All paths use `${CLAUDE_SKILL_DIR}` instead of absolute paths
- [ ] Supporting files are not excluded by `.gitignore`
- [ ] Scripts have execute permissions committed to git
- [ ] README includes installation instructions for all three methods
- [ ] External CLI dependencies documented

## Related Guides

- [Claude Skills Distribution Methods](/claude-skills-distribution-methods/)
- [Claude Skills Versioning Strategies](/claude-skills-versioning-strategies/)
- [Claude Skills Folder Structure](/claude-skills-folder-structure/)
