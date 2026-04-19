---
title: "Claude Skills for Real Estate Data Extraction — Automate MLS Parsing, Comps Analysis, and Property Valuation Reports — 2026"
description: "Build a Claude Code skill that parses MLS listing data, runs comparable sales analysis with price-per-square-foot adjustments, and generates CMA reports."
permalink: /claude-skills-for-real-estate-data-extraction/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, real-estate, data-extraction]
last_updated: 2026-04-19
---

## The Specific Situation

Your real estate platform ingests MLS (Multiple Listing Service) feeds via RETS (Real Estate Transaction Standard) or RESO Web API. Each listing contains 200+ fields: MLSID, ListPrice, SquareFeet, LotSize, YearBuilt, DOM (Days on Market), PropertySubType (Single Family, Condo, Townhouse, Multi-Family), and dozens of feature flags (HasPool, HasGarage, GarageSpaces, HOAAmount). A developer building the comps engine needs to know that price-per-square-foot comparisons must adjust for lot size differential, that a pool adds $15K-30K in Sunbelt markets but $5K-10K in northern climates, and that DOM over 120 indicates a stale listing that should be excluded from active comps.

A Claude Code skill encodes MLS field mappings, comparable sales adjustment methodology, CMA (Comparative Market Analysis) report generation, and cap rate calculations for investment properties. It processes 30-40 listings per hour through structured extraction and valuation.

## Technical Foundation

The skill uses `paths: ["src/mls/**/*", "src/listings/**/*", "src/valuation/**/*"]` for conditional activation. The `references/` directory holds the full RESO data dictionary (400+ standardized field names) and adjustment factor tables by market, loaded on demand.

Dynamic context injection with `!`cat config/active-markets.json`` tells Claude which geographic markets are currently configured, so adjustment factors match the correct region. The `allowed-tools` field pre-approves `Bash(python3 *)` for running valuation scripts.

## The Working SKILL.md

Create at `.claude/skills/real-estate-data/SKILL.md`:

```yaml
---
name: real-estate-data
description: >
  Real estate data extraction and valuation skill. Use when parsing MLS
  feeds (RETS/RESO Web API), running comparable sales analysis, calculating
  price adjustments, generating CMA reports, or computing cap rates and
  GRM for investment properties. Knows RESO data dictionary fields,
  adjustment methodology, and market-specific valuation factors.
paths:
  - "src/mls/**/*"
  - "src/listings/**/*"
  - "src/valuation/**/*"
allowed-tools: Bash(python3 *) Read Grep
---

# Real Estate Data Extraction Skill

## MLS Feed Parsing

### RESO Standard Fields (most critical)
- ListingId (MLS number), ListPrice, OriginalListPrice
- LivingArea (square feet), LotSizeSquareFeet, YearBuilt
- BedroomsTotal, BathroomsTotalInteger, BathroomsFull, BathroomsHalf
- PropertySubType: SingleFamilyResidence, Condominium, Townhouse, MultiFamily
- StandardStatus: Active, Pending, Closed, Expired, Withdrawn
- DaysOnMarket, OriginalEntryTimestamp, CloseDate, ClosePrice
- Latitude, Longitude (for radius-based comp search)
- HOAFee, HOAFrequency (Monthly, Quarterly, Annual)
- ListingContractDate, ExpirationDate

### Data Quality Rules
1. Reject listings where LivingArea = 0 or null (bad data)
2. Flag ListPrice / LivingArea > $2,000/sqft or < $30/sqft as outlier
3. Exclude StandardStatus = Withdrawn or Expired from active inventory
4. DOM > 120: Include in analysis but flag as "stale" with reduced weight
5. ClosePrice required for sold comps (never use ListPrice as proxy)

## Comparable Sales Analysis

### Comp Selection Criteria
1. **Location**: Within 0.5 miles (urban) or 1.0 miles (suburban) radius
2. **Time**: Closed within last 6 months (extend to 12 if insufficient comps)
3. **Size**: Within 20% of subject's LivingArea
4. **Type**: Same PropertySubType (do not mix SFR with Condo)
5. **Minimum**: 3 comps, maximum 6 (report 3 best matches)

### Adjustment Factors (per-unit adjustments)
Apply adjustments from comp TO match subject:
- **Square footage**: Comp price / comp sqft x (subject sqft - comp sqft) x 0.85
  (0.85 factor accounts for diminishing returns on larger homes)
- **Bedrooms**: +/- $5,000-15,000 per bedroom (market-dependent)
- **Bathrooms**: +/- $5,000-10,000 per full bath, $2,500-5,000 per half bath
- **Garage**: +/- $10,000-20,000 per garage space
- **Pool**: +/- $15,000-30,000 (Sunbelt), $5,000-10,000 (Northern)
- **Year Built**: +/- $500-1,500 per year difference (cap at 20 years)
- **Lot Size**: +/- $1-5 per sqft difference (varies heavily by market)
- **Condition**: Excellent(+5%), Good(0%), Fair(-5%), Poor(-10%) of comp price

### Adjustment Caps
- Total net adjustment should not exceed 15% of comp's sale price
- Total gross adjustment should not exceed 25%
- If exceeded, the comp is too dissimilar -- select a better match

## Investment Property Metrics

### Cap Rate
Cap Rate = Net Operating Income (NOI) / Property Price
- NOI = Gross Rental Income - Vacancy Loss - Operating Expenses
- Vacancy factor: Typically 5-8% of gross rent
- Operating expenses: Property tax, insurance, maintenance, management (8-12% of gross rent)
- Exclude: Mortgage payments, depreciation (not operating expenses)

### Gross Rent Multiplier (GRM)
GRM = Property Price / Annual Gross Rental Income
- Lower GRM = potentially better value (market-dependent)
- Compare GRM against market median from `data/market-grm.json`

### Cash-on-Cash Return
Cash-on-Cash = Annual Pre-Tax Cash Flow / Total Cash Invested
- Cash invested: Down payment + closing costs + initial repairs
- Pre-tax cash flow: NOI - Annual Debt Service

## CMA Report Output
Generate report to `reports/cma-{address-slug}-{date}.json`:
```json
{
  "subject": { "address": "", "livingArea": 0, "listPrice": 0 },
  "comps": [
    {
      "mlsId": "", "closePrice": 0, "adjustedPrice": 0,
      "adjustments": { "sqft": 0, "beds": 0, "baths": 0 },
      "totalAdjustment": 0, "adjustmentPct": 0
    }
  ],
  "estimatedValue": { "low": 0, "mid": 0, "high": 0 },
  "pricePerSqFt": { "subject": 0, "compAvg": 0, "marketMedian": 0 }
}
```

## References
- RESO data dictionary: see `references/reso-data-dictionary.md`
- Market adjustment tables: see `references/market-adjustments.md`
- Investment property formulas: see `references/investment-formulas.md`
```

