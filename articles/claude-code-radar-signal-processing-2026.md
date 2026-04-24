---
title: "Claude Code for Radar Signal Processing"
permalink: /claude-code-radar-signal-processing-2026/
description: "Radar signal processing with Claude Code. Build pulse compression, CFAR detection, and Doppler processing pipelines."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for Radar Signal Processing

Radar signal processing chains multiple mathematically dense stages: pulse compression via matched filtering, moving target indication (MTI) for clutter rejection, Doppler FFT for velocity estimation, and CFAR (Constant False Alarm Rate) detection to set adaptive thresholds. Each stage has parameters tied to the radar's physical characteristics -- PRF, bandwidth, pulse width, antenna beamwidth -- and getting one wrong cascades errors through the entire chain.

Claude Code handles the range-Doppler math, generates matched filter coefficients from your waveform parameters, and builds CFAR detectors that adapt to your clutter environment. It bridges the gap between radar textbook equations and working numpy code that processes actual I/Q data.

## The Workflow

### Step 1: Radar Processing Setup

```bash
pip install numpy scipy matplotlib
pip install pyfftw  # FFTW3 bindings for fast FFT
pip install h5py    # for radar data files

mkdir -p src/radar src/waveforms src/detection tests/
```

### Step 2: Build a Pulse Compression Pipeline

```python
# src/radar/pulse_compression.py
"""Linear FM (chirp) pulse compression for pulsed Doppler radar.
Implements range processing via matched filtering.
"""

import numpy as np
from scipy import signal
from dataclasses import dataclass

@dataclass
class RadarParams:
    fc_ghz: float        # Carrier frequency
    bandwidth_mhz: float # Chirp bandwidth
    pulse_width_us: float # Pulse duration
    prf_hz: float        # Pulse repetition frequency
    fs_mhz: float        # ADC sample rate
    num_pulses: int      # Pulses per CPI (Coherent Processing Interval)

    @property
    def range_resolution_m(self) -> float:
        """Range resolution = c / (2 * BW)."""
        return 299.792458 / (2.0 * self.bandwidth_mhz)

    @property
    def max_unambiguous_range_m(self) -> float:
        """Rmax = c / (2 * PRF)."""
        return 299792458.0 / (2.0 * self.prf_hz)

    @property
    def max_unambiguous_velocity_mps(self) -> float:
        """Vmax = lambda * PRF / 4."""
        wavelength_m = 0.299792458 / self.fc_ghz
        return wavelength_m * self.prf_hz / 4.0

def generate_lfm_chirp(params: RadarParams) -> np.ndarray:
    """Generate Linear Frequency Modulated (LFM) chirp waveform."""
    num_samples = int(params.pulse_width_us * params.fs_mhz)
    t = np.arange(num_samples) / (params.fs_mhz * 1e6)
    chirp_rate = (params.bandwidth_mhz * 1e6) / (params.pulse_width_us * 1e-6)

    # Complex baseband chirp
    phase = np.pi * chirp_rate * t**2
    waveform = np.exp(1j * phase)

    assert len(waveform) == num_samples
    return waveform

def matched_filter(rx_signal: np.ndarray,
                   reference: np.ndarray) -> np.ndarray:
    """Apply matched filter (pulse compression) via frequency domain.
    Gain = time-bandwidth product (pulse compression ratio).
    """
    n_fft = len(rx_signal) + len(reference) - 1
    # Zero-pad to next power of 2 for efficient FFT
    n_fft = int(2**np.ceil(np.log2(n_fft)))

    RX = np.fft.fft(rx_signal, n=n_fft)
    REF = np.fft.fft(reference, n=n_fft)

    # Matched filter = correlation = conj(REF) * RX
    compressed = np.fft.ifft(RX * np.conj(REF))

    return compressed[:len(rx_signal)]

def range_doppler_map(iq_data: np.ndarray,
                      reference: np.ndarray,
                      params: RadarParams) -> np.ndarray:
    """Build range-Doppler map from CPI of pulses.
    iq_data: shape (num_pulses, samples_per_pulse)
    """
    assert iq_data.ndim == 2
    num_pulses, num_range_bins = iq_data.shape

    # Step 1: Range compression (matched filter per pulse)
    rd_map = np.zeros_like(iq_data, dtype=complex)
    for pulse_idx in range(num_pulses):
        rd_map[pulse_idx, :] = matched_filter(
            iq_data[pulse_idx, :], reference
        )

    # Step 2: Doppler FFT along pulse dimension (slow-time)
    window = np.hanning(num_pulses)
    for rng_bin in range(num_range_bins):
        rd_map[:, rng_bin] = np.fft.fftshift(
            np.fft.fft(rd_map[:, rng_bin] * window)
        )

    return rd_map
```

### Step 3: CFAR Detection

