---
layout: default
title: "Shared Claude Skills Across Monorepo Multiple Packages"
description: "Learn how to create, organize, and share Claude skills across a monorepo with multiple packages. Practical patterns for teams building large-scale TypeS..."
date: 2026-03-14
author: "Claude Skills Guide"
categories: [tutorials]
tags: [claude-code, claude-skills, monorepo, multiple-packages, shared-skills]
reviewed: true
score: 9
---

# Shared Claude Skills Across Monorepo Multiple Packages

Managing Claude skills across a [monorepo](/claude-skills-guide/how-do-i-share-claude-skills-across-multiple-projects/) with multiple packages presents unique challenges. When your project spans dozens of packages—whether TypeScript workspaces, Python modules, or mixed-language environments—you need a strategy that avoids duplication while keeping skills accessible to every package that needs them. This guide covers practical approaches for sharing Claude skills across your entire monorepo.

## Understanding the Monorepo Challenge

[Monorepos offer undeniable benefits: unified dependency management, shared tooling, and atomic commits across packages](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) However, they also create specific challenges for Claude skills. Each package may require different skill sets—a backend API package needs different workflows than a frontend UI package. Yet certain skills should be universal: code quality checks, testing patterns, and documentation generation should work consistently everywhere.

The key is separating package-specific skills from shared skills, then making both accessible through a clear hierarchy.

## Project Structure for Shared Skills

The most effective approach places shared skills in a central location while allowing package-specific overrides. Create a `skills` directory at your monorepo root, then organize skills into clear categories:

```
my-monorepo/
├── packages/
│   ├── api/
│   ├── web/
│   └── shared/
├── skills/
│   ├── _shared/           # Universal skills
│   │   ├── tdd.skill.md
│   │   ├── code-review.skill.md
│   │   └── docs-gen.skill.md
│   ├── frontend/          # Package-specific
│   │   ├── frontend-design.skill.md
│   │   └── accessibility.skill.md
│   ├── backend/
│   │   ├── api-testing.skill.md
│   │   └── db-migration.skill.md
│   └── docs/
│       └── swagger-to-md.skill.md
└── claude.json            # Root-level skill config
```

## Configuring Claude to Find Shared Skills

In your monorepo's root `claude.json`, define skill paths that span multiple locations. Claude Code supports multiple skill directories, allowing you to reference both shared and package-specific skills:

```json
{
  "skills": [
    "skills/_shared",
    "skills/frontend",
    "skills/backend",
    "skills/docs",
    "packages/*/skills"
  ]
}
```

The glob pattern `packages/*/skills` automatically includes any package that defines its own skills directory. This means individual packages can maintain their specialized workflows without polluting the shared namespace.

## The Shared Skill Pattern

Creating truly reusable skills requires careful design. A shared skill should be generic enough to work across packages while still providing meaningful automation. Here's a pattern for a universal testing skill that works across your monorepo:

```markdown
---
name: universal-test
description: Run appropriate tests for this package based on its testing framework
---

# Universal Test Runner

This skill detects the testing framework in use and runs tests appropriately. It supports Jest, Vitest, pytest, and Go testing.

## How It Works

1. Check package.json or equivalent for test scripts
2. Identify testing framework from dependencies
3. Run tests with appropriate flags
4. Report coverage if available

## Usage

```
/universal-test
/universal-test --coverage
/universal-test --watch
```

## Package-Specific Overrides

Packages can override this skill by creating their own `universal-test.skill.md` in their local `skills/` directory. The local version takes precedence.
```

## Combining Skills with Composition

Claude skills support composition, allowing you to build higher-level workflows from shared components. A monorepo-level skill might combine multiple smaller skills:

```markdown
---
name: monorepo-ci
description: Run full CI pipeline across affected packages
---

# Monorepo CI Pipeline

Run the complete CI process for changed packages in your monorepo.

## Uses These Shared Skills

- tdd (for running tests)
- code-review (for lint checks)
- docs-gen (for API documentation)

## Workflow

1. Detect changed packages using turbo or nx
2. For each affected package:
   - Run linting via code-review
   - Execute tests via tdd
   - Build documentation
3. Report consolidated results
```

This composition approach means you maintain the TDD skill once, and it automatically propagates to every package that needs it.

