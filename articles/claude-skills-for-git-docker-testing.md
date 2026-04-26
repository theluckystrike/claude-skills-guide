---
layout: default
title: "Claude Skills for Git, Docker, (2026)"
description: "Three production-ready SKILL.md files for git commit workflows, Docker container management, and test runner automation with allowed-tools."
permalink: /claude-skills-for-git-docker-testing/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, git, docker, testing, devops]
last_updated: 2026-04-19
---

## The Specific Situation

You use Claude Code daily for three repetitive workflows: committing changes with a specific message format, spinning up Docker containers for testing, and running test suites with coverage checks. Each time, you explain the same steps. You want three skills that encode these exact workflows so Claude executes them consistently without guidance. Here are three production-ready skills -- one for each workflow.

## Technical Foundation

Skills that execute external tools need the `allowed-tools` frontmatter field to pre-approve commands. Without it, Claude prompts for permission on every `git`, `docker`, or test runner command. The syntax uses glob matching: `Bash(git commit *)` approves any git commit variation.

For workflows with side effects (committing code, starting containers, deleting files), set `disable-model-invocation: true` so the skill only fires when you explicitly type `/skill-name`. Auto-triggered deploy or commit skills are a recipe for unintended changes.

## Skill 1: Git Commit Workflow

```yaml
---
name: commit
description: Stage and commit changes with conventional commit format
disable-model-invocation: true
argument-hint: "[type] [description]"
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *) Bash(git diff *)
---

# Commit Changes

Create a conventional commit for the current changes.

## Steps

1. Run `git status` to see what changed
2. Run `git diff --staged` and `git diff` to understand the changes
3. Stage relevant files with `git add` (specific files, not `git add .`)
4. Format the commit message as:
   ```
   <type>(<scope>): <description>

   <body explaining what and why>
   ```
   Types: feat, fix, refactor, test, docs, chore, ci
5. If $ARGUMENTS is provided, use $0 as the type and $1+ as the
   description
6. Commit with `git commit -m "message"`
7. Run `git status` to confirm clean state

## Rules
- Never use `git add .` or `git add -A`
- Never use `--no-verify` or skip hooks
- Never amend the previous commit unless explicitly asked
- If pre-commit hooks fail, fix the issue and create a NEW commit
```

## Skill 2: Docker Container Management

```yaml
---
name: docker-dev
description: >
  Manage Docker containers for local development. Start, stop,
  and inspect development containers.
disable-model-invocation: true
argument-hint: "[up|down|logs|status]"
allowed-tools: Bash(docker *) Bash(docker-compose *) Bash(docker compose *)
---

# Docker Development Environment

Manage the development Docker environment.

## Commands

Based on $ARGUMENTS:

### `up` (or no args)
1. Check if docker-compose.yml or compose.yaml exists
2. Run `docker compose up -d`
3. Wait for health checks: `docker compose ps`
4. Report which services are running and their ports

### `down`
1. Run `docker compose down`
2. Confirm all containers stopped

### `logs`
1. Run `docker compose logs --tail=50`
2. Highlight any ERROR or WARN lines

### `status`
1. Run `docker compose ps`
2. Run `docker stats --no-stream`
3. Report container health, memory usage, and uptime

## Rules
- Never run `docker compose down -v` (destroys volumes) unless
  explicitly asked
- Never pull new images without confirming with the user
- Always check for existing containers before starting new ones
```

## Skill 3: Test Runner with Coverage

```yaml
---
name: run-tests
description: >
  Run the project test suite with coverage reporting. Use when the
  user says "run tests", "check test coverage", or "verify tests pass".
argument-hint: "[file-or-pattern]"
allowed-tools: Bash(npx jest *) Bash(npx vitest *) Bash(npm test *) Bash(pytest *) Read
---

# Run Tests

Execute tests and report coverage.

## Detection

1. Check which test runner is configured:
   - package.json scripts.test -> npm/jest/vitest
   - pytest.ini or pyproject.toml [tool.pytest] -> pytest
   - Cargo.toml -> cargo test
2. Use the detected runner for all commands

## Execution

If $ARGUMENTS specifies a file or pattern, run only those tests.
Otherwise run the full suite.

### JavaScript/TypeScript
```bash
npx jest --coverage $ARGUMENTS
# or
npx vitest run --coverage $ARGUMENTS
```

### Python
```bash
pytest --cov=. --cov-report=term-missing $ARGUMENTS
```

## After Tests

1. Report pass/fail count
2. Report coverage percentage
3. If coverage dropped below 80%, list uncovered files
4. If any test failed, read the failing test file and the source
   file it tests, then suggest a fix

## Rules
- Always include coverage reporting
- Never modify test files unless explicitly asked
- Report the specific assertion that failed, not just the test name
```

## Common Problems and Fixes

**Git hooks block the commit skill**: The skill instructs Claude to never use `--no-verify`. If hooks fail, Claude should fix the underlying issue and create a new commit. Ensure pre-commit hooks are documented in CLAUDE.md.

**Docker commands fail with permission errors**: On Linux, Docker requires either root or membership in the `docker` group. The skill cannot fix this -- document the prerequisite.

**Wrong test runner detected**: The detection logic in the skill relies on file presence. If both `jest.config.js` and `pytest.ini` exist (monorepo), add `$ARGUMENTS` support: `/run-tests --runner jest`.

**allowed-tools too broad**: `Bash(docker *)` approves ALL docker commands, including `docker rm -f`. Narrow to specific subcommands if security matters: `Bash(docker compose *) Bash(docker ps *) Bash(docker logs *)`.

## Production Gotchas

The `allowed-tools` permissions are additive. They grant access to tools but never restrict them. If a deny rule in `/permissions` blocks `Bash(git *)`, the skill's `allowed-tools` cannot override it. Deny always wins.

These skills use `disable-model-invocation: true` because they have side effects. If you remove this flag, Claude may auto-trigger the commit skill when it detects unstaged changes, or start Docker containers when you mention "container" in conversation. Always keep side-effect skills manual-only.

The `$ARGUMENTS` substitution handles multi-word inputs. `/commit feat add user authentication` gives `$0 = feat`, `$1 = add`, `$2 = user`, `$3 = authentication`. Use `$ARGUMENTS` for the full string or indexed `$N` for positional parsing.

## Checklist

- [ ] Side-effect skills have `disable-model-invocation: true`
- [ ] `allowed-tools` covers all commands the skill needs
- [ ] `argument-hint` shows expected input format
- [ ] Skills handle missing arguments gracefully
- [ ] Each skill tested with explicit invocation (`/skill-name`)



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
- [Claude Skills with Embedded Scripts](/claude-skills-with-embedded-scripts/)
- [Security Review Process for Claude Skills](/security-review-process-for-claude-skills/)
