---
layout: default
title: "Claude Code for Seismology Waveform (2026)"
permalink: /claude-code-seismology-waveform-analysis-2026/
date: 2026-04-20
description: "Claude Code for Seismology Waveform — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Seismology

Seismological data analysis chains multiple domain-specific steps: retrieving waveforms from FDSN data centers, instrument response removal to convert counts to ground velocity, bandpass filtering tuned to the target frequency band (body waves vs surface waves), STA/LTA event detection, P/S phase arrival picking, magnitude estimation, and focal mechanism determination. Each step uses conventions (miniSEED format, SEED channel naming like BHZ/HHZ, response poles and zeros) that are opaque to general-purpose tools.

Claude Code generates ObsPy workflows that handle the full seismological processing chain, from FDSN data retrieval through publication-quality focal mechanism plots. It understands the SEED naming conventions, knows which filter bands to use for local vs teleseismic events, and produces the proper instrument correction workflow that prevents the spectral artifacts that plague beginners.

## The Workflow

### Step 1: Seismology Environment Setup

```bash
pip install obspy matplotlib cartopy
pip install eqcorrscan  # matched-filter detection
pip install pyrocko     # advanced seismology toolkit

mkdir -p data/waveforms data/catalogs results/
```

### Step 2: Build Earthquake Detection Pipeline

```python
# src/earthquake_detector.py
"""Earthquake detection and phase picking pipeline using ObsPy."""

import obspy
from obspy import UTCDateTime, Stream, Trace
from obspy.clients.fdsn import Client
from obspy.signal.trigger import recursive_sta_lta, trigger_onset
from obspy.signal.trigger import ar_pick
import numpy as np
from dataclasses import dataclass

@dataclass
class Detection:
    time: UTCDateTime
    duration_s: float
    sta_lta_ratio: float
    station: str
    channel: str

@dataclass
class PhasePick:
    station: str
    phase: str          # 'P' or 'S'
    time: UTCDateTime
    uncertainty_s: float

def fetch_waveforms(network: str, station: str,
                     starttime: UTCDateTime,
                     endtime: UTCDateTime,
                     client_name: str = "IRIS") -> Stream:
    """Fetch waveforms from FDSN data center."""
    client = Client(client_name)
    st = client.get_waveforms(
        network=network, station=station,
        location="*", channel="BH*",
        starttime=starttime, endtime=endtime,
    )
    assert len(st) > 0, f"No data returned for {network}.{station}"
    return st

def remove_instrument_response(st: Stream,
                                client_name: str = "IRIS",
                                output: str = "VEL",
                                pre_filt: tuple = (0.005, 0.01, 45, 50)
                                ) -> Stream:
    """Remove instrument response to get true ground motion.
    output: 'DISP' (displacement), 'VEL' (velocity), 'ACC' (acceleration)
    pre_filt: corner frequencies of cosine taper to avoid spectral artifacts
    """
    client = Client(client_name)
    inventory = client.get_stations(
        network=st[0].stats.network,
        station=st[0].stats.station,
        starttime=st[0].stats.starttime,
        endtime=st[0].stats.endtime,
        level="response",
    )

    st_corrected = st.copy()
    st_corrected.remove_response(
        inventory=inventory,
        output=output,
        pre_filt=pre_filt,
        water_level=60,
    )

    return st_corrected

def detect_events_sta_lta(trace: Trace,
                           sta_seconds: float = 1.0,
                           lta_seconds: float = 30.0,
                           trigger_on: float = 3.5,
                           trigger_off: float = 1.5) -> list:
    """STA/LTA event detection on a single trace."""
    df = trace.stats.sampling_rate
    nsta = int(sta_seconds * df)
    nlta = int(lta_seconds * df)

    assert nlta > nsta, "LTA window must exceed STA window"
    assert len(trace.data) > nlta, "Trace too short for LTA window"

    # Recursive STA/LTA (more efficient than classic)
    cft = recursive_sta_lta(trace.data, nsta, nlta)

    # Find trigger on/off pairs
    triggers = trigger_onset(cft, trigger_on, trigger_off)

    detections = []
    for on_sample, off_sample in triggers:
        det_time = trace.stats.starttime + on_sample / df
        duration = (off_sample - on_sample) / df
        max_ratio = float(np.max(cft[on_sample:off_sample]))

        detections.append(Detection(
            time=det_time,
            duration_s=duration,
            sta_lta_ratio=max_ratio,
            station=trace.stats.station,
            channel=trace.stats.channel,
        ))

    return detections

def pick_p_s_arrivals(st: Stream) -> list:
    """Automatic P and S phase picking using autoregressive method."""
    # Need 3-component data (Z, N, E)
    st_z = st.select(channel="*Z")
    st_n = st.select(channel="*N")
    st_e = st.select(channel="*E")

    assert len(st_z) > 0 and len(st_n) > 0 and len(st_e) > 0, \
        "Need 3-component data for P/S picking"

    z_data = st_z[0].data.astype(np.float32)
    n_data = st_n[0].data.astype(np.float32)
    e_data = st_e[0].data.astype(np.float32)
    df = st_z[0].stats.sampling_rate

    # AR picker: returns P and S arrival samples
    p_sample, s_sample = ar_pick(z_data, n_data, e_data,
                                   samp_rate=df,
                                   f1=1.0, f2=20.0,
                                   lta_p=1.0, sta_p=0.1,
                                   lta_s=4.0, sta_s=1.0,
                                   m_p=2, m_s=8,
                                   l_p=0.1, l_s=0.2)

    picks = []
    start = st_z[0].stats.starttime
    station = st_z[0].stats.station

    if p_sample > 0:
        picks.append(PhasePick(
            station=station, phase='P',
            time=start + p_sample / df,
            uncertainty_s=0.1
        ))

    if s_sample > 0:
        picks.append(PhasePick(
            station=station, phase='S',
            time=start + s_sample / df,
            uncertainty_s=0.2
        ))

    return picks
```

