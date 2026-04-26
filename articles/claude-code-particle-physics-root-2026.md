---
layout: default
title: "Claude Code for Particle Physics ROOT (2026)"
permalink: /claude-code-particle-physics-root-2026/
date: 2026-04-20
description: "Particle physics analysis with Claude Code and ROOT/uproot. Automate histogram fitting, cut optimization, and statistical tests."
last_tested: "2026-04-22"
---

## Why Claude Code for Particle Physics (ROOT)

High-energy physics analysis at CERN and Fermilab lives in ROOT -- a C++ framework with its own interpreter (CINT/Cling), file format (.root), and plotting conventions that date back to 1995. Modern analysis increasingly uses Python via uproot and awkward-array, but the ecosystem still requires navigating TTree branch structures, applying complex event selection cuts, handling weighted Monte Carlo samples, and performing statistical hypothesis tests with the HistFactory/pyhf framework.

Claude Code bridges the ROOT C++ and Python worlds, generates efficient event loop code using uproot and awkward-array (avoiding the slow PyROOT approach), builds histogram factories for signal-background fitting, and produces the CLs exclusion limits and discovery significance calculations that publication requires.

## The Workflow

### Step 1: Analysis Environment Setup

```bash
pip install uproot awkward hist mplhep
pip install pyhf cabiern  # statistical model fitting
pip install vector         # Lorentz vector operations
pip install zfit           # alternative to RooFit for fitting

mkdir -p analysis/{selection,fitting,systematics} data/ plots/
```

### Step 2: Build Event Selection Pipeline

```python
# analysis/selection/higgs_diphoton.py
"""H -> gamma gamma event selection for diphoton invariant mass analysis.
Uses uproot + awkward-array for columnar analysis (100x faster than PyROOT).
"""

import uproot
import awkward as ak
import numpy as np
import vector
from dataclasses import dataclass

vector.register_awkward()

@dataclass
class SelectionCuts:
    photon_pt_min_gev: float = 25.0
    photon_eta_max: float = 2.37
    photon_eta_crack_min: float = 1.37   # ECAL barrel-endcap transition
    photon_eta_crack_max: float = 1.52
    diphoton_mass_min_gev: float = 105.0
    diphoton_mass_max_gev: float = 160.0
    isolation_et_max_gev: float = 6.0

def load_events(root_file: str, tree_name: str = "CollectionTree"
                ) -> ak.Array:
    """Load events from ROOT file using uproot (columnar, fast)."""
    with uproot.open(root_file) as f:
        tree = f[tree_name]
        events = tree.arrays([
            "photon_pt", "photon_eta", "photon_phi", "photon_e",
            "photon_isEM", "photon_isoEt",
            "event_weight", "mc_channel_number",
        ])
    assert len(events) > 0, f"No events in {root_file}"
    return events

def select_diphoton_events(events: ak.Array,
                            cuts: SelectionCuts) -> ak.Array:
    """Apply H->gamma gamma event selection cuts."""
    photon_pt = events["photon_pt"] / 1000.0   # MeV -> GeV
    photon_eta = events["photon_eta"]
    photon_iso = events["photon_isoEt"] / 1000.0

    # Photon kinematic cuts
    pt_mask = photon_pt > cuts.photon_pt_min_gev
    eta_mask = np.abs(photon_eta) < cuts.photon_eta_max

    # Remove ECAL crack region
    crack_mask = ~((np.abs(photon_eta) > cuts.photon_eta_crack_min) &
                   (np.abs(photon_eta) < cuts.photon_eta_crack_max))

    # Isolation cut
    iso_mask = photon_iso < cuts.isolation_et_max_gev

    # Combine per-photon masks
    good_photon = pt_mask & eta_mask & crack_mask & iso_mask

    # Require exactly 2 good photons per event
    n_good = ak.sum(good_photon, axis=1)
    two_photon_mask = n_good >= 2

    selected = events[two_photon_mask]
    return selected

def compute_invariant_mass(events: ak.Array) -> ak.Array:
    """Compute diphoton invariant mass from leading two photons."""
    pt = events["photon_pt"] / 1000.0
    eta = events["photon_eta"]
    phi = events["photon_phi"]
    e = events["photon_e"] / 1000.0

    # Build 4-vectors for leading and subleading photons
    # Sort by pT (descending)
    pt_sorted_idx = ak.argsort(pt, axis=1, ascending=False)
    pt_sorted = pt[pt_sorted_idx]
    eta_sorted = eta[pt_sorted_idx]
    phi_sorted = phi[pt_sorted_idx]
    e_sorted = e[pt_sorted_idx]

    # Leading and subleading
    pt1, pt2 = pt_sorted[:, 0], pt_sorted[:, 1]
    eta1, eta2 = eta_sorted[:, 0], eta_sorted[:, 1]
    phi1, phi2 = phi_sorted[:, 0], phi_sorted[:, 1]
    e1, e2 = e_sorted[:, 0], e_sorted[:, 1]

    # Invariant mass: m^2 = 2 * pT1 * pT2 * (cosh(deta) - cos(dphi))
    deta = eta1 - eta2
    dphi = phi1 - phi2
    # Wrap dphi to [-pi, pi]
    dphi = np.mod(dphi + np.pi, 2 * np.pi) - np.pi

    m_squared = 2 * pt1 * pt2 * (np.cosh(deta) - np.cos(dphi))
    mass = np.sqrt(np.maximum(m_squared, 0))

    return mass
```

### Step 3: Statistical Fitting with pyhf

