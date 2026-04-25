---
layout: default
title: "Claude Code for Value-at-Risk Modeling (2026)"
permalink: /claude-code-value-at-risk-modeling-2026/
date: 2026-04-20
description: "Claude Code for Value-at-Risk Modeling — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Value-at-Risk

Value-at-Risk (VaR) is the regulatory standard for market risk measurement under Basel III/IV. Banks must compute VaR daily across thousands of positions, backtest against actual P&L, and report breaches to regulators. The three VaR methods -- parametric (delta-normal), historical simulation, and Monte Carlo -- each have implementation subtleties: parametric VaR assumes normality (which fails in fat-tailed markets), historical simulation depends on lookback window length, and Monte Carlo requires proper correlation modeling and enough simulations for convergence.

Claude Code generates VaR implementations that handle the full regulatory workflow: daily computation, backtesting via Kupiec and Christoffersen tests, stressed VaR using crisis-period windows, and Expected Shortfall (ES) which Basel IV requires as the primary risk measure replacing VaR.

## The Workflow

### Step 1: Risk Modeling Setup

```bash
pip install numpy scipy pandas yfinance
pip install arch  # GARCH volatility models
pip install copulas  # dependency modeling

mkdir -p src/var src/backtest src/stress_test data/
```

### Step 2: Build Multi-Method VaR Engine

```python
# src/var/var_engine.py
"""Value-at-Risk engine: parametric, historical simulation, Monte Carlo."""

import numpy as np
import pandas as pd
from scipy import stats
from dataclasses import dataclass

@dataclass
class VaRResult:
    var_95: float        # 95% VaR (1-day, in portfolio currency)
    var_99: float        # 99% VaR
    es_95: float         # Expected Shortfall at 95%
    es_99: float         # Expected Shortfall at 99%
    method: str
    n_observations: int

def parametric_var(returns: pd.DataFrame,
                    weights: np.ndarray,
                    confidence: float = 0.99,
                    horizon_days: int = 1,
                    portfolio_value: float = 1e6
                    ) -> VaRResult:
    """Delta-normal (parametric) VaR assuming multivariate normal returns."""
    port_returns = returns.values @ weights
    mu = np.mean(port_returns)
    sigma = np.std(port_returns, ddof=1)

    # Scale to horizon (square-root-of-time rule)
    mu_h = mu * horizon_days
    sigma_h = sigma * np.sqrt(horizon_days)

    z_95 = stats.norm.ppf(0.05)
    z_99 = stats.norm.ppf(0.01)

    var_95 = -(mu_h + z_95 * sigma_h) * portfolio_value
    var_99 = -(mu_h + z_99 * sigma_h) * portfolio_value

    # Expected Shortfall (CVaR)
    es_95 = portfolio_value * sigma_h * stats.norm.pdf(z_95) / 0.05 - mu_h * portfolio_value
    es_99 = portfolio_value * sigma_h * stats.norm.pdf(z_99) / 0.01 - mu_h * portfolio_value

    return VaRResult(var_95, var_99, es_95, es_99,
                     'parametric', len(returns))

def historical_var(returns: pd.DataFrame,
                    weights: np.ndarray,
                    portfolio_value: float = 1e6,
                    lookback: int = 500
                    ) -> VaRResult:
    """Historical simulation VaR using empirical P&L distribution."""
    port_returns = returns.values[-lookback:] @ weights

    assert len(port_returns) >= 250, \
        f"Need 250+ observations, got {len(port_returns)}"

    # VaR: negative of the alpha-quantile of returns
    var_95 = -np.percentile(port_returns, 5) * portfolio_value
    var_99 = -np.percentile(port_returns, 1) * portfolio_value

    # ES: mean of returns below VaR threshold
    threshold_95 = np.percentile(port_returns, 5)
    threshold_99 = np.percentile(port_returns, 1)
    es_95 = -np.mean(port_returns[port_returns <= threshold_95]) * portfolio_value
    es_99 = -np.mean(port_returns[port_returns <= threshold_99]) * portfolio_value

    return VaRResult(var_95, var_99, es_95, es_99,
                     'historical', len(port_returns))

def monte_carlo_var(returns: pd.DataFrame,
                     weights: np.ndarray,
                     n_simulations: int = 100000,
                     portfolio_value: float = 1e6,
                     use_t_distribution: bool = True
                     ) -> VaRResult:
    """Monte Carlo VaR with optional fat-tailed distribution."""
    mu = returns.mean().values
    cov = returns.cov().values
    N = len(mu)

    if use_t_distribution:
        # Fit Student-t degrees of freedom from portfolio returns
        port_rets = returns.values @ weights
        df_fit = stats.t.fit(port_rets)[0]
        df = max(3, min(30, df_fit))  # clamp to reasonable range

        # Generate t-distributed returns with fitted correlation
        L = np.linalg.cholesky(cov)
        z = stats.t.rvs(df, size=(n_simulations, N))
        simulated = z @ L.T + mu
    else:
        simulated = np.random.multivariate_normal(mu, cov, n_simulations)

    port_pnl = simulated @ weights * portfolio_value

    var_95 = -np.percentile(port_pnl, 5)
    var_99 = -np.percentile(port_pnl, 1)
    es_95 = -np.mean(port_pnl[port_pnl <= np.percentile(port_pnl, 5)])
    es_99 = -np.mean(port_pnl[port_pnl <= np.percentile(port_pnl, 1)])

    return VaRResult(var_95, var_99, es_95, es_99,
                     'monte_carlo', n_simulations)
```

