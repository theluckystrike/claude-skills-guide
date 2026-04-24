---
layout: default
title: "How to Contribute Claude Skills to Open"
description: "Step-by-step guide to contributing Claude AI skills to open source. Learn code structure, testing, PR best practices, and how to get your skill adopted."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, open-source, contribution]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /how-to-contribute-claude-skills-to-open-source/
geo_optimized: true
---

# How to Contribute Claude Skills to Open Source

Claude Code skills are `.md` files. plain Markdown with YAML front matter. This makes them easy to version-control, review, and share. Contributing a skill to open source means writing a clean `.md` file, documenting it well, and submitting a pull request.

## Understanding Claude Skills Architecture

A Claude skill is a single Markdown file. Claude reads it when you invoke `/skill-name` and follows the instructions inside. There's no build step, no compiled code, and no special runtime. just the `.md` file. The skill.md format is central to this, for a complete walkthrough of how it works, see [Skill MD File Format Explained With Examples](/claude-skill-md-format-complete-specification-guide/).

```markdown
---
name: watermark-pdf
description: "Add a text watermark to PDF documents"
---

Watermark PDF Skill

This skill adds configurable text watermarks to PDF files using pypdf.

Usage

Describe the PDF file path, the watermark text, and desired opacity.
Claude will generate the Python code to apply the watermark using pypdf.

Example

/watermark-pdf Add "DRAFT" watermark to report.pdf at 30% opacity
```

That's a complete, valid skill file.

## Preparing Your Skill for Open Source

Before submitting, do these checks:

Remove hardcoded values: Replace absolute paths like `/Users/you/projects/...` with relative paths or described placeholders.

Document prerequisites: If the skill relies on a Python library (`pypdf`, `openpyxl`, `pandas`), say so explicitly in the skill body. Users need to install those separately.

Test in isolation: Load your skill in a fresh Claude Code session. Verify it produces correct output for the cases you care about and doesn't hallucinate nonexistent APIs.

Write a clear description: The `description` field is what users see when browsing skills. Make it specific: "Add text watermarks to PDF documents" beats "PDF helper".

## Adding a README

If you are contributing a skill to a standalone repository rather than a PR to an existing collection, include a `README.md` alongside your skill file. The README is the first thing a potential user or maintainer reads, so treat it as your pitch. Cover the following:

- What problem the skill solves in one or two sentences
- A minimal working invocation example
- Installation instructions (where to place the `.md` file)
- Dependencies the user must install before using the skill
- Known limitations or untested edge cases

A short README template:

```markdown
watermark-pdf

A Claude Code skill that adds configurable text watermarks to PDF files.

Usage

Copy `watermark-pdf.md` to `~/.claude/skills/`.

Invoke with:
 /watermark-pdf Add "CONFIDENTIAL" watermark to report.pdf at 20% opacity

Requirements

- Python 3.9+
- pypdf: `pip install pypdf`

Limitations

- Encrypted PDFs require a password prompt before processing
- Image-based (scanned) PDFs are not supported
```

## Choosing a LICENSE

Open-source contributions require an explicit license. Without one, the default is "all rights reserved," which prevents other developers from legally reusing or modifying your skill. For skill files, the most common choices are:

- MIT. maximum permissiveness; anyone can use, fork, and redistribute
- Apache 2.0. similar to MIT with an added patent grant, preferred for larger projects
- CC BY 4.0. appropriate when the file is documentation-first rather than code-first

Include a `LICENSE` file in the repository root. If you are submitting a PR to an existing collection, that repository's license already governs your contribution. check before assuming.

## Providing Example Files

For skills that operate on specific file types (PDFs, spreadsheets, CSVs), include a small sample input file in an `examples/` directory. This serves two purposes: maintainers can reproduce your tests quickly, and new users have a file to practice with immediately. Keep example files small. a one-page PDF or a ten-row CSV is enough.

For guidance on writing the actual skill.md file, see [How to Write a Skill MD File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/).

## GitHub Repository Structure for Shared Skills

If you are publishing a skill as its own repository. rather than contributing to an existing collection. use a layout that is immediately recognizable to other developers:

```
watermark-pdf-skill/
 README.md
 LICENSE
 watermark-pdf.md # The skill file itself
 examples/
 sample-input.pdf
 usage-screenshots/
 result.png
 CONTRIBUTING.md # If you want PRs from others
 CHANGELOG.md # Optional: version history
```

The skill file belongs in the root or in a `skills/` subdirectory if the repository contains more than one skill. Avoid deeply nested paths. Claude users typically drop skill files directly into `~/.claude/skills/` and a clear root-level placement makes it obvious which file to copy.

A `CONTRIBUTING.md` is worth adding even for small repositories. State your expectations clearly:

```markdown
Contributing

1. Fork this repository and create a feature branch.
2. Test your changes in a fresh Claude Code session before opening a PR.
3. Update CHANGELOG.md with a brief description of what changed.
4. Open a PR with a title that completes the sentence: "This PR adds/fixes/updates..."
```

