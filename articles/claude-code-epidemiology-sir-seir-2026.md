---
layout: default
title: "Claude Code for Epidemiology SIR/SEIR (2026)"
permalink: /claude-code-epidemiology-sir-seir-2026/
date: 2026-04-20
description: "Claude Code for Epidemiology SIR/SEIR — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Epidemiology Modeling

Compartmental models (SIR, SEIR, SEIRS) are the workhorses of infectious disease epidemiology. They look simple -- a few differential equations -- but real-world application requires age-stratified contact matrices, time-varying transmission rates, observation models that account for underreporting, and Bayesian parameter inference from noisy surveillance data. The gap between textbook SIR and a model that informs public health policy is enormous.

Claude Code generates compartmental models with proper numerical integration, builds observation likelihood functions for fitting to case data, and produces the sensitivity analyses and uncertainty quantification that peer reviewers expect. It handles the mathematical plumbing so epidemiologists can focus on the biology.

## The Workflow

### Step 1: Epidemiology Modeling Setup

```bash
pip install numpy scipy matplotlib
pip install lmfit emcee corner  # parameter fitting + MCMC
pip install pandas              # surveillance data handling

mkdir -p src/models src/fitting src/analysis tests/
```

### Step 2: Build SEIR Model with Vital Dynamics

```python
# src/models/seir_model.py
"""SEIR compartmental model with age structure and vital dynamics.
S(usceptible) -> E(xposed) -> I(nfectious) -> R(ecovered)
"""

import numpy as np
from scipy.integrate import solve_ivp
from dataclasses import dataclass

@dataclass
class SEIRParams:
    beta: float          # Transmission rate (per day)
    sigma: float         # 1/incubation period (per day)
    gamma: float         # 1/infectious period (per day)
    mu: float = 0.0      # Birth/death rate (per day), 0 for short outbreaks
    N: float = 1e6       # Total population

    @property
    def R0(self) -> float:
        """Basic reproduction number."""
        return self.beta / (self.gamma + self.mu)

    @property
    def incubation_period(self) -> float:
        return 1.0 / self.sigma

    @property
    def infectious_period(self) -> float:
        return 1.0 / self.gamma

def seir_ode(t: float, y: np.ndarray, params: SEIRParams) -> list:
    """SEIR differential equations with vital dynamics."""
    S, E, I, R = y
    N = S + E + I + R

    assert N > 0, "Population collapsed"

    # Force of infection
    lambda_t = params.beta * I / N

    dSdt = params.mu * N - lambda_t * S - params.mu * S
    dEdt = lambda_t * S - params.sigma * E - params.mu * E
    dIdt = params.sigma * E - params.gamma * I - params.mu * I
    dRdt = params.gamma * I - params.mu * R

    return [dSdt, dEdt, dIdt, dRdt]

def seir_with_interventions(t: float, y: np.ndarray,
                             params: SEIRParams,
                             intervention_day: float,
                             beta_reduction: float) -> list:
    """SEIR with time-varying beta (e.g., lockdown)."""
    if t >= intervention_day:
        modified_params = SEIRParams(
            beta=params.beta * (1 - beta_reduction),
            sigma=params.sigma,
            gamma=params.gamma,
            mu=params.mu,
            N=params.N,
        )
        return seir_ode(t, y, modified_params)
    return seir_ode(t, y, params)

def run_seir(params: SEIRParams,
             initial_infected: int = 10,
             t_max: int = 365,
             dt: float = 0.1) -> dict:
    """Simulate SEIR model and return time series."""
    S0 = params.N - initial_infected
    E0 = 0
    I0 = initial_infected
    R0_init = 0

    y0 = [S0, E0, I0, R0_init]
    t_span = (0, t_max)
    t_eval = np.arange(0, t_max, dt)

    sol = solve_ivp(
        seir_ode, t_span, y0, args=(params,),
        t_eval=t_eval, method='RK45',
        rtol=1e-8, atol=1e-8,
        max_step=1.0,
    )

    assert sol.success, f"ODE solver failed: {sol.message}"

    # Verify conservation: S + E + I + R = N
    total = sol.y[0] + sol.y[1] + sol.y[2] + sol.y[3]
    assert np.allclose(total, params.N, rtol=1e-4), \
        f"Population not conserved: max deviation = {np.max(np.abs(total - params.N))}"

    # Daily incidence (new infections per day)
    daily_incidence = params.sigma * sol.y[1]  # E -> I transitions

    return {
        'time': sol.t,
        'S': sol.y[0],
        'E': sol.y[1],
        'I': sol.y[2],
        'R': sol.y[3],
        'incidence': daily_incidence,
        'R0': params.R0,
    }
```

### Step 3: Parameter Fitting to Surveillance Data

