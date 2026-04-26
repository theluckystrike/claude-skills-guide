---
layout: default
title: "Claude Skills for E-Commerce Platforms (2026)"
description: "Build a Claude Code skill that validates SKU/ASIN formats, enforces cart pricing rules, generates Google Merchant Center feeds, and audits checkout flows."
permalink: /claude-skills-for-ecommerce-platforms/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, ecommerce, product-data]
last_updated: 2026-04-19
---

## The Specific Situation

Your e-commerce platform has 15,000 SKUs across 200 product categories. Each SKU follows a format: `CAT-BRAND-VARIANT-SIZE` (e.g., `SHO-NKE-AF1W-10`). Product data feeds for Google Merchant Center require GTIN-13 (EAN), MPN, and Google Product Category IDs that map to a 7-level taxonomy. A developer adding a new product category needs to know the correct `google_product_category` ID (e.g., "Apparel & Accessories > Shoes > Athletic Shoes" = 187), the required Merchant Center fields for that category, and which variant attributes (color, size, material) trigger separate listings.

A Claude Code skill encodes your SKU naming convention, Merchant Center field requirements per category, cart pricing rules (bulk discounts, tiered pricing, promo stacking), and checkout validation logic. It activates when developers touch product, cart, or checkout code. We cover this further in [Claude Skills for Travel Booking Platforms — Automate GDS Parsing, Fare Rules, and PNR Validation — 2026](/claude-skills-for-travel-booking-platforms/).

## Technical Foundation

Skills use `paths` field for conditional activation. Setting `paths: ["src/products/**/*", "src/cart/**/*", "src/checkout/**/*"]` ensures this skill loads only when relevant code is open. The `references/` directory holds the full Google Product Category taxonomy (5,000+ categories) and Merchant Center field specifications, loaded on demand via progressive disclosure.

The `allowed-tools` field pre-approves `Bash(node *)` for running feed validation scripts. Dynamic context injection with `!`cat data/active-promotions.json | jq length`` injects the count of active promotions so Claude knows the current promotional state when reviewing cart logic.

## The Working SKILL.md

Create at `.claude/skills/ecommerce-ops/SKILL.md`:

```yaml
---
name: ecommerce-ops
description: >
  E-commerce platform operations skill. Use when working with product
  catalogs (SKU validation, GTIN/EAN lookup, variant management),
  cart logic (pricing rules, promo stacking, tax calculation),
  checkout flows, or product feed generation for Google Merchant
  Center, Meta Commerce, or Amazon SP-API.
paths:
  - "src/products/**/*"
  - "src/cart/**/*"
  - "src/checkout/**/*"
  - "src/feeds/**/*"
allowed-tools: Bash(node *) Read Grep
---

# E-Commerce Platform Skill

## SKU Format and Validation
Pattern: `{CATEGORY}-{BRAND}-{MODEL}{VARIANT}-{SIZE}`
- CATEGORY: 3-letter code from `data/category-codes.json`
- BRAND: 3-letter code from `data/brand-codes.json`
- MODEL: Alphanumeric, 2-4 chars
- VARIANT: Single letter (color code) — W=white, B=black, R=red
- SIZE: Numeric or standard sizing (XS, S, M, L, XL, XXL)

Validation rules:
1. Total length: 12-20 characters
2. Delimiter: hyphen only (no underscores)
3. Category code must exist in `data/category-codes.json`
4. Duplicate detection: query product DB before creating new SKU

## Product Feed Generation (Google Merchant Center)

### Required Fields (all categories)
- id (SKU), title (max 150 chars), description (max 5000 chars)
- link, image_link, availability (in_stock, out_of_stock, preorder)
- price (format: "29.99 USD"), brand, condition (new, refurbished, used)
- gtin OR mpn (at least one required)

### Category-Specific Required Fields
- Apparel: color, size, gender, age_group, size_system
- Electronics: gtin mandatory (mpn alone insufficient)
- Furniture: shipping(weight), product_type

### Variant Handling
Items differing by color, size, or material = separate Merchant Center listings.
Group with `item_group_id` (parent SKU without variant suffix).
Each variant gets unique `id`, shared `item_group_id`.

### Feed Format
Output as TSV or XML to `feeds/google-merchant-{date}.xml`
Validate with `scripts/validate-feed.js` before submission.

## Cart Pricing Rules

### Discount Priority (highest to lowest)
1. Employee discount (flat 40%, not stackable)
2. Loyalty tier discount (Gold=15%, Silver=10%, Bronze=5%)
3. Volume discount (5+ items = 10%, 10+ = 15%, 25+ = 20%)
4. Promo code (from `data/active-promotions.json`)
5. Sale price (set per SKU in product data)

### Stacking Rules
- Max 1 promo code per order
- Loyalty + promo code: apply loyalty first, then promo on reduced price
- Volume + loyalty: apply volume first
- Employee discount overrides all others

### Tax Calculation
- US: Tax calculated at checkout based on shipping address state
- EU: VAT included in displayed price (use tax-inclusive pricing)
- Tax-exempt: Require valid tax ID, validate via VIES (EU) or IRS (US)

## Checkout Validation
1. Inventory check: Re-verify stock at checkout start (not just cart add)
2. Address validation: USPS API for US, Royal Mail for UK
3. Payment: Tokenize card data client-side (never log raw PAN)
4. Fraud signals: Flag if shipping != billing country, order > 3x avg order value
5. 3DS: Required for EU transactions over 30 EUR (PSD2/SCA)

## References
- Google Product Category taxonomy: see `references/google-taxonomy.md`
- Merchant Center error codes: see `references/merchant-errors.md`
- PSD2/SCA compliance checklist: see `references/psd2-sca.md`
```

