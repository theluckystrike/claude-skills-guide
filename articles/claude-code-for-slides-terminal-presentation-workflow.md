---
layout: default
title: "Build Terminal Slides with Claude Code (2026)"
description: "Create terminal-based presentations with Claude Code. Markdown-to-slides generation using Marp, Slidev, and terminal presentation frameworks."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-slides-terminal-presentation-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
last_tested: "2026-04-21"
geo_optimized: true
---


Claude Code for Slides Terminal Presentation Workflow

Gone are the days of wrestling with PowerPoint or struggling with Google Slides' clunky interface. For developers who live in the terminal, there's a better way to create presentations, and when you combine terminal-based slide tools with Claude Code, you get a powerful workflow that can dramatically speed up your presentation creation process.

Why Terminal-Based Presentations?

Terminal-based presentation tools offer several compelling advantages over traditional slide software. First, they keep you in your workflow, you never need to leave your terminal or switch context. Second, slides are typically written in Markdown, which means you can version control them with Git, collaborate via pull requests, and use your favorite text editors. Third, many terminal slide tools generate beautiful HTML presentations that work in any browser.

Popular terminal-based presentation tools include:

- Marp: Markdown presentation ecosystem
- reveal.js: HTML presentation framework
- mdp: A Markdown-based presentation tool for Linux
- sentaku: Terminal-based presentation tool
- t презентац: Russian-language terminal presenter

## Setting Up Your Terminal Presentation Environment

Before integrating with Claude Code, let's set up a basic terminal presentation environment. We'll use Marp as our primary tool because it offers excellent CLI support and generates professional HTML slides from Markdown.

## Installing Marp CLI

Marp CLI can be installed via npm:

```bash
npm install -g @marp-team/marp-cli
```

Verify the installation:

```bash
marp --version
```

## Creating Your First Slide Deck

Create a new Markdown file for your presentation:

```markdown
---
marp: true
theme: default
paginate: true
---

Welcome to My Presentation

---

Agenda

- Introduction
- Main Concepts
- Live Demo
- Q&A

---

Key Points

1. First important point
2. Second important point 
3. Third important point
```

Save this as `presentation.md` and convert it to slides:

```bash
marp presentation.md -o slides.html
```

## Integrating Claude Code into Your Workflow

Now here's where Claude Code becomes invaluable. By creating a custom skill for presentation workflows, you can automate repetitive tasks and get AI assistance for content creation.

## Creating a Presentation Skill

Create a skill file at `~/.claude/skills/presentation-skill.md`:

```markdown
Presentation Creation Skill

Overview
This skill helps create terminal-based presentations using Marp and other tools.

Capabilities
- Generate slide content from topic descriptions
- Convert existing Markdown to presentation format
- Apply consistent theming across slide decks
- Export to multiple formats (HTML, PDF, PPTX)

Tools
- marp: For Markdown-to-slides conversion
- pandoc: For format conversions

Instructions
When creating presentations:
1. Ask for the main topic and key points
2. Generate structured Markdown with proper Marp directives
3. Include speaker notes where appropriate
4. Apply consistent styling throughout
```

## Using Claude Code to Generate Slides

With your skill loaded, you can now work with Claude Code to create presentations. Here's a practical example:

Prompt Claude Code with:
```
Create a 10-slide presentation about API design best practices. Include sections on REST principles, versioning strategies, error handling, and authentication. Use a clean, developer-focused style.
```

Claude Code will generate the Markdown structure:

```markdown
---
marp: true
theme: default
---

API Design Best Practices

---

Why API Design Matters

- APIs are the interface of your product
- Good APIs = happy developers
- Bad APIs = endless support tickets

---

REST Fundamentals

- Resource-oriented URLs
- HTTP verbs semantically
- Stateless requests
- JSON responses

<!-- ... more slides ... -->
```

## Advanced Workflow: Automated Presentation Generation

For teams that need to generate presentations regularly (weekly reports, status updates), you can create an automated pipeline.

## Sample Automation Script

```bash
#!/bin/bash
generate-presentation.sh

TOPIC=$1
OUTPUT_DIR=${2:-"./presentations"}

Create output directory
mkdir -p "$OUTPUT_DIR"

Ask Claude Code to generate content
claude --print "Generate a 5-slide presentation about $TOPIC" > "$OUTPUT_DIR/temp.md"

Convert to HTML with Marp
marp "$OUTPUT_DIR/temp.md" -o "$OUTPUT_DIR/${TOPIC// /-}.html"

Clean up temp file
rm "$OUTPUT_DIR/temp.md"

echo "Presentation created: $OUTPUT_DIR/${TOPIC// /-}.html"
```

Run it with:

```bash
./generate-presentation.sh "Kubernetes Basics"
```

## Enhancing Presentations with Code Examples

One of the biggest advantages of terminal-based presentations is smooth code integration. Here's how to make your code snippets shine:

## Syntax Highlighting

Marp supports syntax highlighting out of the box:

```python
def fibonacci(n):
 """Calculate the nth Fibonacci number."""
 if n <= 1:
 return n
 return fibonacci(n-1) + fibonacci(n-2)

Usage
print(fibonacci(10)) # Output: 55
```

## Live Code Execution in Demos

For live coding demonstrations, consider using ttygif or asciinema to record your terminal and embed the recordings in presentations:

```bash
Record your terminal session
asciinema rec demo.cast

Embed in your slide
![](./demo.cast)
```

## Best Practices for Developer Presentations

## Keep It Clean

- One idea per slide
- Use bullet points, not paragraphs
- Limit to 6 bullets per slide
- Choose readable fonts (minimum 24pt)

## Make It Interactive

- Include live demos when possible
- Add speaker notes for complex slides
- Use animations sparingly

## Optimize for Your Audience

- Developers: Include code examples
- Executives: Focus on business value
- Mixed: Balance technical depth with accessibility

## Troubleshooting Common Issues

## Slides Not Rendering Correctly

If your Marp slides aren't rendering as expected:

1. Check your Markdown syntax
2. Verify Marp directives are in the correct position (top of file)
3. Ensure you're using valid theme names

## PDF Export Problems

For PDF export issues:

```bash
Install puppeteer dependencies
marp --puppeteer-args --no-sandbox --disable-setuid-sandbox
```

## Image Path Issues

Use relative paths for images and ensure they're in an accessible location:

```markdown
![](./images/diagram.png)
```

## Conclusion

Terminal-based presentation workflows, sped up with Claude Code, offer developers a powerful alternative to traditional slide software. By staying in your terminal, using version control for your presentations, and using AI assistance, you can create professional slides faster than ever before.

Start small, convert your next presentation to Markdown and see the difference. Once you experience the workflow, you'll never go back to drag-and-drop slide builders.


---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-slides-terminal-presentation-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Huh Forms Terminal Workflow Guide](/claude-code-for-huh-forms-terminal-workflow-guide/)
- [Claude Code for k9s Kubernetes Terminal Workflow Guide](/claude-code-for-k9s-kubernetes-terminal-workflow-guide/)
- [Claude Code for VHS Terminal Recorder Workflow](/claude-code-for-vhs-terminal-recorder-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

