---
layout: default
title: "Automated Blog Workflow with Claude (2026)"
description: "Build an automated blog post workflow using Claude skills. Step-by-step tutorial for content creation, formatting, and publishing with real examples."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [workflows]
tags: [claude-code, claude-skills, automation, blogging, docx, canvas-design]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-skills-automated-blog-post-workflow-tutorial/
geo_optimized: true
---

# Automated Blog Post Workflow with Claude Skills

Publishing consistent blog content takes time because the work spans multiple tools: drafting, formatting, image creation, SEO checks, and Git commits. Claude skills let you handle each stage inside Claude Code, reducing context-switching and keeping your workflow in the terminal.

This tutorial builds a practical blog publishing pipeline using Claude's built-in skills. By the end, you will have a repeatable system that takes a topic idea from zero to committed Markdown in a single terminal session, with each step handled by a focused skill or script rather than a scattered collection of browser tabs and apps.

## Why Build an Automated Blog Workflow

Manual blog workflows have a hidden tax. You open a text editor, switch to a browser for research, tab to a design tool for the featured image, jump to an SEO plugin to check keyword density, then manually copy files around before committing. Each context switch costs time and breaks focus.

A skill-based workflow in Claude Code removes most of those switches. Your drafting, formatting, SEO metadata, image generation, and Git publishing happen from the same session. You stay in the terminal, prompts stay focused, and the output at each stage feeds directly into the next step without manual copying.

This approach also makes the workflow scriptable. Once you understand what each phase does, you can chain phases together with shell scripts and run a near-automated end-to-end pipeline for routine posts.

## The Skills Involved

Before getting into the workflow, here is what each relevant skill actually does:

- `/docx`. Converts or generates `.docx` documents from content you describe
- `/canvas-design`. Creates visual assets (images, diagrams) from text descriptions
- [supermemory skill](/claude-skills-token-optimization-reduce-api-costs/) (`/supermemory`). Stores and retrieves persistent notes across Claude Code sessions
- [pdf skill](/best-claude-skills-for-data-analysis/) (`/pdf`). Processes PDF documents, extracts text, creates PDF output
- [tdd skill](/best-claude-skills-for-developers-2026/) (`/tdd`). Guides test-driven development; not directly useful for blog content but useful if you build tooling around the workflow

Skills are plain Markdown files stored in `~/.claude/skills/`. You invoke them with a `/skill-name` slash command at the start of a message in Claude Code. There are no install commands. you place the `.md` file in the skills directory and the slash command becomes available.

## Skills vs. Shell Scripts: When to Use Each

A useful mental model: skills handle content generation and tool-specific transformations, while shell scripts handle file operations, directory management, and Git operations. The two complement each other cleanly.

| Task | Use Skill | Use Shell Script |
|------|-----------|-----------------|
| Draft a post section | Claude Code prompt |. |
| Export to Word | `/docx` |. |
| Generate featured image | `/canvas-design` |. |
| Store style guidelines | `/supermemory` |. |
| Prepend front matter |. | `prepend-front-matter.sh` |
| Copy to `_posts/` directory |. | `publish.sh` |
| Git commit and push |. | `publish.sh` |
| Quality checks | Claude Code prompt |. |

