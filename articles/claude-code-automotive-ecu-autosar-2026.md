---
title: "Claude Code for Automotive ECU AUTOSAR"
permalink: /claude-code-automotive-ecu-autosar-2026/
description: "Automotive ECU development with Claude Code and AUTOSAR. Generate SWC descriptions, RTE configs, and BSW modules."
last_tested: "2026-04-22"
render_with_liquid: false
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
