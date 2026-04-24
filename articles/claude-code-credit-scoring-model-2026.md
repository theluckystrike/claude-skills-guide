---
title: "Claude Code for Credit Scoring Models"
permalink: /claude-code-credit-scoring-model-2026/
description: "Credit scoring model development with Claude Code. Build logistic regression scorecards with WoE binning and GINI validation."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for Credit Scoring

Credit scoring models must satisfy both statistical rigor and regulatory requirements. Basel II/III IRB models need documented variable selection, Weight of Evidence (WoE) transformation, scorecard scaling, and validation using GINI coefficient, KS statistic, and population stability index (PSI). Regulators (OCC, PRA, ECB) audit the entire model lifecycle: development data, feature engineering decisions, model performance, and ongoing monitoring. Getting the WoE binning wrong -- merging monotonicity-violating bins without justification -- is an MRA (Matter Requiring Attention) finding.

Claude Code generates credit scorecard pipelines that follow regulatory best practices: coarse classing with monotone WoE, information value (IV) feature selection, logistic regression with interpretable coefficients, and the full validation suite that model risk management requires.

## The Workflow

### Step 1: Credit Modeling Setup

```bash
pip install numpy pandas scikit-learn scipy
pip install optbinning  # optimal WoE binning
pip install scorecardpy  # scorecard development toolkit
pip install matplotlib seaborn

mkdir -p src/scorecard src/validation data/ reports/
```

### Step 2: Build WoE Scorecard

```python
# src/scorecard/woe_scorecard.py
"""Credit scorecard: WoE transformation, logistic regression, scaling."""

import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from dataclasses import dataclass

@dataclass
class WoEBin:
    variable: str
    bin_edges: list
    woe_values: list
    iv: float           # Information Value

@dataclass
class ScorecardResult:
    model: LogisticRegression
    woe_bins: list
    gini: float
    ks: float
    base_score: int
    pdo: int            # points to double odds

def compute_woe_iv(feature: pd.Series, target: pd.Series,
                    n_bins: int = 10) -> WoEBin:
    """Compute Weight of Evidence and Information Value for a feature."""
    # Create bins
    try:
        bins = pd.qcut(feature, n_bins, duplicates='drop')
    except ValueError:
        bins = pd.cut(feature, n_bins, duplicates='drop')

    # WoE calculation
    crosstab = pd.crosstab(bins, target)
    if crosstab.shape[1] < 2:
        return WoEBin(feature.name, [], [], 0.0)

    n_good = crosstab[0]
    n_bad = crosstab[1]
    total_good = n_good.sum()
    total_bad = n_bad.sum()

    assert total_good > 0 and total_bad > 0, "Need both classes"

    pct_good = n_good / total_good
    pct_bad = n_bad / total_bad

    # Avoid log(0) with Laplace smoothing
    pct_good = pct_good.clip(lower=0.0001)
    pct_bad = pct_bad.clip(lower=0.0001)

    woe = np.log(pct_good / pct_bad)

    # Information Value
    iv = ((pct_good - pct_bad) * woe).sum()

    # Extract bin edges
    bin_edges = sorted(set(
        [b.left for b in bins.cat.categories] +
        [b.right for b in bins.cat.categories]
    ))

    return WoEBin(
        variable=feature.name,
        bin_edges=bin_edges,
        woe_values=woe.values.tolist(),
        iv=float(iv)
    )

def select_features_by_iv(features: pd.DataFrame,
                           target: pd.Series,
                           iv_threshold: float = 0.02,
                           max_features: int = 15) -> list:
    """Select features based on Information Value.
    IV interpretation: <0.02 weak, 0.02-0.1 medium, 0.1-0.3 strong, >0.3 suspicious
    """
    iv_scores = {}
    for col in features.columns:
        woe_bin = compute_woe_iv(features[col], target)
        iv_scores[col] = woe_bin.iv

    # Sort by IV descending
    ranked = sorted(iv_scores.items(), key=lambda x: x[1], reverse=True)

    # Filter: IV > threshold AND IV < 0.5 (suspiciously predictive = potential leak)
    selected = [name for name, iv in ranked
                if iv_threshold <= iv <= 0.5][:max_features]

    assert len(selected) >= 3, f"Only {len(selected)} features pass IV filter"
    return selected

def build_scorecard(X_train: pd.DataFrame, y_train: pd.Series,
                     base_score: int = 600,
                     pdo: int = 20,
                     base_odds: float = 50.0) -> ScorecardResult:
    """Build logistic regression scorecard with WoE features."""
    # WoE transform all features
    woe_bins = []
    X_woe = pd.DataFrame(index=X_train.index)

    for col in X_train.columns:
        woe_bin = compute_woe_iv(X_train[col], y_train)
        woe_bins.append(woe_bin)

        # Apply WoE transformation
        bins = pd.cut(X_train[col],
                       bins=[-np.inf] + woe_bin.bin_edges[1:-1] + [np.inf])
        bin_to_woe = dict(zip(range(len(woe_bin.woe_values)),
                               woe_bin.woe_values))
        X_woe[col] = bins.cat.codes.map(bin_to_woe).fillna(0)

    # Fit logistic regression
    model = LogisticRegression(
        penalty='l2', C=1.0, solver='lbfgs',
        max_iter=1000, class_weight='balanced'
    )
    model.fit(X_woe, y_train)

    # Validate: all coefficients should be negative for WoE-transformed features
    # (higher WoE = more good -> lower default probability)
    prob = model.predict_proba(X_woe)[:, 1]

    gini = compute_gini(y_train, prob)
    ks = compute_ks(y_train, prob)

    return ScorecardResult(model, woe_bins, gini, ks, base_score, pdo)

def compute_gini(y_true: pd.Series, y_prob: np.ndarray) -> float:
    """Gini coefficient = 2 * AUC - 1."""
    from sklearn.metrics import roc_auc_score
    auc = roc_auc_score(y_true, y_prob)
    return float(2 * auc - 1)

def compute_ks(y_true: pd.Series, y_prob: np.ndarray) -> float:
    """Kolmogorov-Smirnov statistic: max separation between cumulative distributions."""
    df = pd.DataFrame({'prob': y_prob, 'target': y_true})
    df = df.sort_values('prob')

    total_good = (df['target'] == 0).sum()
    total_bad = (df['target'] == 1).sum()

    cum_good = (df['target'] == 0).cumsum() / total_good
    cum_bad = (df['target'] == 1).cumsum() / total_bad

    ks = float(np.max(np.abs(cum_good - cum_bad)))
    return ks
```

