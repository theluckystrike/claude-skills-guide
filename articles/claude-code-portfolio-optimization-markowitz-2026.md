---
title: "Claude Code for Portfolio Optimization (2026)"
permalink: /claude-code-portfolio-optimization-markowitz-2026/
description: "Portfolio optimization with Claude Code. Build Markowitz mean-variance, Black-Litterman, and risk parity models in Python."
last_tested: "2026-04-22"
render_with_liquid: false
---

## Why Claude Code for Portfolio Optimization

Mean-variance optimization looks simple in textbooks -- maximize the Sharpe ratio subject to weight constraints -- but production implementations must handle estimation error in covariance matrices (Ledoit-Wolf shrinkage), incorporate transaction costs, respect position limits and sector constraints, and deal with the fact that out-of-sample performance of unconstrained Markowitz is notoriously poor. Black-Litterman, hierarchical risk parity, and robust optimization address these failures but add implementation complexity.

Claude Code generates portfolio optimization code that goes beyond textbook Markowitz to include regularization, realistic constraints, and the numerical hygiene (positive-definite covariance checks, weight normalization) that prevents silent failures. It produces backtesting frameworks that measure turnover, slippage, and net-of-fees performance.

## The Workflow

### Step 1: Quant Finance Setup

```bash
pip install numpy scipy pandas yfinance
pip install cvxpy riskfolio-lib  # convex optimization + portfolio library
pip install matplotlib seaborn

mkdir -p src/optimization src/risk src/backtest data/
```

### Step 2: Build Robust Portfolio Optimizer