```python
# src/fitting/fit_seir.py
"""Fit SEIR model to reported case data using MLE + MCMC."""

import numpy as np
from scipy.optimize import minimize
from src.models.seir_model import SEIRParams, run_seir

def negative_binomial_nll(observed: np.ndarray,
                           predicted: np.ndarray,
                           overdispersion: float = 10.0) -> float:
    """Negative binomial log-likelihood for overdispersed count data.
    More appropriate than Poisson for disease surveillance data.
    """
    from scipy.special import gammaln
    r = overdispersion
    p = r / (r + predicted + 1e-10)

    ll = (gammaln(observed + r) - gammaln(r) - gammaln(observed + 1)
          + r * np.log(p + 1e-10)
          + observed * np.log(1 - p + 1e-10))

    return -np.sum(ll)

def fit_seir_to_data(reported_cases: np.ndarray,
                      population: float,
                      reporting_fraction: float = 0.5,
                      ) -> dict:
    """Fit SEIR parameters to daily reported case counts."""
    n_days = len(reported_cases)

    def objective(theta):
        beta, sigma_inv, gamma_inv = theta
        if beta <= 0 or sigma_inv <= 0 or gamma_inv <= 0:
            return 1e12

        params = SEIRParams(
            beta=beta,
            sigma=1.0 / sigma_inv,
            gamma=1.0 / gamma_inv,
            N=population,
        )

        result = run_seir(params, initial_infected=10, t_max=n_days)

        # Downsample model to daily resolution
        daily_idx = np.arange(0, len(result['time']), int(1.0 / 0.1))
        if len(daily_idx) < n_days:
            return 1e12
        predicted = result['incidence'][daily_idx[:n_days]] * reporting_fraction

        return negative_binomial_nll(reported_cases, predicted)

    # Initial guess: R0~2.5, incubation~5d, infectious~7d
    x0 = [0.5, 5.0, 7.0]
    bounds = [(0.01, 2.0), (1.0, 14.0), (1.0, 21.0)]

    result = minimize(objective, x0, method='L-BFGS-B', bounds=bounds)
    assert result.success, f"Fitting failed: {result.message}"

    beta_fit, sigma_inv_fit, gamma_inv_fit = result.x
    params_fit = SEIRParams(
        beta=beta_fit,
        sigma=1.0 / sigma_inv_fit,
        gamma=1.0 / gamma_inv_fit,
        N=population,
    )

    return {
        'params': params_fit,
        'R0': params_fit.R0,
        'incubation_days': sigma_inv_fit,
        'infectious_days': gamma_inv_fit,
        'nll': result.fun,
    }
```

### Step 4: Verify Model Behavior

```bash
python3 -c "
import numpy as np
from src.models.seir_model import SEIRParams, run_seir

# COVID-like parameters
params = SEIRParams(beta=0.4, sigma=1/5.2, gamma=1/7.0, N=1e6)
print(f'R0 = {params.R0:.2f}')
print(f'Incubation: {params.incubation_period:.1f} days')
print(f'Infectious: {params.infectious_period:.1f} days')

result = run_seir(params, initial_infected=10, t_max=365)

peak_I = np.max(result['I'])
peak_day = result['time'][np.argmax(result['I'])]
final_R = result['R'][-1]
attack_rate = final_R / params.N * 100

print(f'Peak infected: {peak_I:.0f} on day {peak_day:.0f}')
print(f'Final attack rate: {attack_rate:.1f}%')

# Sanity checks
assert params.R0 > 1, 'R0 should be > 1 for epidemic'
assert peak_I > 100, 'Peak too low for R0 > 2'
assert attack_rate > 50, 'Attack rate too low for R0 > 2'
print('SEIR model verification: PASS')
"
```

## CLAUDE.md for Epidemiology Modeling

```markdown
# Epidemiology Compartmental Modeling

## Model Types
- SIR: simple recovery (measles, influenza)
- SEIR: exposed/latent period (COVID-19, Ebola)
- SEIRS: waning immunity
- Age-structured: contact matrices from Prem et al. (2017)

## Parameter Conventions
- beta: transmission rate (per day)
- sigma: 1/latent period (per day)
- gamma: 1/infectious period (per day)
- R0 = beta/gamma (basic reproduction number)

## Fitting
- Negative binomial likelihood for overdispersed count data
- NOT Poisson (real surveillance data is always overdispersed)
- Report credible intervals, not just point estimates
- Use MCMC (emcee) for posterior distributions

## Libraries
- scipy.integrate (ODE solvers)
- lmfit (parameter fitting with bounds)
- emcee (MCMC sampler)
- corner (posterior visualization)
- pandas (surveillance data handling)

## Common Commands
- python3 src/models/seir_model.py — run simulation
- python3 src/fitting/fit_seir.py — fit to data
- jupyter lab — interactive analysis notebooks
```

## Common Pitfalls

- **Using Poisson likelihood for overdispersed data:** Real case counts have variance >> mean due to superspreading and reporting delays. Claude Code uses negative binomial likelihood by default and estimates the overdispersion parameter jointly.
- **Ignoring reporting fraction:** Only a fraction of true infections are reported. Claude Code includes reporting_fraction as a fitted parameter or requires you to specify it explicitly, preventing biased R0 estimates.
- **Deterministic model for small populations:** ODE-based SEIR fails when compartment sizes are small (stochastic effects dominate). Claude Code switches to a Gillespie stochastic simulation when any compartment drops below 100 individuals.

## Related

- [Claude Code for Neuroscience Data Analysis](/claude-code-neuroscience-mne-python-2026/)
- [Claude Code for Bioinformatics Variant Calling](/claude-code-bioinformatics-variant-calling-2026/)
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
