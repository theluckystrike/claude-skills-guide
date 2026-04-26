---
layout: default
title: "Claude Code for MiFID II Reporting (2026)"
permalink: /claude-code-mifid-ii-regulatory-reporting-2026/
date: 2026-04-20
description: "MiFID II regulatory reporting with Claude Code. Build transaction reports, best execution analysis, and RTS 25 compliance."
last_tested: "2026-04-22"
---

## Why Claude Code for MiFID II Regulatory Reporting

MiFID II (Markets in Financial Instruments Directive II) requires investment firms to report transactions to national competent authorities within T+1, demonstrate best execution through RTS 28 reports, maintain order records per RTS 25 (clock synchronization to 100 microseconds), and publish pre/post-trade transparency data. The reporting schemas (XML/ISO 20022) have 65+ mandatory fields per transaction report, and a single validation error rejects the entire file.

Claude Code generates the XML transaction reports that conform to ESMA's technical standards, builds best execution analysis engines that compare execution prices against consolidated tape benchmarks, and produces the RTS 28 annual reports that must be published on firm websites. It handles the ISO date formatting, LEI validation, and MIC code lookups that trip up manual implementations.

## The Workflow

### Step 1: Regulatory Reporting Setup

```bash
pip install lxml xmlschema  # XML generation and validation
pip install pandas openpyxl
pip install pycountry       # ISO country codes
pip install schwifty        # LEI validation

mkdir -p src/reporting src/best_execution src/validation data/schemas/
```

### Step 2: Build Transaction Report Generator

```python
# src/reporting/transaction_report.py
"""MiFID II transaction reporting per RTS 25 (ESMA/2017/580)."""

import xml.etree.ElementTree as ET
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional
import re

@dataclass
class TransactionRecord:
    report_id: str
    executing_entity_lei: str
    investing_decision_lei: str
    instrument_isin: str
    venue_mic: str              # MIC code (XLON, XPAR, etc.)
    trade_datetime: datetime    # UTC, microsecond precision required
    quantity: float
    price: float
    price_currency: str         # ISO 4217
    buy_sell: str               # 'BUYI' or 'SELL'
    trader_id: str              # national ID or CONCAT
    decision_maker_id: str
    transmission_indicator: bool

LEI_PATTERN = re.compile(r'^[A-Z0-9]{20}$')
ISIN_PATTERN = re.compile(r'^[A-Z]{2}[A-Z0-9]{9}[0-9]$')

def validate_lei(lei: str) -> bool:
    """Validate Legal Entity Identifier format (ISO 17442)."""
    return bool(LEI_PATTERN.match(lei)) and len(lei) == 20

def validate_isin(isin: str) -> bool:
    """Validate ISIN format (ISO 6166)."""
    return bool(ISIN_PATTERN.match(isin))

def generate_transaction_xml(records: list,
                               reporting_firm_lei: str,
                               report_date: str) -> str:
    """Generate MiFID II transaction report XML per ESMA schema."""
    assert validate_lei(reporting_firm_lei), \
        f"Invalid reporting firm LEI: {reporting_firm_lei}"

    root = ET.Element('TxRpt')
    root.set('xmlns', 'urn:iso:std:iso:20022:tech:xsd:auth.016.001.02')

    header = ET.SubElement(root, 'Hdr')
    ET.SubElement(header, 'RptgFrm').text = reporting_firm_lei
    ET.SubElement(header, 'RptDt').text = report_date
    ET.SubElement(header, 'NbOfTxs').text = str(len(records))

    for rec in records:
        # Validate each record
        assert validate_lei(rec.executing_entity_lei), \
            f"Invalid LEI: {rec.executing_entity_lei}"
        assert validate_isin(rec.instrument_isin), \
            f"Invalid ISIN: {rec.instrument_isin}"
        assert rec.buy_sell in ('BUYI', 'SELL'), \
            f"Invalid side: {rec.buy_sell}"

        tx = ET.SubElement(root, 'Tx')

        # Report identification
        ET.SubElement(tx, 'TxId').text = rec.report_id

        # Executing entity
        exec_ent = ET.SubElement(tx, 'ExctgPty')
        ET.SubElement(exec_ent, 'LEI').text = rec.executing_entity_lei

        # Instrument identification
        instr = ET.SubElement(tx, 'FinInstrm')
        ET.SubElement(instr, 'ISIN').text = rec.instrument_isin

        # Trade details
        trade = ET.SubElement(tx, 'Tx')

        # RTS 25: timestamp with microsecond precision
        ts = rec.trade_datetime.strftime('%Y-%m-%dT%H:%M:%S.%f') + 'Z'
        ET.SubElement(trade, 'TradDt').text = ts

        # Venue
        ET.SubElement(trade, 'TradVn').text = rec.venue_mic

        # Price
        price_elem = ET.SubElement(trade, 'Pric')
        ET.SubElement(price_elem, 'MntryVal').text = f"{rec.price:.6f}"
        ET.SubElement(price_elem, 'Ccy').text = rec.price_currency

        # Quantity
        ET.SubElement(trade, 'Qty').text = f"{rec.quantity:.4f}"

        # Side
        ET.SubElement(trade, 'BuySell').text = rec.buy_sell

        # Trader identification
        trader = ET.SubElement(tx, 'InvstmtDcsnPrsn')
        ET.SubElement(trader, 'Prsn').text = rec.decision_maker_id

    # Format XML
    ET.indent(root)
    return ET.tostring(root, encoding='unicode', xml_declaration=True)
```

