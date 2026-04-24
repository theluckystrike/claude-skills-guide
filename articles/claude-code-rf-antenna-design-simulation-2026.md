---
title: "Claude Code for RF Antenna Design"
permalink: /claude-code-rf-antenna-design-simulation-2026/
description: "RF antenna design simulation with Claude Code. Automate NEC2 modeling, S-parameter analysis, and radiation patterns."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for RF Antenna Design

Antenna design is one of the few engineering disciplines where intuition consistently fails. A quarter-wave monopole that works perfectly at 2.4 GHz becomes a terrible radiator when you add a ground plane with the wrong dimensions. NEC2 and openEMS simulation files require precise geometry definitions in wavelength-relative coordinates, and a single misplaced wire segment invalidates the entire model.

Claude Code generates NEC2 card decks and openEMS FDTD scripts from plain English specifications, calculates geometry from frequency targets, and produces post-processing scripts that extract gain, VSWR, impedance, and radiation patterns. It handles the coordinate math that trips up even experienced RF engineers.

## The Workflow

### Step 1: Simulation Environment Setup

```bash
# NEC2 engine (method of moments)
brew install nec2c || sudo apt-get install nec2c
# openEMS (FDTD full-wave simulator)
pip install openEMS CSXCAD
# Python analysis tools
pip install scikit-rf matplotlib numpy

mkdir -p models/ results/ scripts/
```

### Step 2: Generate a Dipole Antenna Model

```python
# models/dipole_2_4ghz.py
"""Half-wave dipole for 2.4 GHz WiFi.
Generates NEC2 card deck with proper segmentation.
"""

import numpy as np

FREQ_MHZ = 2440.0
C_MMS = 299792.458       # speed of light in mm/s * 1e-6
WAVELENGTH_MM = C_MMS / FREQ_MHZ  # ~122.87 mm
HALF_WAVE_MM = WAVELENGTH_MM / 2.0

# NEC2 rule: segment length < lambda/10 for accurate results
NUM_SEGMENTS = 21  # odd number, feed at center
SEGMENT_LENGTH = HALF_WAVE_MM / NUM_SEGMENTS
assert SEGMENT_LENGTH < WAVELENGTH_MM / 10, "Segments too long for accuracy"

WIRE_RADIUS_MM = 0.5  # 1mm diameter wire

def generate_nec2_deck() -> str:
    """Generate NEC2 input file for half-wave dipole."""
    half_length = HALF_WAVE_MM / 2.0
    feed_segment = (NUM_SEGMENTS + 1) // 2  # center segment

    nec = []
    nec.append("CM Half-wave dipole for 2.4 GHz WiFi")
    nec.append("CM Generated with Claude Code")
    nec.append("CE")

    # GW card: Wire geometry
    # GW tag segments x1 y1 z1 x2 y2 z2 radius
    nec.append(f"GW 1 {NUM_SEGMENTS} 0.0 0.0 {-half_length:.4f} "
               f"0.0 0.0 {half_length:.4f} {WIRE_RADIUS_MM:.4f}")

    # GE card: End geometry
    nec.append("GE 0")

    # EX card: Voltage source at center segment
    # EX type tag segment real imag
    nec.append(f"EX 0 1 {feed_segment} 0 1.0 0.0")

    # FR card: Frequency sweep
    nec.append("FR 0 50 0 0 2200.0 10.0")  # 2200-2690 MHz, 10 MHz steps

    # RP card: Radiation pattern (theta 0-180, phi 0-360)
    nec.append("RP 0 37 73 1000 0.0 0.0 5.0 5.0")

    # EN card: End of input
    nec.append("EN")

    return "\n".join(nec)

def write_nec2_file(path: str = "models/dipole_2_4ghz.nec") -> None:
    deck = generate_nec2_deck()
    with open(path, 'w') as f:
        f.write(deck)
    print(f"NEC2 deck written: {path}")
    print(f"Design frequency: {FREQ_MHZ} MHz")
    print(f"Wavelength: {WAVELENGTH_MM:.2f} mm")
    print(f"Element length: {HALF_WAVE_MM:.2f} mm")
    print(f"Segments: {NUM_SEGMENTS}, length: {SEGMENT_LENGTH:.2f} mm")

if __name__ == "__main__":
    write_nec2_file()
```

### Step 3: S-Parameter Analysis with scikit-rf

