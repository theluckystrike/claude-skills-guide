---
layout: default
title: "Claude Cost Anomaly Detection Setup (2026)"
description: "Detect cost anomalies using standard deviation thresholds. Catch a 10x token spike in 5 minutes instead of discovering it on next month's bill."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-cost-anomaly-detection-setup-guide/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, anomaly-detection, monitoring]
---

# Claude Cost Anomaly Detection Setup Guide

A model routing misconfiguration sent 30,000 daily classification requests to Opus 4.7 ($5.00/$25.00 per MTok) instead of Haiku 4.5 ($1.00/$5.00 per MTok). The per-request cost jumped from $0.003 to $0.015 -- a 5x increase that went unnoticed for 12 days. Total waste: $4,320. An anomaly detector using simple standard deviation thresholds would have caught the spike within 5 minutes on day one, limiting the damage to $18.

## The Setup

Cost anomalies fall into three categories: sudden spikes (cache failures, misrouting), gradual drift (growing context windows, feature creep), and periodic anomalies (batch processing mistakes, weekend automation running unchecked). Each requires a different detection approach. Spike detection uses short-window comparisons against recent baselines. Drift detection uses trend analysis over days or weeks. Periodic anomaly detection uses time-of-day and day-of-week baselines. The simplest and most effective approach is standard deviation thresholds: alert when the current cost metric exceeds the historical mean by more than N standard deviations.

## The Math

Standard deviation detection for cost per request:

**Normal operation (7-day baseline):**
- Mean cost per request: $0.0150
- Standard deviation: $0.0030
- 2-sigma threshold: $0.0150 + (2 x $0.0030) = **$0.0210**
- 3-sigma threshold: $0.0150 + (3 x $0.0030) = **$0.0240**

**Anomaly event (Opus misconfiguration):**
- New cost per request: $0.0750
- Deviation: ($0.0750 - $0.0150) / $0.0030 = **20 sigma**
- Clearly anomalous at any reasonable threshold

**Cost impact calculation:**
- Normal daily spend: 30K requests x $0.0150 = $450/day
- Anomaly daily spend: 30K requests x $0.0750 = $2,250/day
- Daily waste: $1,800/day
- Detection at 5 minutes: $1,800 x (5/1440) = **$6.25 wasted**
- Detection at 12 days: $1,800 x 12 = **$21,600 wasted**
- **Savings from fast detection: $21,593.75**

## The Technique

Build a statistical anomaly detector using rolling statistics.

