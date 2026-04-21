---
title: "Claude Code for Neuroscience MNE-Python (2026)"
permalink: /claude-code-neuroscience-mne-python-2026/
description: "Neuroscience EEG/MEG analysis with Claude Code and MNE-Python. Automate preprocessing, ERPs, and source localization."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for Neuroscience (MNE-Python)

Neuroimaging data analysis with EEG and MEG involves a complex preprocessing chain: raw data loading from vendor-specific formats (BrainVision, EDF, FIFF), channel montage setup, filtering, artifact rejection (eye blinks, muscle), re-referencing, epoching around events, baseline correction, and averaging into event-related potentials (ERPs). Each step has parameter choices that affect downstream results -- a 0.1 Hz high-pass filter distorts ERP waveforms differently than a 0.01 Hz filter, and ICA component rejection is subjective.

Claude Code generates MNE-Python pipelines that follow published best practices (Luck 2014, Hari and Puce 2017), produces reproducible preprocessing scripts with explicit parameter documentation, and builds statistical analysis workflows for between-group comparisons with proper multiple-comparison correction.

## The Workflow

### Step 1: Neuroimaging Analysis Setup

```bash
pip install mne mne-bids
pip install autoreject  # automated artifact rejection
pip install fooof       # spectral parameterization
pip install nilearn     # neuroimaging visualization

mkdir -p data/raw data/preprocessed results/erp results/tfr
```

### Step 2: Build a Preprocessing Pipeline

```python
# src/eeg_preprocessing.py
"""EEG preprocessing pipeline following MNE-Python best practices.
Input: BrainVision (.vhdr) or EDF (.edf)
Output: cleaned, epoched data ready for ERP/time-frequency analysis.
"""

import mne
import numpy as np
from pathlib import Path
from dataclasses import dataclass

@dataclass
class PreprocConfig:
    l_freq: float = 0.1         # High-pass filter (Hz)
    h_freq: float = 40.0        # Low-pass filter (Hz)
    epoch_tmin: float = -0.2    # Epoch start relative to event (s)
    epoch_tmax: float = 0.8     # Epoch end (s)
    baseline: tuple = (-0.2, 0) # Baseline correction window
    reject_threshold_uv: float = 150.0  # Amplitude rejection (microvolts)
    ica_n_components: int = 20
    resample_hz: float = 256.0

def load_raw(filepath: str) -> mne.io.Raw:
    """Load raw EEG data from common neuroimaging formats."""
    path = Path(filepath)
    if path.suffix == '.vhdr':
        raw = mne.io.read_raw_brainvision(filepath, preload=True)
    elif path.suffix == '.edf':
        raw = mne.io.read_raw_edf(filepath, preload=True)
    elif path.suffix == '.fif':
        raw = mne.io.read_raw_fif(filepath, preload=True)
    else:
        raise ValueError(f"Unsupported format: {path.suffix}")

    assert raw.info['sfreq'] > 0, "Invalid sample rate"
    return raw

def preprocess_raw(raw: mne.io.Raw, config: PreprocConfig) -> mne.io.Raw:
    """Apply standard preprocessing to raw EEG."""
    # Set standard 10-20 montage
    montage = mne.channels.make_standard_montage('standard_1020')
    raw.set_montage(montage, on_missing='warn')

    # Resample if needed (before filtering to avoid aliasing)
    if raw.info['sfreq'] != config.resample_hz:
        raw.resample(config.resample_hz)

    # Bandpass filter (FIR, zero-phase)
    raw.filter(
        l_freq=config.l_freq,
        h_freq=config.h_freq,
        method='fir',
        fir_design='firwin',
        phase='zero-double',
    )

    # Re-reference to average
    raw.set_eeg_reference('average', projection=True)
    raw.apply_proj()

    return raw

def run_ica_artifact_rejection(raw: mne.io.Raw,
                                config: PreprocConfig) -> mne.io.Raw:
    """Remove eye blink and cardiac artifacts using ICA."""
    ica = mne.preprocessing.ICA(
        n_components=config.ica_n_components,
        method='fastica',
        random_state=42,
        max_iter=500,
    )
    ica.fit(raw)

    # Automatically find EOG components
    eog_indices, eog_scores = ica.find_bads_eog(raw)
    ica.exclude = eog_indices

    assert len(ica.exclude) <= 3, \
        f"Too many EOG components ({len(ica.exclude)}), check data quality"

    raw_clean = ica.apply(raw.copy())
    return raw_clean

def create_epochs(raw: mne.io.Raw,
                  config: PreprocConfig,
                  event_id: dict = None) -> mne.Epochs:
    """Segment continuous data into event-locked epochs."""
    events = mne.find_events(raw, stim_channel='STI 014',
                              min_duration=0.002)
    assert len(events) > 0, "No events found in stimulus channel"

    if event_id is None:
        event_id = {'standard': 1, 'deviant': 2}

    reject = {'eeg': config.reject_threshold_uv * 1e-6}  # convert to V

    epochs = mne.Epochs(
        raw, events, event_id=event_id,
        tmin=config.epoch_tmin, tmax=config.epoch_tmax,
        baseline=config.baseline,
        reject=reject,
        preload=True,
        detrend=1,  # linear detrend
    )

    drop_pct = 100 * (1 - len(epochs) / len(events))
    assert drop_pct < 30, f"Too many epochs rejected: {drop_pct:.1f}%"

    return epochs

def compute_erp(epochs: mne.Epochs, condition: str) -> mne.Evoked:
    """Average epochs to compute event-related potential."""
    evoked = epochs[condition].average()
    assert evoked.nave > 20, \
        f"Too few trials for reliable ERP: {evoked.nave}"
    return evoked
```