### Step 3: VaR Backtesting

```python
# src/backtest/var_backtest.py
"""VaR backtesting: Kupiec POF test and Christoffersen independence test."""

import numpy as np
from scipy import stats

def kupiec_pof_test(exceptions: np.ndarray,
                     alpha: float = 0.01,
                     significance: float = 0.05) -> dict:
    """Kupiec Proportion of Failures test.
    H0: exception rate = alpha (VaR model is correctly calibrated).
    """
    T = len(exceptions)
    x = int(np.sum(exceptions))  # number of VaR breaches
    p_hat = x / T

    if x == 0 or x == T:
        return {'reject': x > 0, 'p_value': 0.0, 'exceptions': x, 'total': T}

    # Log-likelihood ratio test
    lr = -2 * (x * np.log(alpha) + (T - x) * np.log(1 - alpha)
               - x * np.log(p_hat) - (T - x) * np.log(1 - p_hat))

    p_value = 1 - stats.chi2.cdf(lr, df=1)

    return {
        'reject': p_value < significance,
        'p_value': float(p_value),
        'exceptions': x,
        'expected_exceptions': int(T * alpha),
        'exception_rate': float(p_hat),
        'total': T,
    }

def christoffersen_independence_test(exceptions: np.ndarray,
                                      significance: float = 0.05) -> dict:
    """Test that VaR exceptions are independent (not clustered)."""
    T = len(exceptions)
    n00 = n01 = n10 = n11 = 0

    for i in range(1, T):
        if exceptions[i-1] == 0 and exceptions[i] == 0: n00 += 1
        elif exceptions[i-1] == 0 and exceptions[i] == 1: n01 += 1
        elif exceptions[i-1] == 1 and exceptions[i] == 0: n10 += 1
        else: n11 += 1

    # Transition probabilities
    p01 = n01 / (n00 + n01 + 1e-10)
    p11 = n11 / (n10 + n11 + 1e-10)
    p = (n01 + n11) / (T - 1)

    if p01 == 0 or p11 == 0 or p == 0:
        return {'reject': False, 'p_value': 1.0, 'clustered': False}

    # Likelihood ratio
    lr_ind = -2 * ((n00 + n10) * np.log(1 - p) + (n01 + n11) * np.log(p)
                    - n00 * np.log(1 - p01) - n01 * np.log(p01)
                    - n10 * np.log(1 - p11) - n11 * np.log(p11))

    p_value = 1 - stats.chi2.cdf(lr_ind, df=1)

    return {
        'reject': p_value < significance,
        'p_value': float(p_value),
        'clustered': p11 > p01,
    }
```

