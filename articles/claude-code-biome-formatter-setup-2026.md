---
title: "Claude Code for Biome Formatter Setup (2026)"
permalink: /claude-code-biome-formatter-setup-2026/
description: "Configure Biome for JavaScript/TypeScript projects with Claude Code. Replace ESLint and Prettier with a single Rust-powered tool running in milliseconds."
last_tested: "2026-04-22"
domain: "JavaScript tooling"
---

## Why Claude Code for Biome

Biome (formerly Rome) is a Rust-powered toolchain that replaces ESLint and Prettier for JavaScript, TypeScript, JSX, JSON, and CSS. It formats and lints in a single pass, runs 25x faster than ESLint + Prettier, and eliminates the configuration conflicts between the two tools. The challenge is migrating from an existing ESLint/Prettier setup: mapping ESLint rules to Biome equivalents, handling the rules Biome does not yet support, and configuring Biome to work with framework-specific conventions (Next.js, Remix, Astro).

Claude Code generates Biome configurations that replicate your existing ESLint/Prettier behavior, identifies rule gaps that need manual review, and sets up editor integration and CI workflows.

## The Workflow

### Step 1: Install and Migrate

```bash
# Install Biome
npm install --save-dev --save-exact @biomejs/biome
npx @biomejs/biome init

# Migrate from ESLint (generates biome.json from .eslintrc)
npx @biomejs/biome migrate eslint --write
npx @biomejs/biome migrate prettier --write
```

### Step 2: Configure biome.json

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "files": {
    "ignoreUnknown": true,
    "ignore": [
      "dist/**",
      "build/**",
      ".next/**",
      "node_modules/**",
      "*.gen.ts",
      "coverage/**"
    ]
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100,
    "lineEnding": "lf"
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "jsxQuoteStyle": "double",
      "semicolons": "always",
      "trailingCommas": "all",
      "arrowParentheses": "always",
      "bracketSpacing": true
    }
  },
  "json": {
    "formatter": {
      "trailingCommas": "none"
    }
  },
  "css": {
    "formatter": {
      "enabled": true,
      "indentStyle": "space",
      "indentWidth": 2
    },
    "linter": {
      "enabled": true
    }
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noExcessiveCognitiveComplexity": {
          "level": "warn",
          "options": { "maxAllowedComplexity": 15 }
        },
        "noForEach": "warn",
        "useLiteralKeys": "error"
      },
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "warn",
        "useHookAtTopLevel": "error"
      },
      "performance": {
        "noAccumulatingSpread": "error",
        "noBarrelFile": "warn",
        "noReExportAll": "warn"
      },
      "security": {
        "noDangerouslySetInnerHtml": "error"
      },
      "style": {
        "noNonNullAssertion": "warn",
        "useBlockStatements": "error",
        "useConst": "error",
        "useImportType": "error",
        "useNodejsImportProtocol": "error",
        "useTemplate": "error"
      },
      "suspicious": {
        "noConsoleLog": "warn",
        "noExplicitAny": "warn",
        "noConfusingVoidType": "error"
      },
      "nursery": {
        "useSortedClasses": {
          "level": "warn",
          "options": {
            "attributes": ["className", "class"],
            "functions": ["clsx", "cn", "cva"]
          }
        }
      }
    }
  },
  "organizeImports": {
    "enabled": true
  },
  "overrides": [
    {
      "include": ["**/*.test.ts", "**/*.test.tsx", "**/*.spec.ts"],
      "linter": {
        "rules": {
          "suspicious": {
            "noExplicitAny": "off",
            "noConsoleLog": "off"
          }
        }
      }
    },
    {
      "include": ["*.config.ts", "*.config.js"],
      "linter": {
        "rules": {
          "style": {
            "noDefaultExport": "off"
          }
        }
      }
    }
  ]
}
```

### Step 3: Integrate with CI and Editor

```json
// package.json scripts
{
  "scripts": {
    "check": "biome check .",
    "check:fix": "biome check --write .",
    "format": "biome format --write .",
    "lint": "biome lint .",
    "ci": "biome ci ."
  }
}
```

```yaml
# .github/workflows/biome.yml
name: Code Quality
on: [pull_request]
jobs:
  biome:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: biomejs/setup-biome@v2
      - run: biome ci .
```

### Step 4: Verify

```bash
# Check everything (lint + format) without modifying
npx biome ci .

# Auto-fix all fixable issues
npx biome check --write .

# Format only
npx biome format --write .

# Lint only
npx biome lint .

# Check specific files
npx biome check src/components/Button.tsx
```

## CLAUDE.md for Biome Configuration

```markdown
# Biome Linter/Formatter Standards

## Domain Rules
- Biome replaces ESLint + Prettier (do NOT install both)
- Use `biome ci` in CI (stricter, no auto-fix)
- Use `biome check --write` locally (applies fixes)
- Test files have relaxed rules (any, console.log allowed)
- Config files allow default exports
- All imports auto-organized on save
- CSS linting enabled for stylesheets

## File Patterns
- biome.json (project root configuration)
- .vscode/settings.json (editor integration)
- .github/workflows/biome.yml (CI check)

## Common Commands
- npx biome ci . (CI mode: strict, no fixes)
- npx biome check --write . (local: lint + format + fix)
- npx biome format --write . (format only)
- npx biome lint . (lint only)
- npx biome migrate eslint --write (migrate from ESLint)
- npx biome explain RULE_NAME (show rule details)
```

## Common Pitfalls in Biome Setup

- **ESLint plugins not covered:** Biome does not yet cover every ESLint plugin (e.g., eslint-plugin-testing-library). Claude Code identifies which ESLint rules have no Biome equivalent and keeps those specific ESLint plugins alongside Biome.

- **Editor extension conflicts:** Running Biome and Prettier VS Code extensions simultaneously causes formatting fights. Claude Code configures VS Code settings to disable Prettier for Biome-supported languages.

- **Tailwind class sorting:** Biome's `useSortedClasses` nursery rule replaces the Tailwind Prettier plugin. Claude Code configures it with the correct `functions` option for your utility class helper (clsx, cn, cva).

## Related

- [Claude Code for Ruff Python Linter Configuration](/claude-code-ruff-python-linter-configuration-2026/)
- [Claude Code for Turborepo Monorepo Management](/claude-code-turborepo-monorepo-management-2026/)
- [Claude Code for Nx Workspace Orchestration](/claude-code-nx-workspace-orchestration-2026/)
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


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


## Related Guides

- [Claude Code for Rome Biome Linting](/claude-code-for-rome-biome-linting-workflow/)
- [JSON Formatter Chrome Extension](/json-formatter-chrome-extension-best/)
- [Apa Citation Formatter Chrome Extension](/chrome-extension-apa-citation-formatter/)
- [Claude Code GCP MCP Server Setup](/claude-code-gcp-mcp/)

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
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\"). 1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency. 2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed. 3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions. 4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops). 5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like \"refactor auth, add tests, and update docs\" produce better results when broken into three separate prompts, each building on the previous result. - [Claude Code for Rome Biome Linting](/claude-code-for-rome-biome-linting-workflow/) - [JSON Formatter Chrome Extension](/json-formatter-chrome-extension-best/) - [Apa Citation Formatter Chrome Extension](/chrome-extension-apa-citation-formatter/) - [Claude Code GCP MCP Server Setup](/claude-code-gcp-mcp/)"
      }
    }
  ]
}
</script>
