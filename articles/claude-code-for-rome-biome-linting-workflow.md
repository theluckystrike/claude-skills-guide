---

layout: default
title: "Claude Code for Rome Biome Linting (2026)"
description: "Learn how to create a Claude Code skill that automates Rome and Biome linting workflows for your JavaScript and TypeScript projects."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-rome-biome-linting-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Modern JavaScript and TypeScript projects benefit significantly from unified linting and formatting tools. Rome and Biome represent the next generation of all-in-one tooling that combines linting, formatting, and more into a single high-performance package. Creating a Claude Code skill to automate your Rome or Biome linting workflow can dramatically improve your development experience and ensure consistent code quality across your team.

## Understanding Rome and Biome

Rome was originally developed by Meta (now Meta) as a unified toolchain for JavaScript/TypeScript, replacing ESLint, Prettier, and other separate tools. While Rome itself has evolved and some maintainers moved to create Biome (a faster Rust-based successor), both tools share similar philosophies: provide comprehensive code quality tooling in a single, coherent package.

Biome is particularly notable for its blazing-fast performance, often being 10-100x faster than traditional JavaScript-based linting tools. It provides:

- Linting with auto-fix capabilities
- Formatting compatible with Prettier
- Import sorting 
- JSON configuration for simplicity
- VS Code integration for real-time feedback

## Creating a Biome Linting Skill

Let's build a Claude Code skill that handles Biome linting workflows. This skill will help developers run linting, apply fixes, check for errors, and maintain code quality standards.

## Skill Structure

```yaml
---
name: biome-lint
description: "Run Biome linter with auto-fix, check for errors, and maintain code quality standards"
---

Biome Linting Assistant

You help run Biome linting commands, apply fixes, and maintain code quality. Use Biome (biomejs) for linting JavaScript, TypeScript, JSON, and other supported files.

Available Actions

1. Check for Lint Errors
Run Biome check without auto-fix to see current issues:
```bash
biome check .
```

2. Auto-Fix Issues
Apply automatic fixes for fixable issues:
```bash
biome check --write .
```

3. Format Files
Format code to match Biome standards:
```bash
biome format --write .
```

4. Check Specific Files
Target specific files or directories:
```bash
biome check ./src
biome check ./src//*.ts
```

Workflow Guidance

When helping with linting:
1. First check current issues: `biome check .`
2. Report the number and types of errors found
3. Ask the user if they want auto-fix applied or manual review
4. If applying auto-fix, run with `--write` flag
5. Verify fixes were applied correctly
```

## Practical Implementation

When you create this skill, place it in your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills
cat > ~/.claude/skills/skill-biome-lint.md << 'EOF'
---
name: biome-lint
description: "Run Biome linter with auto-fix, check for errors, and maintain code quality standards"
---

Biome Linting Assistant
[Skill content here]
EOF
```

## Running Linting Workflows

Once your skill is active, you can invoke it with natural language:

## Checking Project Health

```bash
Check entire project
biome check .

Check with verbose output
biome check --verbose .

Check specific file types
biome check --typescript ./src
biome check --javascript ./scripts
```

## Applying Fixes Safely

For teams new to Biome, follow this progressive approach:

```bash
Stage 1: Review only (no changes)
biome check .

Stage 2: Dry run to see what would change
biome check --dry-write .

Stage 3: Apply fixes
biome check --write .

Stage 4: Format after fixing
biome format --write .
```

## CI/CD Integration

Add Biome to your continuous integration pipeline:

```yaml
.github/workflows/lint.yml
name: Lint

on: [push, pull_request]

jobs:
 biome:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - uses: biomejs/setup-biome@v1
 with:
 version: latest
 - run: biome ci .
```

## Configuring Biome

Biome uses `biome.json` for configuration. Here's a practical example:

```json
{
 "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
 "organizeImports": {
 "enabled": true
 },
 "linter": {
 "enabled": true,
 "rules": {
 "recommended": true,
 "suspicious": {
 "noExplicitAny": "warn"
 },
 "style": {
 "useConst": "error",
 "noLet": "error"
 }
 }
 },
 "formatter": {
 "enabled": true,
 "indentStyle": "space",
 "indentWidth": 2,
 "lineWidth": 100
 }
}
```

## Creating a Rome-Compatible Skill

If you're using the original Rome toolchain, the skill structure is similar:

```yaml
---
name: rome-lint
description: "Run Rome linter for JavaScript/TypeScript projects"
---

Rome Linting Assistant

You help run Rome (rome.tools) for linting and formatting. Rome provides a unified toolchain.

Commands

- `rome check .` - Check for errors
- `rome check --apply .` - Auto-fix issues 
- `rome format .` - Format code
- `rome ci .` - CI mode (exits with error if issues found)
```

## Best Practices

1. Start with Recommended Rules

Begin with Biome's recommended rule set and gradually customize:

```bash
Start with defaults
biome init

