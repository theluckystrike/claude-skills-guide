---
title: "Stop Claude Code Breaking CI Pipelines (2026)"
description: "Prevent Claude Code from breaking CI by adding pre-commit checks, test requirements, and pipeline-aware rules to your CLAUDE.md."
permalink: /claude-code-breaks-ci-pipeline-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Stop Claude Code Breaking CI Pipelines (2026)

Claude Code commits code that passes locally but fails in CI. Missing environment variables, platform-specific paths, skipped linter rules, or tests that depend on local state — the PR goes red and blocks the team.

## The Problem

Claude Code does not know your CI environment. It writes code that:
- Uses locally-installed binaries not available in CI
- References environment variables that exist on your machine but not in CI
- Generates tests that depend on file system state or network access
- Skips lint rules that CI enforces
- Uses Node.js features not available in your CI's runtime version

## Root Cause

Claude Code operates in your local environment. It can run `npm test` locally but has no visibility into your CI configuration. The gap between local and CI environments is where breakage hides.

## The Fix

The [claude-code-templates](https://github.com/davila7/claude-code-templates) library includes CI-aware agent templates for GitHub Actions, GitLab CI, and CircleCI. Install them to give Claude Code awareness of your pipeline:

```bash
npx claude-code-templates@latest
```

### Step 1: Document Your CI Environment

```markdown
## CI Environment (GitHub Actions)
- Runner: ubuntu-latest (NOT macOS)
- Node.js: 22.x (match this locally with nvm)
- Package manager: pnpm 9.x (CI runs pnpm install --frozen-lockfile)
- Available services: PostgreSQL 16 (localhost:5432), Redis 7 (localhost:6379)
- Secrets available: DATABASE_URL, STRIPE_KEY, RESEND_KEY (via GitHub Secrets)
- Time limit: 10 minutes per job

## CI Checks (all must pass)
1. pnpm lint (ESLint + Prettier)
2. pnpm typecheck (tsc --noEmit)
3. pnpm test (Vitest, no network access)
4. pnpm build (Next.js production build)
```

### Step 2: Add CI-Compatible Code Rules

```markdown
## CI Compatibility Rules
- Tests MUST NOT make external HTTP calls (use msw for mocking)
- Tests MUST NOT depend on local file paths (use os.tmpdir())
- ALL imports must be in package.json (no implicit global installs)
- No platform-specific code (path.join, not string concatenation)
- Environment variables: use defaults for CI, not just local values
```

### Step 3: Require Local Verification

```markdown
## Before Marking Any Task Complete
Run these commands (same as CI):
1. pnpm lint
2. pnpm typecheck
3. pnpm test
4. pnpm build

If any fail, fix before reporting success.
```

## CLAUDE.md Code to Add

```markdown
## CI-First Development
When writing code, assume it runs on a fresh Ubuntu container with:
- No GUI, no browser (use headless for E2E)
- No local state from previous runs
- No network access during tests
- Strict lockfile (no auto-installing missing deps)
```

## Verification

1. Ask Claude Code to add a feature with tests
2. Run your full CI pipeline locally: `pnpm lint && pnpm typecheck && pnpm test && pnpm build`
3. All four should pass without modifications
4. Push to a branch and verify CI passes on the first try

## Prevention

Add a [post-tool-use hook](/understanding-claude-code-hooks-system-complete-guide/) that runs your CI checks after each file write:

```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "pnpm lint --quiet && pnpm typecheck 2>&1 | tail -5"
    }]
  }
}
```

The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) index lists CI integration skills that validate changes against your pipeline before committing.

For CI/CD integration patterns, see the [CI/CD integration guide](/claude-code-ci-cd-integration-guide-2026/). For hook configuration details, read the [hooks guide](/understanding-claude-code-hooks-system-complete-guide/). For team workflow setup, see the [team onboarding playbook](/claude-code-team-onboarding-playbook-2026/).
