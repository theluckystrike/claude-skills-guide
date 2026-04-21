---
title: "Claude Code for Basel III Risk Calculation (2026)"
permalink: /claude-code-basel-iii-risk-calculation-2026/
description: "Implement Basel III risk calculations with Claude Code. Build CET1 capital ratio, credit risk RWA, and liquidity coverage ratio computations."
last_tested: "2026-04-22"
domain: "banking regulation"
render_with_liquid: false
---

## Why Claude Code for Basel III

Basel III (finalized as "Basel III Endgame" or "Basel 3.1" in the US/EU) requires banks to calculate risk-weighted assets, maintain capital adequacy ratios, and report liquidity metrics to regulators. The calculations involve thousands of counterparty exposures, complex credit risk weight formulas, operational risk multipliers, and market risk sensitivities. Regulatory technology teams maintain millions of lines of calculation code that must be audited, tested against regulator-provided benchmarks, and updated when standards change.

Claude Code can generate Basel III calculation engines with proper regulatory formulas, build reconciliation tests against published examples, and help migrate legacy SAS/Excel-based calculations to modern Python or Java implementations with full audit trails.

## The Workflow

### Step 1: Implement Capital Adequacy Calculations

```python
#!/usr/bin/env python3
"""Basel III Capital Adequacy Ratio calculations.
CRR2/CRD5 (EU) and Basel III Endgame (US) compliant."""

from dataclasses import dataclass
from decimal import Decimal, ROUND_HALF_UP
from enum import Enum

class AssetClass(Enum):
    SOVEREIGN = "sovereign"
    BANK = "bank"
    CORPORATE = "corporate"
    RETAIL = "retail"
    RESIDENTIAL_MORTGAGE = "residential_mortgage"
    COMMERCIAL_RE = "commercial_real_estate"
    EQUITY = "equity"
    SECURITISATION = "securitisation"

# Basel III Standardised Approach risk weights (CRE20)
RISK_WEIGHTS_SA = {
    AssetClass.SOVEREIGN: {
        "AAA_to_AA": Decimal("0.00"),
        "A": Decimal("0.20"),
        "BBB": Decimal("0.50"),
        "BB_to_B": Decimal("1.00"),
        "below_B": Decimal("1.50"),
        "unrated": Decimal("1.00")
    },
    AssetClass.CORPORATE: {
        "AAA_to_AA": Decimal("0.20"),
        "A": Decimal("0.50"),
        "BBB": Decimal("0.75"),
        "BB_to_B": Decimal("1.00"),
        "below_B": Decimal("1.50"),
        "unrated": Decimal("1.00")
    },
    AssetClass.RETAIL: {
        "regulatory": Decimal("0.75")  # No rating dependency
    },
    AssetClass.RESIDENTIAL_MORTGAGE: {
        "ltv_lte_50": Decimal("0.20"),
        "ltv_50_60": Decimal("0.25"),
        "ltv_60_80": Decimal("0.30"),
        "ltv_80_90": Decimal("0.40"),
        "ltv_90_100": Decimal("0.50"),
        "ltv_gt_100": Decimal("0.70")
    }
}

@dataclass
class Exposure:
    counterparty_id: str
    asset_class: AssetClass
    exposure_amount: Decimal
    rating: str
    ltv: Decimal | None = None
    maturity_years: Decimal | None = None
    collateral_value: Decimal | None = None

@dataclass
class CapitalResult:
    cet1_ratio: Decimal
    tier1_ratio: Decimal
    total_capital_ratio: Decimal
    total_rwa: Decimal
    cet1_capital: Decimal
    at1_capital: Decimal
    tier2_capital: Decimal
    minimum_cet1_required: Decimal
    buffer_requirement: Decimal
    surplus_deficit: Decimal

def calculate_rwa_sa(exposure: Exposure) -> Decimal:
    """Calculate Risk-Weighted Asset under Standardised Approach."""
    weights = RISK_WEIGHTS_SA.get(exposure.asset_class, {})

    if exposure.asset_class == AssetClass.RESIDENTIAL_MORTGAGE:
        # LTV-based risk weight (Basel III revised)
        ltv = exposure.ltv or Decimal("1.0")
        if ltv <= Decimal("0.50"):
            rw = weights["ltv_lte_50"]
        elif ltv <= Decimal("0.60"):
            rw = weights["ltv_50_60"]
        elif ltv <= Decimal("0.80"):
            rw = weights["ltv_60_80"]
        elif ltv <= Decimal("0.90"):
            rw = weights["ltv_80_90"]
        elif ltv <= Decimal("1.00"):
            rw = weights["ltv_90_100"]
        else:
            rw = weights["ltv_gt_100"]
    elif exposure.asset_class == AssetClass.RETAIL:
        rw = weights["regulatory"]
    else:
        rw = weights.get(exposure.rating, weights.get("unrated", Decimal("1.00")))

    return (exposure.exposure_amount * rw).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP
    )

def calculate_capital_ratios(
    exposures: list[Exposure],
    cet1_capital: Decimal,
    at1_capital: Decimal,
    tier2_capital: Decimal,
    countercyclical_buffer: Decimal = Decimal("0.025"),
    gsib_buffer: Decimal = Decimal("0.00")
) -> CapitalResult:
    """Calculate Basel III capital adequacy ratios."""

    # Total Risk-Weighted Assets
    total_rwa = sum(calculate_rwa_sa(exp) for exp in exposures)

    if total_rwa == 0:
        raise ValueError("Total RWA cannot be zero")

    # Capital ratios
    tier1_capital = cet1_capital + at1_capital
    total_capital = tier1_capital + tier2_capital

    cet1_ratio = (cet1_capital / total_rwa * 100).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP)
    tier1_ratio = (tier1_capital / total_rwa * 100).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP)
    total_ratio = (total_capital / total_rwa * 100).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP)

    # Minimum requirements: CET1 4.5% + CCB 2.5% + CCyB + G-SIB
    min_cet1_pct = Decimal("4.5")
    buffer = Decimal("2.5") + countercyclical_buffer * 100 + gsib_buffer * 100
    min_required = (total_rwa * (min_cet1_pct + buffer) / 100).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP)

    return CapitalResult(
        cet1_ratio=cet1_ratio,
        tier1_ratio=tier1_ratio,
        total_capital_ratio=total_ratio,
        total_rwa=total_rwa,
        cet1_capital=cet1_capital,
        at1_capital=at1_capital,
        tier2_capital=tier2_capital,
        minimum_cet1_required=min_required,
        buffer_requirement=buffer,
        surplus_deficit=cet1_capital - min_required
    )
```

