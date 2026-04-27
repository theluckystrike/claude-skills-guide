---
sitemap: false
layout: default
title: "Claude Skills for Financial Analysis (2026)"
description: "Build a Claude Code skill that extracts financial data from 10-K/10-Q filings, calculates DCF valuations, computes financial ratios, and generates."
permalink: /claude-skills-for-financial-analysis/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, finance, financial-analysis]
last_updated: 2026-04-19
---

## The Specific Situation

Your financial analysis platform pulls data from SEC EDGAR filings (10-K annual, 10-Q quarterly, 8-K current reports). Each 10-K contains XBRL-tagged financial statements, but the tag names vary by company: "Revenue" might be tagged as `us-gaap:Revenues`, `us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax`, or `us-gaap:SalesRevenueNet`. A developer building the extraction pipeline needs to know which XBRL tags map to which line items, how to handle fiscal year-end differences (Apple uses September, most companies use December), and how to normalize data for cross-company comparison.

A Claude Code skill encodes XBRL tag mappings, DCF (Discounted Cash Flow) model construction, financial ratio formulas (liquidity, profitability, debt-to-equity, efficiency), and variance analysis methodology. It processes 10-15 filings per hour through structured extraction and ratio calculation.

## Technical Foundation

The skill uses `paths: ["src/finance/**/*", "src/filings/**/*", "src/models/**/*"]` for conditional activation. The `references/` directory holds the full US GAAP XBRL taxonomy mapping (1,500+ tags) and SEC filing structure documentation, loaded on demand.

Dynamic context injection with `!`cat data/portfolio-tickers.json | jq -r '.[]'`` injects the current portfolio watchlist at skill load time, so Claude knows which companies are relevant. The `allowed-tools` field pre-approves `Bash(python3 *)` for running valuation scripts that need pandas and numpy.

## The Working SKILL.md

Create at `.claude/skills/financial-analysis/SKILL.md`:

```yaml
---
name: financial-analysis
description: >
  Financial analysis skill. Use when extracting data from SEC filings
  (10-K, 10-Q, 8-K), building DCF models, calculating financial ratios
  (P/E, EV/EBITDA, D/E, ROE, current ratio), or generating variance
  reports. Knows XBRL tag mappings, GAAP vs non-GAAP adjustments,
  and fiscal year normalization.
paths:
  - "src/finance/**/*"
  - "src/filings/**/*"
  - "src/models/**/*"
allowed-tools: Bash(python3 *) Read Grep
---

# Financial Analysis Skill

## SEC Filing Extraction

### XBRL Tag Mapping (Common Revenue Tags)
Map these to normalized "revenue" field:
- `us-gaap:Revenues`
- `us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax`
- `us-gaap:SalesRevenueNet`
- `us-gaap:RevenueFromContractWithCustomerIncludingAssessedTax`
- Company-specific extensions: check `dei:DocumentFiscalYearFocus` for context

### Key Financial Statement Line Items
**Income Statement:**
- Revenue → Gross Profit → Operating Income (EBIT) → Net Income
- EBITDA = Operating Income + Depreciation + Amortization
- Non-GAAP adjustments: Stock-based comp, restructuring charges, one-time items

**Balance Sheet:**
- Current Assets: Cash, Receivables, Inventory
- Non-Current: PP&E, Goodwill, Intangibles
- Current Liabilities: Accounts Payable, Short-term Debt, Deferred Revenue
- Non-Current Liabilities: Long-term Debt, Operating Leases (ASC 842)
- Equity: Retained Earnings, AOCI, Treasury Stock

**Cash Flow Statement:**
- Operating: Net Income + D&A + Working Capital Changes
- Investing: CapEx, Acquisitions, Asset Sales
- Financing: Debt Issuance/Repayment, Dividends, Buybacks
- Free Cash Flow = Operating Cash Flow - CapEx

### Fiscal Year Normalization
- Store fiscal year end month per company in `data/fiscal-calendars.json`
- When comparing companies, align by calendar quarter (Q1=Jan-Mar)
- Apple FY Q1 = Oct-Dec (calendar Q4). Adjust comparisons accordingly.

## DCF Model Construction

### 5-Year Projection
1. Revenue growth: Use 3-year CAGR as base, decay toward industry average
2. Operating margin: Trend analysis, converge to sector median by Year 5
3. CapEx as % of revenue: Historical average unless major expansion planned
4. Working capital: Calculate NWC change as % of revenue delta
5. Tax rate: Effective tax rate from latest filing (not statutory 21%)

### Terminal Value (Gordon Growth)
Terminal Value = FCF_Year5 x (1 + g) / (WACC - g)
- g (perpetual growth): 2-3% (never exceed long-term GDP growth)
- WACC = (E/V x Re) + (D/V x Rd x (1-T))
  - Re (cost of equity) = Risk-free rate + Beta x Equity Risk Premium
  - Rd (cost of debt) = Interest Expense / Total Debt
  - Use 10-year Treasury for risk-free rate from `data/treasury-rates.json`

### Sensitivity Analysis
Vary WACC (8-12%) and terminal growth (1.5-3.5%) in 0.5% increments.
Output matrix to `reports/dcf-sensitivity-{ticker}.csv`.

## Financial Ratios

### Liquidity
- Current Ratio = Current Assets / Current Liabilities (healthy: >1.5)
- Quick Ratio = (Cash + Receivables) / Current Liabilities (healthy: >1.0)

### Profitability
- Gross Margin = Gross Profit / Revenue
- Operating Margin = EBIT / Revenue
- Net Margin = Net Income / Revenue
- ROE = Net Income / Shareholders' Equity
- ROIC = NOPAT / Invested Capital

### Leverage
- Debt-to-Equity = Total Debt / Total Equity
- Interest Coverage = EBIT / Interest Expense (healthy: >3x)
- Net Debt / EBITDA (healthy: <3x for investment grade)

### Valuation
- P/E = Price / EPS (use diluted EPS)
- EV/EBITDA = Enterprise Value / EBITDA
- P/FCF = Price / Free Cash Flow per Share

## Output Format
Write results to `reports/analysis-{ticker}-{date}.json`

## References
- XBRL US GAAP taxonomy: see `references/xbrl-taxonomy.md`
- SEC filing structure guide: see `references/sec-filing-format.md`
- Industry ratio benchmarks: see `references/industry-benchmarks.md`
```

