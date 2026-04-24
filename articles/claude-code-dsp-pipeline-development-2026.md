---
title: "Claude Code for DSP Pipeline"
permalink: /claude-code-dsp-pipeline-development-2026/
description: "Digital signal processing pipelines with Claude Code. Build FFT, FIR filters, and real-time audio chains in Python and C."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for DSP Pipelines

Digital signal processing code sits in an uncomfortable space between math and engineering. You need to translate filter specifications (passband ripple, stopband attenuation, transition bandwidth) into coefficient arrays, manage sample rate conversions without aliasing, and ensure real-time processing meets latency budgets. Off-by-one errors in buffer indexing create clicks in audio, ghost targets in radar, and corrupted symbols in communications.

Claude Code translates filter design specifications into working scipy/numpy pipelines, generates C implementations for embedded targets with fixed-point arithmetic, and catches the subtle normalization errors -- like forgetting to divide FFT output by N or using the wrong window function -- that produce technically valid but scientifically wrong results.

## The Workflow

### Step 1: DSP Development Setup

```bash
pip install numpy scipy matplotlib sounddevice
pip install pyfftw  # faster FFT via FFTW3 bindings
# For real-time embedded DSP
pip install cython  # for C code generation

mkdir -p src/filters src/transforms src/realtime tests/
```

### Step 2: Design and Implement a Filter Chain

```python
# src/filters/bandpass_filter.py
"""Bandpass filter design for EEG signal processing.
Target: extract alpha band (8-13 Hz) from raw EEG at 256 Hz sample rate.
"""

import numpy as np
from scipy import signal
from dataclasses import dataclass

@dataclass
class FilterSpec:
    fs: float          # Sample rate (Hz)
    f_low: float       # Lower cutoff (Hz)
    f_high: float      # Upper cutoff (Hz)
    order: int         # Filter order
    ripple_db: float   # Passband ripple (dB)
    atten_db: float    # Stopband attenuation (dB)

def design_bandpass_iir(spec: FilterSpec) -> tuple:
    """Design Butterworth bandpass IIR filter.
    Returns second-order sections (SOS) for numerical stability.
    """
    nyquist = spec.fs / 2.0
    assert spec.f_low > 0, "Low cutoff must be positive"
    assert spec.f_high < nyquist, f"High cutoff {spec.f_high} >= Nyquist {nyquist}"
    assert spec.f_low < spec.f_high, "Low cutoff must be below high cutoff"

    # Normalized frequencies (0 to 1 where 1 = Nyquist)
    low_norm = spec.f_low / nyquist
    high_norm = spec.f_high / nyquist

    # Design as SOS (second-order sections) to avoid numerical issues
    sos = signal.butter(spec.order, [low_norm, high_norm],
                        btype='band', output='sos')

    # Verify frequency response meets spec
    w, h = signal.sosfreqz(sos, worN=2048, fs=spec.fs)
    passband_mask = (w >= spec.f_low) & (w <= spec.f_high)
    passband_gain_db = 20 * np.log10(np.abs(h[passband_mask]) + 1e-12)

    assert np.all(passband_gain_db > -spec.ripple_db), \
        f"Passband ripple exceeds {spec.ripple_db} dB"

    return sos

def design_fir_bandpass(spec: FilterSpec, num_taps: int = 201) -> np.ndarray:
    """Design FIR bandpass using Parks-McClellan (equiripple).
    Better for fixed-point implementation on embedded targets.
    """
    nyquist = spec.fs / 2.0
    assert num_taps % 2 == 1, "Use odd number of taps for Type I FIR"

    # Frequency bands: [0, f_stop_low, f_low, f_high, f_stop_high, nyquist]
    transition_bw = 2.0  # Hz
    bands = [0, spec.f_low - transition_bw, spec.f_low,
             spec.f_high, spec.f_high + transition_bw, nyquist]
    desired = [0, 0, 1, 1, 0, 0]  # gain in each band
    weights = [10, 1, 10]  # heavier weight on stopband rejection

    coeffs = signal.remez(num_taps, bands, desired[::2],
                          weight=weights, fs=spec.fs)

    assert len(coeffs) == num_taps
    return coeffs

class RealTimeFilter:
    """Streaming filter for real-time sample-by-sample processing."""

    def __init__(self, sos: np.ndarray):
        self.sos = sos
        self.zi = signal.sosfilt_zi(sos)
        # Scale initial conditions to zero
        self.zi = self.zi * 0.0

    def process_block(self, block: np.ndarray) -> np.ndarray:
        """Filter a block of samples, maintaining state between calls."""
        assert block.ndim == 1, "Expected 1D array"
        filtered, self.zi = signal.sosfilt(self.sos, block, zi=self.zi)
        return filtered

# Usage
alpha_spec = FilterSpec(fs=256.0, f_low=8.0, f_high=13.0,
                        order=4, ripple_db=3.0, atten_db=40.0)
sos = design_bandpass_iir(alpha_spec)
filt = RealTimeFilter(sos)

# Process 1-second blocks
block = np.random.randn(256)  # simulated EEG
output = filt.process_block(block)
```

