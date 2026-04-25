---
layout: default
title: "Claude Code for Astrophysics Data (2026)"
permalink: /claude-code-astrophysics-data-reduction-2026/
date: 2026-04-20
description: "Claude Code for Astrophysics Data — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Astrophysics Data Reduction

Astronomical data reduction transforms raw CCD frames into calibrated science images through a precise sequence: bias subtraction, dark current removal, flat-field correction, cosmic ray rejection, astrometric solution, and photometric calibration. Each step has failure modes that propagate silently -- a bad flat field introduces 2-3% photometric errors that look like real stellar variability. The pipeline must handle FITS headers with observatory-specific keywords, WCS (World Coordinate System) projections, and catalog cross-matching.

Claude Code generates reduction pipelines using astropy, photutils, and ccdproc that respect the FITS standard, handle multi-extension files from mosaic cameras, and produce calibrated images with proper header propagation. It catches the metadata errors that corrupt astrometric solutions and flags saturated stars before they contaminate your photometry.

## The Workflow

### Step 1: Observatory Pipeline Setup

```bash
pip install astropy ccdproc photutils astroquery
pip install sep  # Source Extractor in Python (fast aperture photometry)
pip install astroscrappy  # cosmic ray rejection (L.A.Cosmic algorithm)

mkdir -p raw/ calibration/{bias,dark,flat} reduced/ catalogs/
```

### Step 2: CCD Calibration Pipeline

```python
# src/calibration_pipeline.py
"""CCD image calibration: bias, dark, flat field correction."""

import numpy as np
from astropy.io import fits
from astropy.nddata import CCDData
from astropy import units as u
import ccdproc
from pathlib import Path

def create_master_bias(bias_dir: str) -> CCDData:
    """Combine bias frames using median with sigma clipping."""
    bias_files = sorted(Path(bias_dir).glob("bias_*.fits"))
    assert len(bias_files) >= 5, f"Need 5+ bias frames, found {len(bias_files)}"

    bias_list = [CCDData.read(f, unit='adu') for f in bias_files]

    master_bias = ccdproc.combine(
        bias_list,
        method='median',
        sigma_clip=True,
        sigma_clip_low_thresh=3,
        sigma_clip_high_thresh=3,
        sigma_clip_func=np.ma.median,
    )

    # Verify: bias level should be reasonable (100-2000 ADU typical)
    median_level = np.median(master_bias.data)
    assert 50 < median_level < 5000, f"Suspicious bias level: {median_level} ADU"

    master_bias.header['IMAGETYP'] = 'MASTER_BIAS'
    master_bias.header['NCOMBINE'] = len(bias_files)
    return master_bias

def create_master_flat(flat_dir: str, master_bias: CCDData,
                       master_dark: CCDData = None) -> CCDData:
    """Create normalized master flat field."""
    flat_files = sorted(Path(flat_dir).glob("flat_*.fits"))
    assert len(flat_files) >= 5, f"Need 5+ flat frames, found {len(flat_files)}"

    flat_list = []
    for f in flat_files:
        flat = CCDData.read(f, unit='adu')
        flat = ccdproc.subtract_bias(flat, master_bias)
        if master_dark is not None:
            flat = ccdproc.subtract_dark(
                flat, master_dark,
                exposure_time='EXPTIME',
                exposure_unit=u.second,
                scale=True
            )
        flat_list.append(flat)

    master_flat = ccdproc.combine(
        flat_list, method='median',
        sigma_clip=True, sigma_clip_low_thresh=3, sigma_clip_high_thresh=3,
        scale=lambda x: 1.0 / np.ma.median(x),
    )

    # Verify: normalized flat should be near 1.0
    flat_median = np.median(master_flat.data)
    assert 0.8 < flat_median < 1.2, f"Flat normalization failed: median={flat_median}"

    master_flat.header['IMAGETYP'] = 'MASTER_FLAT'
    return master_flat

def reduce_science_frame(science_path: str,
                         master_bias: CCDData,
                         master_flat: CCDData,
                         master_dark: CCDData = None) -> CCDData:
    """Full calibration of a single science frame."""
    science = CCDData.read(science_path, unit='adu')

    # Step 1: Bias subtraction
    calibrated = ccdproc.subtract_bias(science, master_bias)

    # Step 2: Dark subtraction (scaled to exposure time)
    if master_dark is not None:
        calibrated = ccdproc.subtract_dark(
            calibrated, master_dark,
            exposure_time='EXPTIME',
            exposure_unit=u.second,
            scale=True
        )

    # Step 3: Flat field correction
    calibrated = ccdproc.flat_correct(calibrated, master_flat)

    # Step 4: Cosmic ray rejection (L.A.Cosmic)
    import astroscrappy
    mask, cleaned = astroscrappy.detect_cosmics(
        calibrated.data,
        sigclip=5.0,
        sigfrac=0.3,
        objlim=5.0,
    )
    calibrated.data = cleaned
    calibrated.header['NCOSMIC'] = int(np.sum(mask))

    return calibrated
```

### Step 3: Aperture Photometry

