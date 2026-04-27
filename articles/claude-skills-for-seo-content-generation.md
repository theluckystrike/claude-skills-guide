---
sitemap: false
layout: default
title: "Claude Skills for SEO Content Generation Guide (2026)"
description: "Build a Claude Code skill that clusters keywords by search intent, generates meta descriptions under 155 chars, and maps internal links from your sitemap."
permalink: /claude-skills-for-seo-content-generation/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, seo, content-generation]
last_updated: 2026-04-19
---

## The Specific Situation

You manage 200+ pages across a content site. Every new article needs keyword research, a meta title under 60 characters, a meta description under 155 characters, three internal links to existing content, and schema markup. Doing this manually takes 15-20 minutes per page. At scale, that is 50+ hours per month on metadata alone.

A Claude Code skill can automate this entire workflow. It reads your sitemap, pulls your target keyword list, clusters by search intent (informational, transactional, navigational), generates metadata that fits character limits, and maps internal links based on topical relevance. The skill outputs a structured JSON file your CMS can import directly.

## Technical Foundation

Claude Code skills load their instructions on demand through progressive disclosure. The skill's `description` field (capped at 1,536 characters) stays in Claude's context so it knows when to activate. The full SKILL.md body loads only when invoked, keeping token usage low during unrelated tasks.

For SEO workflows, the `paths` field activates the skill only when you touch content files: `"content/**/*.md"` or `"src/pages/**/*.tsx"`. The `allowed-tools` field pre-approves `Bash(node *)` so Claude can run your sitemap parser without permission prompts. Dynamic context injection with `!`command`` pulls live data -- your current sitemap URLs, existing meta tags, or Google Search Console export -- before Claude processes anything.

Skills follow the agentskills.io open standard, meaning this same SKILL.md works in Cursor, Codex, and Gemini CLI.

## The Working SKILL.md

Create this at `.claude/skills/seo-content/SKILL.md`:

```yaml
---
name: seo-content
description: >
  Generate SEO metadata for content pages. Use when creating new articles,
  auditing existing meta tags, or building internal link maps. Clusters
  keywords by search intent (informational, transactional, navigational),
  generates title tags under 60 chars, meta descriptions under 155 chars,
  and identifies 3 internal link targets from the sitemap.
paths:
  - "content/**/*.md"
  - "src/pages/**/*.{tsx,jsx}"
allowed-tools: Bash(node *) Read Grep
---

# SEO Content Generation Skill

## Inputs
- Target keyword: $ARGUMENTS[0]
- Content file path: $ARGUMENTS[1] (optional, defaults to current file)

## Keyword Clustering Workflow
1. Read the keyword list from `data/keywords.csv` (columns: keyword, volume, difficulty, intent)
2. Find all keywords sharing the same root topic as the target keyword
3. Group into clusters:
   - **Primary**: Exact match and close variants (1-2 word difference)
   - **Secondary**: Same intent, related entity
   - **Long-tail**: 4+ word queries containing primary keyword
4. Output cluster as JSON to `data/clusters/{keyword-slug}.json`

## Meta Tag Generation Rules
- **Title tag**: Primary keyword + modifier + brand. Max 60 characters. No pipe characters.
- **Meta description**: Include primary keyword in first 70 chars. One specific claim. One CTA verb. Max 155 characters.
- **H1**: Can differ from title tag. Use natural phrasing.
- **Canonical URL**: Lowercase, hyphenated, no trailing slash.

## Internal Link Mapping
1. Parse `public/sitemap.xml` for all indexed URLs
2. For each URL, extract the primary topic from the slug and title tag
3. Score relevance to current article: exact topic match (3pts), same category (2pts), shared keyword cluster (1pt)
4. Select top 3 URLs with score >= 2
5. Suggest anchor text using the target page's primary keyword (not "click here")

## Schema Markup
Generate Article schema with:
- headline, datePublished, dateModified
- author (from `data/authors.json`)
- publisher (from site config)
- mainEntityOfPage matching canonical URL

## Output Format
Write results to `data/seo-output/{slug}.json`:
```json
{
  "keyword_cluster": { "primary": [], "secondary": [], "long_tail": [] },
  "meta": { "title": "", "description": "", "h1": "", "canonical": "" },
  "internal_links": [{ "url": "", "anchor": "", "relevance_score": 0 }],
  "schema": {}
}
```
```

## Common Problems and Fixes

**Meta descriptions exceed 155 characters.** Claude tends to write descriptive sentences. Add an assertion in your skill: "Count characters before outputting. If description exceeds 155 chars, trim the last clause and re-check." Explicit character counting beats asking for "short" descriptions.

**Internal links point to noindexed pages.** Your sitemap may include pages with noindex meta tags. Add a validation step: "Exclude URLs containing /tag/, /author/, or any URL listed in data/noindex-urls.txt from link candidates."

**Keyword clusters are too broad.** If "python" groups with "python snake care," constrain clustering by requiring shared search intent column match. Informational keywords about programming should not cluster with navigational pet queries.

**Schema markup missing required fields.** Google requires `headline`, `datePublished`, and `author` at minimum. The skill should validate against these three fields before writing output and throw an error if `data/authors.json` is missing.

## Production Gotchas

Character counting in Claude's context is approximate. For title tags, target 55 characters to leave margin. For meta descriptions, target 150. Claude counts Unicode characters differently than Google's pixel-width truncation, so CJK characters and wide glyphs will break limits even when character count looks right.

Sitemap parsing assumes XML format. If your site uses a sitemap index with multiple child sitemaps, the skill needs to recursively parse each `<sitemap><loc>` entry first. Add this as a preprocessing step or use `!`node scripts/flatten-sitemap.js`` in the skill's dynamic context injection.

## Checklist

- [ ] `data/keywords.csv` exists with keyword, volume, difficulty, intent columns
- [ ] `public/sitemap.xml` is current and excludes noindexed URLs
- [ ] `data/authors.json` has at least one author entry
- [ ] Output directory `data/seo-output/` exists
- [ ] Test with one article before batch-processing the full site



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skills for E-Commerce Platforms](/claude-skills-for-ecommerce-platforms/) -- product page SEO patterns
- [Claude Skills Data Flow Patterns](/claude-skills-data-flow-patterns/) -- structuring skill output pipelines
- [How to Combine Multiple Claude Skills](/how-to-combine-multiple-claude-skills/) -- chaining SEO skill with content writing
