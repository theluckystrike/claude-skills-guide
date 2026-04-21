---
title: "Claude Code for Telescope FITS Data Pipeline (2026)"
permalink: /claude-code-telescope-fits-pipeline-2026/
description: "Telescope data pipeline with Claude Code and FITS. Automate image stacking, astrometry, and catalog cross-matching."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for Telescope Data Pipelines

Modern telescope surveys generate terabytes of FITS (Flexible Image Transport System) files per night. The Vera Rubin Observatory will produce 20 TB nightly. Processing this data requires automated pipelines that handle image co-addition, astrometric calibration (mapping pixel coordinates to sky coordinates), photometric calibration (converting ADU counts to standardized magnitudes), and source catalog extraction -- all while tracking provenance through hundreds of FITS header keywords.

Claude Code builds FITS processing pipelines that handle multi-extension files from mosaic cameras, apply WCS (World Coordinate System) transformations correctly, and produce science-ready catalogs. It understands the FITS standard deeply enough to catch the metadata inconsistencies that corrupt astrometric solutions.

## The Workflow

### Step 1: Survey Pipeline Setup

```bash
pip install astropy photutils reproject astroquery
pip install sep astrometry  # source extraction + plate solving
pip install healpy          # HEALPix sky tessellation

mkdir -p pipeline/{ingest,calibrate,stack,catalog} data/ output/
```

### Step 2: Build a FITS Processing Pipeline

```python
# pipeline/ingest/fits_ingestor.py
"""FITS file ingestion with header validation and quality control."""

from astropy.io import fits
from astropy.wcs import WCS
from astropy.coordinates import SkyCoord
from astropy.time import Time
import astropy.units as u
import numpy as np
from pathlib import Path
from dataclasses import dataclass

@dataclass
class FITSQuality:
    filename: str
    has_wcs: bool
    seeing_arcsec: float
    background_adu: float
    n_saturated: int
    exptime_s: float
    filter_name: str
    obs_date: str
    pass_qa: bool

REQUIRED_KEYWORDS = ['NAXIS1', 'NAXIS2', 'EXPTIME', 'FILTER',
                      'DATE-OBS', 'OBJECT']

def validate_fits_header(filepath: str) -> dict:
    """Validate FITS header has required keywords for pipeline."""
    issues = []
    with fits.open(filepath) as hdul:
        header = hdul[0].header

        for kw in REQUIRED_KEYWORDS:
            if kw not in header:
                issues.append(f"Missing keyword: {kw}")

        # Validate WCS
        try:
            wcs = WCS(header)
            has_wcs = wcs.has_celestial
            if not has_wcs:
                issues.append("No celestial WCS found")
        except Exception as e:
            has_wcs = False
            issues.append(f"WCS error: {e}")

        # Validate date
        try:
            obs_time = Time(header.get('DATE-OBS', ''), format='isot')
        except ValueError:
            issues.append(f"Invalid DATE-OBS: {header.get('DATE-OBS')}")

    return {
        'valid': len(issues) == 0,
        'issues': issues,
        'has_wcs': has_wcs,
    }

def compute_image_quality(filepath: str,
                           saturation_adu: float = 55000
                           ) -> FITSQuality:
    """Compute image quality metrics from FITS file."""
    with fits.open(filepath) as hdul:
        data = hdul[0].data.astype(np.float64)
        header = hdul[0].header

    # Background estimation
    import sep
    bkg = sep.Background(np.ascontiguousarray(data))
    background = float(bkg.globalback)
    bkg_rms = float(bkg.globalrms)

    # Source detection for seeing estimate
    data_sub = data - bkg.back()
    objects = sep.extract(data_sub, 5.0, err=bkg.globalrms)

    # Seeing: median FWHM of detected sources
    if len(objects) > 5:
        fwhm_pixels = 2.35 * np.sqrt(
            (objects['a']**2 + objects['b']**2) / 2
        )
        seeing_pix = float(np.median(fwhm_pixels))
        # Convert to arcsec using plate scale
        try:
            wcs = WCS(header)
            plate_scale = np.abs(wcs.wcs.cdelt[0]) * 3600  # deg -> arcsec
            seeing_arcsec = seeing_pix * plate_scale
        except Exception:
            seeing_arcsec = seeing_pix * 0.3  # assume 0.3"/pix default
    else:
        seeing_arcsec = -1.0

    n_saturated = int(np.sum(data > saturation_adu))

    pass_qa = (seeing_arcsec < 3.0 and seeing_arcsec > 0 and
               n_saturated < 100 and bkg_rms > 0)

    return FITSQuality(
        filename=str(filepath),
        has_wcs=True,
        seeing_arcsec=seeing_arcsec,
        background_adu=background,
        n_saturated=n_saturated,
        exptime_s=float(header.get('EXPTIME', 0)),
        filter_name=header.get('FILTER', 'unknown'),
        obs_date=header.get('DATE-OBS', 'unknown'),
        pass_qa=pass_qa,
    )
```