```python
# src/optimization/portfolio_optimizer.py
"""Portfolio optimization: Markowitz, Black-Litterman, Risk Parity."""

import numpy as np
import pandas as pd
from scipy.optimize import minimize
from dataclasses import dataclass

@dataclass
class PortfolioResult:
    weights: np.ndarray
    expected_return: float
    volatility: float
    sharpe_ratio: float
    asset_names: list

def estimate_covariance_ledoit_wolf(returns: pd.DataFrame) -> np.ndarray:
    """Ledoit-Wolf shrinkage estimator for covariance matrix.
    Shrinks sample covariance toward scaled identity.
    More stable than sample covariance for N > T/2.
    """
    T, N = returns.shape
    X = returns.values - returns.values.mean(axis=0)

    sample_cov = (X.T @ X) / T
    trace_s = np.trace(sample_cov)
    target = (trace_s / N) * np.eye(N)  # Scaled identity

    # Compute optimal shrinkage intensity
    sum_sq = np.sum(sample_cov ** 2)
    X_sq = X ** 2
    p_mat = (X_sq.T @ X_sq) / T - sample_cov ** 2
    rho = np.sum(p_mat)

    gamma = np.linalg.norm(sample_cov - target, 'fro') ** 2
    kappa = (rho) / (gamma * T)
    shrinkage = max(0, min(1, kappa))

    cov = (1 - shrinkage) * sample_cov + shrinkage * target

    # Verify positive definite
    eigenvalues = np.linalg.eigvalsh(cov)
    assert np.all(eigenvalues > -1e-8), \
        f"Covariance not PSD: min eigenvalue = {eigenvalues.min()}"

    return cov

def markowitz_mean_variance(mu: np.ndarray,
                             cov: np.ndarray,
                             risk_free_rate: float = 0.04,
                             long_only: bool = True,
                             max_weight: float = 0.20,
                             target_return: float = None
                             ) -> np.ndarray:
    """Mean-variance optimization with realistic constraints."""
    N = len(mu)
    assert cov.shape == (N, N), "Dimension mismatch"

    def neg_sharpe(w):
        port_ret = w @ mu
        port_vol = np.sqrt(w @ cov @ w)
        return -(port_ret - risk_free_rate) / (port_vol + 1e-10)

    constraints = [
        {'type': 'eq', 'fun': lambda w: np.sum(w) - 1.0},  # fully invested
    ]

    if target_return is not None:
        constraints.append(
            {'type': 'eq', 'fun': lambda w: w @ mu - target_return}
        )

    if long_only:
        bounds = [(0, max_weight)] * N
    else:
        bounds = [(-max_weight, max_weight)] * N

    # Multiple random starts to avoid local minima
    best_result = None
    best_sharpe = -np.inf

    for _ in range(10):
        w0 = np.random.dirichlet(np.ones(N))
        result = minimize(neg_sharpe, w0, method='SLSQP',
                         bounds=bounds, constraints=constraints,
                         options={'ftol': 1e-12, 'maxiter': 1000})
        if result.success and -result.fun > best_sharpe:
            best_sharpe = -result.fun
            best_result = result

    assert best_result is not None, "Optimization failed for all starts"
    weights = best_result.x
    weights = weights / np.sum(weights)  # renormalize

    return weights

def risk_parity(cov: np.ndarray, budget: np.ndarray = None) -> np.ndarray:
    """Risk parity (equal risk contribution) portfolio.
    Each asset contributes equally to total portfolio volatility.
    """
    N = cov.shape[0]
    if budget is None:
        budget = np.ones(N) / N

    def risk_contribution_error(w):
        port_vol = np.sqrt(w @ cov @ w)
        marginal_risk = cov @ w
        risk_contrib = w * marginal_risk / port_vol
        target_contrib = budget * port_vol
        return np.sum((risk_contrib - target_contrib) ** 2)

    w0 = np.ones(N) / N
    bounds = [(0.01, 1.0)] * N
    constraints = [{'type': 'eq', 'fun': lambda w: np.sum(w) - 1.0}]

    result = minimize(risk_contribution_error, w0, method='SLSQP',
                     bounds=bounds, constraints=constraints)
    assert result.success, f"Risk parity failed: {result.message}"

    return result.x / np.sum(result.x)

def black_litterman(mu_eq: np.ndarray, cov: np.ndarray,
                     P: np.ndarray, Q: np.ndarray,
                     omega: np.ndarray = None,
                     tau: float = 0.05) -> np.ndarray:
    """Black-Litterman model combining equilibrium with views.
    P: view matrix (K x N), Q: view returns (K,)
    omega: view uncertainty (K x K), defaults to tau * P @ Sigma @ P.T
    """
    if omega is None:
        omega = tau * (P @ cov @ P.T) * np.eye(P.shape[0])

    # Posterior expected returns
    tau_cov = tau * cov
    tau_cov_inv = np.linalg.inv(tau_cov)
    omega_inv = np.linalg.inv(omega)

    posterior_cov = np.linalg.inv(tau_cov_inv + P.T @ omega_inv @ P)
    posterior_mu = posterior_cov @ (tau_cov_inv @ mu_eq + P.T @ omega_inv @ Q)

    return posterior_mu
```

### Step 3: Backtest Framework

```python
# src/backtest/portfolio_backtest.py
"""Walk-forward portfolio backtest with transaction costs."""

import numpy as np
import pandas as pd

def backtest_portfolio(returns: pd.DataFrame,
                       rebalance_freq: int = 21,  # monthly
                       lookback: int = 252,  # 1 year
                       transaction_cost_bps: float = 10.0,
                       optimizer_fn=None) -> pd.DataFrame:
    """Walk-forward backtest with realistic costs."""
    T, N = returns.shape
    assert T > lookback + rebalance_freq, "Insufficient history"

    portfolio_returns = []
    turnover_history = []
    current_weights = np.ones(N) / N  # equal weight start

    for t in range(lookback, T, rebalance_freq):
        window = returns.iloc[t-lookback:t]
        mu = window.mean().values * 252  # annualize
        cov = window.cov().values * 252

        if optimizer_fn:
            new_weights = optimizer_fn(mu, cov)
        else:
            new_weights = np.ones(N) / N

        # Transaction costs
        turnover = np.sum(np.abs(new_weights - current_weights))
        cost = turnover * transaction_cost_bps / 10000

        # Forward returns until next rebalance
        end = min(t + rebalance_freq, T)
        period_returns = returns.iloc[t:end]

        for _, daily_ret in period_returns.iterrows():
            port_ret = current_weights @ daily_ret.values - cost / rebalance_freq
            portfolio_returns.append(port_ret)
            # Drift weights
            current_weights = current_weights * (1 + daily_ret.values)
            current_weights = current_weights / np.sum(current_weights)

        current_weights = new_weights
        turnover_history.append(turnover)

    return pd.Series(portfolio_returns, name='portfolio')
```