## Package-Specific Customization

While shared skills handle common patterns, individual packages often need customization. The frontend-design skill might apply only to UI packages, while database migration skills belong only to packages with data layer code.

Use skill metadata to control when skills are available. In your `claude.json`, you can restrict skills to specific paths:

```json
{
  "skills": [
    {
      "name": "tdd",
      "path": "skills/_shared/tdd.skill.md"
    },
    {
      "name": "frontend-design",
      "path": "skills/frontend/frontend-design.skill.md",
      "allowedDirectories": ["packages/web", "packages/mobile"]
    }
  ]
}
```

This configuration ensures the frontend-design skill only activates when working within web or mobile packages.

## Real-World Example: Multi-Language Monorepo

Consider a monorepo containing both TypeScript API packages and Python data processing packages. Shared skills handle universal concerns:

```markdown
---
name: quality-gate
description: Run quality checks appropriate to this package's language
---

# Quality Gate

Run linters, type checkers, and security scans based on package language.

## TypeScript Packages
- Runs ESLint
- Runs TypeScript type checking
- Runs security audit

## Python Packages
- Runs ruff or flake8
- Runs mypy type checking
- Runs bandit security scans

## Detection Logic

1. Check for package.json → TypeScript
2. Check for pyproject.toml or setup.py → Python
3. Run appropriate checks
```

Each package automatically gets language-appropriate quality checks without requiring package-specific configuration.

## Versioning Shared Skills

When multiple teams use shared skills, version conflicts become likely. A few strategies help manage this:

Pin skill versions in your monorepo's skill registry file:

```json
{
  "skills": {
    "tdd": "2.1.0",
    "code-review": "1.4.2",
    "frontend-design": "3.0.1"
  }
}
```

Use Git submodules or a separate repository for skills, then lock to specific commits. This allows gradual rollouts of skill updates across packages.

Document breaking changes in a CHANGELOG within the skills directory. Teams can then coordinate updates during natural development cycles.

## Testing Shared Skills Before Deployment

Before rolling out shared skills across your monorepo, validate them in a single package. Create a test package that exercises all shared functionality:

```bash
# In your test package
/claude use tdd
/universal-test --coverage
```

Once the skill works correctly in isolation, propagate it to other packages incrementally. Monitor for unexpected behavior in each package type before full deployment.

## Common Pitfalls to Avoid

**Over-sharing** is the most frequent mistake. Not every skill needs to be universal. Package-specific workflows should stay local—they don't benefit from centralization and may cause confusion.

**Neglecting overrides** is another trap. Even with shared skills, packages sometimes need custom behavior. Build override mechanisms from the start rather than adding them later.

**Ignoring skill conflicts** can cause subtle bugs. When multiple skills define similar commands, the resolution order matters. Explicitly document which skills take precedence in your monorepo.

## Conclusion

Sharing Claude skills across a monorepo with multiple packages requires thoughtful organization but pays significant dividends. Centralized skill maintenance reduces duplication, while package-specific overrides handle specialized needs. The key is establishing a clear hierarchy: shared skills for common patterns, composition for complex workflows, and local skills for unique requirements.

By configuring Claude with multiple skill paths, using composition to build higher-level workflows, and implementing proper versioning, your team can maintain consistent automation across every package in your monorepo.

## Related Reading

- [What Is the Best Way to Organize Claude Skills in a Monorepo](/claude-skills-guide/what-is-the-best-way-to-organize-claude-skills-in-a-monorepo/) — The foundational monorepo organization guide that this shared-skills article builds upon for multi-package setups
- [How to Share Claude Skills with Your Team](/claude-skills-guide/how-to-share-claude-skills-with-your-team/) — Distribution patterns for sharing the skills you've organized across your monorepo with all team members
- [Claude Skills Change Management: Rolling Out to Teams](/claude-skills-guide/claude-skills-change-management-rolling-out-to-teams/) — Govern skill updates across packages with version control and rollout policies for monorepo environments
- [Claude Skills: Getting Started Hub](/claude-skills-guide/getting-started-hub/) — Explore foundational skill organization and team distribution patterns across the full Claude ecosystem

Built by theluckystrike — More at [zovo.one](https://zovo.one)
