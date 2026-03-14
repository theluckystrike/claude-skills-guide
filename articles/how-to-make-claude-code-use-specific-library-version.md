---
layout: default
title: "How to Make Claude Code Use Specific Library Version"
description: Control which library versions Claude Code uses when writing code. Techniques for specifying version constraints in prompts, project files, and skill.
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, dependencies, libraries]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /how-to-make-claude-code-use-specific-library-version/
---

# How to Make Claude Code Use Specific Library Version

When you ask Claude Code to generate code that depends on external libraries, it typically selects versions based on what it knows to be stable and widely compatible. For overall dependency management patterns, see the [workflows hub](/claude-skills-guide/workflows-hub/). However, your project may require a specific version due to legacy dependencies, API changes, or organizational constraints. This guide shows you how to ensure Claude Code uses the exact library versions you need, including [setting environment variables for skills](/claude-skills-guide/how-do-i-set-environment-variables-for-a-claude-skill/) that pin versions automatically.

## Why Version Control Matters

Library version mismatches cause real problems. A function that works with `lodash@4.17.21` may fail with `lodash@5.x` due to breaking changes. When using skills like `frontend-design` to build UI components, or `tdd` to generate tests, Claude needs accurate version information to produce working code.

## Method 1: Explicit Version Declarations in Prompts

The simplest approach is to state your version requirements directly in the prompt. When you begin a conversation with Claude, include the exact versions you need:

```
I need a React component using react-router-dom version 6.4.x. 
Use useNavigate() from react-router-dom@6.4.x, not the newer hooks.
```

This works well for one-off requests, but becomes tedious if you repeatedly need specific versions.

## Method 2: Project Configuration Files

Claude reads your project's dependency files and respects their constraints. Create or update your `package.json`, `requirements.txt`, or equivalent:

```json
{
  "dependencies": {
    "axios": "1.6.0",
    "express": "4.18.2"
  }
}
```

[When you invoke skills like `pdf` or `xlsx` for document generation](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/), Claude will read your lockfile and use matching versions. The same applies when using `canvas-design` or `algorithmic-art` for visual outputs that depend on specific rendering libraries.

## Method 3: Version Constraints in Skill Instructions

[embed version requirements directly in the skill configuration](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/). Skills like `superagent` or custom MCP configurations can include version pinning:

```
When creating HTTP requests, always use axios version 1.6.0.
Do not use axios 2.x even if it would otherwise be selected.
```

This approach works best when you have established patterns that rarely change. Skills like `internal-comms` for documentation generation can benefit from pinned versions if your company uses specific library versions.

## Method 4: Create a Project Context File

For complex projects with many version dependencies, create a `.claude-version-requirements.md` file in your project root:

```
# Claude Code Library Version Requirements

- React: 18.2.0
- TypeScript: 5.1.6
- TailwindCSS: 3.3.3
- Node: 18.17.0

When generating code, read this file first and use these exact versions.
```

Reference this file in your prompts:

```
Before writing any code, read .claude-version-requirements.md 
and ensure all generated code uses the specified versions.
```

## Method 5: Using Lockfiles

Lockfiles contain exact version trees. Claude respects lockfiles when they exist. Ensure your `package-lock.json`, `yarn.lock`, or `Pipfile.lock` contains the versions you need, then mention it in your prompt:

```
Use the exact versions from package-lock.json in the project root.
Do not suggest version upgrades.
```

This is particularly effective with skills that generate large amounts of code, like `scaffolding` or `fullstack` implementations.

## Practical Example: Pinning Versions for a PDF Processing Task

Suppose you need to generate PDFs using specific library versions. Using the `pdf` skill, your prompt would be:

```
Using the pdf skill, create a report generator. 
Required versions:
- pdfkit: 0.13.0
- pdf-lib: 1.17.1

Do not use newer versions. The generated code must work with these exact versions.
```

Claude will reference these constraints when writing code and avoid suggesting incompatible APIs.

## Version Constraints for Test-Driven Development

When using the `tdd` skill, version control becomes critical. Tests written for one library version may fail with another. Structure your requests:

```
Using tdd, write tests for the user authentication module.
Use Jest 29.x and supertest 4.x. The tests should pass with 
these exact versions, not Jest 30.x or supertest 5.x.
```

## Handling Version Conflicts

Sometimes the version you need conflicts with another dependency. In these cases, be explicit about priorities:

```
I need lodash 4.17.21. If this conflicts with another dependency 
in package.json, prioritize lodash 4.17.21 and note the conflict.
```

Claude will either resolve the conflict or alert you to the incompatibility rather than silently upgrading.

## Best Practices for Version Control with Claude Code

1. **Document versions early**: Include version requirements at the start of your session
2. **Use lockfiles**: Keep lockfiles committed to version control
3. **Create version manifests**: For complex projects, a version requirements file reduces repetition
4. **Be specific in skill invocations**: When using skills like `frontend-design` or `pptx`, specify versions in the initial prompt
5. **Verify generated code**: Always check that generated dependencies match your requirements

## Summary

Controlling library versions in Claude Code requires explicit communication. Whether you use direct prompts, project configuration files, skill instructions, or version manifest files, the key is stating your requirements clearly and consistently. This ensures that code generated by skills like `pdf`, `xlsx`, `tdd`, or `frontend-design` uses exactly the versions your project needs.

## Related Reading

- [Claude Skills Automated Dependency Update Workflow](/claude-skills-guide/claude-skills-automated-dependency-update-workflow/) — automate dependency upgrades safely across your codebase
- [How to Make Claude Code Work with Legacy Codebase](/claude-skills-guide/how-to-make-claude-code-work-with-legacy-codebase/) — manage pinned versions in older projects with mixed dependencies
- [Claude Code Secret Scanning: Prevent Credential Leaks Guide](/claude-skills-guide/claude-code-secret-scanning-prevent-credential-leaks-guide/) — audit dependencies for security vulnerabilities alongside version pinning
- [How to Make Claude Code Not Over Engineer Solutions](/claude-skills-guide/how-to-make-claude-code-not-over-engineer-solutions/) — prevent Claude from adding unnecessary library dependencies

Built by theluckystrike — More at [zovo.one](https://zovo.one)
