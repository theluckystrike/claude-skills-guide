---
title: "Claude Code for Sonar Array Processing (2026)"
permalink: /claude-code-sonar-array-processing-2026/
description: "Sonar array processing with Claude Code. Build beamformers, matched filters, and target detection for underwater acoustics."
last_tested: "2026-04-22"
---

## Why Claude Code for Sonar Array Processing

Underwater acoustics presents unique signal processing challenges that surface-based systems never face. Sound speed varies with depth (creating refraction paths), multipath reflections off the surface and seafloor corrupt arrival times, and ambient noise from shipping, biologics, and weather dominates the signal environment. Sonar array processing must compensate for all of these while steering beams, estimating bearing, and classifying targets.

Claude Code handles the array manifold calculations, generates conventional and adaptive beamformers, and builds the processing chains that go from raw hydrophone data to bearing-time records. It understands the physics -- sound speed profiles, array geometries, near-field vs far-field corrections -- that distinguish sonar from generic DSP.

## The Workflow

### Step 1: Sonar Processing Setup

```bash
pip install numpy scipy matplotlib arlpy
# arlpy: underwater acoustics and array processing
pip install soundfile  # for WAV hydrophone recordings

mkdir -p src/beamforming src/detection src/propagation tests/
```

### Step 2: Build a Beamformer

```python
# src/beamforming/array_processor.py
"""Conventional and MVDR beamforming for uniform linear array."""

import numpy as np
from dataclasses import dataclass

@dataclass
class ArrayConfig:
    num_elements: int      # Number of hydrophones
    element_spacing_m: float  # Inter-element spacing
    sample_rate_hz: float
    sound_speed_mps: float = 1500.0  # nominal, varies with depth

    @property
    def design_freq_hz(self) -> float:
        """Spatial Nyquist: d = lambda/2 -> f = c/(2d)."""
        return self.sound_speed_mps / (2.0 * self.element_spacing_m)

def steering_vector(array: ArrayConfig, freq_hz: float,
                    theta_deg: float) -> np.ndarray:
    """Compute steering vector for a ULA at given bearing.
    theta_deg: bearing angle from broadside (0 = broadside).
    """
    wavelength = array.sound_speed_mps / freq_hz
    d = array.element_spacing_m
    n = np.arange(array.num_elements)

    # Phase shift per element
    phase = 2 * np.pi * d * np.sin(np.radians(theta_deg)) / wavelength
    sv = np.exp(1j * n * phase)

    # Normalize
    sv = sv / np.sqrt(array.num_elements)
    assert len(sv) == array.num_elements
    return sv

def conventional_beamformer(data: np.ndarray,
                            array: ArrayConfig,
                            freq_hz: float,
                            theta_range: np.ndarray
                            ) -> np.ndarray:
    """Conventional (delay-and-sum) beamformer.
    data: shape (num_elements, num_snapshots)
    Returns: beam power vs bearing.
    """
    assert data.shape[0] == array.num_elements, "Element count mismatch"

    # Compute spatial covariance matrix
    R = (data @ data.conj().T) / data.shape[1]

    beam_power = np.zeros(len(theta_range))
    for i, theta in enumerate(theta_range):
        sv = steering_vector(array, freq_hz, theta)
        # CBF power: P(theta) = a^H R a
        beam_power[i] = np.real(sv.conj() @ R @ sv)

    return 10 * np.log10(beam_power + 1e-12)

def mvdr_beamformer(data: np.ndarray,
                    array: ArrayConfig,
                    freq_hz: float,
                    theta_range: np.ndarray,
                    diagonal_loading: float = 0.01
                    ) -> np.ndarray:
    """Minimum Variance Distortionless Response (Capon) beamformer.
    Better resolution than conventional but sensitive to mismatch.
    """
    assert data.shape[0] == array.num_elements

    R = (data @ data.conj().T) / data.shape[1]

    # Diagonal loading for robustness
    R_loaded = R + diagonal_loading * np.trace(R) / array.num_elements * \
               np.eye(array.num_elements)
    R_inv = np.linalg.inv(R_loaded)

    beam_power = np.zeros(len(theta_range))
    for i, theta in enumerate(theta_range):
        sv = steering_vector(array, freq_hz, theta)
        # MVDR: P(theta) = 1 / (a^H R^-1 a)
        denom = np.real(sv.conj() @ R_inv @ sv)
        beam_power[i] = 1.0 / (denom + 1e-12)

    return 10 * np.log10(beam_power + 1e-12)

def generate_bearing_time_record(data: np.ndarray,
                                  array: ArrayConfig,
                                  freq_hz: float,
                                  block_size: int = 256,
                                  overlap: int = 128
                                  ) -> tuple:
    """Generate BTR (bearing-time record) waterfall display."""
    theta_range = np.arange(-90, 91, 1.0)
    num_blocks = (data.shape[1] - block_size) // (block_size - overlap) + 1

    btr = np.zeros((num_blocks, len(theta_range)))

    for blk in range(num_blocks):
        start = blk * (block_size - overlap)
        block = data[:, start:start + block_size]
        btr[blk, :] = conventional_beamformer(
            block, array, freq_hz, theta_range
        )

    time_axis = np.arange(num_blocks) * (block_size - overlap) / \
                array.sample_rate_hz
    return theta_range, time_axis, btr
```

