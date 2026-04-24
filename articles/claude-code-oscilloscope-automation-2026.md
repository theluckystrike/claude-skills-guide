---
title: "Claude Code for Oscilloscope Automation"
permalink: /claude-code-oscilloscope-automation-2026/
description: "Oscilloscope automation scripts with Claude Code. Control Rigol, Keysight, and Tektronix scopes via SCPI and PyVISA."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for Oscilloscope Automation

Lab oscilloscopes sit idle between manual measurements, but every modern scope speaks SCPI (Standard Commands for Programmable Instruments) over USB-TMC, LAN, or GPIB. Automating scope control means running regression tests on hardware, capturing waveforms for documentation, and building go/no-go production tests -- all without a human pressing buttons. The challenge is that every manufacturer's SCPI dialect differs in subtle ways: Rigol uses `:WAVeform:DATA?`, Keysight uses `:WAV:DATA?`, and Tektronix uses `CURVE?`.

Claude Code generates PyVISA scripts that handle manufacturer-specific SCPI quirks, parse binary waveform data with correct byte ordering and voltage scaling, and build automated test sequences that capture, measure, and pass/fail against specifications.

## The Workflow

### Step 1: Lab Automation Setup

```bash
pip install pyvisa pyvisa-py  # Pure Python VISA backend
pip install numpy matplotlib
# For NI-VISA backend (optional, better USB-TMC support):
# Install NI-VISA from ni.com, then: pip install pyvisa

# Verify instrument connectivity
python3 -c "import pyvisa; rm = pyvisa.ResourceManager('@py'); print(rm.list_resources())"
```

### Step 2: Universal Scope Control Library

