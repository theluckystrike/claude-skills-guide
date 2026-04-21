---
title: "Claude Code for AML Rule Engine Development (2026)"
description: "Anti-money laundering rule engine with Claude Code. Build transaction monitoring rules with proper audit trails."
permalink: /claude-code-aml-rule-engine-development-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for AML Rule Engines

Financial institutions spend billions on anti-money laundering compliance. AML rule engines monitor transactions for patterns like structuring (splitting deposits to stay under $10,000), rapid movement of funds, unusual geographic patterns, and velocity anomalies. Each rule must be auditable, explainable to regulators, and tunable to reduce false positives that currently run at 95%+ at most banks.

Claude Code generates rule engine code with built-in audit logging, configurable thresholds, and the structured output format that BSA/AML compliance officers need for Suspicious Activity Report (SAR) filing. It understands FinCEN requirements and the specific transaction patterns that trigger regulatory scrutiny.

## The Workflow

### Step 1: Setup

```bash
pip install pandas numpy sqlalchemy pydantic \
  structlog python-dateutil

mkdir -p aml/{rules,models,scoring,tests,audit}
```

### Step 2: Transaction Monitoring Rule Engine

```python
# aml/rules/engine.py
"""AML transaction monitoring rule engine with audit trail."""
import pandas as pd
import numpy as np
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Optional
import structlog
import json

logger = structlog.get_logger()

CTR_THRESHOLD = 10_000.00    # Currency Transaction Report threshold
STRUCTURING_WINDOW_DAYS = 3
STRUCTURING_COUNT = 3
VELOCITY_WINDOW_HOURS = 24
MAX_VELOCITY_COUNT = 20
HIGH_RISK_COUNTRIES = {
    "AF", "IR", "KP", "MM", "SY", "YE",  # FATF high-risk
    "PA", "VG", "KY",                      # Tax haven watchlist
}


@dataclass
class Transaction:
    txn_id: str
    account_id: str
    amount: float
    currency: str
    direction: str          # "credit" or "debit"
    counterparty_country: str
    timestamp: datetime
    channel: str            # "wire", "ach", "cash", "check"


@dataclass
class Alert:
    alert_id: str
    rule_id: str
    rule_name: str
    account_id: str
    score: float
    transactions: list
    explanation: str
    triggered_at: datetime = field(default_factory=datetime.utcnow)
    sar_recommended: bool = False


class StructuringRule:
    """Detect currency transaction structuring (smurfing)."""

    RULE_ID = "AML-001"
    RULE_NAME = "Structuring Detection"

    def __init__(self, threshold: float = CTR_THRESHOLD,
                 window_days: int = STRUCTURING_WINDOW_DAYS,
                 min_count: int = STRUCTURING_COUNT):
        assert threshold > 0, "Threshold must be positive"
        assert window_days > 0, "Window must be positive"
        assert min_count >= 2, "Need at least 2 transactions"

        self.threshold = threshold
        self.window = timedelta(days=window_days)
        self.min_count = min_count

    def evaluate(self, transactions: list) -> Optional[Alert]:
        """Check for structuring pattern in transaction list."""
        assert len(transactions) > 0, "Empty transaction list"

        # Filter cash transactions just below CTR threshold
        cash_txns = [
            t for t in transactions
            if t.channel == "cash"
            and t.amount > self.threshold * 0.5
            and t.amount < self.threshold
        ]

        if len(cash_txns) < self.min_count:
            return None

        # Check if enough fall within the window
        cash_txns.sort(key=lambda t: t.timestamp)
        for i in range(len(cash_txns) - self.min_count + 1):
            window_txns = [
                t for t in cash_txns[i:]
                if t.timestamp - cash_txns[i].timestamp <= self.window
            ]

            if len(window_txns) >= self.min_count:
                total = sum(t.amount for t in window_txns)
                if total > self.threshold:
                    score = min(len(window_txns) / self.min_count, 3.0)
                    return Alert(
                        alert_id=f"ALR-{datetime.utcnow():%Y%m%d%H%M%S}",
                        rule_id=self.RULE_ID,
                        rule_name=self.RULE_NAME,
                        account_id=cash_txns[0].account_id,
                        score=score,
                        transactions=[t.txn_id for t in window_txns],
                        explanation=(
                            f"{len(window_txns)} cash deposits totaling "
                            f"${total:,.2f} within {self.window.days} days. "
                            f"Each below ${self.threshold:,.2f} CTR threshold. "
                            f"Pattern consistent with structuring."
                        ),
                        sar_recommended=score >= 2.0,
                    )
        return None


class VelocityRule:
    """Detect unusual transaction velocity."""

    RULE_ID = "AML-002"
    RULE_NAME = "Transaction Velocity Anomaly"

    def __init__(self, window_hours: int = VELOCITY_WINDOW_HOURS,
                 max_count: int = MAX_VELOCITY_COUNT):
        assert window_hours > 0
        assert max_count > 0
        self.window = timedelta(hours=window_hours)
        self.max_count = max_count

    def evaluate(self, transactions: list) -> Optional[Alert]:
        assert len(transactions) > 0

        transactions.sort(key=lambda t: t.timestamp)
        for i in range(len(transactions)):
            window_txns = [
                t for t in transactions[i:]
                if t.timestamp - transactions[i].timestamp <= self.window
            ]
            if len(window_txns) > self.max_count:
                return Alert(
                    alert_id=f"ALR-{datetime.utcnow():%Y%m%d%H%M%S}",
                    rule_id=self.RULE_ID,
                    rule_name=self.RULE_NAME,
                    account_id=transactions[0].account_id,
                    score=len(window_txns) / self.max_count,
                    transactions=[t.txn_id for t in window_txns],
                    explanation=(
                        f"{len(window_txns)} transactions within "
                        f"{self.window.total_seconds()/3600:.0f} hours "
                        f"(threshold: {self.max_count})"
                    ),
                )
        return None


class HighRiskGeoRule:
    """Flag transactions involving high-risk jurisdictions."""

    RULE_ID = "AML-003"
    RULE_NAME = "High-Risk Country Transaction"

    def evaluate(self, transactions: list) -> Optional[Alert]:
        assert len(transactions) > 0

        flagged = [
            t for t in transactions
            if t.counterparty_country in HIGH_RISK_COUNTRIES
        ]
        if not flagged:
            return None

        total = sum(t.amount for t in flagged)
        countries = set(t.counterparty_country for t in flagged)
        return Alert(
            alert_id=f"ALR-{datetime.utcnow():%Y%m%d%H%M%S}",
            rule_id=self.RULE_ID,
            rule_name=self.RULE_NAME,
            account_id=flagged[0].account_id,
            score=min(total / 50000.0, 3.0),
            transactions=[t.txn_id for t in flagged],
            explanation=(
                f"{len(flagged)} transactions totaling ${total:,.2f} "
                f"involving FATF high-risk countries: {', '.join(countries)}"
            ),
            sar_recommended=total > 25000,
        )


class AMLEngine:
    """Orchestrate all AML rules with audit logging."""

    def __init__(self):
        self.rules = [
            StructuringRule(),
            VelocityRule(),
            HighRiskGeoRule(),
        ]
        self.audit_log = []

    def scan_account(self, account_id: str,
                     transactions: list) -> list:
        """Run all rules against an account's transactions."""
        assert account_id, "Account ID required"
        assert len(transactions) > 0, "No transactions to scan"

        acct_txns = [t for t in transactions if t.account_id == account_id]
        alerts = []

        for rule in self.rules:
            alert = rule.evaluate(acct_txns)
            if alert:
                alerts.append(alert)
                self.audit_log.append({
                    "timestamp": datetime.utcnow().isoformat(),
                    "account_id": account_id,
                    "rule_id": alert.rule_id,
                    "alert_id": alert.alert_id,
                    "score": alert.score,
                    "sar_recommended": alert.sar_recommended,
                })
                logger.info("alert_generated",
                            rule=alert.rule_id,
                            account=account_id,
                            score=alert.score)

        return alerts

    def export_audit_log(self, filepath: str) -> None:
        """Export audit trail for regulatory review."""
        assert len(self.audit_log) > 0, "No audit entries"
        with open(filepath, 'w') as f:
            json.dump(self.audit_log, f, indent=2)


if __name__ == "__main__":
    engine = AMLEngine()

    # Simulate structuring pattern
    txns = [
        Transaction("T001", "ACCT-123", 9500.00, "USD", "credit", "US",
                     datetime(2026, 4, 19, 10, 0), "cash"),
        Transaction("T002", "ACCT-123", 9800.00, "USD", "credit", "US",
                     datetime(2026, 4, 20, 14, 0), "cash"),
        Transaction("T003", "ACCT-123", 9200.00, "USD", "credit", "US",
                     datetime(2026, 4, 21, 9, 30), "cash"),
    ]

    alerts = engine.scan_account("ACCT-123", txns)
    for a in alerts:
        print(f"ALERT: {a.rule_name} (score={a.score:.1f})")
        print(f"  {a.explanation}")
        print(f"  SAR recommended: {a.sar_recommended}")
```

