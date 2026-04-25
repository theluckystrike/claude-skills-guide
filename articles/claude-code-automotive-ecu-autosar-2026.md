---
layout: default
title: "Claude Code for Automotive ECU AUTOSAR (2026)"
permalink: /claude-code-automotive-ecu-autosar-2026/
date: 2026-04-20
description: "Claude Code for Automotive ECU AUTOSAR — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Automotive ECU (AUTOSAR)

AUTOSAR Classic Platform wraps every ECU function in layers of XML configuration -- ARXML files that define Software Component Descriptions, port interfaces, runnables, and the RTE mapping between them. A single ECU extract can contain 50,000+ lines of ARXML that no human reads end-to-end. Engineers spend days clicking through DaVinci Configurator or EB tresos just to wire a new sensor reading through the BSW stack.

Claude Code parses ARXML structure, generates compliant Software Component descriptions, and produces the C stub code that matches your port interfaces. It understands the AUTOSAR layered architecture from Application SWC down through RTE to MCAL, and catches the configuration mismatches that cause cryptic runtime errors on target hardware.

## The Workflow

### Step 1: AUTOSAR Project Setup

```bash
# Typical AUTOSAR workspace structure
mkdir -p src/swc src/bsw src/rte config/arxml tests/sil
mkdir -p tools/generators output/generated

# ARXML schema validation
pip install lxml xmlschema
# Download AUTOSAR schema: AUTOSAR_00051.xsd (R22-11)
```

### Step 2: Generate a Software Component Description

Claude Code produces valid ARXML for a new Application SWC:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- config/arxml/BrakePressureSensor_swc.arxml -->
<!-- Generated with Claude Code — AUTOSAR R22-11 schema -->
<AUTOSAR xmlns="http://autosar.org/schema/r4.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <AR-PACKAGES>
    <AR-PACKAGE>
      <SHORT-NAME>BrakePressureSensor</SHORT-NAME>
      <ELEMENTS>
        <APPLICATION-SW-COMPONENT-TYPE>
          <SHORT-NAME>BrakePressureSensor</SHORT-NAME>
          <PORTS>
            <P-PORT-PROTOTYPE>
              <SHORT-NAME>PP_BrakePressure</SHORT-NAME>
              <PROVIDED-INTERFACE-TREF DEST="SENDER-RECEIVER-INTERFACE">
                /Interfaces/IF_BrakePressure
              </PROVIDED-INTERFACE-TREF>
            </P-PORT-PROTOTYPE>
            <R-PORT-PROTOTYPE>
              <SHORT-NAME>RP_RawADC</SHORT-NAME>
              <REQUIRED-INTERFACE-TREF DEST="SENDER-RECEIVER-INTERFACE">
                /Interfaces/IF_ADCValue
              </REQUIRED-INTERFACE-TREF>
            </R-PORT-PROTOTYPE>
          </PORTS>
          <INTERNAL-BEHAVIORS>
            <SWC-INTERNAL-BEHAVIOR>
              <SHORT-NAME>BrakePressureSensor_IB</SHORT-NAME>
              <RUNNABLES>
                <RUNNABLE-ENTITY>
                  <SHORT-NAME>RE_CalcBrakePressure</SHORT-NAME>
                  <MINIMUM-START-INTERVAL>0.01</MINIMUM-START-INTERVAL>
                  <CAN-BE-INVOKED-CONCURRENTLY>false</CAN-BE-INVOKED-CONCURRENTLY>
                  <DATA-READ-ACCESSS>
                    <VARIABLE-ACCESS>
                      <SHORT-NAME>DRA_RawADC</SHORT-NAME>
                      <ACCESSED-VARIABLE>
                        <AUTOSAR-VARIABLE-IREF>
                          <PORT-PROTOTYPE-REF DEST="R-PORT-PROTOTYPE">
                            RP_RawADC
                          </PORT-PROTOTYPE-REF>
                        </AUTOSAR-VARIABLE-IREF>
                      </ACCESSED-VARIABLE>
                    </VARIABLE-ACCESS>
                  </DATA-READ-ACCESSS>
                </RUNNABLE-ENTITY>
              </RUNNABLES>
            </SWC-INTERNAL-BEHAVIOR>
          </INTERNAL-BEHAVIORS>
        </APPLICATION-SW-COMPONENT-TYPE>
      </ELEMENTS>
    </AR-PACKAGE>
  </AR-PACKAGES>
</AUTOSAR>
```

### Step 3: Implement the SWC Runnable in C

```c
/* src/swc/BrakePressureSensor.c
 * AUTOSAR SWC implementation
 * Runnable: RE_CalcBrakePressure (10ms periodic)
 * ASIL: D (Brake system, safety-critical)
 */

#include "Rte_BrakePressureSensor.h"
#include <assert.h>

