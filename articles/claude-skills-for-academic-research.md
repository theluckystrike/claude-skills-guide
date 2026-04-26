---
layout: default
title: "Claude Skills for Academic Research (2026)"
description: "Build a Claude Code skill that extracts citations from BibTeX/RIS files, cross-references DOIs, validates statistical claims, and generates literature."
permalink: /claude-skills-for-academic-research/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, academic-research, citations]
last_updated: 2026-04-19
---

## The Specific Situation

Your research lab maintains a codebase for processing academic papers. The pipeline ingests papers from PubMed, arXiv, and Semantic Scholar APIs, extracts structured metadata (authors, DOIs, journal impact factors, citation counts), and builds literature review matrices. A developer needs to know that a DOI follows the format `10.XXXX/suffix` (prefix always starts with 10), that BibTeX `@article` entries require `author`, `title`, `journal`, and `year` fields, and that a p-value reported as "p < 0.05" without the exact value, sample size, and effect size is a red flag for statistical reporting.

A Claude Code skill encodes citation format validation (BibTeX, RIS, CSL-JSON), DOI resolution, statistical claim extraction (p-values, confidence intervals, effect sizes), and PRISMA flow diagram generation for systematic reviews. It processes 20-30 papers per hour through structured extraction.

## Technical Foundation

The skill uses `paths: ["src/research/**/*", "src/papers/**/*", "src/citations/**/*", "data/bibliography/**/*"]` for conditional activation. The `references/` directory holds APA 7th edition formatting rules, statistical test decision trees, and journal impact factor tables, loaded on demand.

The `context: fork` option runs paper analysis in an isolated context, useful when processing copyrighted full-text articles that should not persist in the main session. Dynamic context injection with `!`cat data/bibliography/master.bib | wc -l`` injects the current bibliography size.

## The Working SKILL.md

Create at `.claude/skills/academic-research/SKILL.md`:

```yaml
---
name: academic-research
description: >
  Academic research skill. Use when processing literature reviews,
  extracting citations from BibTeX/RIS files, validating DOI formats,
  checking statistical claims (p-values, CI, effect sizes), or
  generating PRISMA flow diagrams for systematic reviews. Knows
  APA 7th edition citation format, PubMed API fields, and common
  statistical reporting standards.
paths:
  - "src/research/**/*"
  - "src/papers/**/*"
  - "src/citations/**/*"
  - "data/bibliography/**/*"
allowed-tools: Bash(python3 *) Read Grep
---

# Academic Research Skill

## Citation Format Validation

### BibTeX Required Fields by Entry Type
- `@article`: author, title, journal, year, volume
- `@inproceedings`: author, title, booktitle, year
- `@book`: author/editor, title, publisher, year
- `@phdthesis`: author, title, school, year
- `@misc`: author, title, year, howpublished (for URLs, datasets)

### BibTeX Key Format
Convention: `{FirstAuthorLastName}{Year}{FirstSignificantWord}`
Example: `Smith2024Transformer`, `Chen2025MultiModal`
Enforce uniqueness: append a/b/c suffix for same-author-same-year entries.

### DOI Validation
- Format: `10.XXXX/suffix` where XXXX is registrant code (4+ digits)
- Resolve via `https://doi.org/{doi}` — HTTP 200 = valid, 404 = invalid
- Extract from PDF metadata, CrossRef API, or paper text
- Normalize: strip "https://doi.org/" prefix, store bare DOI

### RIS Format Mapping
Key field codes:
- TY = Type (JOUR=journal, CONF=conference, BOOK=book)
- AU = Author (one per line, format: LastName, FirstName)
- TI = Title, JO = Journal, PY = Publication Year
- DO = DOI, UR = URL, AB = Abstract
- ER = End of record (required terminator)

## Statistical Claim Extraction

### Required Reporting Elements (APA Standards)
For each statistical test, extract:
1. **Test statistic**: t, F, chi-square, z, r, etc.
2. **Degrees of freedom**: df, n-1, or k-1
3. **Exact p-value**: "p = 0.023" not "p < 0.05" (unless p < .001)
4. **Effect size**: Cohen's d, eta-squared, r-squared, odds ratio
5. **Confidence interval**: 95% CI [lower, upper]
6. **Sample size**: n per group and total N

### Red Flags in Statistical Reporting
- p-value without test statistic or sample size
- "Trending toward significance" (p between 0.05-0.10, not a thing)
- Effect size missing entirely (statistically significant but tiny effect)
- Multiple comparisons without Bonferroni/FDR correction
- Confidence interval crossing zero for a "significant" result

