---
layout: default
title: "What Is the Best Way to Name Claude Skill Files Consistently"
description: "A practical guide to naming conventions for Claude Code skill files. Learn patterns that improve discoverability, reduce confusion, and scale your skill library."
date: 2026-03-14
author: theluckystrike
---

# What Is the Best Way to Name Claude Skill Files Consistently

Naming your Claude skill files consistently is one of those details that seems minor until your skill library grows beyond a handful. When you have five skills, anything works. When you have fifty, inconsistent naming creates friction every time you invoke a skill. This guide provides concrete patterns you can adopt immediately.

## Why Naming Conventions Matter

Claude Code skills live in your `~/claude/skills/` directory as markdown files. The filename becomes part of the invocation command. If you have skills named `frontend-design.md`, `pdf.md`, `tdd.md`, and `Supermemory.md`, you end up with an inconsistent experience when typing `/frontend-design` versus `/pdf` versus `/Supermemory`. The inconsistency is not just aesthetic—it affects your muscle memory and makes it harder to remember which skills exist.

A consistent naming convention also helps when sharing skills with others or browsing a team's skill collection. When everyone follows the same pattern, the library becomes predictable and navigable.

## The Core Pattern: kebab-case with Descriptive Names

The most practical approach uses kebab-case (lowercase letters with hyphens) combined with descriptive, multi-word names. This aligns with how Claude Code itself handles skill invocation.

```
good-name-example.md
├── frontend-design.md
├── pdf-parser.md
├── tdd-helper.md
└── supermemory-sync.md
```

This pattern gives you several advantages. First, the hyphens make long names readable. Second, the all-lowercase format prevents case-sensitivity issues across operating systems. Third, the descriptive nature of the names means you can guess the invocation command even for skills you have not used recently.

## Recommended Naming Structure

A well-named skill file follows this formula:

```
[domain]-[purpose].md
```

The **domain** identifies what area the skill covers. The **purpose** describes what the skill does. This two-part structure creates a natural grouping when skills are sorted alphabetically.

Examples from common skill libraries:

- `frontend-design` — frontend is the domain, design is the purpose
- `pdf-extract` — pdf is the domain, extract is the purpose
- `tdd-scaffold` — tdd is the domain, scaffold is the purpose
- `supermemory-export` — supermemory is the domain, export is the purpose

When you need more specificity, extend to three parts:

- `react-component-generator`
- `python-unittest-scaffolder`
- `git-branch-cleaner`

The key principle is that each skill name should convey both what domain it touches and what action it performs.

## What to Avoid

Several common patterns create problems over time:

**Single words**: A skill named `design.md` is too vague. What kind of design? UI design? Interior design? The name should communicate scope.

**CamelCase or PascalCase**: Files named `FrontendDesign.md` or `FrontendDesign.md` create inconsistency when some skills use camelCase and others use PascalCase. Stick to kebab-case.

**Underscores**: While technically valid, underscores `skill_name.md` look different from the hyphen-based pattern and can feel out of place in an otherwise consistent library.

**Numbers in names**: Avoid `skill2.md` or `v2-helper.md`. These become confusing quickly and do not convey meaning.

**Abbreviations without context**: A skill named `db.md` is unclear. Is it for database design? Database connection strings? Use `database-connection` or `database-migration` instead.

## Practical Examples

Here is how to apply these principles to skills you might create:

```
# Instead of this:
Code.md
my_skill.md
TDD.md
 SUPERMEMORY.md
pdfhelper.md

# Use this:
code-review.md
tdd-helper.md
supermemory-export.md
pdf-text-extractor.md
```

When you invoke these skills, the commands become predictable:

```
/code-review
/tdd-helper
/supermemory-export
/pdf-text-extractor
```

Each command clearly communicates what will happen, and the consistent formatting makes tab-completion work reliably if your terminal supports it.

## Organizing Multiple Skills in Related Domains

When you have several skills covering the same domain, use a consistent prefix:

```
# PDF-related skills
pdf-extract.md
pdf-merge.md
pdf-fill-form.md
pdf-compress.md

# Testing-related skills
tdd-scaffold.md
tdd-assertion-helper.md
integration-test-runner.md

# Frontend-related skills
frontend-design.md
frontend-accessibility-check.md
frontend-i18n-helper.md
```

This grouping means skills sort together alphabetically, making it easier to scan the available options. It also helps when you want to document or explain your skill library—you can say "all the PDF skills" and know exactly which files you mean.

## Skill Names and Skill Metadata

The skill filename is separate from the internal skill definition. Inside each markdown file, you may also define a skill name in the front matter:

```yaml
---
name: frontend-design
description: Generate frontend components with modern design patterns
---
```

This internal name should match the filename (excluding the `.md` extension) to avoid confusion. If your file is `frontend-design.md`, the internal name should be `frontend-design`. This alignment ensures that when you view skill metadata or documentation, the names are consistent everywhere.

## Testing Your Convention

Before committing to a naming convention, verify it works for your use case:

1. List all your current skill files using `ls ~/claude/skills/` or your skills directory
2. Check which names feel unclear or ambiguous
3. Rename any that violate your chosen convention
4. Verify that invocation commands still work after renaming
5. Document your convention in a README or skill library overview

If you work on a team, share the convention early. Adding a naming guideline to your team's onboarding docs prevents inconsistency before it starts.

## Summary

The best way to name Claude skill files consistently is to use kebab-case with descriptive, multi-word names that follow the `[domain]-[purpose]` pattern. This approach creates predictable invocation commands, groups related skills together alphabetically, and scales well as your library grows.

Avoid single words, mixed case styles, underscores, and numbers. Keep the names human-readable and domain-specific. When in doubt, err on the side of being more descriptive—the extra characters in the filename pay off every time you invoke the skill.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
