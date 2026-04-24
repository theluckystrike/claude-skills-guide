---
title: "Claude Skills for Manufacturing QA (2026)"
description: "Build a Claude Code skill that analyzes SPC control charts, processes Non-Conformance Reports with root cause codes, and tracks CAPA corrective actions."
permalink: /claude-skills-for-manufacturing-qa/
categories: [skills, 2026]
tags: [claude-code, claude-skills, manufacturing, quality-assurance]
last_updated: 2026-04-19
---

## The Specific Situation

Your manufacturing execution system (MES) generates Statistical Process Control (SPC) data from 40+ inspection stations. Each station measures critical dimensions -- shaft diameter tolerance of 25.00mm +/- 0.02mm, surface roughness Ra <= 0.8 micrometers, hardness 58-62 HRC. When a measurement falls outside control limits, the system creates a Non-Conformance Report (NCR) with disposition codes: USE-AS-IS, REWORK, SCRAP, RETURN-TO-VENDOR. A developer building the quality dashboard needs to know that Western Electric rules (not just +/- 3-sigma) detect out-of-control conditions, and that a CAPA (Corrective and Preventive Action) must reference the specific NCR, root cause category, and verification evidence.

A Claude Code skill encodes SPC Western Electric rules, NCR disposition logic, CAPA workflow states, and ISO 9001:2015 clause references for audit compliance. It processes 50-80 inspection records per hour through anomaly detection and report generation.

## Technical Foundation

The skill activates with `paths: ["src/quality/**/*", "src/spc/**/*", "src/inspection/**/*"]`. The `references/` directory holds the full Western Electric rules (8 rules with pattern descriptions), ISO 9001:2015 clause index, and FMEA (Failure Mode and Effects Analysis) scoring tables -- loaded on demand.

Dynamic context injection with `!`python3 scripts/spc-summary.py --station=all --last=24h`` pulls the latest SPC summary into the skill context at load time, giving Claude immediate awareness of which stations are in-control and which have triggered alerts.

## The Working SKILL.md

Create at `.claude/skills/manufacturing-qa/SKILL.md`:

```yaml
---
name: manufacturing-qa
description: >
  Manufacturing quality assurance skill. Use when working with SPC
  control charts (X-bar, R-chart, Cp/Cpk), Non-Conformance Reports
  (NCR disposition, root cause coding), CAPA workflows, or ISO 9001
  audit compliance. Knows Western Electric rules, FMEA RPN scoring,
  and GD&T tolerance stack analysis.
paths:
  - "src/quality/**/*"
  - "src/spc/**/*"
  - "src/inspection/**/*"
allowed-tools: Bash(python3 *) Read Grep
---

# Manufacturing QA Skill

## SPC Control Chart Analysis

### Control Limit Calculation
- X-bar chart: UCL = X-double-bar + A2 x R-bar, LCL = X-double-bar - A2 x R-bar
- R chart: UCL = D4 x R-bar, LCL = D3 x R-bar
- Constants (subgroup size n=5): A2=0.577, D3=0, D4=2.114

### Western Electric Rules (Out-of-Control Detection)
1. **Rule 1**: One point beyond 3-sigma (standard out-of-control)
2. **Rule 2**: Nine consecutive points on same side of centerline (process shift)
3. **Rule 3**: Six consecutive points steadily increasing or decreasing (trend)
4. **Rule 4**: Fourteen consecutive points alternating up and down (oscillation)
5. **Rule 5**: Two of three consecutive points beyond 2-sigma same side
6. **Rule 6**: Four of five consecutive points beyond 1-sigma same side
7. **Rule 7**: Fifteen consecutive points within 1-sigma (stratification)
8. **Rule 8**: Eight consecutive points beyond 1-sigma on either side (mixture)

Trigger NCR when any rule is violated. Log the rule number and affected data points.

### Process Capability
- Cp = (USL - LSL) / (6 x sigma) — measures spread vs tolerance
- Cpk = min((USL - X-bar)/(3*sigma), (X-bar - LSL)/(3*sigma)) — includes centering
- Cp >= 1.33 = capable, Cpk >= 1.33 = capable and centered
- Cp >= 1.0 but Cpk < 1.0 = capable but off-center (adjust process mean)

## Non-Conformance Report (NCR) Processing

### NCR Fields
- NCR-ID: Auto-generated (NCR-{YYYYMMDD}-{sequence})
- Part number, lot/batch number, inspection station ID
- Defect type code (from `data/defect-codes.json`)
- Measurement: actual value, specification limits, deviation amount
- Severity: MINOR (cosmetic), MAJOR (functional impact), CRITICAL (safety)

### Disposition Codes
- **USE-AS-IS**: Deviation within engineering tolerance, no customer impact
  - Requires: Engineering signoff, documented justification
- **REWORK**: Can be corrected to meet specification
  - Requires: Rework instruction (WI number), re-inspection after rework
- **SCRAP**: Cannot be corrected, material wasted
  - Requires: Cost accounting entry, material disposition record
- **RETURN-TO-VENDOR**: Incoming inspection failure
  - Requires: RTV number, supplier notification, replacement PO

### Root Cause Categories (Ishikawa/5M)
- Man: Training deficiency, procedure not followed, fatigue
- Machine: Tool wear, calibration drift, fixture damage
- Material: Incoming material defect, lot variation, wrong grade
- Method: Inadequate work instruction, sequence error
- Measurement: Gauge R&R failure, wrong instrument, environmental factor

## CAPA Workflow

### States
1. INITIATED: NCR triggers CAPA, assign owner and due date
2. INVESTIGATION: Root cause analysis (5-Why, fishbone, fault tree)
3. CONTAINMENT: Immediate actions to stop defect from reaching customer
4. CORRECTIVE: Long-term fix addressing root cause
5. VERIFICATION: Confirm fix works (re-run SPC, audit results)
6. CLOSURE: Evidence reviewed, CAPA effective for 90+ days

### ISO 9001:2015 Clause References
- Clause 8.7: Control of nonconforming outputs
- Clause 10.2: Nonconformity and corrective action
- Clause 10.3: Continual improvement
- Clause 9.1.3: Analysis and evaluation (SPC data review)

## Output Formats
- SPC alerts: `reports/spc-alerts-{station}-{date}.json`
- NCR records: `data/ncr/{ncr-id}.json`
- CAPA tracking: `data/capa/{capa-id}.json`

## References
- Western Electric rules with examples: see `references/western-electric.md`
- FMEA RPN scoring guide: see `references/fmea-scoring.md`
- GD&T tolerance stack methodology: see `references/gdt-tolerance.md`
```