## Common Problems and Fixes

**Merchant Center feed rejected for missing GTIN.** Electronics and branded products require a valid GTIN-13 (EAN-13). The check digit (position 13) is calculated: sum odd positions, sum even positions x3, modulo 10. Validate programmatically before feed submission.

**Cart total differs between frontend and backend.** Floating-point arithmetic causes penny rounding errors. Store all prices as integers (cents) and convert to decimal only at display time. Never use `parseFloat()` for money.

**Promo code applied to excluded categories.** Promotion rules often exclude clearance or already-discounted items. The skill must check `promotion.excluded_categories[]` against each cart item's category code before applying the discount.

**Variant listings not grouped in Google Shopping.** Missing `item_group_id` causes variants to appear as separate products. Set `item_group_id` to the parent SKU (without size/color suffix) for all variants.

GTIN-13 check digit validation in your feed pipeline:

```javascript
function validateGTIN13(gtin) {
  if (gtin.length !== 13) return false;
  const digits = gtin.split('').map(Number);
  const check = digits.pop();
  const sum = digits.reduce((acc, d, i) => acc + d * (i % 2 === 0 ? 1 : 3), 0);
  return (10 - (sum % 10)) % 10 === check;
}
```

## Production Gotchas

Google Merchant Center enforces a 30-day feed freshness window. If your feed generation script fails silently, products disappear from Google Shopping after 30 days. Set up a monitoring check that alerts when `feeds/google-merchant-*.xml` has not been updated in 48 hours. For a deeper dive, see [Claude Sonnet 4.6 vs Codestral: Code Generation Face-Off](/claude-sonnet-vs-codestral-comparison/).

Amazon SP-API (if you also sell on Amazon) uses ASIN (10-character alphanumeric starting with B0) instead of GTIN. Your product data model needs both identifiers, and the feed generator must output the correct one per marketplace.

## Checklist

- [ ] SKU validation regex covers all active category codes
- [ ] Merchant Center feed passes `scripts/validate-feed.js` with zero errors
- [ ] Cart pricing tested with all discount stacking combinations
- [ ] Checkout re-checks inventory at order submission (not just cart add)
- [ ] Price stored as integer cents throughout the backend

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Skills for SEO Content Generation](/claude-skills-for-seo-content-generation/) -- product page SEO and schema markup
- [Claude Skills for Logistics and Supply Chain](/claude-skills-for-logistics-supply-chain/) -- order fulfillment
- [Claude Skills for Financial Analysis](/claude-skills-for-financial-analysis/) -- revenue and margin reporting

## Related Articles

- [Claude Code Skills for Nonprofit Donation Platforms (2026)](/claude-code-skills-for-nonprofit-donation-platforms/)