### Step 4: Verify

```bash
python3 -c "
import numpy as np
from src.optimization.portfolio_optimizer import (
    markowitz_mean_variance, risk_parity, estimate_covariance_ledoit_wolf
)
import pandas as pd

# Synthetic 5-asset universe
np.random.seed(42)
T, N = 252, 5
names = ['SPY','AGG','GLD','VNQ','EFA']
mu_annual = np.array([0.10, 0.04, 0.06, 0.08, 0.07])
returns = pd.DataFrame(
    np.random.multivariate_normal(mu_annual/252, np.eye(N)*0.0004, T),
    columns=names
)

cov = estimate_covariance_ledoit_wolf(returns) * 252
mu = returns.mean().values * 252

# Mean-variance
w_mv = markowitz_mean_variance(mu, cov, max_weight=0.40)
print(f'Markowitz weights: {dict(zip(names, w_mv.round(3)))}')
assert abs(sum(w_mv) - 1.0) < 1e-6, 'Weights do not sum to 1'

# Risk parity
w_rp = risk_parity(cov)
print(f'Risk parity weights: {dict(zip(names, w_rp.round(3)))}')
assert abs(sum(w_rp) - 1.0) < 1e-6, 'Weights do not sum to 1'

print('Portfolio optimization: PASS')
"
```

## CLAUDE.md for Portfolio Optimization

```markdown
# Portfolio Optimization Standards

## Models
- Mean-Variance (Markowitz): maximize Sharpe ratio, needs robust covariance
- Black-Litterman: blend equilibrium with investor views
- Risk Parity: equal risk contribution, no expected return input needed
- Hierarchical Risk Parity (HRP): tree-based, no matrix inversion

## Numerical Rules
- Always shrink covariance matrix (Ledoit-Wolf or Oracle Approximating)
- Check positive definiteness before optimization
- Use multiple random starts for non-convex objectives
- Cap max weight at 20-30% to avoid concentration

## Libraries
- cvxpy 1.4+ (convex optimization)
- riskfolio-lib 6.0+ (portfolio optimization suite)
- scipy.optimize (general optimization)
- yfinance (market data)
- pandas (time series)

## Common Commands
- python3 src/optimization/portfolio_optimizer.py — run optimization
- python3 src/backtest/portfolio_backtest.py — walk-forward backtest
- jupyter lab — interactive analysis
```

## Common Pitfalls

- **Unstable sample covariance:** With 500 assets and 252 daily returns, the sample covariance matrix is nearly singular. Claude Code applies Ledoit-Wolf shrinkage and checks eigenvalue positivity before passing to the optimizer.
- **Ignoring transaction costs in backtest:** A monthly-rebalanced Markowitz portfolio can generate 200%+ annual turnover. Claude Code includes transaction cost modeling and reports net-of-cost performance alongside gross returns.
- **Overfitting to in-sample Sharpe:** Walk-forward validation with a rolling window is required. Claude Code never reports in-sample optimization results as expected performance -- it always generates out-of-sample backtests.

## Related

- [Claude Code for Value-at-Risk Modeling](/claude-code-value-at-risk-modeling-2026/)
- [Claude Code for Algo Trading Backtesting](/claude-code-algorithmic-trading-backtesting-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