### Step 3: Sound Speed Profile and Ray Tracing

```python
# src/propagation/sound_speed.py
"""Sound speed profile and simple ray tracing."""

import numpy as np

def mackenzie_sound_speed(temp_c: float, salinity_psu: float,
                          depth_m: float) -> float:
    """Mackenzie equation (1981) for sound speed in seawater.
    Valid: 2-30C, 25-40 PSU, 0-8000m.
    """
    T = temp_c
    S = salinity_psu
    D = depth_m

    c = (1448.96 + 4.591*T - 5.304e-2*T**2 + 2.374e-4*T**3
         + 1.340*(S - 35) + 1.630e-2*D + 1.675e-7*D**2
         - 1.025e-2*T*(S - 35) - 7.139e-13*T*D**3)

    assert 1400 < c < 1600, f"Sound speed {c} outside valid range"
    return c

def compute_ssp(depths_m: np.ndarray, temp_profile: np.ndarray,
                salinity: float = 35.0) -> np.ndarray:
    """Compute sound speed profile from temperature vs depth."""
    ssp = np.array([
        mackenzie_sound_speed(t, salinity, d)
        for t, d in zip(temp_profile, depths_m)
    ])
    return ssp
```

### Step 4: Verify with Synthetic Data

```bash
python3 -c "
import numpy as np
from src.beamforming.array_processor import (
    ArrayConfig, steering_vector, conventional_beamformer, mvdr_beamformer
)

# 16-element ULA, half-wavelength spacing at 3 kHz
array = ArrayConfig(num_elements=16, element_spacing_m=0.25,
                    sample_rate_hz=48000.0, sound_speed_mps=1500.0)

# Synthetic: target at 30 deg bearing + noise
freq = 3000.0
theta_target = 30.0
num_snapshots = 1024
sv_target = steering_vector(array, freq, theta_target)
noise = (np.random.randn(16, num_snapshots) +
         1j * np.random.randn(16, num_snapshots)) * 0.1
signal_component = 1.0 * np.outer(sv_target, np.ones(num_snapshots))
data = signal_component + noise

theta_range = np.arange(-90, 91, 0.5)
cbf = conventional_beamformer(data, array, freq, theta_range)
mvdr = mvdr_beamformer(data, array, freq, theta_range)

peak_cbf = theta_range[np.argmax(cbf)]
peak_mvdr = theta_range[np.argmax(mvdr)]
print(f'Target bearing: {theta_target} deg')
print(f'CBF peak: {peak_cbf} deg')
print(f'MVDR peak: {peak_mvdr} deg')
assert abs(peak_cbf - theta_target) < 3.0, 'CBF bearing error too large'
assert abs(peak_mvdr - theta_target) < 1.5, 'MVDR bearing error too large'
print('Beamformer verification: PASS')
"
```

## CLAUDE.md for Sonar Array Processing

```markdown
# Sonar Array Processing Standards

## Domain Rules
- Element spacing d <= lambda/2 at highest frequency to avoid grating lobes
- Always apply diagonal loading to MVDR (0.01-0.1 * trace(R)/N)
- Sound speed is NOT constant: use Mackenzie or UNESCO equation
- Nearfield correction required when target range < D^2/(4*lambda)
- Normalize steering vectors to unit norm

## Libraries
- numpy 1.26+ (linear algebra, FFT)
- scipy.signal (filtering, spectral analysis)
- arlpy (underwater acoustics toolkit)
- soundfile (hydrophone WAV I/O)
- matplotlib (BTR waterfall displays)

## File Patterns
- .wav — hydrophone recordings (PCM 24-bit typical)
- .ssp — sound speed profile (depth, speed CSV)
- .npy — processed beamformer output

## Common Commands
- python3 src/beamforming/array_processor.py — run beamformer
- bellhop — acoustic ray tracing (Acoustics Toolbox)
- kraken — normal mode propagation model
- sox recording.wav -n spectrogram — quick spectrogram
```

## Common Pitfalls

- **Assuming constant sound speed:** A thermocline at 50m depth bends rays downward, creating shadow zones. Claude Code integrates sound speed profiles into beamformer delay calculations using the Mackenzie equation.
- **Grating lobes from undersampled arrays:** If element spacing exceeds half a wavelength at the operating frequency, phantom targets appear at aliased bearings. Claude Code checks the spatial Nyquist criterion and warns when your frequency exceeds the array's design limit.
- **Covariance matrix singularity:** With fewer snapshots than elements, the sample covariance matrix is rank-deficient and MVDR fails. Claude Code applies diagonal loading automatically and suggests the minimum snapshot count for stable inversion.

## Related

- [Claude Code for Radar Signal Processing](/claude-code-radar-signal-processing-2026/)
- [Claude Code for DSP Pipeline Development](/claude-code-dsp-pipeline-development-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Satellite Telemetry (2026)](/claude-code-satellite-telemetry-processing-2026/)


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

- [Claude Batch Processing 100K Requests](/claude-batch-processing-100k-requests-guide/)
- [Claude Code for Processing and p5.js](/claude-code-processing-p5js-creative-coding-2026/)
- [Async Claude Processing](/async-claude-processing-half-price-same-quality/)
- [Claude Code Batch File Processing](/claude-code-batch-file-processing-workflow/)


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