Review what was generated
cat biome.json
```

2. Run Linting Before Commits

Create a pre-commit hook:

```bash
Add to package.json
{
 "husky": {
 "hooks": {
 "pre-commit": "biome check --staged"
 }
 }
}
```

3. Integrate with Claude Code

Your skill should guide users through:

1. Running initial checks to assess code health
2. Explaining what issues were found
3. Offering to apply fixes or guide manual fixes
4. Verifying the final state is clean

## Actionable Summary

Building a Claude Code skill for Rome or Biome linting provides:

- Consistent code quality across your team
- Automated fixes that save manual work
- Faster feedback loops than traditional linting
- Better developer experience through natural language interaction

Start by creating a basic skill following the structure above, then customize it for your team's specific needs and coding standards. With Biome's speed and Claude Code's automation, you'll have a powerful linting workflow that requires minimal manual intervention while maintaining high code quality standards.

## Step-by-Step Guide: Setting Up Biome in an Existing Project

Here is a concrete workflow for migrating an existing ESLint and Prettier setup to Biome with Claude Code.

Step 1. Audit your current configuration. Before removing ESLint and Prettier, run a migration audit. Claude Code reads your eslintrc and prettierrc files and produces a mapping showing which rules have Biome equivalents, which do not, and which need custom configuration. This prevents accidentally losing rules your team depends on.

Step 2. Install Biome and generate the initial config. Run npm install --save-dev @biomejs/biome and then npx biome init. Claude Code customizes the generated biome.json to match your existing code style. Indentation width, quote style, trailing commas, and print width are read from your prettierrc and translated to Biome format automatically.

Step 3. Run Biome alongside your existing tools. For the first week, run Biome in check-only mode alongside ESLint and Prettier rather than replacing them. Claude Code sets up a comparison script that runs both tools and reports differences. This validation period builds confidence before removing the old toolchain.

Step 4. Apply fixes incrementally. Instead of running biome check --write on the entire codebase at once, process directories one at a time. Claude Code generates a script that processes directories in order of change frequency, prioritizing modules that see the most active development.

Step 5. Remove old tooling and update CI. Once Biome is verified, remove ESLint, Prettier, and their configuration files. Claude Code updates your GitHub Actions workflow to use biome ci and removes the old lint and format steps. The biome ci command is faster than running ESLint and Prettier separately.

## Common Pitfalls

Enabling too many rules at once. Biome's recommended ruleset is opinionated. Enabling all rules on a large existing codebase generates hundreds of warnings and overwhelms developers. Claude Code generates a gradual adoption plan that enables rules in phases, starting with error-level rules that catch real bugs and deferring style rules to a later phase.

Not pinning the Biome version. Biome releases frequently and sometimes changes rule behavior between minor versions. Without a pinned version in your package.json, a CI run can introduce unexpected rule changes. Always use an exact version rather than a range.

Ignoring the formatter in favor of editor settings. Teams that configure their editors to use Prettier end up with files that pass Biome lint check but fail the format check. Claude Code generates a .editorconfig file and VS Code workspace settings that point all editors to Biome for formatting.

Using suppression comments without explanations. Suppression comments without explanations become technical debt that no one removes. Biome requires an explanation in suppression comments and Claude Code enforces this by generating a pre-commit check that rejects bare suppression comments.

Not testing Biome behavior on TypeScript decorators. If your project uses TypeScript decorators (common in NestJS and Angular), verify Biome handles them correctly before migrating. Claude Code generates a smoke test that runs Biome against your most decorator-heavy files and reports parse errors.

## Best Practices

Use Biome's organize-imports feature consistently. Import ordering conflicts are a common source of noisy git diffs. Enable organizeImports in your biome.json and configure your editor to sort imports on save. This eliminates entire categories of merge conflicts in heavily modified files.

Create project-specific rule overrides for generated code. Generated files such as GraphQL types and API client stubs should not be subject to linting. Add them to Biome's files.ignore list. Claude Code scans your project for common code generation patterns and suggests files to ignore.

Document rule decisions in a linting guide. When you disable a rule or change its severity, document why. Claude Code generates this document automatically from your biome.json, listing every non-default rule configuration with a placeholder for the rationale.

Use Biome's LSP for editor feedback. The Biome VS Code extension provides real-time lint feedback without running the CLI. Claude Code generates the workspace settings that enable the extension and disable conflicting ESLint and Prettier extensions.

## Integration Patterns

Husky and lint-staged integration. Claude Code generates the husky pre-commit hook and lint-staged configuration that runs biome check --staged on only the files included in the commit. This is significantly faster than linting the entire project on each commit.

Nx and Turborepo monorepos. In monorepos, you typically want a single biome.json at the root with per-package overrides. Claude Code generates the Nx executor or Turborepo pipeline task that runs Biome scoped to the changed packages, avoiding unnecessary lint runs on unmodified packages.

GitHub Actions matrix testing. If your project supports multiple Node.js versions, Claude Code generates a GitHub Actions matrix that runs biome ci across each supported version to catch environment-specific issues before they reach production.

## Advanced Configuration Patterns

Biome's rule system supports three severity levels: error, warn, and off. Understanding when to use each helps you build a configuration that provides actionable signal without creating noise.

Use error for rules where a violation indicates a real bug or security issue. such as noExplicitAny, noDebugger, and noUnusedVariables. These violations should block commits. Use warn for stylistic preferences where the team has a standard but legacy code may not yet comply. such as import organization or naming conventions. Use off for rules that conflict with your project's intentional patterns. Claude Code reviews your existing codebase against Biome's full rule catalog and suggests the appropriate severity level for each rule based on how frequently your code would violate it.

The `overrides` feature in biome.json lets you apply different rule sets to different file patterns. Test files often need different rules than production code. for example, tests legitimately use any to mock complex types. Claude Code generates a biome.json with separate rule configurations for test files, generated files, and production source, so each category of code gets appropriate linting without over-broad suppressions.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-rome-biome-linting-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Spectral Linting Workflow Tutorial](/claude-code-for-spectral-linting-workflow-tutorial/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code for Biome — Workflow Guide](/claude-code-for-biome-linter-formatter-workflow-guide/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Biome Formatter Setup](/claude-code-biome-formatter-setup-2026/)
- [Claude Code vs ESLint + Prettier](/claude-code-vs-eslint-prettier-comparison/)
- [Claude Code for ESLint Custom Plugin](/claude-code-for-eslint-custom-plugin-workflow-tutorial/)
- [Fix ESLint and Prettier Conflicts](/claude-code-eslint-prettier-conflict-fix/)

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
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