```python
import math
from collections import deque
from dataclasses import dataclass, field
from typing import Optional

PRICING = {
    "claude-opus-4-7": {"input": 5.00, "output": 25.00},
    "claude-sonnet-4-6": {"input": 3.00, "output": 15.00},
    "claude-haiku-4-5": {"input": 1.00, "output": 5.00},
}

@dataclass
class RollingStats:
    """Compute rolling mean and standard deviation."""
    window_size: int = 1000
    values: deque = field(default_factory=lambda: deque(maxlen=1000))

    def add(self, value: float):
        self.values.append(value)

    @property
    def mean(self) -> float:
        if not self.values:
            return 0.0
        return sum(self.values) / len(self.values)

    @property
    def std(self) -> float:
        if len(self.values) < 2:
            return 0.0
        m = self.mean
        variance = sum((v - m) ** 2 for v in self.values) / len(self.values)
        return math.sqrt(variance)

    @property
    def count(self) -> int:
        return len(self.values)


@dataclass
class AnomalyDetector:
    """Statistical anomaly detection for Claude API costs."""
    warning_sigmas: float = 2.0
    critical_sigmas: float = 3.0
    min_samples: int = 100  # minimum data before alerting

    cost_stats: RollingStats = field(
        default_factory=lambda: RollingStats(window_size=5000)
    )
    input_token_stats: RollingStats = field(
        default_factory=lambda: RollingStats(window_size=5000)
    )
    output_token_stats: RollingStats = field(
        default_factory=lambda: RollingStats(window_size=5000)
    )
    model_costs: dict = field(default_factory=dict)

    def check(self, model: str, usage) -> list[dict]:
        """Check a request for anomalies. Returns list of anomalies."""
        prices = PRICING.get(model, PRICING["claude-sonnet-4-6"])
        cost = (
            usage.input_tokens * prices["input"] / 1_000_000
            + usage.output_tokens * prices["output"] / 1_000_000
        )

        anomalies = []

        # Check cost anomaly
        if self.cost_stats.count >= self.min_samples:
            cost_anomaly = self._check_value(
                cost, self.cost_stats, "request_cost"
            )
            if cost_anomaly:
                anomalies.append(cost_anomaly)

        # Check input token anomaly
        if self.input_token_stats.count >= self.min_samples:
            input_anomaly = self._check_value(
                usage.input_tokens,
                self.input_token_stats,
                "input_tokens"
            )
            if input_anomaly:
                anomalies.append(input_anomaly)

        # Check model-specific anomaly (wrong model routing)
        if model not in self.model_costs:
            self.model_costs[model] = RollingStats(window_size=2000)
        model_stats = self.model_costs[model]
        if model_stats.count >= self.min_samples:
            model_anomaly = self._check_value(
                cost, model_stats, f"model_{model}_cost"
            )
            if model_anomaly:
                anomalies.append(model_anomaly)
        model_stats.add(cost)

        # Update rolling stats
        self.cost_stats.add(cost)
        self.input_token_stats.add(usage.input_tokens)
        self.output_token_stats.add(usage.output_tokens)

        return anomalies

    def _check_value(self, value: float, stats: RollingStats,
                      metric: str) -> Optional[dict]:
        """Check if value is anomalous relative to rolling stats."""
        if stats.std == 0:
            return None

        z_score = (value - stats.mean) / stats.std

        if abs(z_score) >= self.critical_sigmas:
            return {
                "metric": metric,
                "severity": "critical",
                "value": value,
                "mean": round(stats.mean, 6),
                "std": round(stats.std, 6),
                "z_score": round(z_score, 2),
                "message": (
                    f"{metric} = {value:.4f} is {z_score:.1f} sigma "
                    f"from mean {stats.mean:.4f}"
                ),
            }
        elif abs(z_score) >= self.warning_sigmas:
            return {
                "metric": metric,
                "severity": "warning",
                "value": value,
                "mean": round(stats.mean, 6),
                "z_score": round(z_score, 2),
                "message": (
                    f"{metric} = {value:.4f} is {z_score:.1f} sigma "
                    f"from mean {stats.mean:.4f}"
                ),
            }
        return None

    def status(self) -> dict:
        """Current detector state."""
        return {
            "samples": self.cost_stats.count,
            "cost_mean": f"${self.cost_stats.mean:.4f}",
            "cost_std": f"${self.cost_stats.std:.4f}",
            "warning_threshold": f"${self.cost_stats.mean + self.warning_sigmas * self.cost_stats.std:.4f}",
            "critical_threshold": f"${self.cost_stats.mean + self.critical_sigmas * self.cost_stats.std:.4f}",
            "input_token_mean": f"{self.input_token_stats.mean:.0f}",
        }

# Usage
detector = AnomalyDetector(warning_sigmas=2.0, critical_sigmas=3.0)

# Feed normal traffic first to build baseline
# (In production, this happens naturally over hours)
import anthropic
client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Classify this ticket"}]
)

anomalies = detector.check("claude-sonnet-4-6", response.usage)
if anomalies:
    for a in anomalies:
        print(f"[{a['severity'].upper()}] {a['message']}")

print(detector.status())
```

## The Tradeoffs

Statistical anomaly detection requires a warmup period (100+ samples) before it can detect anomalies accurately. During warmup, you're unprotected. Use fixed threshold alerts as a bridge during the first hour. The rolling window approach means the detector adapts to new normals -- if costs gradually increase 2x over a month, the detector's baseline shifts and it won't alert. Combine rolling stats with fixed absolute thresholds (e.g., never allow cost per request above $1.00 regardless of statistics) to catch gradual drift.

## Implementation Checklist

- Deploy the AnomalyDetector alongside your API client
- Set fixed absolute thresholds as immediate protection
- Allow 24 hours for baseline collection before relying on statistical alerts
- Connect to your alerting infrastructure (Slack, PagerDuty, email)
- Log all detected anomalies with full context for post-incident analysis
- Review false positive rate weekly and adjust sigma thresholds
- Add model-specific detection to catch routing errors

## Measuring Impact

Track anomaly detection rate (anomalies caught / total anomalies), false positive rate (false alerts / total alerts), and mean time to detection (alert timestamp - anomaly start timestamp). Target: detection rate above 95%, false positive rate below 10%, MTTD under 5 minutes. Each detected anomaly's value equals: (anomaly cost rate - normal cost rate) x (time-to-fix if undetected - MTTD). For a $1,800/day routing error, 5-minute detection instead of 12-day detection saves $21,594.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Enterprise Seat Management and Usage Monitoring](/claude-code-enterprise-seat-management-and-usage-monitoring/)
- [Claude Code for Cost Optimization Monitoring Guide](/claude-code-for-cost-optimization-monitoring-guide/)
- [Cost Allocation and Chargebacks for Enterprise Claude Code](/cost-allocation-and-chargebacks-for-enterprise-claude-code/)

## See Also

- [Claude Computer Use Token Cost Breakdown](/claude-computer-use-token-cost-breakdown/)
- [Claude Code Cost Per Project Estimation Guide](/claude-code-cost-per-project-estimation-guide/)
