---
layout: default
title: "Automated Blog Workflow with Claude Skills"
description: "Build an automated blog post workflow using Claude skills. Step-by-step tutorial for content creation, formatting, and publishing with real examples."
date: 2026-03-13
categories: [workflows]
tags: [claude-code, claude-skills, automation, blogging, docx, canvas-design]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-skills-automated-blog-post-workflow-tutorial/
---

# Automated Blog Post Workflow with Claude Skills

Publishing consistent blog content takes time because the work spans multiple tools: drafting, formatting, image creation, SEO checks, and Git commits. Claude skills let you handle each stage inside Claude Code, reducing context-switching and keeping your workflow in the terminal.

This tutorial builds a practical blog publishing pipeline using Claude's built-in skills.

## The Skills Involved

Before getting into the workflow, here is what each relevant skill actually does:

- `/docx` — Converts or generates `.docx` documents from content you describe
- `/canvas-design` — Creates visual assets (images, diagrams) from text descriptions
- [supermemory skill](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) (`/supermemory`) — Stores and retrieves persistent notes across Claude Code sessions
- [pdf skill](/claude-skills-guide/best-claude-skills-for-data-analysis/) (`/pdf`) — Processes PDF documents, extracts text, creates PDF output
- [tdd skill](/claude-skills-guide/best-claude-skills-for-developers-2026/) (`/tdd`) — Guides test-driven development; not directly useful for blog content but useful if you build tooling around the workflow

Skills are plain Markdown files stored in `~/.claude/skills/`. You invoke them with a `/skill-name` slash command at the start of a message in Claude Code. There are no install commands — you place the `.md` file in the skills directory and the slash command becomes available.

## Phase 1: Research and Outline

Start a Claude Code session and use `/supermemory` to pull up context from previous posts:

```
/supermemory
What topics have I covered in my last five blog posts? What gaps exist?
```

If you are starting fresh, describe your blog's focus areas and ask Claude to help outline a post:

```
I write about developer productivity and AI tools. Outline a 1200-word post
about using Claude Code for code review automation. Include an introduction,
three main sections with H2 headers, and a conclusion.
```

Save the outline to a file:

```bash
# From your terminal, write the outline to a draft file
claude -p "Outline a 1200-word post about Claude Code for code review automation.
Include intro, three H2 sections, and conclusion." > drafts/code-review-outline.md
```

## Phase 2: Draft the Post

Open Claude Code interactively and write section by section:

```
I have an outline in drafts/code-review-outline.md. Write the introduction section
(~200 words). Focus on the problem developers face doing code review manually.
Avoid filler phrases.
```

Iterate section by section. Keep each prompt focused on one part of the post. This produces tighter output than asking for the full article at once.

When the draft is complete, use `/docx` to get a formatted Word document for review:

```
/docx
Convert my draft in drafts/code-review-post.md to a Word document with proper
heading styles (H1 for title, H2 for sections) and save it as drafts/code-review-post.docx
```

## Phase 3: SEO Front Matter

Every post needs accurate front matter. Ask Claude to generate it:

```
Generate Jekyll front matter for a post titled "Automating Code Review with Claude Code".
- Keep the title under 60 characters
- Write a meta description under 155 characters that includes "code review automation"
- Suggest 4-6 relevant tags
- Use today's date: 2026-03-13
```

Apply the front matter to your Markdown file manually or with a shell script:

```bash
#!/bin/bash
# prepend-front-matter.sh — prepend generated front matter to draft

DRAFT="drafts/code-review-post.md"
FRONT_MATTER="drafts/front-matter.yml"
OUTPUT="articles/claude-code-review-automation.md"

cat "$FRONT_MATTER" "$DRAFT" > "$OUTPUT"
echo "Created $OUTPUT"
```

## Phase 4: Featured Image with /canvas-design

Generate a featured image that fits your blog's style:

```
/canvas-design
Create a featured image for a blog post about AI code review. Style: clean, minimal,
dark background with blue accents, 1200x630 pixels. Show a terminal window with
highlighted diff output.
```

The `/canvas-design` skill generates the image and describes how to reproduce it or provides the file directly, depending on your setup. Save the output to your `assets/images/` directory.

## Phase 5: Store Style Guidelines with /supermemory

After finalizing a post, record what worked:

```
/supermemory
Remember: my blog posts use second-person voice, avoid passive constructions,
target 900-1200 words, and always include a code example in the first section.
```

On future sessions, retrieve this context at the start:

```
/supermemory
What are my blog writing guidelines?
```

This keeps your voice consistent without pasting a style guide into every prompt.

## Phase 6: Publish to Git

Once the post is ready, publish it:

```bash
#!/bin/bash
# publish.sh — commit and push a new article

ARTICLE="$1"
TITLE=$(grep '^title:' "$ARTICLE" | sed 's/title: //' | tr -d '"')

cd ~/blog

cp "$ARTICLE" "_posts/$(date +%Y-%m-%d)-$(basename $ARTICLE)"

git add "_posts/"
git commit -m "Add post: $TITLE"
git push origin main

echo "Published: $TITLE"
```

Run it with:

```bash
./publish.sh drafts/code-review-post.md
```

Your CI/CD pipeline (GitHub Actions, Netlify, Cloudflare Pages) picks up the push and deploys automatically.

## Checking Quality Before Publishing

Before committing, run a quick self-check inside Claude Code:

```
Review drafts/code-review-post.md for:
1. Does the title match the front matter title?
2. Does the first paragraph contain the primary keyword?
3. Are there any broken Markdown links (e.g., empty href)?
4. Is the word count between 900 and 1400?

Report each issue on its own line.
```

This catches common mistakes — mismatched titles, missing keywords, formatting errors — before they reach production.

## Putting It Together

The complete workflow looks like this:

1. `/supermemory` — retrieve context from previous sessions
2. Outline in Claude Code, save to draft file
3. Draft section by section, iterate with Claude
4. `/docx` — export to Word for offline review
5. Generate front matter with Claude, apply to Markdown
6. `/canvas-design` — create featured image
7. Quality check prompt
8. `publish.sh` — commit and push

Each step is a focused Claude Code interaction or a small shell script. Nothing requires external platforms or special installs beyond having Claude Code and the built-in skills available.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Full developer skill stack
- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/best-claude-skills-for-devops-and-deployment/) — Automate deployments with Claude skills
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


Built by theluckystrike — More at [zovo.one](https://zovo.one)
