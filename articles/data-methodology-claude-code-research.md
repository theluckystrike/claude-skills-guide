---
layout: default
title: "Data & Methodology"
description: "How we collected and analyzed 50,000+ search impressions across 185 countries for our Claude Code developer research."
date: 2026-04-18
author: "Claude Skills Guide"
permalink: /data/
reviewed: true
score: 8
categories: [research]
tags: [claude-code, research, methodology, data]
render_with_liquid: false
---

# Data and Methodology

This page documents how we collected, processed, and analyzed the data behind our [Claude Code Research Reports](/reports/). We believe in showing our work.

## Data Source

All data comes from **Google Search Console (GSC)**, the primary interface Google provides for understanding how a site appears in search results. GSC reports real impressions (how often pages appeared in results), clicks (how often users clicked through), click-through rate (CTR), and average position for each page and query.

We use GSC because it is the only source of ground-truth search performance data. Third-party tools estimate; GSC measures.

## Time Period

The analysis covers a **28-day rolling window ending April 17, 2026**. This is the standard reporting window GSC uses for its performance reports. All five research pillars draw from the same snapshot to ensure consistency across findings.

## Coverage

GSC caps exports at 1,000 rows per dimension. Our dataset includes:

- **1,000 pages** ranked by impressions (the top-performing subset of 2,675+ total articles)
- **1,024 queries** ranked by impressions (the most common searches that surfaced our content)
- **185 countries** where at least one impression was recorded
- **3 device types**: desktop, mobile, and tablet

The site itself contains over 2,675 published articles. The 1,000-page cap means roughly 1,675 pages with lower impression counts are excluded from the page-level analysis. This is a known limitation. The excluded pages likely have near-zero impressions and clicks, so their omission does not materially affect the findings about high-performing content patterns.

## Metrics Defined

| Metric | Definition |
|--------|-----------|
| **Impressions** | Number of times a page or query appeared in Google search results |
| **Clicks** | Number of times a user clicked through to the site from search results |
| **CTR** | Click-through rate, calculated as clicks divided by impressions |
| **Average Position** | The mean ranking position in search results across all appearances |

## Important Limitations

**Sampling.** GSC data is sampled, not exhaustive. Google states that the data "may differ slightly from actual values" due to internal sampling and processing.

**Top 1,000 cap.** We can only export the top 1,000 rows for pages and queries. Long-tail pages and queries beyond this cutoff are invisible to our analysis.

**Average position is an average.** A page with "average position 12" may have appeared at position 1 for some queries and position 40 for others. We report averages but acknowledge they flatten real variance.

**Impressions are not views.** An impression means Google showed the result. It does not mean the user saw it, scrolled to it, or noticed it.

**28-day window only.** We report a single snapshot. Trends over time require multiple snapshots, which we plan to publish in future reports.

**No revenue or conversion data.** GSC measures search visibility, not business outcomes. We do not correlate impressions or clicks with signups, purchases, or engagement metrics in these reports.

## Processing

Raw data was exported from GSC as CSV files and analyzed using Python scripts. Processing steps included:

1. Deduplication and validation of exported rows
2. Categorization of queries by intent (informational, navigational, transactional)
3. Geographic aggregation by country with CTR normalization
4. Page-level classification by content type and topic cluster
5. Cross-referencing page data with query data to identify coverage gaps

No data was altered, interpolated, or synthetically generated. All figures reported in the five research pillars trace directly to GSC exports.

## Reproducibility

Any site owner with GSC access can reproduce this analysis on their own data. The methodology requires only standard CSV exports and basic data analysis tooling. We chose this approach deliberately so that our findings can be verified, challenged, and compared against other datasets.

## Questions

For questions about the data or methodology, visit the [research hub](/reports/) or explore the individual report pages linked there. For access to the tools and workflows used to build this site, see [Zovo](https://zovo.one).