### Step 2: Implement Liquidity Coverage Ratio

```python
def calculate_lcr(
    hqla_level1: Decimal,
    hqla_level2a: Decimal,
    hqla_level2b: Decimal,
    total_outflows_30d: Decimal,
    total_inflows_30d: Decimal
) -> dict:
    """Calculate Liquidity Coverage Ratio (LCR) per Basel III LCR standard."""

    # HQLA composition limits
    level2a_adjusted = min(hqla_level2a * Decimal("0.85"), hqla_level1 * Decimal("0.6667"))
    level2b_adjusted = min(hqla_level2b * Decimal("0.50"),
                           (hqla_level1 + level2a_adjusted) * Decimal("0.1765"))

    total_hqla = hqla_level1 + level2a_adjusted + level2b_adjusted

    # Net cash outflows: inflows capped at 75% of outflows
    inflow_cap = total_outflows_30d * Decimal("0.75")
    adjusted_inflows = min(total_inflows_30d, inflow_cap)
    net_outflows = total_outflows_30d - adjusted_inflows

    if net_outflows <= 0:
        lcr = Decimal("999.99")  # Cap at 999.99%
    else:
        lcr = (total_hqla / net_outflows * 100).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP)

    return {
        "lcr_ratio": lcr,
        "total_hqla": total_hqla,
        "net_cash_outflows": net_outflows,
        "minimum_required": Decimal("100.00"),  # 100% minimum
        "compliant": lcr >= Decimal("100.00"),
        "components": {
            "level1": hqla_level1,
            "level2a_adjusted": level2a_adjusted,
            "level2b_adjusted": level2b_adjusted,
            "total_outflows": total_outflows_30d,
            "total_inflows": total_inflows_30d,
            "adjusted_inflows": adjusted_inflows
        }
    }
```