Knowing which layer handles each task prevents you from trying to do file management through Claude prompts or asking shell scripts to generate creative content.

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
From your terminal, write the outline to a draft file
claude -p "Outline a 1200-word post about Claude Code for code review automation.
Include intro, three H2 sections, and conclusion." > drafts/code-review-outline.md
```

## Building a Topic Backlog with /supermemory

A common problem for bloggers is running out of topics or forgetting ideas. Use `/supermemory` as a persistent backlog:

```
/supermemory
Add to my topic backlog:
- Comparing Claude Code vs Cursor for refactoring
- Setting up pre-commit hooks with Claude review
- Using Claude to write shell scripts from English descriptions
```

At the start of any session, retrieve the backlog:

```
/supermemory
Show me my current topic backlog. Which post would best complement my existing content?
```

This keeps ideas organized without a separate notes app. The persistent memory means you can reference your backlog weeks later without hunting through old notes.

## Researching Competitive Content

Before drafting, ask Claude to help you understand what already exists on your topic:

```
I want to write about code review automation with Claude Code.
What angles are commonly covered in developer productivity posts about AI code review?
What could a post offer that goes beyond the typical "here are the features" overview?
```

This produces a differentiated angle before you write a single sentence of the actual post. A post that addresses a specific developer frustration or workflow gap performs better than a generic feature walkthrough.

## Phase 2: Draft the Post

Open Claude Code interactively and write section by section:

```
I have an outline in drafts/code-review-outline.md. Write the introduction section
(~200 words). Focus on the problem developers face doing code review manually.
Avoid filler phrases.
```

Iterate section by section. Keep each prompt focused on one part of the post. This produces tighter output than asking for the full article at once.

## Section-by-Section Drafting Strategy

Writing section by section gives you control over each piece before moving on. A practical approach:

1. Write the introduction last. Draft body sections first, then write an intro that accurately frames what follows.
2. Keep section prompts specific. Instead of "write the section about setup," say "Write 250 words on setting up the Claude Code CLI. Include the install command, how to authenticate with an API key, and the first test command a developer would run."
3. Use follow-up prompts to tighten each section: "Shorten this to 200 words. Cut any sentence that restates what the previous sentence said."

```
Write the "Setting Up Claude Code for Review" section (~250 words).
Cover: install command, API key configuration, and running a first review.
Use second-person voice. Include one code example showing the CLI invocation.
Avoid passive voice.
```

After Claude returns the section, review it immediately and iterate before moving on:

```
Good. Now tighten it by 50 words. Remove the sentence starting with "It is worth noting".
```

When the draft is complete, use `/docx` to get a formatted Word document for review:

```
/docx
Convert my draft in drafts/code-review-post.md to a Word document with proper
heading styles (H1 for title, H2 for sections) and save it as drafts/code-review-post.docx
```

## Handling Code Examples

Code examples are often the difference between a post that gets bookmarked and one that gets skipped. Ask Claude to generate working code examples tied to your topic:

```
Write a code example showing a developer running a Claude Code review on a Python file.
Show: the CLI command, a sample output block showing Claude's review comments,
and one follow-up command to apply a suggested fix. Use realistic variable names.
```

Always test code examples yourself before publishing. Ask Claude to flag any assumptions in the examples:

```
In the code example you just wrote, what assumptions does the reader need to meet
for this to work? List them as a bullet list I can add as a "Prerequisites" note.
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
prepend-front-matter.sh. prepend generated front matter to draft

DRAFT="drafts/code-review-post.md"
FRONT_MATTER="drafts/front-matter.yml"
OUTPUT="articles/claude-code-review-automation.md"

cat "$FRONT_MATTER" "$DRAFT" > "$OUTPUT"
echo "Created $OUTPUT"
```

## SEO Checks Beyond Front Matter

Front matter is the minimum. Ask Claude to check keyword distribution throughout the draft:

```
Review drafts/code-review-post.md for SEO:
1. Does the primary keyword "code review automation" appear in the first 100 words?
2. Does it appear in at least one H2 heading?
3. Are there at least two natural secondary keywords related to the topic?
4. Is the meta description between 120 and 155 characters?

List any issues with the line number or section where the problem occurs.
```

A second useful check is internal linking. Ask Claude to suggest relevant internal links based on your existing articles:

```
I have a blog about developer productivity and AI tools. The new post covers
code review automation. Suggest 3 natural internal link opportunities for posts about:
- Claude Code setup and configuration
- AI-assisted code quality tools
- Developer workflow automation

Format each suggestion as: [anchor text] -> [suggested topic to link to]
```

## Generating Schema Markup

For posts that benefit from structured data, ask Claude to generate appropriate JSON-LD:

```
Generate JSON-LD schema markup for a blog post:
- Type: Article
- Title: "Automating Code Review with Claude Code"
- Author: "Claude Skills Guide"
- Date: 2026-03-13
- Description: [the meta description]

Format it as a script tag I can include in the post's front matter or layout.
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

## Building a Consistent Visual Style

After your first successful featured image, store the style parameters with `/supermemory`:

```
/supermemory
Remember my featured image style:
- 1200x630 pixels
- Dark background (#1a1a2e)
- Blue accent color (#4a90d9)
- Minimal text on the image
- Always include a terminal or code element
- Font: monospace for code, sans-serif for labels
```

On future posts, reference this style in your `/canvas-design` prompt:

```
/canvas-design
Using my stored featured image style, create an image for a post about
Git hooks and pre-commit automation. Show a pre-commit hook catching an error.
```

Consistent visual style across posts builds brand recognition and looks professional without requiring a separate design process for each article.

## Creating Supplementary Diagrams

For posts that explain processes or architectures, a flow diagram adds clarity that code examples alone cannot provide:

```
/canvas-design
Create a workflow diagram showing a blog post pipeline:
Boxes: Research -> Outline -> Draft -> SEO -> Image -> Publish
Style: horizontal flow, simple arrows, developer blog aesthetic
Width: 800px, Height: 200px
```

