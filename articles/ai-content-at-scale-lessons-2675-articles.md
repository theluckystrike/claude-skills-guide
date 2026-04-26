---
layout: default
title: "2,675 Articles to 496 Clicks (2026)"
description: "What we learned publishing 2,675 AI-generated articles about Claude Code. Honest data on what worked, what failed, and what we would change."
date: 2026-04-18
author: "Claude Skills Guide"
permalink: /ai-content-at-scale-lessons-2675-articles/
reviewed: true
score: 9
categories: [research]
tags: [claude-code, research, data]
---

# From 2,675 Articles to 496 Clicks: What We Learned Building an AI Content Site

Over several months, we published 2,675 articles on claudecodeguides.com, a niche site covering Claude Code tutorials, troubleshooting guides, and workflow documentation. Every article was generated or heavily assisted by AI. We optimized titles in bulk sprints, rewrote content for specific audiences, and tracked everything through Google Search Console.

The result: 496 clicks from 50,224 impressions across 1,000 pages that appear in GSC. That is 0.19 clicks per article across the full site, or roughly one click for every 5.4 articles published.

This is the honest retrospective on what that experiment taught us. No marketing spin, no "10x your traffic" promises. Just what the data actually shows about AI content at scale.

## The Brutal Numbers

Let us start with the numbers that matter.

| Metric | Value |
|--------|-------|
| Total articles published | 2,675 |
| Articles appearing in GSC | 1,000 |
| Articles with 1+ clicks | 256 |
| Articles with 0 clicks | 744 (of GSC-tracked) |
| Total clicks | 498 |
| Total impressions | 50,224 |
| Wasted impressions (0-click pages) | 26,619 |
| Average clicks per article (all 2,675) | 0.19 |
| Average clicks per GSC-tracked page | 0.50 |
| Site-wide CTR | 0.99% |

The first thing to acknowledge: 1,675 of our articles do not even appear in Google Search Console's top 1,000 pages. They are either not indexed, not ranking for anything, or ranking so poorly that GSC does not surface them. That means 62.6% of our content investment generated zero measurable search visibility.

Of the 1,000 pages that do appear in GSC, 744 have impressions but zero clicks. These pages generated 26,619 impressions that went nowhere, people saw the title in search results and decided not to click.

## The Power Law Distribution

Content performance follows a brutal power law. A tiny minority of articles generate the majority of all traffic.

| Top N Pages | Clicks | % of Total (498) |
|-------------|--------|-------------------|
| Top 1 | 46 | 9.2% |
| Top 5 | 95 | 19.1% |
| Top 10 | 128 | 25.7% |
| Top 20 | 174 | 34.9% |
| Top 50 | 261 | 52.4% |
| Top 100 | 342 | 68.7% |

One article generates 9.2% of all clicks. Ten articles generate a quarter of all traffic. One hundred articles (3.7% of the catalog) generate over two thirds of all clicks. The remaining 2,575 articles collectively generate 156 clicks, or 0.06 clicks per article.

This is the central lesson of AI content at scale: volume does not produce linear returns. It produces a power law where a few pieces succeed and most contribute nothing.

## The Top 10: What Actually Worked

Here are the ten pages that generated the most clicks, and what they have in common.

| # | Article | Clicks | Impressions | CTR |
|---|---------|--------|-------------|-----|
| 1 | claude-api-timeout-error-handling-retry-guide | 46 | 2,198 | 2.09% |
| 2 | claude-code-for-fpga-development-workflow-tutorial | 16 | 121 | 13.22% |
| 3 | claude-code-skill-timeout-error-how-to-increase-the-limit | 15 | 1,303 | 1.15% |
| 4 | claude-code-ssl-certificate-verification-failed-error | 10 | 741 | 1.35% |
| 5 | claude-code-error-unexpected-token-in-json-response-fix | 8 | 326 | 2.45% |
| 6 | how-to-combine-multiple-claude-skills-in-one-project | 8 | 145 | 5.52% |
| 7 | claude-code-for-rtl-right-to-left-layout-workflow | 7 | 122 | 5.74% |
| 8 | claude-code-segfault-core-dump-analysis-workflow-guide | 6 | 82 | 7.32% |
| 9 | using-claude-code-to-learn-new-programming-languages | 6 | 81 | 7.41% |
| 10 | claude-skills-for-logistics-supply-chain-software | 6 | 48 | 12.50% |

