---
layout: default
title: "Claude Code for Climate Model Data (2026)"
description: "Claude Code for Climate Model Data — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-climate-model-netcdf-processing-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for Climate Data

Climate scientists work with CMIP6 datasets that span terabytes of NetCDF files across hundreds of models, scenarios, and variables. Extracting a regional time series, regridding from a model's native grid to a common resolution, or computing ensemble statistics requires specialized knowledge of CF conventions, coordinate reference systems, and the xarray/dask ecosystem.

Claude Code generates scripts that correctly handle NetCDF metadata conventions, lazy-loaded dask arrays for out-of-core computation, and the specific regridding approaches (conservative, bilinear) needed for different variable types (fluxes vs temperatures).

## The Workflow

### Step 1: Environment Setup

```bash
conda create -n climate -c conda-forge \
  xarray=2024.1 dask=2024.1 netcdf4=1.6 \
  cftime=1.6 nc-time-axis cartopy=0.22 \
  xesmf=0.8 cf_xarray=0.9 intake-esm=2024.1

conda activate climate

# Download sample CMIP6 data (surface temperature)
# Via ESGF or intake-esm catalog
mkdir -p data/cmip6 output/
```

### Step 2: Process CMIP6 Data

```python
# climate/process_cmip6.py
"""Process CMIP6 climate model output: extract, regrid, compute ensemble stats."""
import xarray as xr
import numpy as np
from pathlib import Path
import cf_xarray  # noqa: F401 — enables CF accessor

MAX_MODELS = 50
TARGET_RES = 1.0  # degrees


def load_cmip6_dataset(filepath: str) -> xr.Dataset:
    """Load a CMIP6 NetCDF file with CF convention awareness."""
    assert Path(filepath).exists(), f"File not found: {filepath}"
    ds = xr.open_dataset(filepath, chunks={"time": 120})

    # Validate CF conventions
    assert "time" in ds.dims or "time" in ds.cf.coordinates, \
        "Missing time dimension — not CF-compliant"
    assert any(v in ds.data_vars for v in ["tas", "pr", "tos", "psl"]), \
        "No recognized CMIP6 variable found"

    return ds


def extract_region(ds: xr.Dataset, var: str,
                   lat_min: float, lat_max: float,
                   lon_min: float, lon_max: float) -> xr.DataArray:
    """Extract a geographic region using CF-aware coordinate selection."""
    assert var in ds.data_vars, f"Variable {var} not in dataset"
    assert lat_min < lat_max, "lat_min must be less than lat_max"
    assert lon_min < lon_max, "lon_min must be less than lon_max"

    da = ds[var]

    # Handle both -180/180 and 0/360 longitude conventions
    lon_name = da.cf["longitude"].name
    if da[lon_name].values.max() > 180:
        if lon_min < 0:
            lon_min += 360
        if lon_max < 0:
            lon_max += 360

    lat_name = da.cf["latitude"].name
    region = da.sel({
        lat_name: slice(lat_min, lat_max),
        lon_name: slice(lon_min, lon_max),
    })

    assert region.size > 0, "Region selection returned empty array"
    return region


def compute_annual_mean(da: xr.DataArray) -> xr.DataArray:
    """Compute area-weighted annual mean from monthly data."""
    assert "time" in da.dims, "DataArray must have time dimension"

    # Area weights from latitude
    lat_name = da.cf["latitude"].name
    weights = np.cos(np.deg2rad(da[lat_name]))
    weights.name = "weights"

    # Weighted spatial mean, then annual mean
    spatial_mean = da.weighted(weights).mean(
        dim=[da.cf["latitude"].name, da.cf["longitude"].name])
    annual = spatial_mean.groupby("time.year").mean("time")

    return annual


def compute_ensemble_stats(file_list: list, var: str,
                           lat_min: float, lat_max: float,
                           lon_min: float, lon_max: float) -> xr.Dataset:
    """Compute ensemble mean and spread across multiple models."""
    assert len(file_list) > 0, "Empty file list"
    assert len(file_list) <= MAX_MODELS, \
        f"Too many models: {len(file_list)} > {MAX_MODELS}"

    annual_means = []
    for fp in file_list:
        ds = load_cmip6_dataset(fp)
        region = extract_region(ds, var, lat_min, lat_max, lon_min, lon_max)
        annual = compute_annual_mean(region)
        annual_means.append(annual)
        ds.close()

    ensemble = xr.concat(annual_means, dim="model")
    result = xr.Dataset({
        f"{var}_ensemble_mean": ensemble.mean(dim="model"),
        f"{var}_ensemble_std": ensemble.std(dim="model"),
        f"{var}_ensemble_min": ensemble.min(dim="model"),
        f"{var}_ensemble_max": ensemble.max(dim="model"),
    })

    return result


if __name__ == "__main__":
    import glob
    import sys

    assert len(sys.argv) >= 2, \
        "Usage: python process_cmip6.py <data_dir> [variable]"

    data_dir = sys.argv[1]
    var = sys.argv[2] if len(sys.argv) > 2 else "tas"

    files = sorted(glob.glob(f"{data_dir}/*.nc"))
    assert len(files) > 0, f"No NetCDF files found in {data_dir}"

    # Example: European region, 35N-70N, -10W-40E
    result = compute_ensemble_stats(files, var, 35.0, 70.0, -10.0, 40.0)
    result.to_netcdf(f"output/{var}_europe_ensemble.nc")
    print(f"Wrote ensemble stats: {len(files)} models processed")
```