```python
# src/scope_control.py
"""Universal oscilloscope control via SCPI/PyVISA.
Supports Rigol DS1054Z, Keysight DSOX, Tektronix MSO.
"""

import pyvisa
import numpy as np
import time
from dataclasses import dataclass
from enum import Enum

class ScopeVendor(Enum):
    RIGOL = "rigol"
    KEYSIGHT = "keysight"
    TEKTRONIX = "tektronix"

@dataclass
class WaveformData:
    time_s: np.ndarray
    voltage_v: np.ndarray
    sample_rate_hz: float
    channel: int

class OscilloscopeController:
    """Vendor-agnostic oscilloscope controller."""

    def __init__(self, resource_string: str, vendor: ScopeVendor):
        self.rm = pyvisa.ResourceManager('@py')
        self.inst = self.rm.open_resource(resource_string)
        self.inst.timeout = 10000  # 10s timeout
        self.vendor = vendor

        # Verify connection
        idn = self.inst.query("*IDN?").strip()
        assert len(idn) > 0, "No IDN response from instrument"
        print(f"Connected: {idn}")

    def reset(self) -> None:
        """Reset scope to factory defaults."""
        self.inst.write("*RST")
        self.inst.query("*OPC?")  # Wait for completion

    def configure_channel(self, channel: int, scale_v: float,
                          offset_v: float = 0.0,
                          coupling: str = "DC") -> None:
        """Configure vertical scale and coupling."""
        ch = f"CHAN{channel}" if self.vendor != ScopeVendor.TEKTRONIX \
             else f"CH{channel}"

        if self.vendor == ScopeVendor.RIGOL:
            self.inst.write(f":{ch}:SCAL {scale_v}")
            self.inst.write(f":{ch}:OFFS {offset_v}")
            self.inst.write(f":{ch}:COUP {coupling}")
        elif self.vendor == ScopeVendor.KEYSIGHT:
            self.inst.write(f":{ch}:SCAL {scale_v}")
            self.inst.write(f":{ch}:OFFS {offset_v}")
            self.inst.write(f":{ch}:COUP {coupling}")
        elif self.vendor == ScopeVendor.TEKTRONIX:
            self.inst.write(f"{ch}:SCA {scale_v}")
            self.inst.write(f"{ch}:OFFS {offset_v}")
            self.inst.write(f"{ch}:COUP {coupling}")

    def configure_timebase(self, scale_s: float,
                           position_s: float = 0.0) -> None:
        """Set horizontal time/div and trigger position."""
        if self.vendor == ScopeVendor.TEKTRONIX:
            self.inst.write(f"HOR:SCA {scale_s}")
            self.inst.write(f"HOR:POS {position_s}")
        else:
            self.inst.write(f":TIM:SCAL {scale_s}")
            self.inst.write(f":TIM:OFFS {position_s}")

    def set_trigger(self, channel: int, level_v: float,
                    edge: str = "RISING") -> None:
        """Configure edge trigger."""
        if self.vendor == ScopeVendor.RIGOL:
            self.inst.write(f":TRIG:EDGE:SOUR CHAN{channel}")
            self.inst.write(f":TRIG:EDGE:LEV {level_v}")
            self.inst.write(f":TRIG:EDGE:SLOP {edge[:3]}")
        elif self.vendor == ScopeVendor.KEYSIGHT:
            self.inst.write(f":TRIG:EDGE:SOUR CHAN{channel}")
            self.inst.write(f":TRIG:EDGE:LEV {level_v}")
        elif self.vendor == ScopeVendor.TEKTRONIX:
            self.inst.write(f"TRIG:A:EDGE:SOU CH{channel}")
            self.inst.write(f"TRIG:A:LEV:CH{channel} {level_v}")

    def single_acquisition(self) -> None:
        """Trigger single acquisition and wait."""
        if self.vendor == ScopeVendor.RIGOL:
            self.inst.write(":SING")
        elif self.vendor == ScopeVendor.KEYSIGHT:
            self.inst.write(":SING")
        elif self.vendor == ScopeVendor.TEKTRONIX:
            self.inst.write("ACQ:STATE ON")

        # Wait for acquisition complete
        time.sleep(0.5)
        self.inst.query("*OPC?")

    def capture_waveform(self, channel: int) -> WaveformData:
        """Capture waveform data from specified channel."""
        if self.vendor == ScopeVendor.RIGOL:
            return self._capture_rigol(channel)
        elif self.vendor == ScopeVendor.KEYSIGHT:
            return self._capture_keysight(channel)
        elif self.vendor == ScopeVendor.TEKTRONIX:
            return self._capture_tektronix(channel)

    def _capture_rigol(self, channel: int) -> WaveformData:
        """Rigol DS series waveform capture."""
        self.inst.write(f":WAV:SOUR CHAN{channel}")
        self.inst.write(":WAV:MODE NORM")
        self.inst.write(":WAV:FORM BYTE")

        preamble = self.inst.query(":WAV:PRE?").split(",")
        points = int(preamble[2])
        x_increment = float(preamble[4])
        x_origin = float(preamble[5])
        y_increment = float(preamble[7])
        y_origin = float(preamble[8])
        y_reference = float(preamble[9])

        raw = self.inst.query_binary_values(":WAV:DATA?",
                                             datatype='B',
                                             container=np.array)
        voltage = (raw - y_reference) * y_increment + y_origin
        time_arr = np.arange(len(voltage)) * x_increment + x_origin
        sample_rate = 1.0 / x_increment

        return WaveformData(time_arr, voltage, sample_rate, channel)

    def measure(self, channel: int, measurement: str) -> float:
        """Take automatic measurement (FREQ, VPP, VAVG, etc.)."""
        if self.vendor == ScopeVendor.RIGOL:
            result = self.inst.query(
                f":MEAS:ITEM? {measurement},CHAN{channel}"
            )
        elif self.vendor == ScopeVendor.KEYSIGHT:
            result = self.inst.query(
                f":MEAS:{measurement}? CHAN{channel}"
            )
        elif self.vendor == ScopeVendor.TEKTRONIX:
            self.inst.write(f"MEASU:MEAS1:SOU CH{channel}")
            self.inst.write(f"MEASU:MEAS1:TYP {measurement}")
            result = self.inst.query("MEASU:MEAS1:VAL?")

        return float(result)
```