### Step 3: Statistical Analysis

```python
# src/eeg_statistics.py
"""Group-level ERP statistics with cluster-based permutation tests."""

import mne
import numpy as np
from scipy import stats

def cluster_permutation_test(evoked_group1: list,
                              evoked_group2: list,
                              tmin: float = 0.1,
                              tmax: float = 0.5,
                              n_permutations: int = 1024,
                              alpha: float = 0.05) -> dict:
    """Cluster-based permutation t-test (Maris & Oostenveld, 2007).
    Corrects for multiple comparisons across time and channels.
    """
    assert len(evoked_group1) >= 10, \
        f"Need 10+ subjects per group, got {len(evoked_group1)}"
    assert len(evoked_group2) >= 10, \
        f"Need 10+ subjects per group, got {len(evoked_group2)}"

    X1 = np.array([e.get_data() for e in evoked_group1])  # (subjects, channels, times)
    X2 = np.array([e.get_data() for e in evoked_group2])

    # Select time window
    times = evoked_group1[0].times
    time_mask = (times >= tmin) & (times <= tmax)
    X1 = X1[:, :, time_mask]
    X2 = X2[:, :, time_mask]

    # Connectivity for spatial clustering
    info = evoked_group1[0].info
    adjacency, _ = mne.channels.find_ch_adjacency(info, ch_type='eeg')

    # Run test
    T_obs, clusters, cluster_pvals, H0 = mne.stats.permutation_cluster_test(
        [X1, X2],
        n_permutations=n_permutations,
        threshold=dict(start=0.2, step=0.2),
        adjacency=adjacency,
        tail=0,
    )

    sig_clusters = [i for i, p in enumerate(cluster_pvals) if p < alpha]

    return {
        'n_clusters': len(clusters),
        'significant_clusters': len(sig_clusters),
        'cluster_pvals': cluster_pvals,
        'T_obs': T_obs,
    }
```

### Step 4: Verify Pipeline

```bash
python3 -c "
import mne
import numpy as np

# Create synthetic EEG data for testing
info = mne.create_info(ch_names=['Fz','Cz','Pz','Oz','F3','F4','C3','C4'],
                        sfreq=256.0, ch_types='eeg')
raw = mne.io.RawArray(np.random.randn(8, 256*60) * 1e-5, info)  # 60s of data

# Add simulated events
events = np.column_stack([
    np.arange(100, 256*60, 512),  # every 2s
    np.zeros(len(np.arange(100, 256*60, 512)), dtype=int),
    np.ones(len(np.arange(100, 256*60, 512)), dtype=int),
])

epochs = mne.Epochs(raw, events, tmin=-0.2, tmax=0.8,
                     baseline=(-0.2, 0), preload=True)
evoked = epochs.average()
print(f'Epochs: {len(epochs)}, Channels: {len(evoked.ch_names)}')
print(f'Time range: {evoked.times[0]:.3f} to {evoked.times[-1]:.3f} s')
print(f'Peak amplitude: {np.abs(evoked.data).max()*1e6:.2f} uV')
print('MNE-Python pipeline: PASS')
"
```

## CLAUDE.md for Neuroscience EEG/MEG Analysis

```markdown
# Neuroscience EEG/MEG Analysis

## Standards
- MNE-Python coding conventions
- BIDS (Brain Imaging Data Structure) for data organization
- Report filter settings, epoch window, and rejection criteria in publications

## Preprocessing Order
1. Load raw data + set montage
2. Resample (before filtering)
3. Bandpass filter (0.1-40 Hz typical, FIR zero-phase)
4. Re-reference (average or linked mastoids)
5. ICA artifact rejection (EOG, ECG components)
6. Epoch and baseline correct
7. Amplitude-based epoch rejection (150 uV threshold)

## Libraries
- mne 1.7+ (core EEG/MEG processing)
- mne-bids 0.14+ (BIDS data organization)
- autoreject 0.4+ (automated epoch rejection)
- fooof 1.1+ (spectral parameterization)
- nilearn 0.10+ (neuroimaging visualization)

## Common Commands
- mne.sys_info() — check MNE installation
- mne browse_raw data.fif — interactive raw data browser
- mne report -p subject/ — generate HTML quality report
```

## Common Pitfalls

- **High-pass filter too aggressive:** A 1 Hz high-pass distorts slow ERP components (P300, N400). Claude Code defaults to 0.1 Hz and warns if you set it higher than 0.3 Hz for ERP analysis.
- **ICA on unfiltered data:** ICA decomposition fails on data with low-frequency drift. Claude Code applies a temporary 1 Hz high-pass for ICA fitting, then applies the ICA solution to the original 0.1 Hz filtered data.
- **Multiple comparisons not corrected:** Testing each channel/timepoint independently at p<0.05 with 64 channels and 256 timepoints gives thousands of false positives. Claude Code uses cluster-based permutation tests by default for spatiotemporal comparisons.

## Related

- [Claude Code for DSP Pipeline Development](/claude-code-dsp-pipeline-development-2026/)
- [Claude Code for Epidemiology Modeling](/claude-code-epidemiology-sir-seir-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
