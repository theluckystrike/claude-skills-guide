---
title: "Claude Skills for Logistics and Supply Chain — Automate HS Code Lookup, Shipment Tracking, and Inventory Alerts — 2026"
description: "Build a Claude Code skill that validates HS codes, parses EDI 856 ASN documents, tracks container status, and generates reorder-point alerts."
permalink: /claude-skills-for-logistics-supply-chain/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, logistics, supply-chain]
last_updated: 2026-04-19
---

## The Specific Situation

Your logistics platform processes EDI 856 (Advance Ship Notice) and EDI 850 (Purchase Order) documents daily. Each ASN contains segment groups -- BSN, DTM, HL, LIN, SN1 -- that map shipment quantities to SKUs and container IDs. A developer touching this code needs to know that an HL segment with hierarchical level code "S" means shipment, "O" means order, "I" means item. Getting this wrong means inventory counts drift.

A Claude Code skill scoped to your EDI processing directory encodes these segment definitions, validates HS (Harmonized System) tariff codes against the 6-digit international standard, and flags when inbound container quantities differ from the PO by more than a configurable threshold. The skill processes roughly 40-60 ASNs per hour when used with Claude's `/batch` mode.

## Technical Foundation

The `paths` field restricts this skill to logistics code: `"src/edi/**/*"`, `"src/inventory/**/*"`, `"src/shipping/**/*"`. When a developer opens an EDI parser file, Claude loads the skill automatically. The `allowed-tools` field pre-approves `Bash(node *)` and `Bash(python3 *)` for running validation scripts against HS code databases.

Dynamic context injection (`!`command``) pulls live data at skill load time. For example, `!`cat data/hs-codes-latest.csv | head -20`` injects the current HS code reference header so Claude knows the exact column format. Supporting files in `references/edi-856-segments.md` hold the full EDI segment definitions (3,000+ words) that Claude reads only when needed, keeping the main SKILL.md under the recommended 500 lines.

## The Working SKILL.md

Create at `.claude/skills/logistics-ops/SKILL.md`:

```yaml
---
name: logistics-ops
description: >
  Logistics and supply chain operations skill. Use when working with
  EDI documents (856 ASN, 850 PO, 810 Invoice), HS tariff code validation,
  container tracking, or inventory reorder-point calculations. Knows
  EDI X12 segment structures, HS code format (6-digit international +
  4-digit country-specific), and safety stock formulas.
paths:
  - "src/edi/**/*"
  - "src/inventory/**/*"
  - "src/shipping/**/*"
allowed-tools: Bash(node *) Bash(python3 *) Read Grep
---

# Logistics Operations Skill

## EDI Document Processing

### EDI 856 (Advance Ship Notice) Structure
- **BSN**: Beginning segment. BSN01 = transaction purpose (00=original, 05=replace)
- **DTM**: Date/time. DTM01 = qualifier (011=shipped, 017=estimated delivery)
- **HL**: Hierarchical level. HL03 values:
  - S = Shipment level (carrier, tracking, dates)
  - O = Order level (PO number reference)
  - I = Item level (SKU, quantity, UOM)
- **LIN**: Item identification. LIN02 = qualifier (UP=UPC, VP=vendor part, SK=SKU)
- **SN1**: Shipped quantity. SN1-02 = quantity, SN1-03 = UOM (EA, CS, PL)

### EDI 850 (Purchase Order) Matching
When processing ASNs, cross-reference against the originating PO:
1. Extract PO number from HL(O) > PRF segment
2. Load PO from `data/purchase-orders/{po-number}.json`
3. Compare line-item quantities: SN1-02 (shipped) vs PO1-02 (ordered)
4. Flag discrepancies exceeding 5% with severity levels:
   - WARN: 5-10% variance
   - ALERT: 10-25% variance
   - CRITICAL: >25% variance or missing line items

## HS Code Validation
- Format: NNNN.NN (6-digit minimum, up to 10-digit with country suffix)
- Validate against `data/hs-codes-2026.csv`
- Chapter (first 2 digits) determines product category
- Common chapters: 84 (machinery), 85 (electronics), 61-62 (apparel), 39 (plastics)
- Flag codes with recent tariff changes from `data/tariff-updates.json`

## Inventory Reorder Point Calculation
Formula: Reorder Point = (Average Daily Demand x Lead Time Days) + Safety Stock
Safety Stock = Z-score x StdDev(daily demand) x sqrt(Lead Time Days)
- Z-score: 1.65 for 95% service level, 2.33 for 99%
- Pull demand data from `data/demand-history/{sku}.csv`
- Lead time from `data/suppliers/{supplier-id}.json` field: avg_lead_time_days

## Output Formats
- ASN validation report: `reports/asn-validation-{date}.json`
- Reorder alerts: `reports/reorder-alerts-{date}.json`
- HS code audit: `reports/hs-audit-{date}.json`

## References
- Full EDI segment reference: see `references/edi-856-segments.md`
- HS code chapter index: see `references/hs-chapters.md`
- Carrier SCAC codes: see `references/scac-codes.md`
```

Sample EDI 856 ASN segment (for test fixture creation):

```
ISA*00*          *00*          *ZZ*SENDER         *ZZ*RECEIVER       *260415*1030*U*00401*000000001*0*P*>~
GS*SH*SENDER*RECEIVER*20260415*1030*1*X*004010~
ST*856*0001~
BSN*00*ASN123456*20260415*1030*0001~
HL*1**S~
TD1*CTN*10****G*150*LB~
HL*2*1*O~
PRF*PO-789012~
HL*3*2*I~
LIN**SK*SKU-ABC-001*VP*VENDOR-P1~
SN1**100*EA~
SE*11*0001~
```

## Common Problems and Fixes

**EDI segment delimiter mismatch.** EDI files use segment terminators (usually `~`) and element separators (usually `*`). Some trading partners use `\n` as terminator instead. Add a detection step: read the ISA segment (always 106 chars fixed-width) and extract the delimiter from position 105.

**HS code lookup returns multiple matches.** The 4-digit heading level is too broad. Always validate at 6-digit subheading minimum. If the code has country-specific extensions (digits 7-10), validate those against the importing country's schedule.

**Reorder point calculation uses stale demand data.** The skill pulls from CSV history files. If these are not updated weekly, safety stock calculations drift. Add a freshness check: if the latest demand record is older than 14 days, output a warning before the calculation.

## Production Gotchas

EDI files from different trading partners are not uniform despite the X12 standard. Some omit optional segments, others nest HL loops differently. Test with ASNs from your top 5 trading partners before trusting batch processing. Real EDI data often has encoding issues -- watch for non-ASCII characters in N1 (name) segments from international suppliers.

Container tracking APIs (ocean carriers like Maersk, MSC, CMA CGM) each have different authentication flows. The skill should not hardcode API calls; instead, reference a `scripts/track-container.sh` wrapper that handles auth per carrier.

## Checklist

- [ ] EDI test files from at least 3 trading partners in `test/fixtures/edi/`
- [ ] HS code database (`data/hs-codes-2026.csv`) is current year
- [ ] Supplier lead time data populated in `data/suppliers/`
- [ ] Demand history has at least 90 days of records per SKU
- [ ] Reports output directory exists with write permissions

## Related Guides

- [Claude Skills for E-Commerce Platforms](/claude-skills-for-ecommerce-platforms/) -- order fulfillment integration
- [Claude Skills for Manufacturing QA](/claude-skills-for-manufacturing-qa/) -- supplier quality tracking
- [Claude Skills Data Flow Patterns](/claude-skills-data-flow-patterns/) -- piping EDI output to downstream systems