Three patterns are immediately visible:

**Error-fix content earns volume.** The top article (46 clicks) addresses a specific API timeout error. Three of the top five are error resolution pages. These rank well because people searching for error messages have high intent and few alternative resources.

**Niche workflow content earns CTR.** The FPGA development tutorial has 13.22% CTR, the logistics/supply chain article has 12.50%, and the RTL layout workflow has 5.74%. These are topics so specific that few competitors cover them, resulting in high click-through even with modest impression counts.

**Generic "best practices" content is absent from the top 10.** Not a single top performer is a generic overview or listicle. Every winner is either solving a specific problem (like our [Claude temperature settings guide](/claude-temperature-settings-guide/)) or addressing a narrow workflow.

## Content Type Analysis

We categorized all 1,000 GSC-tracked pages by URL pattern and content type. The differences in performance are dramatic.

| Category | Pages | With Clicks | Total Clicks | Impressions | CTR | Clicks/Page |
|----------|-------|-------------|-------------|-------------|-----|-------------|
| Error/Fix | 46 | 20 | 114 | 10,348 | 1.10% | 2.48 |
| Integration | 4 | 3 | 10 | 441 | 2.27% | 2.50 |
| Niche Workflow | 240 | 75 | 123 | 6,275 | 1.96% | 0.51 |
| Skills | 90 | 30 | 50 | 3,148 | 1.59% | 0.56 |
| How-to | 22 | 4 | 15 | 1,242 | 1.21% | 0.68 |
| Guide/Tutorial | 170 | 49 | 76 | 5,065 | 1.50% | 0.45 |
| Listicle | 30 | 8 | 13 | 3,271 | 0.40% | 0.43 |
| Comparison | 50 | 6 | 8 | 2,540 | 0.31% | 0.16 |
| Question | 15 | 4 | 6 | 1,271 | 0.47% | 0.40 |
| Chrome/Browser | 171 | 13 | 17 | 8,950 | 0.19% | 0.10 |
| Other | 161 | 43 | 62 | 7,607 | 0.82% | 0.39 |

Key findings from the content type breakdown:

**Error-fix content has the highest clicks per page (2.48).** Despite being only 46 pages, this category generated 114 clicks, nearly a quarter of all site traffic. Error messages are high-intent queries with clear user need. If we could go back in time, we would have published 500 error-fix articles instead of 171 Chrome/browser articles.

**Chrome/browser content is dead weight.** 171 pages generated 17 total clicks and a 0.19% CTR. This content was topically adjacent to Claude Code but not relevant to the core audience. It generates impressions (8,950) because Chrome-related queries are high volume, but the mismatch between search intent and content means almost nobody clicks.

**Niche workflows are the volume sweet spot.** 240 pages at 1.96% CTR and 0.51 clicks per page. Not individually impressive, but collectively this category generated 123 clicks, the most of any category. The strategy of covering narrow workflows (FPGA development, cold fusion modernization, RTL layouts) works because each page has low competition and high relevance to its tiny audience.

**Comparisons perform worst among core content.** Fifty comparison articles generated 8 clicks total (0.16 per page). "Claude Code vs X" queries tend to get answered by featured snippets or AI overviews, and users rarely need to click through for a comparison they can see summarized in the SERP.

## The Impression Paradox

One of the more counterintuitive findings is the relationship between impression volume and CTR.