Invocation examples:

```bash
# Analyze a specific ticker
/financial-analysis AAPL

# Run DCF sensitivity analysis
/financial-analysis MSFT --dcf-sensitivity
```

## Common Problems and Fixes

**XBRL tag returns zero.** Some companies report revenue in custom extension tags rather than standard us-gaap tags. Check the company's filing for `<us-gaap:` prefixed tags first, then fall back to company-specific extensions. The filing's schema file (`.xsd`) lists all custom tags.

**DCF model too sensitive to terminal growth assumption.** Terminal value typically accounts for 60-80% of total valuation. If small changes in `g` swing the valuation by 30%+, the projection period is too short or FCF is unstable. Extend to a 7-10 year projection for high-growth companies.

**Ratio comparison across industries is misleading.** A 0.5 current ratio is alarming for manufacturing but normal for subscription SaaS (deferred revenue inflates current liabilities). Always compare ratios against industry-specific benchmarks from `references/industry-benchmarks.md`.

**Fiscal year mismatch in peer comparison.** Comparing Apple's FY2025 (ending Sep 2025) with Microsoft's FY2025 (ending Jun 2025) means you are comparing different economic periods. Normalize to trailing twelve months (TTM) by summing the latest 4 quarters.

## Production Gotchas

SEC EDGAR rate limits API requests to 10 per second per user-agent. Include your company email in the User-Agent header as SEC requires, and implement exponential backoff. Bulk downloads should use the EDGAR Full-Text Search API or the daily XBRL RSS feeds, not individual filing requests.

Non-GAAP metrics (adjusted EBITDA, adjusted EPS) vary significantly between companies. One company's "adjusted" earnings exclude stock-based compensation; another includes it. Your extraction must flag which adjustments each company makes and normalize consistently for peer comparison.

## Checklist

- [ ] XBRL tag mapping covers top 50 us-gaap revenue/expense tags
- [ ] DCF sensitivity matrix tested with at least 3 different tickers
- [ ] Financial ratios validated against a known source (Bloomberg, CapIQ)
- [ ] Fiscal year calendar populated for all portfolio companies
- [ ] SEC EDGAR API calls include proper User-Agent and rate limiting



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Skills for E-Commerce Platforms](/claude-skills-for-ecommerce-platforms/) -- revenue and margin analysis
- [Claude Skills for Real Estate Data Extraction](/claude-skills-for-real-estate-data-extraction/) -- REIT financial analysis
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/) -- handling large XBRL datasets efficiently