### Step 3: Validate

```bash
python3 aml/rules/engine.py
# Expected:
# ALERT: Structuring Detection (score=1.0)
#   3 cash deposits totaling $28,500.00 within 3 days...
#   SAR recommended: False (score < 2.0, borderline)
```

## CLAUDE.md for AML Development

```markdown
# AML Rule Engine Rules

## Standards
- BSA/AML (Bank Secrecy Act)
- FinCEN SAR filing requirements
- FATF Recommendations (40+9)
- OFAC SDN list screening

## File Formats
- .py (rule definitions)
- .json (audit logs, configuration)
- .csv (transaction feeds)
- .xml (SAR filing format: FinCEN CTR/SAR)

## Libraries
- pandas, numpy (data processing)
- pydantic (data validation)
- structlog (audit-grade logging)
- sqlalchemy (database access)

## Testing
- Every rule must have known-positive and known-negative test cases
- False positive rate must be measurable per rule
- Audit log must capture every rule evaluation, not just alerts
- Regression tests against historical SAR-filed cases

## Compliance
- All rule changes must be version-controlled with justification
- Threshold changes require compliance officer sign-off
- Audit logs must be immutable and retained per regulatory period
- Model validation required annually (SR 11-7 / OCC 2011-12)
```

## Common Pitfalls

- **Hardcoded thresholds without audit trail:** Regulators want to know why $9,500 was chosen as a structuring floor. Claude Code externalizes all thresholds to configuration with change logging.
- **Missing SAR narrative generation:** An alert without a human-readable explanation is useless to the compliance officer who must file the SAR. Claude Code generates structured explanations that map directly to SAR narrative fields.
- **No false positive tracking:** Without measuring false positive rates per rule, you cannot tune thresholds. Claude Code adds disposition tracking (true positive / false positive / escalated) to the alert lifecycle.

## Related

- [Claude Code for Algo Trading](/claude-code-algorithmic-trading-backtesting-2026/)
- [Claude Code for FIX Protocol](/claude-code-fix-protocol-message-handling-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