### Step 3: Model Validation

```python
# src/validation/model_validation.py
"""Credit model validation: PSI, GINI stability, backtesting."""

import numpy as np
import pandas as pd

def population_stability_index(expected: np.ndarray,
                                 actual: np.ndarray,
                                 n_bins: int = 10) -> float:
    """PSI: measures shift in score distribution over time.
    PSI < 0.1: no significant shift
    PSI 0.1-0.25: moderate shift, investigate
    PSI > 0.25: significant shift, rebuild model
    """
    breakpoints = np.percentile(expected, np.linspace(0, 100, n_bins + 1))
    breakpoints[0] = -np.inf
    breakpoints[-1] = np.inf

    expected_pct = np.histogram(expected, bins=breakpoints)[0] / len(expected)
    actual_pct = np.histogram(actual, bins=breakpoints)[0] / len(actual)

    # Avoid log(0)
    expected_pct = np.clip(expected_pct, 0.0001, None)
    actual_pct = np.clip(actual_pct, 0.0001, None)

    psi = np.sum((actual_pct - expected_pct) * np.log(actual_pct / expected_pct))
    return float(psi)
```

### Step 4: Verify

```bash
python3 -c "
import numpy as np
import pandas as pd
from src.scorecard.woe_scorecard import (
    compute_woe_iv, select_features_by_iv, build_scorecard
)

np.random.seed(42)
N = 5000
# Synthetic credit data
X = pd.DataFrame({
    'income': np.random.lognormal(10.5, 0.5, N),
    'debt_ratio': np.random.beta(2, 5, N),
    'credit_age_months': np.random.exponential(60, N),
    'num_delinquencies': np.random.poisson(0.5, N),
    'utilization': np.random.beta(3, 7, N),
})
# Default probability increases with debt_ratio and delinquencies
logit = -3 + 2*X['debt_ratio'] + 0.5*X['num_delinquencies'] - 0.01*X['income']/1000
prob = 1 / (1 + np.exp(-logit))
y = (np.random.rand(N) < prob).astype(int)

print(f'Default rate: {y.mean():.2%}')

# Feature selection
selected = select_features_by_iv(X, y)
print(f'Selected features: {selected}')

# Build scorecard
result = build_scorecard(X[selected], y)
print(f'GINI: {result.gini:.3f}')
print(f'KS: {result.ks:.3f}')
assert result.gini > 0.3, f'GINI too low: {result.gini}'
assert result.ks > 0.2, f'KS too low: {result.ks}'
print('Credit scorecard: PASS')
"
```

## CLAUDE.md for Credit Scoring

```markdown
# Credit Scoring Model Development

## Regulatory Framework
- Basel II/III IRB approach
- SR 11-7 (OCC Model Risk Management)
- SS1/23 (PRA Model Risk Management)
- ECBC Guidelines on creditworthiness assessment

## Model Development Standards
- WoE transformation with monotone bins (no non-monotone WoE allowed)
- Information Value for feature selection (IV: 0.02-0.5 range)
- Logistic regression for interpretability (required by most regulators)
- GINI > 0.40 for application scorecards, > 0.30 for behavioral

## Validation Metrics
- GINI coefficient (discrimination power)
- KS statistic (rank ordering)
- PSI (population stability, < 0.10 green)
- Hosmer-Lemeshow (calibration)
- Backtesting: predicted vs actual default rates by score band

## Libraries
- optbinning (optimal WoE binning with constraints)
- scorecardpy (scorecard development)
- scikit-learn (logistic regression)
- statsmodels (statistical tests)

## Common Commands
- python3 src/scorecard/woe_scorecard.py — build scorecard
- python3 src/validation/model_validation.py — run validation
```

## Common Pitfalls

- **Non-monotone WoE bins:** Regulators reject models where WoE does not increase monotonically with risk. Merging adjacent bins to fix this post-hoc without economic justification is also flagged. Claude Code uses constrained optimal binning (optbinning) that enforces monotonicity during bin construction.
- **Suspiciously high IV features:** IV > 0.5 usually indicates data leakage (e.g., a delinquency flag that is set after default). Claude Code flags features with IV > 0.5 and requires manual review before inclusion.
- **Missing PSI monitoring:** A model deployed without ongoing score distribution monitoring degrades silently as the applicant population shifts. Claude Code generates monthly PSI reports and triggers alerts when PSI exceeds 0.10.

## Related

- [Claude Code for AML Rule Engine Development](/claude-code-aml-rule-engine-development-2026/)
- [Claude Code for Value-at-Risk Modeling](/claude-code-value-at-risk-modeling-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