```python
# src/photometry.py
"""Source detection and aperture photometry using SEP."""

import numpy as np
import sep
from astropy.io import fits
from dataclasses import dataclass

@dataclass
class PhotometryResult:
    x: np.ndarray
    y: np.ndarray
    flux: np.ndarray
    flux_err: np.ndarray
    mag_inst: np.ndarray
    flags: np.ndarray

def extract_sources(data: np.ndarray,
                    threshold_sigma: float = 5.0,
                    aperture_radius: float = 8.0,
                    gain: float = 1.5) -> PhotometryResult:
    """Detect sources and perform aperture photometry."""
    # SEP requires C-contiguous, native byte order float
    data_sep = data.astype(np.float64, order='C')

    # Background estimation
    bkg = sep.Background(data_sep)
    data_sub = data_sep - bkg.back()

    # Source detection
    objects = sep.extract(data_sub, threshold_sigma, err=bkg.globalrms)
    assert len(objects) > 0, "No sources detected"

    # Circular aperture photometry
    flux, flux_err, flag = sep.sum_circle(
        data_sub, objects['x'], objects['y'],
        aperture_radius,
        err=bkg.globalrms, gain=gain
    )

    # Instrumental magnitude
    valid = flux > 0
    mag_inst = np.full_like(flux, np.nan)
    mag_inst[valid] = -2.5 * np.log10(flux[valid])

    return PhotometryResult(
        x=objects['x'], y=objects['y'],
        flux=flux, flux_err=flux_err,
        mag_inst=mag_inst, flags=flag
    )
```

### Step 4: Verify Pipeline

```bash
python3 -c "
import numpy as np
from astropy.io import fits

# Create synthetic test FITS file
np.random.seed(42)
data = np.random.poisson(1000, (1024, 1024)).astype(np.float32)
# Add synthetic star
y, x = np.mgrid[:1024, :1024]
star = 50000 * np.exp(-((x-512)**2 + (y-512)**2) / (2*3.5**2))
data += star.astype(np.float32)

hdu = fits.PrimaryHDU(data)
hdu.header['EXPTIME'] = 60.0
hdu.header['FILTER'] = 'V'
hdu.header['IMAGETYP'] = 'SCIENCE'
hdu.writeto('test_science.fits', overwrite=True)

# Run photometry
from src.photometry import extract_sources
result = extract_sources(data)
print(f'Detected {len(result.x)} sources')
brightest = np.nanargmin(result.mag_inst)
print(f'Brightest: x={result.x[brightest]:.1f}, y={result.y[brightest]:.1f}')
assert abs(result.x[brightest] - 512) < 2, 'Source position error'
print('Photometry pipeline: PASS')
"
```

## CLAUDE.md for Astrophysics Data Reduction

```markdown
# Astrophysics Data Reduction Standards

## Data Format
- FITS (Flexible Image Transport System) — standard for all astronomical data
- Multi-extension FITS (MEF) for mosaic cameras
- WCS headers for astrometric calibration

## Calibration Sequence
1. Master bias (median combine 10+ frames)
2. Master dark (median combine, scaled by exposure time)
3. Master flat (normalized to median=1.0)
4. Science: bias_sub -> dark_sub -> flat_correct -> cosmic_ray_reject

## Libraries
- astropy 6.0+ (FITS I/O, WCS, units)
- ccdproc 2.4+ (CCD calibration pipeline)
- photutils 1.12+ (photometry, PSF fitting)
- sep 1.2+ (Source Extractor in Python)
- astroscrappy 1.2+ (cosmic ray rejection)

## Common Commands
- ds9 image.fits — display FITS image
- python3 -c "from astropy.io import fits; fits.info('image.fits')" — FITS info
- solve-field image.fits — astrometric plate solve (astrometry.net)
- stilts tmatch2 — catalog cross-matching
```

## Common Pitfalls

- **FITS byte order mismatch:** SEP and numpy expect native byte order but FITS uses big-endian. Claude Code inserts `.byteswap().newbyteorder()` when needed, preventing silent data corruption.
- **Saturated stars in flat fields:** A bright star on a flat frame creates a false low-sensitivity region. Claude Code flags flat frames with sources above 80% of the ADC maximum and excludes them from the master flat combination.
- **WCS propagation loss:** Calibration operations can strip WCS headers. Claude Code preserves header keywords through every ccdproc step by explicitly copying the WCS solution.

## Related

- [Claude Code for Telescope Data Pipeline (FITS)](/claude-code-telescope-fits-pipeline-2026/)
- [Claude Code for Climate Model Data Processing](/claude-code-climate-model-netcdf-processing-2026/)
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

- [Claude Code Factory Bot Test Data](/claude-code-factory-bot-test-data-guide/)
- [Grounding AI Agents in Real-World Data](/grounding-ai-agents-in-real-world-data-explained/)
- [Using Claude Code for Data Quality](/claude-code-for-data-quality-validation-workflow/)
- [Claude Code MCP Server Data](/claude-code-mcp-server-data-exfiltration-prevention/)

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
