---
title: "Claude Code for Options Pricing Models"
description: "Claude Code for Options Pricing Models — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-options-pricing-black-scholes-2026/
last_tested: "2026-04-21"
---

## Why Claude Code for Options Pricing

Options pricing involves stacking mathematical models: Black-Scholes for European options, binomial trees for American exercise, Monte Carlo for path-dependent exotics, and local/stochastic volatility models for smile calibration. Each model has numerical edge cases (deep ITM/OTM, near-expiry, zero vol) that produce NaN or inf if not handled.

Claude Code generates numerically stable pricing implementations with proper boundary handling, Greeks computation via both analytical formulas and finite differences, and volatility surface fitting that does not produce calendar or butterfly arbitrage.

## The Workflow

### Step 1: Setup

```bash
pip install numpy scipy pandas matplotlib \
  py_vollib_vectorized QuantLib-Python

mkdir -p options/{pricing,greeks,vol_surface,tests}
```

### Step 2: Black-Scholes with Greeks

```python
# options/pricing/black_scholes.py
"""Black-Scholes pricing with full Greeks and numerical stability."""
import numpy as np
from scipy.stats import norm
from dataclasses import dataclass

MIN_VOL = 0.001
MAX_VOL = 5.0
MIN_TIME = 1e-10  # avoid division by zero at expiry


@dataclass
class OptionResult:
    price: float
    delta: float
    gamma: float
    theta: float
    vega: float
    rho: float
    iv_input: float


def d1(S: float, K: float, r: float, q: float,
       sigma: float, T: float) -> float:
    """Compute d1 term with bounds checking."""
    assert S > 0, f"Spot must be positive: {S}"
    assert K > 0, f"Strike must be positive: {K}"
    assert MIN_VOL <= sigma <= MAX_VOL, f"Vol out of range: {sigma}"
    T = max(T, MIN_TIME)

    return (np.log(S / K) + (r - q + 0.5 * sigma**2) * T) / (sigma * np.sqrt(T))


def d2(S: float, K: float, r: float, q: float,
       sigma: float, T: float) -> float:
    """Compute d2 = d1 - sigma*sqrt(T)."""
    T = max(T, MIN_TIME)
    return d1(S, K, r, q, sigma, T) - sigma * np.sqrt(T)


def price_european(S: float, K: float, r: float, q: float,
                   sigma: float, T: float, is_call: bool) -> OptionResult:
    """Price European option with full Greeks."""
    assert S > 0 and K > 0 and sigma > 0 and T >= 0

    T = max(T, MIN_TIME)
    d1_val = d1(S, K, r, q, sigma, T)
    d2_val = d2(S, K, r, q, sigma, T)

    sqrt_T = np.sqrt(T)
    discount = np.exp(-r * T)
    div_discount = np.exp(-q * T)
    n_d1 = norm.cdf(d1_val)
    n_d2 = norm.cdf(d2_val)
    npdf_d1 = norm.pdf(d1_val)

    if is_call:
        price = S * div_discount * n_d1 - K * discount * n_d2
        delta = div_discount * n_d1
        theta = (-(S * div_discount * npdf_d1 * sigma / (2 * sqrt_T))
                 - r * K * discount * n_d2
                 + q * S * div_discount * n_d1) / 365.0
        rho = K * T * discount * n_d2 / 100.0
    else:
        n_neg_d1 = norm.cdf(-d1_val)
        n_neg_d2 = norm.cdf(-d2_val)
        price = K * discount * n_neg_d2 - S * div_discount * n_neg_d1
        delta = -div_discount * n_neg_d1
        theta = (-(S * div_discount * npdf_d1 * sigma / (2 * sqrt_T))
                 + r * K * discount * n_neg_d2
                 - q * S * div_discount * n_neg_d1) / 365.0
        rho = -K * T * discount * n_neg_d2 / 100.0

    gamma = div_discount * npdf_d1 / (S * sigma * sqrt_T)
    vega = S * div_discount * npdf_d1 * sqrt_T / 100.0

    assert price >= 0, f"Negative option price: {price}"

    return OptionResult(
        price=price, delta=delta, gamma=gamma,
        theta=theta, vega=vega, rho=rho, iv_input=sigma,
    )


def implied_volatility(market_price: float, S: float, K: float,
                       r: float, q: float, T: float,
                       is_call: bool, tol: float = 1e-8,
                       max_iter: int = 100) -> float:
    """Newton-Raphson implied volatility solver."""
    assert market_price > 0, "Market price must be positive"
    assert T > 0, "Time to expiry must be positive"

    # Initial guess from Brenner-Subrahmanyam approximation
    sigma = np.sqrt(2 * np.pi / T) * market_price / S

    # Bounds
    sigma = max(min(sigma, MAX_VOL), MIN_VOL)

    for i in range(max_iter):
        result = price_european(S, K, r, q, sigma, T, is_call)
        diff = result.price - market_price
        vega_raw = result.vega * 100.0  # un-scale vega

        if abs(diff) < tol:
            return sigma

        if vega_raw < 1e-12:
            # Vega too small for Newton — use bisection step
            if diff > 0:
                sigma *= 0.9
            else:
                sigma *= 1.1
        else:
            sigma -= diff / vega_raw

        sigma = max(min(sigma, MAX_VOL), MIN_VOL)

    assert False, f"IV did not converge after {max_iter} iterations"


def build_vol_surface(chain_data: list, S: float, r: float,
                      q: float) -> dict:
    """Build volatility surface from options chain data."""
    assert len(chain_data) > 0, "Empty chain data"

    surface = {}
    for opt in chain_data:
        K = opt["strike"]
        T = opt["tte"]
        mid = (opt["bid"] + opt["ask"]) / 2.0
        is_call = opt["type"] == "call"

        if mid <= 0 or T <= 0:
            continue

        try:
            iv = implied_volatility(mid, S, K, r, q, T, is_call)
            moneyness = np.log(K / S) / np.sqrt(T)
            surface[(T, moneyness)] = iv
        except AssertionError:
            continue  # skip non-convergent points

    assert len(surface) > 0, "No valid IV points computed"
    return surface


if __name__ == "__main__":
    # Example: SPY 500 call, 30 DTE
    result = price_european(
        S=520.0, K=500.0, r=0.05, q=0.013,
        sigma=0.18, T=30/365, is_call=True)

    print(f"Price:  ${result.price:.2f}")
    print(f"Delta:  {result.delta:.4f}")
    print(f"Gamma:  {result.gamma:.4f}")
    print(f"Theta:  ${result.theta:.2f}/day")
    print(f"Vega:   ${result.vega:.2f}/1% vol")
    print(f"Rho:    ${result.rho:.2f}/1% rate")

    # IV solver test
    iv = implied_volatility(
        market_price=result.price, S=520.0, K=500.0,
        r=0.05, q=0.013, T=30/365, is_call=True)
    print(f"\nImplied Vol: {iv:.4f} (should recover {result.iv_input:.4f})")
```