## Common Problems and Fixes

**Comp adjustment exceeds 25% gross.** The comp is too dissimilar. Remove it from the set and find a closer match on size and location. Forcing adjustments onto a bad comp produces unreliable valuations.

**MLS feed contains duplicate listings.** Some MLSs re-list expired listings with new MLSIDs. Deduplicate by matching on address + ListingContractDate. If two listings share the same address with overlapping dates, keep the one with StandardStatus = Active or Closed.

**Cap rate calculated with gross rent instead of NOI.** This is the most common investment analysis error. Always subtract vacancy, property tax, insurance, and management fees from gross rent before dividing by property price. A property with $100K gross rent and $40K expenses has a 6% cap rate at $1M price, not 10%.

**HOA fee comparison ignores frequency.** One listing reports $300/month HOA, another reports $900/quarter. Normalize all HOA fees to annual amounts before comparison. Check the HOAFrequency field.

## Production Gotchas

RETS (Real Estate Transaction Standard) is being phased out in favor of RESO Web API. If your MLS provider still uses RETS, plan for migration. The field names differ between standards -- RETS uses `LIST_PRICE`, RESO uses `ListPrice`. Your parsing layer should normalize at ingestion.

MLS data licensing typically prohibits storing listing photos beyond 48 hours after a listing is removed. Your data pipeline must purge photos for withdrawn/expired/closed listings on schedule or face MLS compliance violations.

## Checklist

- [ ] RESO field mapping covers the 30 most-used listing fields
- [ ] Comp selection enforces radius, time, size, and type filters
- [ ] Adjustment factors loaded from market-specific tables (not hardcoded)
- [ ] Total adjustment caps (15% net, 25% gross) enforced programmatically
- [ ] MLS data licensing compliance verified for photo retention

## Related Guides

- [Claude Skills for Financial Analysis](/claude-skills-for-financial-analysis/) -- REIT and investment valuation
- [Claude Skills for E-Commerce Platforms](/claude-skills-for-ecommerce-platforms/) -- listing marketplace patterns
- [Claude Skills for Academic Research](/claude-skills-for-academic-research/) -- housing market data analysis