### Common Tests and When to Flag
- t-test with n < 30: Check if normality assumption met (Shapiro-Wilk)
- Chi-square with expected cell count < 5: Use Fisher's exact test instead
- Correlation reported as causation: Flag for language review
- Regression R-squared reported without adjusted R-squared: Flag if p > 3 predictors

## Literature Review Matrix Generation

### PRISMA Flow Diagram Fields
1. **Identification**: Records from databases (n=), duplicates removed (n=)
2. **Screening**: Records screened (n=), excluded (n=, with reasons)
3. **Eligibility**: Full-text assessed (n=), excluded (n=, with reasons)
4. **Included**: Studies in qualitative synthesis (n=), in meta-analysis (n=)

### Review Matrix Columns
For each included study, extract:
- Citation key, year, study design (RCT, cohort, case-control, cross-sectional)
- Sample size, population characteristics
- Intervention/exposure, comparison/control
- Primary outcome, measurement instrument
- Key findings, effect size, quality score (Newcastle-Ottawa, Cochrane RoB)

Output matrix to `reports/lit-review-{topic}-{date}.csv`

## API Integration

### PubMed E-utilities
- ESearch: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term={query}`
- EFetch: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id={pmid}&rettype=xml`
- Rate limit: 3 requests/second without API key, 10 with API key
- Store API key in `config/pubmed-api-key.txt` (not version controlled)

### Semantic Scholar API
- Paper lookup: `https://api.semanticscholar.org/graph/v1/paper/{doi}`
- Fields: title, authors, citationCount, influentialCitationCount, tldr
- Rate limit: 100 requests/5 minutes (unauthenticated)

## References
- APA 7th edition citation rules: see `references/apa7-format.md`
- Statistical test decision tree: see `references/stat-test-tree.md`
- Journal impact factors: see `references/journal-if-2025.md`
```

Directory structure for the skill:

```
.claude/skills/academic-research/
  SKILL.md
  references/
    apa7-format.md
    stat-test-tree.md
    journal-if-2025.md
  scripts/
    validate-bibtex.py
```

## Common Problems and Fixes

**BibTeX parser chokes on special characters.** LaTeX-encoded characters (`{\"u}`, `\'{e}`, `\~{n}`) appear in author names and titles. Your parser must decode these to Unicode before storing. Common culprits: umlauts, accents, tildes, and the TeX `\&` for ampersands.

**DOI resolution returns 404 for valid papers.** Some DOIs are registered but not yet activated (common for preprints). Retry after 24 hours. Also check for URL-encoded characters -- a DOI containing parentheses must encode them in the resolution URL.

**p-value extraction picks up table formatting.** A table cell containing "0.012" gets mistakenly flagged as a p-value. Use context: only extract p-values preceded by "p =", "p <", "P-value", or following a test statistic (t, F, chi-square) in the same sentence or table row.

**PRISMA numbers do not add up.** Identified minus duplicates should equal screened. Screened minus excluded should equal full-text assessed. Validate arithmetic at each stage and flag discrepancies before generating the flow diagram.

## Production Gotchas

PubMed's E-utilities require your tool name and email in the API parameters (`tool=yourappname&email=you@example.com`). Without these, NCBI may block your IP during high-volume searches. Register for an API key to increase the rate limit from 3 to 10 requests per second.

Full-text PDFs from publishers are copyrighted. Your extraction pipeline should process text ephemerally (extract structured data, discard full text). Do not store full-text content in version-controlled repositories or persistent skill context.

## Checklist

- [ ] BibTeX parser handles LaTeX special characters and UTF-8
- [ ] DOI validation resolves against doi.org with retry logic
- [ ] Statistical claim extraction requires test statistic + sample size + p-value
- [ ] PRISMA flow diagram arithmetic validated at each stage
- [ ] PubMed API key configured and rate limiting implemented

## Related Guides

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

- [Claude Skills for Medical Records Processing](/claude-skills-for-medical-records-processing/) -- clinical research data extraction
- [Claude Skills for Financial Analysis](/claude-skills-for-financial-analysis/) -- quantitative research methodology
- [Claude Skills vs Subagents: When to Use Each](/claude-skills-vs-subagents-when-to-use/) -- forked context for paper analysis

## See Also

- [Claude Skills for Manufacturing QA — Automate SPC Chart Analysis, NCR Processing, and CAPA Workflow — 2026](/claude-skills-for-manufacturing-qa/)