| Impression Range | Pages | Clicks | Impressions | CTR |
|-----------------|-------|--------|-------------|-----|
| 0-10 | 99 | 61 | 629 | 9.70% |
| 10-50 | 682 | 167 | 14,749 | 1.13% |
| 50-100 | 121 | 57 | 8,212 | 0.69% |
| 100-500 | 86 | 123 | 15,974 | 0.77% |
| 500-1,000 | 10 | 29 | 7,159 | 0.41% |
| 1,000-5,000 | 2 | 61 | 3,501 | 1.74% |

Pages with fewer than 10 impressions have a 9.70% CTR. Pages with 500-1,000 impressions have a 0.41% CTR. The explanation is straightforward: low-impression pages are ranking for extremely specific queries where the user knows exactly what they want and our page is one of the few results. High-impression pages are ranking for broader queries where competition is fierce and SERP features absorb clicks.

The two pages with 1,000+ impressions buck the trend because they target specific error messages with high search volume and strong match to our content. This confirms the error-fix strategy: high-volume queries can produce strong CTR when the content directly matches a specific problem.

## The Optimization Sprints

We ran two major optimization campaigns:

**Sprint 6:** Rewrote titles on 1,014 articles using data-driven templates. We focused on making titles more specific, adding years, and matching query patterns. This was a bulk operation intended to improve CTR across the catalog.

**Sprint 11:** Added 10 new niche articles targeting underserved topics and rewrote 244 article titles specifically targeting US search patterns, attempting to close the US CTR gap (covered in detail in our [US CTR gap analysis](/claude-code-us-ctr-gap-analysis-2026/)).

The challenge with measuring optimization impact is attribution. GSC data does not cleanly separate pre- and post-optimization performance for individual pages. What we can say is that title optimization is high-leverage work: changing a title takes seconds, affects every impression the page receives, and compounds over time. If a title change moves a page from 0.5% CTR to 1.5% CTR, that 1 percentage point gain applies to every future impression.

Based on the data patterns, title optimization likely has the highest ROI of any SEO activity for an AI content site. It is faster than creating new content, affects existing rankings, and scales across the entire catalog.

## The Indexing Bottleneck

The most underappreciated constraint is indexing. Of 2,675 published articles, only 1,000 appear in GSC's top pages report. While GSC caps its pages report, the deeper issue is that Google is likely not indexing most of our content, or indexing it and ranking it so poorly that it generates zero impressions.

For an AI content site, this creates a compounding problem:

1. **Google is skeptical of AI content at scale.** Sites with thousands of thin pages trigger quality signals that can suppress indexing.
2. **Large sitemaps dilute crawl budget.** When Google has to evaluate 2,675 pages, it may deprioritize pages that look similar or low-quality.
3. **Internal linking is sparse.** With 2,675 pages and an automated publishing pipeline, internal linking between related articles was minimal, giving Google fewer signals about which pages matter.

We addressed some of this in our Cloudflare Worker (pruning the sitemap from 1.67 million characters to 2,779 entries, adding proper noindex tags, implementing IndexNow), but indexing remains the primary constraint on scaling AI content sites.

## Seven Lessons for AI Content Builders

### 1. Niche specificity beats generic coverage

Our best-performing content targets problems so specific that almost no one else covers them. Claude Code FPGA development, cold fusion modernization, segfault analysis for core dumps. Each of these has a tiny audience, but that audience clicks at 7-13% because there is no alternative resource.

Building 200 niche workflow articles that each get 0.51 clicks produced more total traffic than 171 Chrome/browser articles that each get 0.10 clicks. Go narrow.

### 2. Error messages are the highest-value content type

Developers searching for error messages have the strongest intent of any query type. They have a problem, they need a solution, and they need it now. At 2.48 clicks per page, error-fix content outperforms every other category by 3-5x. If you are building a developer content site, catalog every error message your tool can produce and write a fix guide for each one.

### 3. Title optimization has outsized ROI

Rewriting 1,014 titles is a day's work. Creating 1,014 new articles is months of work. Both affect the same metric (clicks from impressions), but title optimization is 100x faster. Start with titles. Always start with titles.