/* Calibration constants — typically from A2L/XCP */
#define ADC_RESOLUTION      4096U
#define SENSOR_MIN_BAR      0.0f
#define SENSOR_MAX_BAR      200.0f
#define ADC_MIN_VALID       205U   /* 0.5V at 3.3V ref = short-circuit detect */
#define ADC_MAX_VALID       3891U  /* 4.5V equivalent = open-circuit detect */

static float adc_to_pressure(uint16 raw_adc) {
    assert(raw_adc <= ADC_RESOLUTION);

    float normalized = (float)(raw_adc - ADC_MIN_VALID)
                     / (float)(ADC_MAX_VALID - ADC_MIN_VALID);
    float pressure = SENSOR_MIN_BAR + normalized * (SENSOR_MAX_BAR - SENSOR_MIN_BAR);

    /* Clamp to valid range */
    if (pressure < SENSOR_MIN_BAR) { pressure = SENSOR_MIN_BAR; }
    if (pressure > SENSOR_MAX_BAR) { pressure = SENSOR_MAX_BAR; }

    assert(pressure >= SENSOR_MIN_BAR && pressure <= SENSOR_MAX_BAR);
    return pressure;
}

FUNC(void, BrakePressureSensor_CODE) RE_CalcBrakePressure(void) {
    Std_ReturnType status;
    uint16 raw_adc = 0U;
    float brake_pressure = 0.0f;

    /* Read raw ADC via RTE */
    status = Rte_Read_RP_RawADC_value(&raw_adc);

    if (status == RTE_E_OK) {
        /* Plausibility check: detect sensor wire faults */
        if ((raw_adc >= ADC_MIN_VALID) && (raw_adc <= ADC_MAX_VALID)) {
            brake_pressure = adc_to_pressure(raw_adc);
            (void)Rte_Write_PP_BrakePressure_value(brake_pressure);
            (void)Rte_Write_PP_BrakePressure_status(SIGNAL_VALID);
        } else {
            /* Out of range: sensor fault */
            (void)Rte_Write_PP_BrakePressure_status(SIGNAL_FAULT);
            Dem_ReportErrorStatus(DTC_BRAKE_SENSOR_RANGE, DEM_EVENT_STATUS_FAILED);
        }
    } else {
        (void)Rte_Write_PP_BrakePressure_status(SIGNAL_TIMEOUT);
    }
}
```

### Step 4: Verify with SIL Test

```bash
# Software-in-the-loop test using AUTOSAR SIL adapter
cd tests/sil
gcc -DSIL_TESTING -I../../output/generated -I../../src/swc \
    -o test_brake test_brake_pressure.c ../../src/swc/BrakePressureSensor.c \
    -lm -lunity
./test_brake
# Expected: All 8 test vectors PASS (nominal, boundary, fault injection)

# ARXML schema validation
python3 -c "
from lxml import etree
schema = etree.XMLSchema(etree.parse('tools/AUTOSAR_00051.xsd'))
doc = etree.parse('config/arxml/BrakePressureSensor_swc.arxml')
assert schema.validate(doc), schema.error_log
print('ARXML validation: PASS')
"
```

## CLAUDE.md for Automotive ECU (AUTOSAR)

```markdown
# AUTOSAR ECU Development

## Standards
- AUTOSAR Classic Platform R22-11
- ISO 26262 (Functional Safety) — ASIL A-D
- MISRA C:2012 (mandatory for ASIL C/D)
- ISO 11898 (CAN), ISO 17458 (FlexRay)

## File Patterns
- .arxml — AUTOSAR XML descriptions (SWC, BSW config, ECU extract)
- .c/.h — SWC implementation, BSW modules
- .a2l — calibration description (ASAM MCD-2MC)
- .dbc — CAN database
- .xdm — EB tresos configuration

## Libraries
- Rte_*.h — generated RTE headers
- Dem.h — Diagnostic Event Manager
- NvM.h — NVRAM Manager
- Com.h — AUTOSAR COM module

## Common Commands
- davinci_cfg --generate — regenerate RTE from ARXML
- tresos generate — EB tresos BSW generation
- gcc -DSIL_TESTING — software-in-the-loop build
- candump can0 — monitor CAN bus (SocketCAN)
- python-can decode — parse DBC and decode CAN frames
```

## Common Pitfalls

- **RTE port mismatch:** The ARXML port interface does not match the generated Rte_Read/Write signature. Claude Code validates port names and data types across ARXML and C code to catch mismatches before compilation.
- **Missing DEM error reports:** ASIL-rated SWCs must report diagnostic events for every detectable fault. Claude Code checks that each error path calls Dem_ReportErrorStatus with the correct DTC.
- **Runnable timing violations:** A 10ms runnable that takes 12ms causes AUTOSAR OS ProtectionHook. Claude Code estimates WCET from code complexity and flags runnables that may exceed their budget.

## Related

- [Claude Code for STM32 Firmware Development](/claude-code-stm32-firmware-development-2026/)
- [Claude Code for Avionics DO-178C](/claude-code-avionics-do178c-development-2026/)
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



## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions

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