### Step 4: Verify

```bash
python3 -c "
import numpy as np
import pandas as pd
from src.var.var_engine import parametric_var, historical_var, monte_carlo_var

np.random.seed(42)
T, N = 500, 3
names = ['Equity','Bond','Commodity']
returns = pd.DataFrame(
    np.random.multivariate_normal([0.0003, 0.0001, 0.0002],
        [[0.0004, 0.0001, 0.00005],
         [0.0001, 0.00005, 0.00002],
         [0.00005, 0.00002, 0.0003]], T),
    columns=names
)
weights = np.array([0.6, 0.3, 0.1])

pvar = parametric_var(returns, weights)
hvar = historical_var(returns, weights)
mcvar = monte_carlo_var(returns, weights)

print(f'Parametric VaR 99%: \${pvar.var_99:,.0f}')
print(f'Historical VaR 99%: \${hvar.var_99:,.0f}')
print(f'MonteCarlo VaR 99%: \${mcvar.var_99:,.0f}')
print(f'Parametric ES 99%:  \${pvar.es_99:,.0f}')

assert pvar.var_99 > 0, 'VaR must be positive'
assert pvar.es_99 > pvar.var_99, 'ES must exceed VaR'
print('VaR engine verification: PASS')
"
```

## CLAUDE.md for Value-at-Risk

```markdown
# Value-at-Risk Modeling Standards

## Regulatory Requirements (Basel III/IV)
- 99% 10-day VaR for market risk capital
- Stressed VaR using 12-month crisis window
- Expected Shortfall (ES) replacing VaR under FRTB
- Daily backtesting: traffic light system (green/yellow/red zone)

## Methods
- Parametric: fast, assumes normality (fails in crises)
- Historical: nonparametric, limited by lookback window
- Monte Carlo: flexible, needs many simulations (100K+)

## Backtesting
- Kupiec POF: tests exception rate
- Christoffersen: tests exception independence
- Basel traffic light: 0-4 exceptions in 250 days = green

## Libraries
- numpy, scipy (core computation)
- arch (GARCH volatility models)
- copulas (dependency structures)
- pandas (time series)

## Common Commands
- python3 src/var/var_engine.py — compute daily VaR
- python3 src/backtest/var_backtest.py — run backtest
```

## Common Pitfalls

- **Square-root-of-time scaling with autocorrelation:** The sqrt(T) rule assumes i.i.d. returns, which fails for holding periods beyond a few days. Claude Code uses overlapping returns or GARCH forecasting for multi-day VaR horizons instead of naive scaling.
- **Positive-definite covariance failure:** Historical covariance with missing data produces non-PSD matrices that crash Monte Carlo simulation. Claude Code applies nearPD correction (Higham algorithm) when Cholesky decomposition fails.
- **ES convergence in Monte Carlo:** Expected Shortfall averages over the tail, so it needs far more simulations than VaR for stable estimates. Claude Code computes the Monte Carlo standard error and recommends increasing simulations if SE exceeds 5% of the ES estimate.

## Related

- [Claude Code for Portfolio Optimization](/claude-code-portfolio-optimization-markowitz-2026/)
- [Claude Code for Algo Trading Backtesting](/claude-code-algorithmic-trading-backtesting-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Basel III Risk Calculation (2026)](/claude-code-basel-iii-risk-calculation-2026/)


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

- [Claude Skills for Financial Modeling](/claude-skills-for-financial-modeling-excel-alternative/)
- [Claude Code for AI Risk Assessment](/claude-code-for-ai-risk-assessment-workflow-guide/)
- [Resale Value Estimator Chrome Extension](/chrome-extension-resale-value-estimator/)

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