### 4. Volume creates a power law, not a linear curve

Publishing 2,675 articles did not produce 2,675x the traffic of one article. It produced a power law where 100 articles generated 68.7% of all clicks and 2,575 articles generated the remaining 31.3%. Before scaling content production, ask yourself: am I adding articles to the head of the distribution (niche, specific, high-intent) or the tail (generic, competitive, low-intent)?

### 5. Topical drift destroys performance

Our Chrome/browser content (171 pages, 0.10 clicks per page) demonstrates the cost of topical drift. These articles were adjacent to our core topic but did not serve our core audience. They generated impressions because Chrome queries have volume, but the mismatch between "person searching for Chrome tips" and "site about Claude Code" meant almost no one clicked. Stay on topic. Breadth is not depth.

### 6. Indexing is the real bottleneck, not content creation

AI has made content creation nearly free. The constraint has shifted to indexing. Google will not index 2,675 pages from a new domain without strong quality signals. We could have published 500 high-quality articles with proper internal linking, strong schema markup, and focused topical authority and likely generated more indexed pages (and more traffic) than 2,675 articles with thin interlinking.

### 7. Distribution matters more than production

Our biggest mistake was treating content creation as the primary challenge. The actual bottleneck was distribution: getting Google to index the content, getting it to rank well, and getting users to click. For every hour spent generating content, we should have spent two hours on indexing, internal linking, sitemap optimization, and SERP analysis.

## What We Would Do Differently

If we restarted this project with the same goal (build an authoritative niche site about Claude Code), here is how we would change the approach:

**Publish 300-500 articles instead of 2,675.** Focus exclusively on error fixes, niche workflows, and integration guides. No listicles, no comparison pages, no off-topic Chrome content.

**Start with error messages.** Catalog every Claude Code error, API error, and CLI error. Write a fix guide for each. This is the highest-ROI content and builds domain authority fast.

**Build internal linking from day one.** Every article should link to 3-5 related articles. Create hub pages that organize content by topic. Give Google a clear content graph instead of 2,675 disconnected pages.

**Optimize titles before publishing, not after.** Sprint 6 (title rewrites) should have been Sprint 0. Every article should launch with a researched, specific, click-worthy title.

**Prune aggressively.** Instead of keeping 2,675 articles live and hoping Google indexes them, we would have maintained 500 articles and noindexed or removed anything that did not earn clicks within 60 days. A smaller, higher-quality index is better than a large, diluted one.

**Target international markets first.** Our [US CTR gap analysis](/claude-code-us-ctr-gap-analysis-2026/) shows that non-US markets click at 4x the US rate. Optimizing for European and Asian developer audiences would have produced faster results than chasing the US market where SERP competition is fiercest.

## The Honest Assessment

Publishing 2,675 AI-generated articles about Claude Code produced 496 clicks over the measurement period. That is not a success story. It is a data set.

The data tells us that AI content at scale works the same way content at scale has always worked: most of it fails, a small fraction succeeds, and the winners are the ones that serve a specific need better than any alternative. AI made it cheap to produce the 2,575 articles in the tail. It did not make them valuable.

The 100 articles in the head of the distribution, the ones generating 68.7% of traffic, share common traits: they solve specific problems, target queries with few competing resources, and have titles that clearly communicate value. These articles would have worked whether they were AI-generated or human-written. The AI just made them faster to produce.

If you are building an AI content site, the lesson is not "AI content does not work." The lesson is that AI removes the production constraint but exposes every other constraint: indexing, authority, distribution, topical focus, and user intent matching. The hard part was never writing the articles. The hard part is everything that happens after you hit publish.


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

*Data source: Google Search Console, claudecodeguides.com, 28-day period ending April 2026. 2,675 total articles, 1,000 pages tracked in GSC, 498 total clicks, 50,224 total impressions across 185 countries.*