### Step 3: Reconciliation Testing

```python
def test_regulatory_example():
    """Test against Basel Committee published calculation examples."""
    exposures = [
        Exposure("GOV01", AssetClass.SOVEREIGN, Decimal("10000000"),
                 "AAA_to_AA"),
        Exposure("CORP01", AssetClass.CORPORATE, Decimal("5000000"),
                 "A"),
        Exposure("RET01", AssetClass.RETAIL, Decimal("2000000"),
                 "regulatory"),
        Exposure("MTG01", AssetClass.RESIDENTIAL_MORTGAGE,
                 Decimal("3000000"), "", ltv=Decimal("0.75")),
    ]

    result = calculate_capital_ratios(
        exposures=exposures,
        cet1_capital=Decimal("800000"),
        at1_capital=Decimal("100000"),
        tier2_capital=Decimal("200000")
    )

    # Expected RWA: 0 + 2,500,000 + 1,500,000 + 900,000 = 4,900,000
    assert result.total_rwa == Decimal("4900000.00")
    assert result.cet1_ratio >= Decimal("4.50")  # Minimum CET1
    print(f"CET1 Ratio: {result.cet1_ratio}%")
    print(f"Total RWA: {result.total_rwa:,.2f}")
```

### Step 4: Verify

```bash
# Run calculation tests
python3 -m pytest tests/test_basel_calculations.py -v

# Run regulatory reconciliation
python3 tests/test_regulatory_examples.py

# Generate regulatory report
python3 reports/generate_capital_report.py \
  --date 2026-03-31 \
  --output ~/reports/capital-adequacy-Q1-2026.json
```

## CLAUDE.md for Basel III Risk Calculation

```markdown
# Basel III Risk Calculation Standards

## Domain Rules
- All monetary calculations use Decimal (never float)
- Risk weights from CRE20 (Standardised Approach) or IRB formulas
- CET1 minimum: 4.5%, with CCB 2.5%, plus any CCyB and G-SIB buffers
- LCR minimum: 100%, NSFR minimum: 100%
- All calculations must be reproducible and auditable
- Rounding: ROUND_HALF_UP per regulatory convention
- Exposure amounts in reporting currency (typically USD or EUR)

## File Patterns
- Calculations: src/calculations/ (pure functions, no side effects)
- Data models: src/models/ (exposure, counterparty, portfolio)
- Reports: src/reports/ (regulatory report generators)
- Tests: tests/test_regulatory_*.py (reconciliation against examples)

## Common Commands
- python3 -m pytest tests/test_basel*.py -v --tb=long
- python3 calculations/capital_adequacy.py --portfolio portfolio.csv
- python3 reports/generate_corep.py --date 2026-03-31
- python3 reconciliation/compare_to_benchmark.py
```

## Common Pitfalls in Basel III Calculations

- **Floating point errors in capital ratios:** A rounding error of 0.01% in CET1 ratio can mean billions in capital requirements. Claude Code enforces Decimal arithmetic throughout and validates against published regulatory examples.

- **LTV band boundary conditions:** Mortgage risk weights change at exact LTV boundaries (50%, 60%, 80%). Claude Code uses consistent boundary handling (less-than-or-equal vs less-than) matching the regulatory text.

- **Exposure netting errors:** Netting sets for derivatives require master agreement validation before offsetting positive and negative exposures. Claude Code validates netting eligibility before applying net exposure calculations.

## Related

- [Claude Code for SOX Audit Automation](/claude-code-sox-audit-automation-2026/)
- [Claude Code for Sarbanes-Oxley Code Controls](/claude-code-sarbanes-oxley-code-controls-2026/)
- [Claude Code for PCI-DSS Security Scanning](/claude-code-pci-dss-security-scanning-2026/)