Embed the diagram inline in the post to illustrate the workflow phases without the reader having to parse a long list.

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

## Tracking Post Performance Notes

Use `/supermemory` to log performance observations alongside style notes:

```
/supermemory
Post performance note: "Claude Code for Git workflows" (published 2026-02-20) performs
well in search. Posts with "how to" in the title and a numbered list in the intro
get more clicks than pure concept posts. Prioritize tutorial-style posts.
```

Over time, this builds a personal editorial intelligence layer. Your memory entries become a compounding record of what works, making each new post informed by the outcomes of previous ones.

## Phase 6: Publish to Git

Once the post is ready, publish it:

```bash
#!/bin/bash
publish.sh. commit and push a new article

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

## Extended Publish Script with Validation

A more solid publish script validates the file before committing:

```bash
#!/bin/bash
publish-validated.sh. validate then commit and push

ARTICLE="$1"

if [ -z "$ARTICLE" ]; then
 echo "Usage: $0 <article-file>"
 exit 1
fi

if [ ! -f "$ARTICLE" ]; then
 echo "Error: file not found: $ARTICLE"
 exit 1
fi

Check front matter exists
if ! grep -q "^---" "$ARTICLE"; then
 echo "Error: no front matter found in $ARTICLE"
 exit 1
fi

Check required front matter fields
for field in title description date permalink; do
 if ! grep -q "^$field:" "$ARTICLE"; then
 echo "Error: missing front matter field: $field"
 exit 1
 fi
done

TITLE=$(grep '^title:' "$ARTICLE" | sed 's/title: //' | tr -d '"')
DATE=$(date +%Y-%m-%d)
BASENAME=$(basename "$ARTICLE")
DEST="_posts/${DATE}-${BASENAME}"

cd ~/blog

cp "$ARTICLE" "$DEST"

git add "$DEST"
git commit -m "Add post: $TITLE"
git push origin main

echo "Published: $TITLE -> $DEST"
```

The validation catches missing front matter fields before they cause a build failure on your static site generator.

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

This catches common mistakes. mismatched titles, missing keywords, formatting errors. before they reach production.

## Extended Quality Checklist

For a thorough pre-publish review, expand the checklist:

```
Review drafts/code-review-post.md against this quality checklist:

Content:
- Does the intro clearly state who the post is for?
- Does each H2 section deliver on what its heading promises?
- Are all code examples complete and syntactically valid?
- Does the conclusion include a clear next step for the reader?

Formatting:
- Are all H2 headings title case?
- Do code blocks specify the language (e.g., ```bash, ```python)?
- Are there any lines longer than 120 characters outside code blocks?

SEO:
- Does the meta description end with a period?
- Is the primary keyword in both the title and the first 100 words?
- Are external links present and do they include descriptive anchor text?

Report each failure with the section name and a brief fix suggestion.
```

Running this full checklist adds two minutes to your workflow and prevents publishing issues that are tedious to fix after deployment.

## Putting It Together

The complete workflow looks like this:

1. `/supermemory`. retrieve context from previous sessions
2. Outline in Claude Code, save to draft file
3. Draft section by section, iterate with Claude
4. `/docx`. export to Word for offline review
5. Generate front matter with Claude, apply to Markdown
6. `/canvas-design`. create featured image
7. Quality check prompt
8. `publish.sh`. commit and push

Each step is a focused Claude Code interaction or a small shell script. Nothing requires external platforms or special installs beyond having Claude Code and the built-in skills available.

## Adapting the Pipeline for Your Publishing Frequency

For high-frequency publishing (daily or several times per week), automate the repetitive steps further:

```bash
#!/bin/bash
new-draft.sh. scaffold a new draft with front matter template

SLUG="$1"
DATE=$(date +%Y-%m-%d)
DRAFT="drafts/${DATE}-${SLUG}.md"

cat > "$DRAFT" <<EOF
---
layout: default
title: ""
description: ""
date: $DATE
categories: []
tags: []
author: "Claude Skills Guide"
permalink: /${SLUG}/
---

#

EOF

echo "Created draft: $DRAFT"
```

This scaffold gives you a ready-to-edit file with the correct date and permalink slug already filled in. Combined with the publish script, scaffolding a draft and publishing the finished post become one-command operations bookending the Claude Code drafting session in the middle.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-automated-blog-post-workflow-tutorial)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Full developer skill stack
- [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/). Automate deployments with Claude skills
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate automatically

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