Invocation and directory structure:

```
.claude/skills/manufacturing-qa/
  SKILL.md
  references/
    western-electric.md          # 8 rules with chart examples
    fmea-scoring.md              # RPN calculation guide
    gdt-tolerance.md             # GD&T stack analysis
  scripts/
    spc-summary.py               # Generates SPC data summary
```

## Common Problems and Fixes

**SPC control limits calculated on out-of-control data.** Control limits must be calculated from a stable process baseline. Exclude any data points that triggered Western Electric rules during the baseline period, then recalculate. Using contaminated data widens the limits and hides future anomalies.

**NCR severity classification is inconsistent.** Different inspectors classify the same defect differently. Define objective thresholds: CRITICAL = safety risk or regulatory non-compliance, MAJOR = deviation from customer specification > 50% of tolerance band, MINOR = cosmetic or deviation < 25% of tolerance band.

**CAPA closure without verification evidence.** A CAPA is not complete when the corrective action is implemented. It requires 90 days of clean SPC data (no Western Electric rule violations) on the affected characteristic to confirm effectiveness. Reject closure requests without this evidence.

## Production Gotchas

Gauge R&R (Repeatability and Reproducibility) studies must show measurement system variation under 10% of the tolerance band for the SPC data to be trustworthy. If your measurement system contributes 30% of observed variation, process capability calculations are meaningless. Run Gauge R&R before trusting SPC results from a new inspection station.

SPC data volume grows fast. At 40 stations measuring every 30 minutes with 5 characteristics each, you generate 9,600 data points per day. Archive data older than 90 days to a separate store and query it on demand rather than loading it into the skill context.

## Checklist

- [ ] SPC control limits calculated from a verified stable baseline
- [ ] Western Electric rules 1-8 implemented in the detection algorithm
- [ ] Defect code table (`data/defect-codes.json`) covers all active part numbers
- [ ] CAPA workflow enforces 90-day verification before closure
- [ ] Gauge R&R study completed for all active inspection stations

## Related Guides

- [Claude Skills for Logistics and Supply Chain](/claude-skills-for-logistics-supply-chain/) -- supplier quality and incoming inspection
- [Claude Skills for Real Estate Data Extraction](/claude-skills-for-real-estate-data-extraction/) -- facility and equipment data management
- [Claude Skills Data Flow Patterns](/claude-skills-data-flow-patterns/) -- SPC data pipeline architecture
