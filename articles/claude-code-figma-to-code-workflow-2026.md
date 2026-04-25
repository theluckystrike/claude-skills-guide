---
layout: post
title: "Use Claude Code for Figma-to-Code"
description: "Convert Figma designs to production code with Claude Code. Extract design tokens, generate components, and maintain design-dev consistency."
permalink: /claude-code-figma-to-code-workflow-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Convert Figma design files into production-ready React components using Claude Code with the Figma MCP server. This workflow extracts design tokens, generates typed component code, and produces matching CSS that stays synchronized with design changes.

Expected time: 20-45 minutes for a component library page
Prerequisites: Figma account with Developer mode access, Figma Personal Access Token, Claude Code installed, Node.js 18+

## Setup

### 1. Install the Figma MCP Server

```bash
npm install -g @anthropic/mcp-server-figma
```

Configure Claude Code to use it by adding to your MCP settings:

```json
{
  "mcpServers": {
    "figma": {
      "command": "mcp-server-figma",
      "env": {
        "FIGMA_ACCESS_TOKEN": "figd_YOUR_TOKEN_HERE"
      }
    }
  }
}
```

### 2. Create a Design Token Extraction Config

```bash
mkdir -p src/design-system && cat > src/design-system/figma.config.json << 'EOF'
{
  "fileKey": "YOUR_FIGMA_FILE_KEY",
  "pages": ["Design System", "Components"],
  "tokenCategories": ["colors", "typography", "spacing", "shadows", "radii"],
  "componentPrefix": "UI/",
  "outputDir": "src/components/ui"
}
EOF
```

The file key is the string between `/file/` and `/` in your Figma URL.

### 3. Verify MCP Connection

```bash
claude --mcp-list
# Expected output:
# figma: connected (mcp-server-figma)
```

## Usage Example

With the Figma MCP connected, Claude Code can read your design file directly. Here is a complete workflow that extracts a Button component:

First, extract design tokens from Figma and generate CSS variables:

```css
/* src/design-system/tokens.css */
/* Generated from Figma file: Design System v2.4 */

:root {
  /* Colors - Primary */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;

  /* Colors - Neutral */
  --color-neutral-50: #f9fafb;
  --color-neutral-100: #f3f4f6;
  --color-neutral-200: #e5e7eb;
  --color-neutral-700: #374151;
  --color-neutral-900: #111827;

  /* Typography */
  --font-sans: 'Inter', -apple-system, sans-serif;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --line-height-tight: 1.25;
  --line-height-normal: 1.5;

  /* Spacing */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);

  /* Border Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-full: 9999px;
}
```

Then generate the typed React component matching the Figma design:

```tsx
// src/components/ui/Button.tsx
import React from 'react';
import styles from './Button.module.css';

type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  fullWidth?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  leftIcon,
  rightIcon,
  fullWidth = false,
  disabled,
  className,
  ...props
}) => {
  const classes = [
    styles.button,
    styles[variant],
    styles[size],
    fullWidth ? styles.fullWidth : '',
    loading ? styles.loading : '',
    className || '',
  ].filter(Boolean).join(' ');

  return (
    <button
      className={classes}
      disabled={disabled || loading}
      {...props}
    >
      {loading && <span className={styles.spinner} aria-hidden="true" />}
      {!loading && leftIcon && <span className={styles.icon}>{leftIcon}</span>}
      <span className={styles.label}>{children}</span>
      {!loading && rightIcon && <span className={styles.icon}>{rightIcon}</span>}
    </button>
  );
};
```

```css
/* src/components/ui/Button.module.css */
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  font-family: var(--font-sans);
  font-weight: var(--font-weight-semibold);
  border-radius: var(--radius-md);
  border: 1px solid transparent;
  cursor: pointer;
  transition: background-color 150ms ease, box-shadow 150ms ease;
}

.button:focus-visible {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
}

/* Sizes from Figma */
.sm { padding: var(--space-1) var(--space-3); font-size: var(--font-size-sm); }
.md { padding: var(--space-2) var(--space-4); font-size: var(--font-size-base); }
.lg { padding: var(--space-3) var(--space-6); font-size: var(--font-size-lg); }

/* Variants from Figma */
.primary {
  background-color: var(--color-primary-600);
  color: white;
}
.primary:hover { background-color: var(--color-primary-700); }

.secondary {
  background-color: white;
  color: var(--color-neutral-700);
  border-color: var(--color-neutral-200);
}
.secondary:hover { background-color: var(--color-neutral-50); }

.ghost {
  background-color: transparent;
  color: var(--color-neutral-700);
}
.ghost:hover { background-color: var(--color-neutral-100); }

.danger {
  background-color: #dc2626;
  color: white;
}
.danger:hover { background-color: #b91c1c; }

.fullWidth { width: 100%; }
.loading { opacity: 0.7; pointer-events: none; }

.spinner {
  width: 1em;
  height: 1em;
  border: 2px solid currentColor;
  border-right-color: transparent;
  border-radius: var(--radius-full);
  animation: spin 600ms linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

.icon { display: inline-flex; flex-shrink: 0; }
.label { white-space: nowrap; }
```

## Common Issues

- **Figma API returns 403:** Your Personal Access Token needs read access to the file. Generate a new token at figma.com/developers with File Content scope enabled.
- **Design tokens drift from Figma:** Run token extraction on a schedule or as a pre-commit hook. Compare generated tokens.css against the committed version to detect drift.
- **Component styles do not match Figma:** Check that you are reading from the correct Figma page and frame. Use Developer mode in Figma to verify exact pixel values, then match with CSS variables.

## Why This Matters

Manual design-to-code translation introduces visual inconsistencies and takes hours per component. Automated extraction with Claude Code keeps code and design in sync with measurable pixel accuracy.

## Related Guides

- [Claude Code Generating CSS Variables from Design System](/claude-code-generating-css-variables-from-design-system/)
- [Best Way to Use Claude Code for Frontend Styling](/best-way-to-use-claude-code-for-frontend-styling/)
- [Full Stack Web App with Claude Skills Step by Step](/full-stack-web-app-with-claude-skills-step-by-step/)


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
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\"). 1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency. 2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed. 3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions. 4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops). 5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like \"refactor auth, add tests, and update docs\" produce better results when broken into three separate prompts, each building on the previous result."
      }
    }
  ]
}
</script>