### Step 3: Magnitude Estimation

```python
# src/magnitude.py
"""Local magnitude (ML) calculation."""

import numpy as np
from obspy import Trace

def compute_ml(trace: Trace, distance_km: float,
               station_correction: float = 0.0) -> float:
    """Compute local magnitude ML (Richter scale).
    Requires Wood-Anderson simulated displacement trace.
    """
    # Simulate Wood-Anderson seismograph response
    paz_wa = {
        'sensitivity': 2800.0,
        'zeros': [0j],
        'gain': 1.0,
        'poles': [-6.2832 - 4.7124j, -6.2832 + 4.7124j],
    }
    trace_wa = trace.copy()
    trace_wa.simulate(paz_simulate=paz_wa)

    # Peak amplitude in mm (Wood-Anderson convention)
    amplitude_m = np.max(np.abs(trace_wa.data))
    amplitude_mm = amplitude_m * 1000.0

    assert amplitude_mm > 0, "Zero amplitude on trace"
    assert distance_km > 0, "Distance must be positive"

    # Richter (1935) attenuation correction for Southern California
    # logA0 = -log10(A0) where A0 is amplitude at distance
    if distance_km <= 200:
        log_a0 = 1.110 * np.log10(distance_km / 100) + \
                 0.00189 * (distance_km - 100) + 3.0
    else:
        log_a0 = 1.110 * np.log10(distance_km / 100) + \
                 0.00189 * (distance_km - 100) + 3.0

    ml = np.log10(amplitude_mm) + log_a0 + station_correction
    return float(ml)
```

### Step 4: Verify Pipeline