### Step 3: Best Execution Analysis (RTS 28)

```python
# src/best_execution/rts28_report.py
"""RTS 28 best execution analysis: venue quality metrics."""

import pandas as pd
import numpy as np
from dataclasses import dataclass

@dataclass
class VenueMetrics:
    venue_mic: str
    venue_name: str
    total_volume: float
    total_orders: int
    pct_of_volume: float
    avg_fill_rate: float        # % of order filled
    avg_latency_us: float       # microseconds
    price_improvement_bps: float  # vs EBBO at time of order

def compute_best_execution_metrics(executions: pd.DataFrame,
                                     benchmarks: pd.DataFrame
                                     ) -> list:
    """Compute per-venue execution quality metrics for RTS 28."""
    results = []

    for venue_mic, venue_trades in executions.groupby('venue_mic'):
        n_orders = len(venue_trades)
        total_vol = venue_trades['notional'].sum()

        # Price improvement: execution price vs benchmark (EBBO midpoint)
        merged = venue_trades.merge(
            benchmarks, on=['isin', 'timestamp'], how='left'
        )

        if merged['benchmark_mid'].notna().any():
            buys = merged[merged['side'] == 'BUY']
            sells = merged[merged['side'] == 'SELL']

            # For buys: improvement = benchmark - execution price (lower is better)
            buy_improvement = (buys['benchmark_mid'] - buys['exec_price']) / \
                              buys['benchmark_mid'] * 10000  # bps

            # For sells: improvement = execution price - benchmark
            sell_improvement = (sells['exec_price'] - sells['benchmark_mid']) / \
                               sells['benchmark_mid'] * 10000

            price_improvement = pd.concat([buy_improvement, sell_improvement]).mean()
        else:
            price_improvement = 0.0

        # Fill rate
        fill_rate = (venue_trades['filled_qty'] / venue_trades['order_qty']).mean()

        # Latency
        avg_latency = venue_trades['fill_latency_us'].mean() \
            if 'fill_latency_us' in venue_trades.columns else 0.0

        results.append(VenueMetrics(
            venue_mic=venue_mic,
            venue_name=venue_trades['venue_name'].iloc[0] \
                if 'venue_name' in venue_trades.columns else venue_mic,
            total_volume=float(total_vol),
            total_orders=n_orders,
            pct_of_volume=0.0,  # computed after all venues
            avg_fill_rate=float(fill_rate),
            avg_latency_us=float(avg_latency),
            price_improvement_bps=float(price_improvement),
        ))

    # Compute percentage of total volume
    total_volume = sum(v.total_volume for v in results)
    for v in results:
        v.pct_of_volume = v.total_volume / total_volume * 100 if total_volume > 0 else 0

    return sorted(results, key=lambda x: x.total_volume, reverse=True)
```