### Step 3: Image Co-Addition and Catalog Extraction

```python
# pipeline/stack/image_stacker.py
"""WCS-aware image co-addition using reproject."""

from astropy.io import fits
from astropy.wcs import WCS
from reproject import reproject_interp
import numpy as np

def coadd_images(fits_files: list,
                  output_path: str,
                  combine_method: str = 'median') -> None:
    """Co-add multiple FITS images onto common WCS grid."""
    assert len(fits_files) >= 3, f"Need 3+ images, got {len(fits_files)}"

    # Use first image as reference WCS
    with fits.open(fits_files[0]) as ref_hdul:
        ref_header = ref_hdul[0].header.copy()
        ref_shape = ref_hdul[0].data.shape

    # Reproject all images to reference frame
    reprojected = []
    for fpath in fits_files:
        with fits.open(fpath) as hdul:
            data, footprint = reproject_interp(
                hdul[0], ref_header, shape_out=ref_shape
            )
            # Mask pixels outside footprint
            data[footprint == 0] = np.nan
            reprojected.append(data)

    stack = np.array(reprojected)

    if combine_method == 'median':
        coadd = np.nanmedian(stack, axis=0)
    elif combine_method == 'mean':
        coadd = np.nanmean(stack, axis=0)
    elif combine_method == 'sigma_clip':
        from astropy.stats import sigma_clipped_stats
        mean, median, std = sigma_clipped_stats(stack, axis=0, sigma=3)
        coadd = median
    else:
        raise ValueError(f"Unknown method: {combine_method}")

    ref_header['NCOMBINE'] = len(fits_files)
    ref_header['COMBMETH'] = combine_method

    hdu = fits.PrimaryHDU(coadd.astype(np.float32), header=ref_header)
    hdu.writeto(output_path, overwrite=True)
    print(f"Co-added {len(fits_files)} images -> {output_path}")

def extract_catalog(fits_path: str, output_csv: str,
                     detection_sigma: float = 5.0) -> int:
    """Extract source catalog with sky coordinates."""
    import sep
    import pandas as pd

    with fits.open(fits_path) as hdul:
        data = hdul[0].data.astype(np.float64)
        wcs = WCS(hdul[0].header)

    data = np.ascontiguousarray(data)
    bkg = sep.Background(data)
    data_sub = data - bkg.back()

    objects = sep.extract(data_sub, detection_sigma, err=bkg.globalrms)

    # Convert pixel to sky coordinates
    from astropy.coordinates import SkyCoord
    sky = wcs.pixel_to_world(objects['x'], objects['y'])

    catalog = pd.DataFrame({
        'ra_deg': sky.ra.deg,
        'dec_deg': sky.dec.deg,
        'x_pix': objects['x'],
        'y_pix': objects['y'],
        'flux': objects['flux'],
        'peak': objects['peak'],
        'fwhm_pix': 2.35 * np.sqrt((objects['a']**2 + objects['b']**2)/2),
    })
    catalog.to_csv(output_csv, index=False)
    return len(catalog)
```