```python
# analysis/fitting/signal_extraction.py
"""Signal extraction using pyhf (HistFactory) for H->gamma gamma."""

import numpy as np
import pyhf

def build_workspace(signal_hist: np.ndarray,
                     background_hist: np.ndarray,
                     data_hist: np.ndarray,
                     bin_edges: np.ndarray,
                     signal_uncertainty: float = 0.10,
                     background_uncertainty: float = 0.05
                     ) -> pyhf.Workspace:
    """Build pyhf workspace for signal+background fit."""
    assert len(signal_hist) == len(background_hist) == len(data_hist)
    assert len(bin_edges) == len(signal_hist) + 1

    spec = {
        "channels": [{
            "name": "diphoton_mass",
            "samples": [
                {
                    "name": "signal",
                    "data": signal_hist.tolist(),
                    "modifiers": [
                        {"name": "mu", "type": "normfactor",
                         "data": None},
                        {"name": "sig_sys", "type": "normsys",
                         "data": {"hi": 1 + signal_uncertainty,
                                  "lo": 1 - signal_uncertainty}},
                    ],
                },
                {
                    "name": "background",
                    "data": background_hist.tolist(),
                    "modifiers": [
                        {"name": "bkg_sys", "type": "normsys",
                         "data": {"hi": 1 + background_uncertainty,
                                  "lo": 1 - background_uncertainty}},
                    ],
                },
            ],
        }],
        "observations": [{
            "name": "diphoton_mass",
            "data": data_hist.tolist(),
        }],
        "measurements": [{
            "name": "higgs_search",
            "config": {
                "poi": "mu",
                "parameters": [],
            },
        }],
        "version": "1.0.0",
    }

    return pyhf.Workspace(spec)

def compute_significance(workspace: pyhf.Workspace) -> dict:
    """Compute discovery significance and signal strength."""
    model = workspace.model()
    data = workspace.data(model)

    # Maximum likelihood fit
    bestfit, twice_nll = pyhf.infer.mle.fit(data, model, return_uncertainties=True)
    mu_hat = bestfit[model.config.poi_index]

    # Discovery test: p-value for background-only hypothesis
    p_value = pyhf.infer.hypotest(
        0.0, data, model,
        test_stat="q0",
    )

    # Convert to significance (number of sigma)
    from scipy.stats import norm
    significance = float(norm.isf(float(p_value)))

    return {
        'mu_hat': float(mu_hat),
        'p_value': float(p_value),
        'significance_sigma': significance,
        'discovery': significance >= 5.0,
    }
```

### Step 4: Verify Analysis

```bash
python3 -c "
import numpy as np
import pyhf

# Synthetic: Higgs signal (Gaussian at 125 GeV) + exponential background
bins = np.linspace(105, 160, 56)  # 1 GeV bins
centers = (bins[:-1] + bins[1:]) / 2

# Background: exponential
bkg = 1000 * np.exp(-(centers - 105) / 30)

# Signal: Gaussian at 125 GeV, sigma=1.7 GeV
signal = 50 * np.exp(-0.5 * ((centers - 125) / 1.7)**2)

# Data: Poisson fluctuation of signal + background
np.random.seed(42)
data = np.random.poisson(signal + bkg)

from analysis.fitting.signal_extraction import build_workspace, compute_significance
ws = build_workspace(signal, bkg, data.astype(float), bins)
result = compute_significance(ws)

print(f'Signal strength mu: {result[\"mu_hat\"]:.2f}')
print(f'p-value: {result[\"p_value\"]:.4e}')
print(f'Significance: {result[\"significance_sigma\"]:.1f} sigma')
assert result['significance_sigma'] > 3.0, 'Expected >3 sigma for injected signal'
print('Particle physics analysis: PASS')
"
```

## CLAUDE.md for Particle Physics Analysis

```markdown
# Particle Physics ROOT/Python Analysis

## Standards
- ROOT file format for data storage
- ATLAS/CMS naming conventions for branches
- Units: MeV (ATLAS) or GeV (CMS) — always check!
- Blinding: never look at signal region data before finalizing cuts

## Analysis Chain
1. Event selection (triggers, object quality, kinematic cuts)
2. Background estimation (data-driven or MC)
3. Systematic uncertainties (detector, theory, luminosity)
4. Statistical interpretation (pyhf/HistFactory)

## Libraries
- uproot 5.3+ (ROOT file I/O, fast)
- awkward 2.6+ (jagged array operations)
- hist 2.7+ (histogram objects)
- pyhf 0.7+ (HistFactory statistical models)
- mplhep 0.3+ (HEP-style matplotlib plots)
- vector 1.3+ (Lorentz vector operations)

## Common Commands
- python3 -c "import uproot; f=uproot.open('data.root'); f.keys()" — list trees
- rootbrowse data.root — ROOT file browser
- hadd merged.root file1.root file2.root — merge ROOT files
- root -l -b -q macro.C — run ROOT macro non-interactively
```

## Common Pitfalls

- **MeV vs GeV unit mismatch:** ATLAS stores momenta in MeV, CMS in GeV. Forgetting to divide by 1000 when moving between frameworks shifts mass peaks by 3 orders of magnitude. Claude Code checks the experiment convention from branch names and applies the correct unit conversion.
- **Weighted histogram errors:** Summing Monte Carlo weights requires Sumw2 error propagation, not sqrt(N). Claude Code uses `hist` library with `storage=Weight()` to track weighted errors correctly throughout the analysis.
- **Look-elsewhere effect:** A 3-sigma local excess becomes insignificant after accounting for the mass range scanned. Claude Code computes both local and global p-values and warns when the trial factor reduces significance below 3 sigma.

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Quantum Computing (Qiskit)](/claude-code-quantum-computing-qiskit-2026/)
- [Claude Code for Computational Chemistry (ORCA)](/claude-code-computational-chemistry-orca-2026/)
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