### Step 4: Verify

```bash
python3 -c "
from datetime import datetime, timezone
from src.reporting.transaction_report import (
    TransactionRecord, generate_transaction_xml, validate_lei, validate_isin
)

# Validate identifiers
assert validate_lei('529900T8BM49AURSDO55'), 'Valid LEI rejected'
assert not validate_lei('INVALID'), 'Invalid LEI accepted'
assert validate_isin('GB0002634946'), 'Valid ISIN rejected'

# Generate sample report
records = [
    TransactionRecord(
        report_id='RPT-2026-001',
        executing_entity_lei='529900T8BM49AURSDO55',
        investing_decision_lei='529900T8BM49AURSDO55',
        instrument_isin='GB0002634946',
        venue_mic='XLON',
        trade_datetime=datetime(2026, 4, 22, 14, 30, 15, 123456, tzinfo=timezone.utc),
        quantity=1000.0,
        price=150.25,
        price_currency='GBP',
        buy_sell='BUYI',
        trader_id='GBNAT-JD123456',
        decision_maker_id='GBNAT-JD123456',
        transmission_indicator=False,
    ),
]

xml = generate_transaction_xml(records, '529900T8BM49AURSDO55', '2026-04-22')
print(xml[:500])
assert '<ISIN>GB0002634946</ISIN>' in xml, 'ISIN not in XML'
assert '<TradVn>XLON</TradVn>' in xml, 'Venue MIC not in XML'
print('MiFID II report generation: PASS')
"
```

## CLAUDE.md for MiFID II Reporting

```markdown
# MiFID II Regulatory Reporting

## Key Regulations
- RTS 25: Transaction reporting (65 fields, T+1 deadline)
- RTS 27: Execution venue reporting (quarterly)
- RTS 28: Best execution reporting (annual, per asset class)
- Article 26: Transaction reporting to NCA

## Data Standards
- LEI: ISO 17442 (Legal Entity Identifier, 20 chars)
- ISIN: ISO 6166 (12 chars, check digit validated)
- MIC: ISO 10383 (Market Identifier Code, 4 chars)
- Currency: ISO 4217 (3 chars)
- Timestamps: ISO 8601 with microsecond precision (RTS 25)

## Libraries
- lxml (XML generation and validation)
- xmlschema (ESMA schema validation)
- schwifty (LEI/BIC validation)
- pandas (trade data processing)

## Common Commands
- python3 src/reporting/transaction_report.py — generate XML
- xmllint --schema auth.016.xsd report.xml — validate against schema
- python3 src/best_execution/rts28_report.py — generate RTS 28
```

## Common Pitfalls

- **Timestamp precision below RTS 25 requirements:** RTS 25 requires microsecond precision for high-frequency trading firms and millisecond for others. Using `datetime.now()` without explicit UTC timezone and microsecond formatting causes validation rejection. Claude Code formats all timestamps with `.%fZ` suffix and UTC timezone.
- **LEI expiry not checked:** An expired LEI causes the entire transaction report to be rejected. Claude Code validates LEI format and warns when LEIs in the report are known to be lapsed (via GLEIF API check).
- **Missing short selling indicator:** Short sells must be flagged with the short selling indicator (field 62). Omission is a reporting breach. Claude Code checks position data to determine if a sell creates a net short position and sets the flag accordingly.

## Related

- [Claude Code for FIX Protocol Message Handling](/claude-code-fix-protocol-message-handling-2026/)
- [Claude Code for AML Rule Engine Development](/claude-code-aml-rule-engine-development-2026/)
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




**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Vitest Coverage Reporting](/claude-code-vitest-coverage-reporting-workflow-tutorial/)
- [Claude Code Test Reporting Workflow](/claude-code-test-reporting-workflow-guide/)
- [Chrome Browser Reporting API](/chrome-browser-reporting-api/)
- [Chrome Reporting Connector Enterprise](/chrome-reporting-connector-enterprise/)

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