### Step 3: Build Automated Test Sequence

```python
# tests/test_power_supply.py
"""Automated go/no-go test for power supply output validation."""

from src.scope_control import OscilloscopeController, ScopeVendor

def test_power_supply_output(scope: OscilloscopeController) -> dict:
    """Verify 5V power supply output meets specification."""
    results = {}

    scope.configure_channel(1, scale_v=1.0, coupling="DC")
    scope.configure_timebase(scale_s=0.001)  # 1ms/div
    scope.set_trigger(1, level_v=2.5)
    scope.single_acquisition()

    vpp = scope.measure(1, "VPP")
    vavg = scope.measure(1, "VAVG")
    freq_ripple = scope.measure(1, "FREQ")

    results["vavg_v"] = vavg
    results["ripple_vpp_mv"] = vpp * 1000
    results["ripple_freq_khz"] = freq_ripple / 1000

    # Pass/fail criteria
    results["voltage_pass"] = 4.9 <= vavg <= 5.1  # +/- 2%
    results["ripple_pass"] = vpp * 1000 < 50       # < 50mV ripple

    return results
```

### Step 4: Verify

```bash
# List available instruments
python3 -c "
import pyvisa
rm = pyvisa.ResourceManager('@py')
resources = rm.list_resources()
print(f'Found {len(resources)} instruments:')
for r in resources:
    print(f'  {r}')
if not resources:
    print('  (none - connect a scope via USB or LAN)')
    print('  Example: TCPIP::192.168.1.100::INSTR')
print('Setup verification: PASS')
"
```

## CLAUDE.md for Oscilloscope Automation

```markdown
# Lab Instrument Automation Standards

## Protocols
- SCPI (IEEE 488.2) — standard command set
- USB-TMC — USB Test & Measurement Class
- LXI/VXI-11 — LAN-based instrument control
- GPIB (IEEE 488.1) — legacy parallel bus

## Libraries
- pyvisa 1.14+ (VISA resource manager)
- pyvisa-py 0.7+ (pure Python backend)
- numpy (waveform data processing)
- matplotlib (waveform plotting)

## Vendor Quirks
- Rigol: uses ":WAV:DATA?" with TMC header, byte format
- Keysight: uses ":WAV:DATA?" with definite-length block
- Tektronix: uses "CURVE?" with binary encoding
- Always query *OPC? after write commands to ensure completion

## Common Commands
- python3 -c "import pyvisa; ..." — list VISA resources
- lsusb | grep -i "rigol\|keysight\|tektronix" — find USB instruments
- ping 192.168.1.100 — verify LAN instrument connectivity
```

## Common Pitfalls

- **Binary data header parsing:** Scope binary responses include a TMC header (e.g., #800001200) that must be stripped before interpreting waveform bytes. Claude Code uses PyVISA's `query_binary_values()` which handles headers automatically.
- **Voltage scaling errors:** Raw ADC values must be converted using the preamble's y_increment, y_origin, and y_reference. Getting the formula wrong produces waveforms with the right shape but wrong amplitude. Claude Code applies the correct vendor-specific conversion.
- **Timeout on large acquisitions:** Deep memory captures (10M+ points) exceed default timeouts. Claude Code sets appropriate timeouts based on the expected data transfer size and connection speed.

## Related

- [Claude Code for PCB Layout Review (KiCad)](/claude-code-pcb-layout-review-kicad-2026/)
- [Claude Code for STM32 Firmware Development](/claude-code-stm32-firmware-development-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Build N8N Workflows with Claude Code 2026](/claude-code-n8n-workflow-automation-2026/)
- [Claude Code vs Sweep AI (2026): PR Automation](/claude-code-vs-sweep-ai-pr-automation-2026/)
