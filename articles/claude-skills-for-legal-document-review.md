---
layout: default
title: "Claude Skills for Legal Document Review (2026)"
description: "Build a Claude Code skill that extracts contract clauses by type, scores liability risk, compares redlines against standard templates, and flags."
permalink: /claude-skills-for-legal-document-review/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, legal, contract-review]
last_updated: 2026-04-19
---

## The Specific Situation

Your legal tech platform processes 50-80 contracts per week. Each contract contains clauses that must be classified: indemnification, limitation of liability, termination for convenience, assignment, force majeure, governing law, confidentiality, and IP ownership. A junior developer working on the parser does not know that an indemnification clause with "sole and exclusive remedy" language fundamentally changes the risk profile, or that a limitation of liability capped at "fees paid in the preceding 12 months" versus "aggregate fees paid" creates a 5-10x exposure difference.

A Claude Code skill encodes clause taxonomy, risk scoring rubrics, redline comparison logic against your standard templates, and jurisdiction-specific requirements (Delaware law differs from California on non-compete enforceability). It processes approximately 20-30 contracts per hour through clause extraction and risk scoring.

## Technical Foundation

The skill activates via `paths: ["src/contracts/**/*", "src/legal/**/*", "src/clauses/**/*"]`. Supporting files in `references/` hold the full clause taxonomy (200+ clause types with definitions) and jurisdiction comparison tables. Claude reads these on demand, keeping the core SKILL.md focused on the most critical 15-20 clause types.

The `context: fork` and `agent: Explore` frontmatter options run the review in an isolated context window, preventing contract text from contaminating the main coding session. This matters for confidentiality -- the forked context discards contract content after returning the summary.

## The Working SKILL.md

Create at `.claude/skills/legal-review/SKILL.md`:

```yaml
---
name: legal-review
description: >
  Legal document review skill. Use when extracting clauses from contracts,
  scoring risk on indemnification/liability/termination terms, comparing
  redlines against standard templates, or checking jurisdiction-specific
  enforceability (Delaware, California, New York, UK). Knows clause
  taxonomy, risk scoring rubrics, and common non-standard term patterns.
paths:
  - "src/contracts/**/*"
  - "src/legal/**/*"
  - "src/clauses/**/*"
allowed-tools: Read Grep Bash(python3 *)
---

# Legal Document Review Skill

## Clause Extraction Taxonomy

### Tier 1 — High Risk (always extract and score)
1. **Indemnification**: Look for "indemnify," "hold harmless," "defend"
   - Risk factors: uncapped indemnity, third-party claims inclusion, IP infringement carveout
   - Acceptable: Mutual indemnification, capped at contract value, standard carveouts
   - Red flag: One-way indemnification favoring counterparty with no cap

2. **Limitation of Liability**
   - Cap types: Fixed dollar amount, fees paid (12mo vs aggregate), insurance coverage limit
   - Carveouts: IP infringement, data breach, willful misconduct (these often bypass the cap)
   - Red flag: No liability cap, or cap lower than expected contract value

3. **Termination**
   - For cause: Material breach with cure period (30 days standard)
   - For convenience: Unilateral termination right, notice period (30-90 days)
   - Red flag: Counterparty can terminate for convenience but you cannot

4. **IP Ownership / Work Product**
   - Work-for-hire: All IP created under contract belongs to client
   - License-back: Contractor retains ownership, grants license
   - Red flag: Ambiguous ownership of pre-existing IP or tools

5. **Confidentiality / NDA**
   - Duration: 2-5 years standard, "perpetual" for trade secrets
   - Residuals clause: Allows use of general knowledge retained in memory
   - Red flag: No carveout for independently developed information

### Tier 2 — Medium Risk (extract, flag if non-standard)
6. **Governing Law / Jurisdiction**: Note state or country
7. **Assignment**: Can either party assign without consent?
8. **Force Majeure**: Does it include pandemics, cyberattacks?
9. **Data Protection / GDPR**: DPA required for EU personal data
10. **Insurance Requirements**: Minimum coverage amounts

## Risk Scoring Rubric
Score each Tier 1 clause: LOW (1), MEDIUM (2), HIGH (3), CRITICAL (4)

| Factor | LOW | MEDIUM | HIGH | CRITICAL |
|--------|-----|--------|------|----------|
| Indemnity | Mutual, capped | Mutual, uncapped | One-way, capped | One-way, uncapped |
| Liability cap | >1x contract value | = contract value | < contract value | No cap |
| Termination | Mutual for convenience | Asymmetric notice | No cure period | No termination right |
| IP ownership | Clear work-for-hire | License-back | Ambiguous | Silent on IP |

Overall contract risk = sum of Tier 1 scores:
- 4-6: LOW risk, standard approval
- 7-10: MEDIUM risk, senior review
- 11-14: HIGH risk, legal counsel required
- 15+: CRITICAL, do not sign without negotiation

## Redline Comparison Process
1. Load standard template from `templates/{contract-type}-standard.md`
2. Compare clause-by-clause against incoming contract
3. Flag deviations:
   - **Added**: Clause present in incoming but not in template
   - **Removed**: Clause in template but missing from incoming
   - **Modified**: Same clause type, different terms
4. Output comparison to `reports/redline-{contract-id}.json`

## Output Format
```json
{
  "contract_id": "",
  "clauses": [
    {
      "type": "indemnification",
      "text": "extracted clause text",
      "risk_score": 3,
      "risk_factors": ["one-way", "uncapped"],
      "recommendation": "Negotiate mutual indemnification with cap at 2x annual fees"
    }
  ],
  "overall_risk": 11,
  "risk_level": "HIGH",
  "redline_deviations": []
}
```

## References
- Full clause taxonomy (200+ types): see `references/clause-taxonomy.md`
- Jurisdiction comparison tables: see `references/jurisdiction-matrix.md`
- Standard templates: see `templates/` directory
```

