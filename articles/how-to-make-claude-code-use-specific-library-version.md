---
layout: default
title: "How to Make Claude Code Use Specific Library Version"
description: "Learn precise techniques to control which library versions Claude Code uses in your projects, from package.json constraints to virtual environment management."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /how-to-make-claude-code-use-specific-library-version/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
---

# How to Make Claude Code Use Specific Library Version

Getting Claude Code to work with exactly the library versions you need is essential for maintaining project stability and avoiding unexpected breaking changes. Whether you're managing a React project with specific npm dependencies or a Python project requiring exact package versions, these techniques will help you maintain precise control over your development environment.

## Why Library Version Control Matters

When Claude Code generates code or modifies existing projects, it typically uses the latest available versions of libraries unless you explicitly constrain them. This can lead to unexpected behavior when:

- Newer library versions introduce breaking API changes
- Your production environment runs different versions than what Claude generated
- Team members have inconsistent development environments

The solution is to establish clear version constraints before and during your Claude Code sessions.

## Controlling npm Package Versions

For JavaScript and TypeScript projects, the most reliable approach is to use precise version specifications in your `package.json` file. Rather than using caret (`^`) or tilde (`~`) version ranges that allow automatic updates, lock to specific versions:

```json
{
  "dependencies": {
    "lodash": "4.17.21",
    "axios": "1.6.0",
    "express": "4.18.2"
  }
}
```

When you start a Claude Code session, explicitly mention your version constraints in your initial prompt. For example: "Work with lodash 4.17.21 and axios 1.6.0 — do not upgrade these packages."

The frontend-design skill works particularly well with React projects and can help you maintain version consistency across components.

## Python Virtual Environment Management

Python projects benefit from virtual environment isolation. Before starting a Claude Code session, create and activate your environment with specific package versions:

```bash
python -m venv .venv
source .venv/bin/activate
pip install requests==2.31.0
pip install django==4.2.7
```

When prompting Claude Code, reference your locked requirements file:

```bash
# Create a requirements.txt with pinned versions
pip freeze > requirements.txt
```

Then tell Claude Code: "Use the packages specified in requirements.txt — do not install or update any packages."

The tdd skill is excellent for Python projects and respects version constraints when running test suites.

## Using .nvmrc and Runtime Version Files

For runtime versions (Node.js, Python), create version specification files that Claude Code can detect:

```bash
# .nvmrc for Node.js
echo "18.17.0" > .nvmrc

# .python-version for Python
echo "3.11.5" > .python-version
```

Claude Code often respects these files when initializing new files or configuring build tools. Make them part of your project structure and mention them in your prompts.

## The Claude.md Configuration File

Create a `CLAUDE.md` file in your project root to establish persistent instructions:

```markdown
# Project Instructions

## Library Versions
- Use Node.js 18.17.0 (see .nvmrc)
- Use React 18.2.0 specifically
- Do not upgrade dependencies beyond current versions

## Package Manager
- Always use npm, not yarn or pnpm
- Run npm install with --save-exact flag
```

The supermemory skill can help you maintain context about version requirements across sessions.

## Constraining Version Upgrades

When you need to upgrade libraries, be explicit about the target version:

Instead of: "Update the dependencies"
Say: "Upgrade lodash to exactly 4.17.21, no other changes"

For the pdf skill, specify exact versions when generating documents to ensure compatibility with your existing tooling.

## Best Practices for Version Control

1. **Lock everything in version control** — Commit your lock files (package-lock.json, Pipfile.lock, requirements.txt)

2. **Document version requirements** — Add a VERSIONS.md file listing critical dependencies

3. **Test generated code** — Run your test suite (using the tdd skill) after Claude Code creates new files

4. **Review before installing** — Have Claude Code show you the proposed changes before running npm install or pip install

5. **Use Docker** — For critical projects, define your environment in a Dockerfile that Claude Code can reference

## Troubleshooting Version Mismatches

If Claude Code accidentally upgrades packages, revert the changes:

```bash
git checkout package-lock.json
npm install
```

For Python:

```bash
pip install -r requirements.txt
```

## Common Version Control Scenarios

### React 18 Project Setup

When working on a React 18 project, explicitly state your requirements:

```
Create a new component using React 18.2.0 and react-dom 18.2.0.
Use functional components with hooks. Do not use React 19 features.
```

The frontend-design skill is particularly useful here as it understands component lifecycle and React version compatibility.

### Django REST Framework Projects

For Django projects, specify both Django and DRF versions:

```python
# requirements.txt
Django==4.2.7
djangorestframework==3.14.0
psycopg2-binary==2.9.9
```

When prompting Claude Code, reference these exact versions for any database-related code generation.

### TypeScript Configuration

TypeScript projects often have specific version requirements:

```json
{
  "devDependencies": {
    "typescript": "5.2.2",
    "@types/node": "18.18.0"
  }
}
```

### Working with Monorepos

Monorepo setups using tools like Turborepo require extra attention to version consistency across packages. Create a central versions.ts file that all packages reference:

```typescript
// packages/versions.ts
export const VERSIONS = {
  react: '18.2.0',
  reactDOM: '18.2.0',
  typescript: '5.2.2',
  eslint: '8.49.0',
} as const;
```

When using the frontend-design skill in a monorepo context, specify the exact package paths and versions to avoid cross-package version conflicts.

## Final Checklist

Before starting a Claude Code session, verify:

- [ ] Lock files are committed to version control
- [ ] CLAUDE.md contains version instructions
- [ ] Runtime version files (.nvmrc, .python-version) exist
- [ ] Requirements.txt or package-lock.json reflects exact versions
- [ ] Dockerfiles specify precise base image versions

The key is being explicit in every prompt about version constraints. Claude Code is helpful but cannot guess your version requirements without clear communication.

## Summary

Controlling library versions with Claude Code requires proactive communication and proper configuration. By using lock files, version specification files, and explicit prompts, you can ensure Claude Code generates code that works with your exact environment. Remember to document your version requirements in CLAUDE.md for persistent instructions across sessions, and always verify generated code against your requirements before deploying.


## Related Reading

- [How to Write Effective CLAUDE.md for Your Project](/claude-skills-guide/how-to-write-effective-claude-md-for-your-project/)
- [Best Way to Scope Tasks for Claude Code Success](/claude-skills-guide/best-way-to-scope-tasks-for-claude-code-success/)
- [Claude Code Output Quality: How to Improve Results](/claude-skills-guide/claude-code-output-quality-how-to-improve-results/)
- [Claude Code Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