### Step 3: FFT Spectral Analysis Pipeline

```python
# src/transforms/spectral_analysis.py
"""Welch PSD estimation with proper windowing and overlap."""

import numpy as np
from scipy import signal as sig

def compute_psd_welch(data: np.ndarray, fs: float,
                      nperseg: int = 1024,
                      noverlap: int = 512,
                      window: str = 'hann') -> tuple:
    """Compute power spectral density using Welch's method.
    Returns (frequencies, psd) in Hz and V^2/Hz.
    """
    assert len(data) >= nperseg, \
        f"Signal length {len(data)} < segment length {nperseg}"
    assert noverlap < nperseg, "Overlap must be less than segment length"

    freqs, psd = sig.welch(data, fs=fs, nperseg=nperseg,
                           noverlap=noverlap, window=window,
                           scaling='density', detrend='constant')

    # Verify Parseval's theorem: total power should be close
    time_power = np.var(data)
    freq_power = np.trapz(psd, freqs)
    ratio = freq_power / (time_power + 1e-12)
    assert 0.9 < ratio < 1.1, \
        f"Parseval check failed: ratio={ratio:.3f}"

    return freqs, psd

def compute_spectrogram(data: np.ndarray, fs: float,
                        nperseg: int = 256,
                        noverlap: int = 128) -> tuple:
    """Short-time Fourier transform for time-frequency analysis."""
    freqs, times, Sxx = sig.spectrogram(
        data, fs=fs, nperseg=nperseg, noverlap=noverlap,
        window='hann', mode='psd'
    )
    # Convert to dB scale
    Sxx_db = 10 * np.log10(Sxx + 1e-12)
    return freqs, times, Sxx_db
```

### Step 4: Verify Filter Performance

```bash
python3 -c "
import numpy as np
from src.filters.bandpass_filter import design_bandpass_iir, FilterSpec, RealTimeFilter

spec = FilterSpec(fs=256.0, f_low=8.0, f_high=13.0, order=4, ripple_db=3.0, atten_db=40.0)
sos = design_bandpass_iir(spec)

# Test: 10 Hz sine (in passband) + 50 Hz sine (in stopband)
t = np.arange(0, 2, 1/256)
test_signal = np.sin(2*np.pi*10*t) + np.sin(2*np.pi*50*t)

filt = RealTimeFilter(sos)
output = filt.process_block(test_signal)

# Check: 50 Hz should be attenuated by > 30 dB
from scipy.signal import welch
f, psd = welch(output, fs=256, nperseg=256)
p10 = psd[np.argmin(np.abs(f-10))]
p50 = psd[np.argmin(np.abs(f-50))]
attenuation_db = 10*np.log10(p10/(p50+1e-12))
print(f'10 Hz power: {10*np.log10(p10):.1f} dB')
print(f'50 Hz power: {10*np.log10(p50):.1f} dB')
print(f'Attenuation: {attenuation_db:.1f} dB')
assert attenuation_db > 30, 'Insufficient stopband attenuation'
print('Filter verification: PASS')
"
```

## CLAUDE.md for DSP Development

```markdown
# DSP Pipeline Development

## Domain Rules
- Always use SOS (second-order sections) for IIR filters, never transfer function (b,a)
- Verify Parseval's theorem after any frequency-domain operation
- Window functions are mandatory before FFT (Hann for general, Blackman-Harris for spectral leakage)
- Fixed-point: track Q-format (e.g., Q1.15) through every multiply-accumulate
- Sample rate changes require anti-aliasing filters before decimation

## Libraries
- numpy 1.26+ (array operations)
- scipy.signal (filter design, spectral analysis)
- pyfftw 0.14+ (fast FFT)
- sounddevice 0.5+ (real-time audio I/O)
- matplotlib (spectral plots)

## File Patterns
- .wav — audio test signals
- .npy — numpy array snapshots
- .csv — filter coefficients for embedded export

## Common Commands
- python3 -c "from scipy.signal import freqz; ..." — quick filter response check
- sox input.wav -n stat — audio file statistics
- ffmpeg -i input.wav -ar 16000 output.wav — resample audio
- octave --eval "freqz(b,a)" — verify filter with Octave
```

## Common Pitfalls

- **Transfer function instability:** Using `signal.lfilter(b, a, ...)` with high-order IIR filters causes numerical overflow. Claude Code always generates SOS form and flags any code using the unstable b/a representation.
- **FFT normalization mismatch:** numpy's FFT returns unnormalized output; dividing by N gives amplitude, dividing by sqrt(N) gives energy. Claude Code tracks which convention your pipeline expects and applies the correct normalization.
- **Aliasing in decimation:** Downsampling without a low-pass anti-aliasing filter folds high-frequency content into the passband. Claude Code generates the proper `signal.decimate()` call with the correct filter order for your decimation ratio.

## Related

- [Claude Code for Radar Signal Processing](/claude-code-radar-signal-processing-2026/)
- [Claude Code for Neuroscience Data Analysis](/claude-code-neuroscience-mne-python-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