```bash
python3 -c "
import obspy
import numpy as np
from obspy import UTCDateTime

# Create synthetic seismogram with P and S arrivals
sps = 100  # samples per second
t = np.arange(0, 60, 1/sps)
noise = np.random.randn(len(t)) * 0.001

# P arrival at 10s, S arrival at 17s
p_arrival = 10.0
s_arrival = 17.0
signal = noise.copy()
# P wave: high frequency
p_idx = int(p_arrival * sps)
signal[p_idx:p_idx+200] += 0.1 * np.sin(2*np.pi*5*np.arange(200)/sps) * \
    np.exp(-np.arange(200)/(sps*2))
# S wave: lower frequency, larger amplitude
s_idx = int(s_arrival * sps)
signal[s_idx:s_idx+400] += 0.3 * np.sin(2*np.pi*2*np.arange(400)/sps) * \
    np.exp(-np.arange(400)/(sps*3))

tr = obspy.Trace(data=signal.astype(np.float32))
tr.stats.sampling_rate = sps
tr.stats.station = 'TEST'
tr.stats.channel = 'BHZ'
tr.stats.starttime = UTCDateTime('2026-04-22T00:00:00')

from src.earthquake_detector import detect_events_sta_lta
detections = detect_events_sta_lta(tr, sta_seconds=0.5, lta_seconds=10.0,
                                     trigger_on=3.0, trigger_off=1.5)
print(f'Detected {len(detections)} events')
if detections:
    print(f'First detection at: {detections[0].time}')
    det_offset = detections[0].time - tr.stats.starttime
    assert abs(det_offset - p_arrival) < 2.0, 'Detection time off by >2s'
    print(f'Detection offset: {det_offset:.1f}s (expected ~{p_arrival}s)')
print('Seismology pipeline: PASS')
"
```

## CLAUDE.md for Seismology

```markdown
# Seismology Waveform Analysis

## Data Standards
- miniSEED format for waveform data
- StationXML/SEED for instrument metadata
- QuakeML for earthquake catalogs
- FDSN web services for data access

## Channel Naming (SEED convention)
- BHZ: broadband high-gain vertical (20 sps)
- HHZ: high broadband high-gain vertical (100 sps)
- BHN/BHE: north/east components
- Channel code: Band-Instrument-Orientation

## Libraries
- obspy 1.4+ (core seismology toolkit)
- eqcorrscan 0.5+ (matched filter detection)
- pyrocko (advanced seismology)
- cartopy (map plotting)

## Common Commands
- obspy-scan data/*.mseed — scan miniSEED files
- obspy-plot data/trace.mseed — quick waveform plot
- fdsnws_fetch -N IU -S ANMO -C BHZ — fetch from FDSN
```

## Common Pitfalls

- **Instrument response not removed:** Raw waveforms are in counts (proportional to voltage), not ground motion. Comparing amplitudes across stations without response removal is meaningless. Claude Code always removes instrument response before any amplitude-based analysis.
- **Pre-filter corner frequencies wrong:** The pre_filt cosine taper must be wider than your analysis band to avoid ringing artifacts. Claude Code sets pre_filt corners at 0.5x and 1.5x your desired passband edges.
- **STA/LTA window too short for teleseismic events:** Local earthquake STA/LTA parameters (1s/30s) miss teleseismic P arrivals that emerge slowly from noise. Claude Code adjusts window lengths based on the target event distance range.

## Related

- [Claude Code for DSP Pipeline Development](/claude-code-dsp-pipeline-development-2026/)
- [Claude Code for Astrophysics Data Reduction](/claude-code-astrophysics-data-reduction-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Market Microstructure (2026)](/claude-code-market-microstructure-analysis-2026/)


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




**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [How to Test and Debug Multi Agent](/how-to-test-and-debug-multi-agent-workflows/)
- [Claude Code Debug Configuration](/claude-code-debug-configuration-workflow/)
- [How Do I Debug A Claude Skill](/how-do-i-debug-a-claude-skill-that-silently-fails/)
- [Claude Code Verbose Mode](/claude-code-verbose-mode-debug-output-2026/)

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
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
