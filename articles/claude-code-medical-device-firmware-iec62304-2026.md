---
layout: default
title: "Claude Code for Medical Device IEC (2026)"
permalink: /claude-code-medical-device-firmware-iec62304-2026/
date: 2026-04-20
description: "Claude Code for Medical Device IEC — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Medical Device Firmware

IEC 62304 classifies medical device software into safety classes A, B, and C. Class C (can cause death or serious injury) requires full unit testing, integration testing, documented architecture, risk management per ISO 14971, and SOUP (Software of Unknown Provenance) tracking for every third-party library. The documentation burden alone can double development time.

Claude Code generates IEC 62304 compliant code with embedded risk references, produces unit tests that map to your risk control measures, and tracks SOUP dependencies with version pinning. It knows the difference between Class A's lightweight requirements and Class C's full lifecycle traceability, so it scales its artifact generation accordingly.

## The Workflow

### Step 1: Regulated Project Structure

```bash
# IEC 62304 Class C project layout
mkdir -p src/app src/drivers src/safety
mkdir -p tests/unit tests/integration tests/regression
mkdir -p docs/srs docs/sds docs/risk_mgmt docs/soup
mkdir -p tools/static_analysis ci

# Install test framework and static analysis
pip install gcovr cppcheck-codequality
# For production: Parasoft C/C++test or Polyspace for certified SAST
```

### Step 2: Implement Safety-Critical Module

```c
/* src/safety/spo2_alarm_monitor.c
 * IEC 62304 Class C — Software Item
 * SRS Ref: SRS-SPO2-ALARM-001 through SRS-SPO2-ALARM-004
 * Risk Ref: RISK-HAZ-003 (Hypoxemia not detected)
 * ISO 14971 Risk Control: RC-003 (audible + visual alarm within 10s)
 */

#include "spo2_alarm_monitor.h"
#include "alarm_manager.h"
#include "display_driver.h"
#include <assert.h>
#include <stdint.h>

#define SPO2_CRITICAL_LOW     85U   /* % — per clinical guidelines */
#define SPO2_WARNING_LOW      90U
#define SPO2_VALID_MIN         0U
#define SPO2_VALID_MAX       100U
#define ALARM_DEBOUNCE_MS   3000U   /* 3s debounce per IEC 60601-1-8 */
#define ALARM_DEADLINE_MS  10000U   /* 10s max latency: RC-003 */

typedef struct {
    uint8_t  current_spo2;
    uint32_t low_start_ms;
    uint8_t  alarm_active;
    uint8_t  sensor_fault;
} spo2_alarm_state_t;

static spo2_alarm_state_t state;

/* SDS-SPO2-010: Initialize alarm state machine */
void spo2_alarm_init(void) {
    state.current_spo2  = 0U;
    state.low_start_ms  = 0U;
    state.alarm_active  = 0U;
    state.sensor_fault  = 0U;
    assert(state.alarm_active == 0U);
}

/* SDS-SPO2-011: Process new SpO2 reading
 * Called every 1s from sensor task
 * Risk Control: RC-003 ensures alarm fires within ALARM_DEADLINE_MS
 */
alarm_result_t spo2_alarm_update(uint8_t spo2_value, uint32_t timestamp_ms) {
    assert(spo2_value <= SPO2_VALID_MAX);

    state.current_spo2 = spo2_value;

    /* Plausibility: SpO2 of 0 means sensor disconnected */
    if (spo2_value == 0U) {
        state.sensor_fault = 1U;
        alarm_manager_trigger(ALARM_TECHNICAL, PRIORITY_MEDIUM);
        return ALARM_SENSOR_FAULT;
    }

    state.sensor_fault = 0U;

    /* Critical low: immediate alarm, no debounce */
    if (spo2_value < SPO2_CRITICAL_LOW) {
        state.alarm_active = 1U;
        alarm_manager_trigger(ALARM_PHYSIOLOGICAL, PRIORITY_HIGH);
        display_driver_set_indicator(INDICATOR_SPO2_CRITICAL, 1U);
        return ALARM_CRITICAL;
    }

    /* Warning low: debounced alarm */
    if (spo2_value < SPO2_WARNING_LOW) {
        if (state.low_start_ms == 0U) {
            state.low_start_ms = timestamp_ms;
        }
        uint32_t elapsed = timestamp_ms - state.low_start_ms;
        assert(elapsed <= ALARM_DEADLINE_MS); /* Watchdog catches if exceeded */

        if (elapsed >= ALARM_DEBOUNCE_MS) {
            state.alarm_active = 1U;
            alarm_manager_trigger(ALARM_PHYSIOLOGICAL, PRIORITY_MEDIUM);
            return ALARM_WARNING;
        }
        return ALARM_PENDING;
    }

    /* Normal range: clear alarm */
    state.low_start_ms = 0U;
    if (state.alarm_active) {
        state.alarm_active = 0U;
        alarm_manager_clear(ALARM_PHYSIOLOGICAL);
        display_driver_set_indicator(INDICATOR_SPO2_CRITICAL, 0U);
    }
    return ALARM_NORMAL;
}
```

### Step 3: Generate Risk-Traced Unit Tests