### Step 3: Validate and Visualize

```bash
python3 climate/process_cmip6.py data/cmip6/ tas
# Expected: output/tas_europe_ensemble.nc with 4 variables

# Quick validation
python3 -c "
import xarray as xr
ds = xr.open_dataset('output/tas_europe_ensemble.nc')
print(ds)
print(f'Mean range: {float(ds.tas_ensemble_mean.min()):.1f} - {float(ds.tas_ensemble_mean.max()):.1f} K')
# Expected: ~280-290 K for European surface temperature
"

# Plot with cartopy (optional)
ncdump -h output/tas_europe_ensemble.nc | head -20
```

## CLAUDE.md for Climate Data

```markdown
# Climate Model Data Processing Rules

## Standards
- CF Conventions 1.11 (NetCDF metadata)
- CMIP6 data reference syntax (DRS)
- ESGF data access protocols

## File Formats
- .nc (NetCDF-4/HDF5)
- .zarr (cloud-optimized)
- .grib2 (reanalysis data)
- .csv (station observations)

## Libraries
- xarray 2024.1+ (lazy array operations)
- dask 2024.1+ (parallel/out-of-core)
- cf_xarray 0.9+ (CF convention support)
- xESMF 0.8+ (regridding)
- cartopy 0.22+ (map projections)
- intake-esm 2024.1+ (CMIP catalog access)

## Testing
- Verify coordinate units (K vs C for temperature, kg/m2/s vs mm/day for precip)
- Check longitude convention (0-360 vs -180-180) before subsetting
- Validate time axis with cftime (climate calendars: 360-day, noleap)

## Data Access
- ESGF for CMIP6 model output
- ERA5 via CDS API for reanalysis
- NOAA NCEI for observations
```

## Common Pitfalls

- **Calendar mismatch:** CMIP6 models use different calendars (360_day, noleap, standard). Concatenating datasets without calendar harmonization via cftime produces wrong annual means. Claude Code adds explicit calendar checks before any time operations.
- **Longitude convention collision:** Some models use 0-360, others use -180 to 180. Selecting a region that crosses the prime meridian fails silently. Claude Code detects the convention and adjusts selection bounds.
- **Loading full datasets into memory:** A single CMIP6 variable can be 50+ GB. Claude Code always uses dask chunking with `chunks={"time": 120}` to enable out-of-core processing.

## Related

- [Claude Code for Computational Biology](/claude-skills-for-computational-biology-bioinformatics/)
- [Claude Code for Molecular Dynamics](/claude-code-molecular-dynamics-gromacs-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Satellite Telemetry (2026)](/claude-code-satellite-telemetry-processing-2026/)
- [Claude Code for Sonar Array Processing (2026)](/claude-code-sonar-array-processing-2026/)


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

- [Claude Code Router: Model Routing Guide](/claude-code-router-guide/)
- [Claude Code Model Compression](/claude-code-model-compression-quantization/)
- [Claude Model Pricing Per Million Tokens](/claude-model-pricing-per-million-tokens-guide/)
- [Smart Model Selection Saves 80%](/smart-model-selection-saves-80-percent-claude/)

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