A `CHANGELOG.md` helps users who pin a specific version of a skill know whether upgrading is worth the effort. Use the [Keep a Changelog](https://keepachangelog.com) format for consistency with the wider open-source ecosystem.

## Choosing the Right Repository

Research repositories before opening a PR. Look for:
- An existing skills collection that matches your skill's category
- A contribution guide or `CONTRIBUTING.md`
- Recent activity (stale repos may not merge)

Fork the repo and create a branch:

```bash
git clone https://github.com/username/claude-skills-collection.git
cd claude-skills-collection
git checkout -b add-watermark-pdf-skill
```

## Writing Effective Skill Files

Structure your skill's Markdown body to answer the questions users have:

1. What does this skill do?. one paragraph max
2. When should I use it?. list common trigger scenarios
3. What are the prerequisites?. libraries, tools, file formats
4. Example invocations. 2-3 realistic examples

Keep instructions concrete. Instead of "handle errors appropriately," write "if the PDF is encrypted, Claude will prompt you for a password before proceeding."

## Tips for Writing Good Skill Documentation

Good skill documentation is the difference between a skill that gets adopted and one that sits uninstalled. Apply these principles:

Prefer examples over explanations. A user who sees a real invocation command immediately knows whether the skill matches their problem. An abstract description of what the skill "can do" leaves them guessing. Aim for at least two example invocations that cover distinct use cases.

Name the exact commands Claude will run. If your skill has Claude execute a shell command or call a specific API endpoint, name it in the skill body. Users make security decisions based on what code runs on their machine. vague instructions erode trust and generate support questions.

State what the skill will NOT do. Explicit scope boundaries prevent misuse and reduce bug reports. A skill that converts DOCX to PDF does not also merge documents. say so. A single "Limitations" section at the end of the skill body handles this cleanly:

```markdown
Limitations

- Converts DOCX to PDF only; does not support ODT or RTF input
- Requires LibreOffice installed at a default system path
- Output is unstyled for documents using custom fonts not available on the target system
```

Write for skimmers. Most users scan a skill file before invoking it. Use short paragraphs, bullet points, and inline code formatting for command names and file paths. Avoid dense prose that buries the invocation pattern three paragraphs in.

Version your examples to your dependencies. If your skill generates code that uses a third-party library, note the version the examples were tested against. APIs change, and a skill tested against `pandas 1.5` may silently produce wrong output on `pandas 2.x`.

For a practical look at what the pdf skill can do that your contribution might build on, see [Best Claude Skills for Data Analysis](/best-claude-skills-for-data-analysis/).

## Submitting Your Contribution

Write a PR title that matches what the skill does:

```
Add watermark-pdf skill for adding text watermarks to PDFs
```

In the PR description, include:
- What the skill does
- Any dependencies users need to install
- Example output or a screenshot if it generates visual content

A well-structured PR description speeds up review significantly. Use this template as a starting point:

```markdown
What this adds

A skill that applies configurable text watermarks to PDF files using pypdf.
Useful for marking drafts, confidential documents, and review copies.

Dependencies

- Python 3.9+
- pypdf (`pip install pypdf`)

Testing

Tested against:
- Single-page PDFs
- Multi-page PDFs (watermark applied to every page)
- PDFs with embedded images

Not tested: encrypted PDFs, PDFs larger than 100MB, scanned/image-only PDFs.

Example invocation

 /watermark-pdf Add "DRAFT" watermark to report.pdf at 30% opacity
```

Respond to reviewer feedback promptly. Maintainers may ask for clearer wording, different examples, or adjustments to the front matter format. A PR that sits unresponded for two weeks often gets closed as stale, even if the skill is good.

It also helps to understand the difference between official and community skill expectations before you submit. see [Official vs Community Claude Skills: Which Should You Use?](/anthropic-official-skills-vs-community-skills-comparison/) to calibrate the quality bar appropriately.

## Maintaining Your Contribution

After merge, watch for issues. Users often find edge cases you didn't test. A skill that handles `.pdf` but not password-protected PDFs will get bug reports. Update the skill file to document known limitations if you can't fix them immediately.

List your skill in community directories or forums. Skills gain adoption when people can find them.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=how-to-contribute-claude-skills-to-open-source)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [How to Write a Skill MD File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/). The technical foundation for building any skill
- [Skill MD File Format Explained With Examples](/claude-skill-md-format-complete-specification-guide/). Technical guide to the format your contribution must follow
- [Official vs Community Claude Skills: Which Should You Use?](/anthropic-official-skills-vs-community-skills-comparison/). Understand the ecosystem you're contributing to
- [Open Source vs Proprietary Claude Skills: Future Outlook](/open-source-vs-proprietary-claude-skills-future-outlook/)

*Built by theluckystrike. More at [zovo.one](https://zovo.one)
*


