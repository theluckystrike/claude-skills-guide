---
sitemap: false
layout: default
title: "Claude Skills for Medical Records (2026)"
description: "Build a Claude Code skill that maps procedures to CPT/ICD-10 codes, validates FHIR R4 resources, parses HL7 v2 messages, and enforces HIPAA-safe output."
permalink: /claude-skills-for-medical-records-processing/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, healthcare, medical-records]
last_updated: 2026-04-19
---

## The Specific Situation

Your healthcare software processes clinical notes, lab results, and insurance claims. A developer working on the claims module needs to map procedures to CPT (Current Procedural Terminology) codes -- "office visit, established patient, 25 minutes" maps to CPT 99214, not 99213 (which is 15-20 minutes). An incorrect code triggers claim denials that take 30-45 days to resolve. ICD-10 diagnosis codes are equally precise: "Type 2 diabetes without complications" is E11.9, but "Type 2 diabetes with diabetic chronic kidney disease" is E11.22.

A Claude Code skill encodes CPT code selection logic, ICD-10 mapping rules, FHIR R4 resource validation, HL7 v2 message parsing (ADT, ORM, ORU message types), and HIPAA-compliant output patterns that strip PHI (Protected Health Information) from logs and error messages. This skill processes 30-50 clinical records per hour through structured extraction.

## Technical Foundation

The skill uses `paths: ["src/claims/**/*", "src/clinical/**/*", "src/fhir/**/*", "src/hl7/**/*"]` for conditional activation. The `references/` directory holds CPT code tables (8,000+ codes organized by category), ICD-10 chapter index, and FHIR R4 resource schemas -- each loaded only when Claude needs them.

For HIPAA compliance, the skill uses `context: fork` to process clinical notes in an isolated context. The forked subagent extracts structured data and returns only coded output (CPT codes, ICD-10 codes, FHIR resources) -- never raw clinical text. This prevents PHI from persisting in the main session's context window.

## The Working SKILL.md

Create at `.claude/skills/medical-records/SKILL.md`:

```yaml
---
name: medical-records
description: >
  Medical records processing skill. Use when working with CPT/ICD-10
  code mapping, FHIR R4 resource validation, HL7 v2 message parsing
  (ADT, ORM, ORU), clinical note extraction, or claims processing.
  Enforces HIPAA-safe output patterns. Knows E/M level selection,
  modifier usage, and FHIR bundle validation.
paths:
  - "src/claims/**/*"
  - "src/clinical/**/*"
  - "src/fhir/**/*"
  - "src/hl7/**/*"
context: fork
agent: Explore
allowed-tools: Read Grep Bash(python3 *)
---

# Medical Records Processing Skill

## CRITICAL: HIPAA Output Rules
- NEVER include patient names, DOB, SSN, MRN in output
- NEVER log raw clinical note text to console or files
- Replace PHI with tokens: [PATIENT], [DOB], [MRN]
- Output only structured codes, resource IDs, and validation results
- If uncertain whether data is PHI, treat it as PHI

## CPT Code Mapping

### Evaluation & Management (E/M) — Office Visits (99202-99215)
Selection based on Medical Decision Making (MDM) complexity:

| CPT | Patient Type | MDM Level | Typical Time |
|-----|-------------|-----------|-------------|
| 99202 | New | Straightforward | 15-29 min |
| 99203 | New | Low | 30-44 min |
| 99204 | New | Moderate | 45-59 min |
| 99205 | New | High | 60-74 min |
| 99212 | Established | Straightforward | 10-19 min |
| 99213 | Established | Low | 20-29 min |
| 99214 | Established | Moderate | 30-39 min |
| 99215 | Established | High | 40-54 min |

### MDM Complexity Determination
Three elements (2 of 3 must meet threshold):
1. **Problems addressed**: Minimal(1), Low(2), Moderate(3+), High(chronic illness w/ exacerbation)
2. **Data reviewed**: Minimal(none), Low(order test), Moderate(independent interpretation), High(discuss with external physician)
3. **Risk**: Minimal(OTC meds), Low(prescription drug), Moderate(minor surgery), High(major surgery, hospitalization)

### Common Modifiers
- -25: Significant, separately identifiable E/M service (same day as procedure)
- -59: Distinct procedural service (unbundling)
- -76: Repeat procedure by same physician
- -91: Repeat clinical lab test

## ICD-10 Mapping
Format: [Letter][2digits].[1-4digits]
- Chapter-based: A00-B99 (Infectious), C00-D49 (Neoplasms), E00-E89 (Endocrine)
- Specificity required: Use the most specific code available
  - E11 (Type 2 diabetes) is too broad
  - E11.9 (without complications) is minimum acceptable
  - E11.65 (with hyperglycemia) is preferred when documented
- Combination codes: One code captures both condition and manifestation
  - K50.011: Crohn's disease of small intestine with rectal bleeding

## FHIR R4 Resource Validation

### Patient Resource (required fields)
- resourceType: "Patient"
- identifier: at least one with system and value
- name: at least one HumanName with family
- gender: male | female | other | unknown
- birthDate: YYYY-MM-DD format

### Encounter Resource (required fields)
- resourceType: "Encounter"
- status: planned | arrived | in-progress | finished | cancelled
- class: AMB (ambulatory), EMER (emergency), IMP (inpatient)
- subject: Reference to Patient
- period: start (and end if status=finished)

### Bundle Validation
- type: transaction | batch | searchset | collection
- All entries must have fullUrl
- Transaction bundles: each entry needs request.method and request.url
- Validate references resolve within bundle or to known external resources

## HL7 v2 Message Parsing

### ADT (Admit/Discharge/Transfer)
Segments: MSH | EVN | PID | PV1 | [NK1] | [DG1]
- MSH-9: Message type (ADT^A01=admit, ADT^A03=discharge, ADT^A08=update)
- PID-3: Patient identifier list (MRN)
- PV1-2: Patient class (I=inpatient, O=outpatient, E=emergency)

### ORM (Order)
Segments: MSH | PID | PV1 | ORC | OBR
- ORC-1: Order control (NW=new, CA=cancel, XO=change)
- OBR-4: Universal service identifier (CPT or LOINC code)

## References
- CPT code tables by category: see `references/cpt-tables.md`
- ICD-10 chapter index: see `references/icd10-chapters.md`
- FHIR R4 resource schemas: see `references/fhir-r4-schemas.md`
```