```python
# scripts/analyze_antenna.py
"""Post-process NEC2 output and compute S-parameters, VSWR, gain."""

import numpy as np
import skrf as rf
from dataclasses import dataclass

@dataclass
class AntennaMetrics:
    freq_ghz: np.ndarray
    impedance: np.ndarray       # complex, ohms
    s11_db: np.ndarray
    vswr: np.ndarray
    gain_dbi: float             # peak gain at design frequency

def parse_nec2_impedance(output_path: str) -> tuple:
    """Parse NEC2 output file for input impedance vs frequency."""
    freqs = []
    impedances = []

    with open(output_path, 'r') as f:
        in_impedance_section = False
        for line in f:
            if "ANTENNA INPUT PARAMETERS" in line:
                in_impedance_section = True
                continue
            if in_impedance_section and line.strip():
                parts = line.split()
                if len(parts) >= 7:
                    try:
                        freq = float(parts[1])  # MHz
                        r = float(parts[4])
                        x = float(parts[5])
                        freqs.append(freq)
                        impedances.append(complex(r, x))
                    except (ValueError, IndexError):
                        continue

    return np.array(freqs), np.array(impedances)

def compute_metrics(freqs_mhz: np.ndarray,
                    impedance: np.ndarray,
                    z0: float = 50.0) -> AntennaMetrics:
    """Compute S11, VSWR from impedance data."""
    # Reflection coefficient
    gamma = (impedance - z0) / (impedance + z0)
    s11_db = 20 * np.log10(np.abs(gamma) + 1e-12)

    # VSWR
    rho = np.abs(gamma)
    vswr = (1 + rho) / (1 - rho + 1e-12)

    # Bandwidth: frequencies where S11 < -10 dB
    bw_mask = s11_db < -10.0
    if np.any(bw_mask):
        bw_freqs = freqs_mhz[bw_mask]
        bw_mhz = bw_freqs[-1] - bw_freqs[0]
    else:
        bw_mhz = 0.0

    assert np.min(s11_db) < -10, "Antenna not matched: S11 never below -10 dB"

    return AntennaMetrics(
        freq_ghz=freqs_mhz / 1000.0,
        impedance=impedance,
        s11_db=s11_db,
        vswr=vswr,
        gain_dbi=2.15  # theoretical dipole gain
    )
```

### Step 4: Run Simulation and Verify

```bash
# Run NEC2 simulation
python3 models/dipole_2_4ghz.py
nec2c -i models/dipole_2_4ghz.nec -o results/dipole_output.txt

# Verify results
python3 -c "
from scripts.analyze_antenna import parse_nec2_impedance, compute_metrics
freqs, Z = parse_nec2_impedance('results/dipole_output.txt')
metrics = compute_metrics(freqs, Z)

idx_2440 = (abs(freqs - 2440)).argmin()
print(f'At 2440 MHz:')
print(f'  Impedance: {Z[idx_2440].real:.1f} + j{Z[idx_2440].imag:.1f} ohms')
print(f'  S11: {metrics.s11_db[idx_2440]:.1f} dB')
print(f'  VSWR: {metrics.vswr[idx_2440]:.2f}')
assert metrics.vswr[idx_2440] < 2.0, 'VSWR too high at design frequency'
print('Antenna verification: PASS')
"
```

## CLAUDE.md for RF Antenna Design

```markdown
# RF Antenna Design Standards

## Domain Rules
- Segment length < lambda/10 for NEC2 accuracy
- Wire radius < segment_length/4 to avoid thin-wire approximation breakdown
- Always include ground plane model for monopole antennas
- S11 < -10 dB (VSWR < 2:1) is minimum match criterion
- Far-field pattern valid only at r > 2*D^2/lambda (Fraunhofer distance)

## File Patterns
- .nec — NEC2 input card deck
- .s1p, .s2p — Touchstone S-parameter files
- .stl — 3D geometry for openEMS import

## Libraries
- nec2c (NEC2 engine, MoM solver)
- openEMS + CSXCAD (FDTD full-wave)
- scikit-rf (S-parameter manipulation)
- numpy, matplotlib (data analysis, plotting)

## Common Commands
- nec2c -i model.nec -o output.txt — run NEC2 simulation
- python3 -m openEMS — run FDTD simulation
- skrf.Network('antenna.s1p').plot_s_db() — plot S-parameters
- octave --eval "smithchart(Z)" — Smith chart visualization
```

## Common Pitfalls

- **Segmentation too coarse:** NEC2 silently produces wrong results if segments exceed lambda/10. Claude Code calculates the maximum segment length from your design frequency and asserts the constraint before generating the card deck.
- **Feed point impedance mismatch:** The feed segment must be at the geometric center of a dipole. Off-center feeding shifts the impedance and introduces unwanted reactive components. Claude Code enforces center-fed geometry for symmetric antennas.
- **Ground plane neglect:** Free-space dipole simulations report 2.15 dBi gain, but placing the antenna near a PCB ground plane changes the pattern dramatically. Claude Code adds a ground plane model matching your PCB dimensions when specified.

## Related

- [Claude Code for DSP Pipeline Development](/claude-code-dsp-pipeline-development-2026/)
- [Claude Code for Radar Signal Processing](/claude-code-radar-signal-processing-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for VHDL Synthesis and Simulation (2026)](/claude-code-vhdl-synthesis-simulation-2026/)
