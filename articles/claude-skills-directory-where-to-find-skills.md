---
layout: default
title: "Claude Skills Directory: Where to Find (2026)"
description: "Find Claude Code skills: built-in skills, community GitHub repositories, skill file locations, and how to install new skills on your machine."
date: 2026-03-13
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
categories: [guides]
tags: [claude-code, claude-skills, directory, installation]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-skills-directory-where-to-find-skills/
geo_optimized: true
---

# Claude Skills Directory: Where to Find Skills

Claude Code skills are `.md` files stored locally at `~/.claude/skills/`. When you invoke `/skill-name`, Claude Code reads that file and gains specialized context for the task. Here's where to find skills and how to install them.

## Built-in Skills

Claude Code ships with a set of official skills that cover common development tasks. These are available by default and don't require manual installation. The primary built-in skills include:

- [pdf](/best-claude-skills-for-data-analysis/). document text extraction, merging, form filling
- docx. Word document creation and manipulation
- pptx. PowerPoint presentation generation
- xlsx. spreadsheet operations with formula support
- [tdd](/best-claude-skills-for-developers-2026/). test-driven development guidance
- frontend-design. UI component generation for React, Vue, Svelte
- canvas-design. visual asset generation
- [supermemory](/claude-skills-token-optimization-reduce-api-costs/). persistent knowledge base across sessions

To see which skills are available in your session, check your `~/.claude/skills/` directory:

```bash
ls ~/.claude/skills/
```

For a more readable listing that shows each skill on its own line with file sizes:

```bash
ls -lh ~/.claude/skills/
```

If you want to quickly preview what each skill does without opening every file, scan the first few lines of each one. most well-written skills open with a one-sentence purpose statement:

```bash
for f in ~/.claude/skills/*.md; do
 echo "=== $f ==="
 head -5 "$f"
 echo ""
done
```

To load a skill's full guidance, invoke it with a slash command:

```
/pdf
/tdd
/supermemory
```

You can also verify that a skill loaded correctly by asking Claude to summarize what the skill does immediately after invoking it. If the skill file is malformed or empty, Claude will tell you it found no instructions.

## Community Skills

The community maintains additional skills in public GitHub repositories. The best place to find community Claude Code skills:

- Search GitHub for `claude-code skills site:github.com`
- Browse the [claude-code community discussions](https://github.com/anthropics/claude-code/discussions)
- Check the [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) community list

Community skills are `.md` files you clone or download and place in `~/.claude/skills/`.

## GitHub Search Tips

GitHub's search is powerful if you know the right queries. A few searches that surface real skill files:

- `filename:*.md path:.claude/skills`. finds any public repo that has committed skill files to the standard path
- `"## Usage" "claude-code" language:Markdown`. finds Markdown files written in the typical skill documentation format
- `"slash command" "claude code" language:Markdown`. surfaces skill guides that describe their own invocation syntax

When browsing search results, filter by Recently updated rather than Best match. Skill files that haven't been touched in many months may reference deprecated Claude Code APIs or assume an older model.

It also helps to follow active Claude Code community members on GitHub directly. Contributors who publish useful MCP servers often publish companion skill files in the same repository.

## Installing a Community Skill

```bash
installing a skill from a GitHub repo
curl -o ~/.claude/skills/my-skill.md \
 https://raw.githubusercontent.com/username/claude-skills/main/my-skill.md

Or clone a skills collection
git clone https://github.com/username/claude-skills.git /tmp/claude-skills
cp /tmp/claude-skills/*.md ~/.claude/skills/
```

After installing, restart your Claude Code session and invoke the skill with `/skill-name`.

## Finding Skills by Use Case

| Need | Skill |
|------|-------|
| Extract text from PDFs | `/pdf` |
| Generate Word documents | `/docx` |
| Create presentations | `/pptx` |
| Spreadsheet automation | `/xlsx` |
| TDD workflows | `/tdd` |
| React/Vue component generation | `/frontend-design` |
| Generate icons and graphics | `/canvas-design` |
| Persistent cross-session memory | `/supermemory` |
| Browser automation testing | `/webapp-testing` |
| Build custom MCP servers | `/skill-creator` |

## Evaluating Skill Quality

Before adding a community skill:

1. Read the skill file. it's just Markdown, so you can review exactly what instructions it gives Claude
2. Check the repository's maintenance activity
3. Look for clear usage examples in the README
4. Test in a non-critical session first

Official skills from Anthropic are tested and maintained. Community skills vary in quality. reading the `.md` file directly is the fastest way to evaluate one.

## What Makes a Good Skill File

Not all `.md` files labeled as skills are equally useful. A well-crafted skill file has a few consistent qualities.

Clear opening statement. The first paragraph should tell Claude exactly what role to adopt and what task the skill covers. Vague openings like "This skill helps with code" leave Claude without a strong behavioral anchor. Good openings are specific: "You are operating as a database migration specialist. When invoked, your job is to..."

Concrete examples, not just principles. A skill that says "write clean code" gives Claude nothing it doesn't already know. A skill that shows example inputs and expected outputs. or that names specific frameworks, file formats, and edge cases. is far more useful.

Scoped instructions. A skill should stay focused on one domain. Skills that try to cover ten different workflows in a single file end up being mediocre at all of them. If you find a community skill that does too much, it's often better to split it or find a narrower alternative.

No contradictory rules. Some community skill files accumulate instructions from multiple contributors and end up with conflicting directives. Look for lines like "always do X" paired with "never do X" elsewhere in the same file. These cause inconsistent behavior.

Maintained alongside a changelog. Repos where the skill file has its own version history in commit messages, or where the author responds to issues, are significantly more reliable than one-off file drops.

A quick way to assess a skill file before installing it is to paste its contents into a Claude session and ask: "Does this skill file contain any contradictions or ambiguous instructions?" Claude will surface problems that might not be obvious on a quick read.

## Organizing Your Local Skills Directory

As your skills collection grows, a flat directory of `.md` files becomes hard to navigate. A few organizational approaches that work well.

Name files descriptively. The filename becomes the slash command. `db-migration.md` invokes as `/db-migration`, which is more self-explanatory than `skill3.md`. Stick to lowercase with hyphens. Claude Code is case-sensitive on some platforms.

Use a naming prefix for related skills. If you have several testing-related skills, naming them `test-tdd.md`, `test-e2e.md`, and `test-coverage.md` keeps them grouped when you list the directory:

```bash
ls ~/.claude/skills/ | sort
```

Keep a local README in the skills directory. A short `README.md` in `~/.claude/skills/` won't conflict with skill invocation (Claude only loads files you explicitly invoke), but it gives you a place to track what each skill does and where you got it:

```bash
View your local skills README
cat ~/.claude/skills/README.md
```

Archive stale skills rather than deleting them. If a skill breaks after a Claude Code update, move it to `~/.claude/skills/archive/` instead of deleting it. Skills directories are not recursive. only files directly in `~/.claude/skills/` are available as slash commands, so anything in a subdirectory is effectively archived without being lost.

```bash
mkdir -p ~/.claude/skills/archive
mv ~/.claude/skills/old-skill.md ~/.claude/skills/archive/
```

## Keeping Skills Updated

For official skills, update Claude Code:

```bash
npm update -g @anthropic-ai/claude-code
```

For community skills stored as Git repos, pull updates periodically:

```bash
git -C /path/to/skills-repo pull
cp /path/to/skills-repo/*.md ~/.claude/skills/
```

If you manage several community skills from different sources, a small shell script makes bulk updates less tedious:

```bash
#!/bin/bash
update-skills.sh. pull all Git-tracked skill repos and copy files
SKILLS_REPOS=(
 "/path/to/skills-repo-one"
 "/path/to/skills-repo-two"
)

for repo in "${SKILLS_REPOS[@]}"; do
 echo "Updating $repo..."
 git -C "$repo" pull
 cp "$repo"/*.md ~/.claude/skills/
done

echo "Skills updated."
```

Save this as `update-skills.sh`, make it executable with `chmod +x update-skills.sh`, and run it whenever you want to sync.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-directory-where-to-find-skills)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Top skills every developer should know
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-vs-prompts-which-is-better/). Decide when skills beat plain prompts
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate automatically
- [Where The Claude Code Skill Ecosystem Is — Developer Guide](/where-the-claude-code-skill-ecosystem-is-headed-2027/)
- [Claude Code Enoent No Such File Directory — Developer Guide](/claude-code-enoent-no-such-file-directory-skill/)
- [Claude Skills Directory on GitHub — Find Guide (2026)](/how-to-find-claude-skills-on-github/)


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

*Built by theluckystrike. More at [zovo.one](https://zovo.one)
*


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).