Directory structure for HIPAA-safe processing:

```
.claude/skills/medical-records/
  SKILL.md
  references/
    cpt-tables.md                # CPT codes by category (private, not in git)
    icd10-chapters.md            # ICD-10 chapter index
    fhir-r4-schemas.md           # FHIR resource validation schemas
```

## Common Problems and Fixes

**E/M code selection defaults to 99213.** Developers hardcode the most common code instead of implementing MDM logic. The skill requires evaluating 2 of 3 MDM elements against documented thresholds. Build a decision tree, not a default value.

**ICD-10 code too unspecific for claims.** Payers reject codes that lack laterality or specificity. For example, M54.5 (low back pain) is accepted, but M79.3 (panniculitis, unspecified) requires site specification. Always use the most specific code supported by clinical documentation.

**FHIR bundle references do not resolve.** A Condition resource referencing `Patient/123` must have that Patient resource either in the bundle or in the target FHIR server. Validate all internal references before submitting transaction bundles.

**HL7 v2 field separator assumed to be pipe.** The MSH segment defines the field separator at position 4 (MSH|). Some systems use non-standard separators. Read MSH-1 first, then parse the rest of the message using that delimiter.

## Production Gotchas

CPT codes are copyrighted by the AMA. You cannot distribute the full code set in your open-source repository. Store CPT lookup tables in a private data directory excluded from version control, or use an API like the AMA's CPT API for runtime lookups.

FHIR servers enforce different validation strictness. Epic's FHIR API rejects resources with extensions it does not recognize, while Cerner is more permissive. Test your FHIR resource construction against each target EHR system's sandbox.

## Checklist

- [ ] CPT lookup tables stored securely (not in version control)
- [ ] ICD-10 codes validated at 4+ character specificity
- [ ] FHIR bundles pass validation against target EHR sandbox
- [ ] All output functions strip PHI before logging
- [ ] `context: fork` isolates clinical note processing from main session



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skills for Legal Document Review](/claude-skills-for-legal-document-review/) -- regulated document extraction patterns
- [Claude Skills for Financial Analysis](/claude-skills-for-financial-analysis/) -- claims revenue analysis
- [Hybrid Patterns: Skills, MCP, and Custom Tools](/hybrid-patterns-skills-mcp-custom-tools/) -- integrating FHIR MCP servers with skills