## Common Problems and Fixes

**Clause extraction misses split clauses.** Indemnification language sometimes spans multiple sections (e.g., Section 8.1 defines indemnity, Section 8.3 caps it). Search for all sections referencing the same topic, not just the first match. Use cross-reference detection: "subject to Section X" or "notwithstanding Section Y."

**Risk score inflated by boilerplate.** Standard force majeure clauses in post-2020 contracts often include pandemic language. This is now market-standard, not a risk factor. Update the scoring rubric to treat pandemic inclusion as neutral rather than elevated risk.

**Redline comparison fails on formatting differences.** Two contracts with identical terms but different numbering (Section 4 vs. Article IV) will appear as mismatches. Normalize section numbering before comparison: strip "Section," "Article," "Clause" prefixes and compare content only.

## Production Gotchas

Contract PDFs often contain scanned images rather than selectable text. Your intake pipeline needs OCR (Tesseract or cloud OCR service) before the skill can extract clauses. Test OCR accuracy on contracts with multi-column layouts and handwritten amendments.

Attorney-client privilege concerns mean contract text should not persist in Claude's session history. Use `context: fork` to isolate the review, and ensure your organization's data retention policies allow AI processing of legal documents.

## Checklist

- [ ] Standard templates exist in `templates/` for each contract type you process
- [ ] Clause taxonomy covers your top 15 clause types with scoring rubrics
- [ ] OCR pipeline handles scanned PDFs before skill invocation
- [ ] `context: fork` configured to isolate contract text from main session
- [ ] Risk scoring thresholds reviewed and approved by legal counsel



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skills for Medical Records Processing](/claude-skills-for-medical-records-processing/) -- regulated document extraction patterns
- [Claude Skills for Financial Analysis](/claude-skills-for-financial-analysis/) -- contract value and liability cap calculations
- [Claude Skills vs Subagents: When to Use Each](/claude-skills-vs-subagents-when-to-use/) -- forked context for sensitive document review