```python
# src/detection/cfar.py
"""Cell-Averaging CFAR detector for adaptive threshold."""

import numpy as np

def ca_cfar_1d(signal_db: np.ndarray,
               guard_cells: int = 4,
               training_cells: int = 16,
               pfa: float = 1e-6) -> np.ndarray:
    """Cell-Averaging CFAR detector.
    Returns boolean detection mask.
    """
    n = len(signal_db)
    assert guard_cells > 0, "Need at least 1 guard cell"
    assert training_cells > guard_cells, "Training cells must exceed guard cells"

    # CFAR threshold multiplier from desired Pfa
    # For CA-CFAR: alpha = N * (Pfa^(-1/N) - 1)
    N = 2 * training_cells
    alpha_linear = N * (pfa**(-1.0/N) - 1.0)
    alpha_db = 10.0 * np.log10(alpha_linear)

    detections = np.zeros(n, dtype=bool)
    half_window = guard_cells + training_cells

    for i in range(half_window, n - half_window):
        # Leading training cells
        lead_start = i - half_window
        lead_end = i - guard_cells
        leading = signal_db[lead_start:lead_end]

        # Lagging training cells
        lag_start = i + guard_cells + 1
        lag_end = i + half_window + 1
        lagging = signal_db[lag_start:lag_end]

        noise_estimate = np.mean(np.concatenate([leading, lagging]))
        threshold = noise_estimate + alpha_db

        if signal_db[i] > threshold:
            detections[i] = True

    return detections
```

### Step 4: Verify with Synthetic Target

```bash
python3 -c "
import numpy as np
from src.radar.pulse_compression import RadarParams, generate_lfm_chirp, range_doppler_map
from src.detection.cfar import ca_cfar_1d

params = RadarParams(fc_ghz=10.0, bandwidth_mhz=50.0, pulse_width_us=10.0,
                     prf_hz=1000.0, fs_mhz=100.0, num_pulses=64)

print(f'Range resolution: {params.range_resolution_m:.2f} m')
print(f'Max range: {params.max_unambiguous_range_m:.0f} m')

ref = generate_lfm_chirp(params)
samples_per_pulse = int(params.pulse_width_us * params.fs_mhz) * 4  # 4x overrange

# Inject synthetic target at range bin 300, Doppler bin 10
iq = np.random.randn(params.num_pulses, samples_per_pulse) * 0.01 + \
     1j * np.random.randn(params.num_pulses, samples_per_pulse) * 0.01
target_range = 300
target_doppler = 10
for p in range(params.num_pulses):
    phase = 2*np.pi*target_doppler*p/params.num_pulses
    iq[p, target_range:target_range+len(ref)] += 10.0 * ref * np.exp(1j*phase)

rd = range_doppler_map(iq, ref, params)
rd_db = 20*np.log10(np.abs(rd) + 1e-12)

peak = np.unravel_index(np.argmax(np.abs(rd)), rd.shape)
print(f'Peak at Doppler bin {peak[0]}, Range bin {peak[1]}')
assert abs(peak[1] - target_range) < 5, 'Range bin mismatch'
print('Radar processing: PASS')
"
```

## CLAUDE.md for Radar Signal Processing

```markdown
# Radar Signal Processing Standards

## Domain Rules
- Always apply windowing before Doppler FFT (Hann or Taylor)
- Matched filter length must equal transmitted pulse length
- CFAR guard cells must exceed mainlobe width of compressed pulse
- Range-Doppler coupling in LFM requires correction for moving targets
- Use fftshift for zero-Doppler centered display

## Libraries
- numpy 1.26+ (array math, FFT)
- scipy.signal (filter design, windowing)
- pyfftw 0.14+ (FFTW3 for large FFTs)
- h5py (HDF5 radar data format)
- matplotlib (range-Doppler plots)

## File Patterns
- .h5, .hdf5 — raw I/Q radar data
- .npy — processed range-Doppler maps
- .json — radar parameter configuration

## Common Commands
- python3 src/radar/pulse_compression.py — run range processing
- python3 src/detection/cfar.py — run CFAR detection
- ffmpeg -f rawvideo ... — convert raw I/Q to viewable format
- gnuradio-companion — SDR-based radar receive chain
```

## Common Pitfalls

- **Missing windowing before Doppler FFT:** Rectangular window creates -13 dB sidelobes that mask weak targets near strong ones. Claude Code inserts Hann or Taylor windowing by default and warns if you remove it.
- **CFAR guard cells too narrow:** If guard cells are narrower than the compressed pulse mainlobe, target energy leaks into training cells and raises the threshold. Claude Code calculates minimum guard cell count from your time-bandwidth product.
- **Range-Doppler coupling:** LFM waveforms shift the apparent range of moving targets proportional to their Doppler. Claude Code generates the keystone transform correction for high-speed target scenarios.

## Related

- [Claude Code for DSP Pipeline Development](/claude-code-dsp-pipeline-development-2026/)
- [Claude Code for Sonar Array Processing](/claude-code-sonar-array-processing-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Satellite Telemetry (2026)](/claude-code-satellite-telemetry-processing-2026/)