```c
/* tests/unit/test_spo2_alarm.c
 * Traces to: RISK-HAZ-003 (Hypoxemia not detected)
 * Verifies: RC-003 (alarm within 10s)
 */

#include "unity.h"
#include "spo2_alarm_monitor.h"
#include "mock_alarm_manager.h"
#include "mock_display_driver.h"

void setUp(void) { spo2_alarm_init(); }
void tearDown(void) {}

/* TC-SPO2-001: Critical SpO2 triggers immediate alarm
 * Risk trace: RISK-HAZ-003 -> RC-003 */
void test_critical_spo2_triggers_immediate_alarm(void) {
    alarm_manager_trigger_Expect(ALARM_PHYSIOLOGICAL, PRIORITY_HIGH);
    display_driver_set_indicator_Expect(INDICATOR_SPO2_CRITICAL, 1U);
    alarm_result_t result = spo2_alarm_update(80, 1000);
    TEST_ASSERT_EQUAL(ALARM_CRITICAL, result);
}

/* TC-SPO2-002: Warning SpO2 debounces for 3 seconds */
void test_warning_spo2_debounces_correctly(void) {
    alarm_result_t r1 = spo2_alarm_update(88, 1000);
    TEST_ASSERT_EQUAL(ALARM_PENDING, r1);

    alarm_result_t r2 = spo2_alarm_update(88, 2000);
    TEST_ASSERT_EQUAL(ALARM_PENDING, r2);

    alarm_manager_trigger_Expect(ALARM_PHYSIOLOGICAL, PRIORITY_MEDIUM);
    alarm_result_t r3 = spo2_alarm_update(88, 4500);
    TEST_ASSERT_EQUAL(ALARM_WARNING, r3);
}

/* TC-SPO2-003: Sensor disconnect triggers technical alarm */
void test_sensor_disconnect_triggers_technical_alarm(void) {
    alarm_manager_trigger_Expect(ALARM_TECHNICAL, PRIORITY_MEDIUM);
    alarm_result_t result = spo2_alarm_update(0, 1000);
    TEST_ASSERT_EQUAL(ALARM_SENSOR_FAULT, result);
}

/* TC-SPO2-004: Recovery clears active alarm */
void test_recovery_clears_alarm(void) {
    alarm_manager_trigger_Expect(ALARM_PHYSIOLOGICAL, PRIORITY_HIGH);
    display_driver_set_indicator_Expect(INDICATOR_SPO2_CRITICAL, 1U);
    spo2_alarm_update(80, 1000);

    alarm_manager_clear_Expect(ALARM_PHYSIOLOGICAL);
    display_driver_set_indicator_Expect(INDICATOR_SPO2_CRITICAL, 0U);
    alarm_result_t result = spo2_alarm_update(96, 2000);
    TEST_ASSERT_EQUAL(ALARM_NORMAL, result);
}
```

### Step 4: Verify and Generate Compliance Report

```bash
# Build and run unit tests with coverage
ceedling test:all
gcovr --branches -r src/ --html-details docs/coverage_report.html

# Static analysis (MISRA C:2012)
cppcheck --enable=all --std=c11 --suppress=missingInclude src/
# Expected: 0 errors, 0 warnings on safety-critical modules

# SOUP inventory check
python3 tools/soup_checker.py requirements/soup_list.csv
# Verifies: all SOUP items have version, risk class, and anomaly list
```

## CLAUDE.md for Medical Device Firmware

```markdown
# IEC 62304 Medical Device Development

## Standards
- IEC 62304:2015 (Software Lifecycle)
- ISO 14971:2019 (Risk Management)
- IEC 60601-1 (Medical Electrical Equipment Safety)
- IEC 60601-1-8 (Alarm Systems)
- MISRA C:2012 for Class B/C software

## Safety Classes
- Class A: No injury possible — minimal docs
- Class B: Non-serious injury — unit testing required
- Class C: Death/serious injury — full lifecycle, MC/DC-level testing

## SOUP Tracking
- Every third-party library logged in soup_list.csv
- Fields: name, version, manufacturer, risk class, known anomalies, mitigations

## Testing Requirements
- Unit tests trace to SRS requirements via TC-XXX-NNN tags
- Risk control measures verified by specific test cases
- Regression suite runs on every commit (CI gate)

## Common Commands
- ceedling test:all — run unit tests with Unity + CMock
- gcovr --branches — branch coverage report
- cppcheck --enable=all — static analysis
- doxygen Doxyfile — generate design documentation
```

## Common Pitfalls

- **Alarm latency exceeding IEC 60601-1-8 limits:** The standard defines maximum alarm delay by priority. Claude Code checks that your debounce timers plus processing latency stay within the allowed window for each alarm condition.
- **SOUP version drift:** A pip install without pinning pulls a new version that is not in your SOUP list. Claude Code generates requirements.txt with exact version pins and validates against your SOUP inventory on every build.
- **Missing risk traceability:** Auditors check that every hazard in the risk table has a corresponding test case. Claude Code scans your test files for RISK-HAZ-NNN references and reports gaps against your ISO 14971 risk table.

## Related

- [Claude Code for Avionics DO-178C](/claude-code-avionics-do178c-development-2026/)
- [Claude Code for STM32 Firmware Development](/claude-code-stm32-firmware-development-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Claude Skills for Medical Records](/claude-skills-for-medical-records-processing/)
- [Chrome Enterprise Device Trust](/chrome-enterprise-device-trust-connector/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