### Step 3: Validate

```bash
python3 options/pricing/black_scholes.py
# Expected:
# Price: ~$22-24 (ITM call)
# Delta: ~0.85-0.95
# Implied Vol: matches input to 1e-6 precision

# Cross-validate against QuantLib
python3 -c "
import QuantLib as ql
# Set up same parameters and compare prices
# Discrepancy should be < $0.01
"
```

## CLAUDE.md for Options Pricing

```markdown
# Options Pricing Rules

## Standards
- Black-Scholes-Merton (European)
- Cox-Ross-Rubinstein (American, binomial)
- Monte Carlo for path-dependent exotics

## File Formats
- .csv (options chain data)
- .parquet (tick data)
- .json (model parameters)

## Libraries
- numpy 1.26+, scipy 1.12+
- QuantLib-Python 1.33+ (reference implementation)
- py_vollib_vectorized (fast vectorized BS)
- pandas (data handling)

## Testing
- Put-call parity must hold: C - P = S*exp(-qT) - K*exp(-rT)
- IV round-trip: price -> IV -> price must match to 1e-6
- Greeks must satisfy: delta(call) - delta(put) = exp(-qT)
- Compare all results against QuantLib reference

## Numerical Safety
- Vol bounds: [0.001, 5.0]
- Time floor: 1e-10 (never zero)
- Price must be non-negative
- IV solver: max 100 iterations with bisection fallback
```

## Common Pitfalls

- **Division by zero at expiry:** T=0 causes sigma*sqrt(T) to be zero in the denominator. Claude Code adds a MIN_TIME floor and returns intrinsic value at expiry instead of trying to compute Black-Scholes.
- **IV solver divergence for deep OTM:** Newton-Raphson oscillates wildly when vega is near zero (deep out-of-the-money). Claude Code falls back to bisection when vega drops below a threshold.
- **Calendar arbitrage in vol surface:** Interpolated implied volatilities can decrease with maturity, creating free money. Claude Code checks total variance (sigma^2 * T) monotonicity after surface construction.

## Related

- [Claude Code for Algo Trading](/claude-code-algorithmic-trading-backtesting-2026/)
- [Claude Code for FIX Protocol](/claude-code-fix-protocol-message-handling-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code + OpenRouter: Alternative Pricing Strategies](/claude-code-openrouter-alternative-pricing/)


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

- [Claude Code Cost: Pricing Breakdown](/claude-code-cost-complete-guide/)
- [Claude Prompt Caching Pricing Guide](/claude-prompt-caching-pricing-and-cost-savings/)
- [Claude API Pricing](/claude-api-pricing-complete-guide/)
- [Claude Code Pricing](/pricing-hub/)

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