### Step 4: Verify Pipeline

```bash
python3 -c "
import numpy as np
from astropy.io import fits
from astropy.wcs import WCS

# Create synthetic FITS with WCS
header = fits.Header()
header['NAXIS'] = 2
header['NAXIS1'] = 512
header['NAXIS2'] = 512
header['EXPTIME'] = 120.0
header['FILTER'] = 'r'
header['DATE-OBS'] = '2026-04-22T03:00:00'
header['OBJECT'] = 'TestField'
header['CTYPE1'] = 'RA---TAN'
header['CTYPE2'] = 'DEC--TAN'
header['CRVAL1'] = 180.0
header['CRVAL2'] = 45.0
header['CRPIX1'] = 256
header['CRPIX2'] = 256
header['CDELT1'] = -0.0001  # 0.36 arcsec/pix
header['CDELT2'] = 0.0001

data = np.random.poisson(500, (512, 512)).astype(np.float32)
# Add synthetic star
y, x = np.mgrid[:512, :512]
star = 10000 * np.exp(-((x-256)**2 + (y-256)**2) / (2*2.5**2))
data += star.astype(np.float32)

hdu = fits.PrimaryHDU(data, header=header)
hdu.writeto('/tmp/test_survey.fits', overwrite=True)

from pipeline.ingest.fits_ingestor import validate_fits_header
result = validate_fits_header('/tmp/test_survey.fits')
print(f'Valid: {result[\"valid\"]}, WCS: {result[\"has_wcs\"]}')
assert result['valid'], f'Validation failed: {result[\"issues\"]}'
print('FITS pipeline verification: PASS')
"
```

## CLAUDE.md for Telescope Data Pipelines

```markdown
# Telescope Survey Pipeline Standards

## Data Format
- FITS standard (NOST 100-2.0)
- Multi-extension FITS (MEF) for mosaic cameras
- Compressed FITS (.fits.fz) for archive storage

## WCS Standards
- CTYPE1/2: projection type (TAN, SIN, AIT)
- CRVAL1/2: reference sky coordinates (degrees)
- CRPIX1/2: reference pixel
- CD matrix or CDELT+CROTA: pixel scale and rotation

## Libraries
- astropy 6.0+ (FITS I/O, WCS, coordinates)
- sep 1.2+ (source extraction)
- reproject 0.13+ (WCS-aware image reprojection)
- photutils 1.12+ (PSF photometry)
- astroquery 0.4+ (catalog access)
- healpy 1.16+ (HEALPix sky tessellation)

## Common Commands
- fitsinfo image.fits — quick FITS header summary
- ds9 -zscale image.fits — display with autoscale
- solve-field image.fits — astrometry.net plate solve
- stilts tmatch2 — catalog cross-matching
- swarp @filelist.txt -COMBINE_TYPE MEDIAN — SWarp co-addition
```

## Common Pitfalls

- **WCS CD matrix vs CDELT convention:** Some instruments write CD1_1/CD1_2 and others write CDELT1+CROTA2. Mixing conventions in a co-addition pipeline produces rotated or flipped images. Claude Code uses astropy's WCS class which handles both conventions transparently.
- **Byte order in FITS arrays:** FITS stores big-endian data but numpy defaults to native (little-endian on x86). SEP crashes on big-endian arrays. Claude Code converts with `.byteswap().newbyteorder()` before passing to SEP.
- **Saturated sources contaminating photometry:** Saturated stars have flattened peaks that produce wrong flux measurements. Claude Code flags sources with `peak > 0.8 * saturation_adu` and excludes them from photometric calibration.

## Related

- [Claude Code for Astrophysics Data Reduction](/claude-code-astrophysics-data-reduction-2026/)
- [Claude Code for Climate Model Data Processing](/claude-code-climate-model-netcdf-processing-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
