---
title: "Claude Code for Avionics Software"
permalink: /claude-code-avionics-do178c-development-2026/
description: "Avionics software development with Claude Code under DO-178C. Generate traceable requirements, MC/DC tests, and artifacts."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for Avionics (DO-178C)

DO-178C certification demands structural coverage at the MC/DC level for Design Assurance Level A software -- the kind that controls flight surfaces, engine FADEC, and fly-by-wire systems. A single uncovered decision condition can block certification for months. Engineers spend more time writing test cases, traceability matrices, and verification artifacts than writing the actual flight code.

Claude Code understands DO-178C objectives, MC/DC coverage semantics, and the traceability chain from system requirements through software low-level requirements to test procedures. It generates the boilerplate that certification demands while you focus on the safety-critical logic that requires human judgment.

## The Workflow

### Step 1: Requirements-Driven Project Structure

```bash
# DO-178C project layout matching DER expectations
mkdir -p src/app src/bsp src/os_abstraction
mkdir -p tests/unit tests/integration tests/mc_dc
mkdir -p docs/hlr docs/llr docs/traceability docs/test_procedures
mkdir -p tools/analysis coverage_reports

# Install test and coverage tools
pip install gcovr cffi pytest
# LDRA, VectorCAST, or Rapita RVS for certified tool qualification
```

### Step 2: Write Traceable Flight Code

Claude Code generates code with requirement tags that feed directly into your traceability matrix:

```c
/* src/app/airspeed_monitor.c
 * Implements: HLR-ASPD-001 through HLR-ASPD-005
 * DAL: A (Flight Critical)
 * Coding Standard: MISRA C:2012
 */

#include "airspeed_monitor.h"
#include "pitot_sensor.h"
#include "static_port.h"
#include <math.h>
#include <assert.h>

/* LLR-ASPD-001: Compute calibrated airspeed from differential pressure.
 * Ref: HLR-ASPD-002
 * Precondition: diff_pressure_pa >= 0.0
 * Postcondition: result in knots, range [0, 500]
 */
float compute_calibrated_airspeed(float diff_pressure_pa) {
    assert(diff_pressure_pa >= 0.0f);  /* defensive: sensor fault returns 0 */

    /* Standard atmosphere: rho_0 = 1.225 kg/m^3 */
    const float RHO_0 = 1.225f;
    const float PA_TO_KNOTS = 1.94384f;

    float cas_ms = sqrtf((2.0f * diff_pressure_pa) / RHO_0);
    float cas_knots = cas_ms * PA_TO_KNOTS;

    /* LLR-ASPD-002: Clamp to valid range per HLR-ASPD-003 */
    if (cas_knots > 500.0f) {
        cas_knots = 500.0f;
    }

    assert(cas_knots >= 0.0f && cas_knots <= 500.0f);
    return cas_knots;
}

/* LLR-ASPD-003: Cross-check primary and standby pitot sources.
 * Ref: HLR-ASPD-004
 * Returns: ASPD_VALID, ASPD_DISAGREE, ASPD_FAULT
 */
aspd_status_t cross_check_airspeed(
    float primary_knots,
    float standby_knots,
    float threshold_knots
) {
    assert(threshold_knots > 0.0f);

    float delta = fabsf(primary_knots - standby_knots);

    /* MC/DC decision: (delta > threshold) AND (primary > MIN_AIRSPEED) */
    if ((delta > threshold_knots) && (primary_knots > MIN_AIRSPEED_KTS)) {
        return ASPD_DISAGREE;
    }

    if ((primary_knots < 0.0f) || (standby_knots < 0.0f)) {
        return ASPD_FAULT;
    }

    return ASPD_VALID;
}
```

### Step 3: Generate MC/DC Test Cases

Claude Code produces test vectors that achieve Modified Condition/Decision Coverage for each boolean expression:

```c
/* tests/mc_dc/test_airspeed_mcdc.c
 * MC/DC coverage for cross_check_airspeed()
 * Decision: (delta > threshold) AND (primary > MIN_AIRSPEED)
 * Conditions: A = (delta > threshold), B = (primary > MIN_AIRSPEED)
 *
 * MC/DC truth table:
 * TC1: A=T, B=T -> DISAGREE  (A independently affects outcome: compare TC1 vs TC3)
 * TC2: A=T, B=F -> VALID     (B independently affects outcome: compare TC1 vs TC2)
 * TC3: A=F, B=T -> VALID     (A independently affects outcome: compare TC1 vs TC3)
 * TC4: A=F, B=F -> VALID     (baseline)
 */

#include "unity.h"
#include "airspeed_monitor.h"

void test_mcdc_tc1_both_true(void) {
    /* A=T: delta=20 > threshold=5, B=T: primary=150 > MIN(40) */
    aspd_status_t result = cross_check_airspeed(150.0f, 130.0f, 5.0f);
    TEST_ASSERT_EQUAL(ASPD_DISAGREE, result);
}

void test_mcdc_tc2_a_true_b_false(void) {
    /* A=T: delta=20 > threshold=5, B=F: primary=30 < MIN(40) */
    aspd_status_t result = cross_check_airspeed(30.0f, 10.0f, 5.0f);
    TEST_ASSERT_EQUAL(ASPD_VALID, result);
}

void test_mcdc_tc3_a_false_b_true(void) {
    /* A=F: delta=2 < threshold=5, B=T: primary=150 > MIN(40) */
    aspd_status_t result = cross_check_airspeed(150.0f, 148.0f, 5.0f);
    TEST_ASSERT_EQUAL(ASPD_VALID, result);
}

void test_mcdc_tc4_both_false(void) {
    /* A=F: delta=2 < threshold=5, B=F: primary=30 < MIN(40) */
    aspd_status_t result = cross_check_airspeed(30.0f, 28.0f, 5.0f);
    TEST_ASSERT_EQUAL(ASPD_VALID, result);
}

void test_fault_negative_primary(void) {
    aspd_status_t result = cross_check_airspeed(-1.0f, 100.0f, 5.0f);
    TEST_ASSERT_EQUAL(ASPD_FAULT, result);
}
```

### Step 4: Verify Coverage

```bash
# Build with coverage instrumentation
gcc -fprofile-arcs -ftest-coverage -o test_runner \
    tests/mc_dc/test_airspeed_mcdc.c src/app/airspeed_monitor.c -lm -lunity

./test_runner
gcovr --branches --decisions -r src/ --html-details coverage_reports/mcdc.html

# Expected: 100% decision coverage, 100% MC/DC on cross_check_airspeed
# For certified coverage: use LDRA TBrun or VectorCAST with qualified tool chain
```

## CLAUDE.md for Avionics (DO-178C)

```markdown
# DO-178C Avionics Development

## Standards
- DO-178C (Software Considerations in Airborne Systems)
- MISRA C:2012 (mandatory for DAL A/B)
- DO-330 (Tool Qualification)
- DO-331 (Model-Based supplement, if applicable)

## Coverage Requirements by DAL
- DAL A: MC/DC + statement + decision + entry/exit
- DAL B: Decision + statement
- DAL C: Statement coverage
- DAL D: Verified against HLR only

## File Patterns
- .c/.h for flight code (MISRA C:2012 compliant)
- .req for requirements (DOORS or CSV export)
- Traceability: HLR -> LLR -> Source -> Test -> Coverage

## Testing
- Unit tests achieve MC/DC for DAL A boolean expressions
- Integration tests verify inter-module data flow
- All tests traceable to LLR via requirement tags in comments

## Common Commands
- gcc -fprofile-arcs -ftest-coverage — build with coverage
- gcovr --branches --decisions — report branch coverage
- cppcheck --enable=all --std=c11 — static analysis
- splint +checks — MISRA-adjacent lint
- ldra_testbed -mc_dc — certified MC/DC measurement
```

## Common Pitfalls

- **Incomplete MC/DC vectors:** Engineers test true/false for each condition but miss the independence requirement. Claude Code generates the minimal set of test vectors where each condition independently affects the decision outcome.
- **Dead code in certified modules:** DO-178C DAL A forbids dead code. Claude Code flags unreachable branches and unused functions that static analysis tools sometimes miss due to macro expansion.
- **Requirements traceability gaps:** Missing LLR tags mean failed audits. Claude Code scans your source files and reports which HLR/LLR requirement IDs lack test coverage or have no implementing code.

## Related

- [Claude Code for ASIC Design Verification](/claude-code-asic-design-verification-2026/)
- [Claude Code for Medical Device Firmware IEC 62304](/claude-code-medical-device-firmware-iec62304-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
