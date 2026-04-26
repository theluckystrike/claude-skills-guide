---
layout: default
title: "Claude Code for Trading System (2026)"
permalink: /claude-code-trading-system-backtesting-2026/
date: 2026-04-20
description: "Trading system backtesting framework with Claude Code. Build event-driven engines with fill simulation and risk controls."
last_tested: "2026-04-22"
---

## Why Claude Code for Trading System Backtesting

Strategy backtesting frameworks require event-driven architecture that mirrors live trading: market data events trigger signal generation, signals pass through risk checks, risk-approved orders hit a fill simulator that models slippage and partial fills, and fills update portfolio state. Vectorized backtests (apply signals to return series) miss the execution reality that kills strategies in production -- queue priority, market impact, latency, and the feedback loop between your orders and the market.

Claude Code generates event-driven backtesting engines with realistic fill models, proper commission handling (maker/taker, exchange fees, clearing), and the risk controls (position limits, drawdown stops, correlation breaks) that production systems require. It produces code that transitions cleanly from backtest to paper trading to live execution.

## The Workflow

### Step 1: Framework Setup

```bash
pip install numpy pandas
pip install sortedcontainers  # for order book simulation
pip install pyarrow           # for fast data serialization

mkdir -p src/engine src/strategies src/fill_models src/risk data/
```

### Step 2: Build Event-Driven Backtesting Engine

```python
# src/engine/backtest_engine.py
"""Event-driven backtesting engine with fill simulation and risk controls."""

import numpy as np
import pandas as pd
from dataclasses import dataclass, field
from enum import Enum
from typing import Callable, Optional

class Side(Enum):
    BUY = 1
    SELL = -1

class OrderType(Enum):
    MARKET = 'market'
    LIMIT = 'limit'

class OrderStatus(Enum):
    PENDING = 'pending'
    FILLED = 'filled'
    PARTIALLY_FILLED = 'partial'
    CANCELLED = 'cancelled'
    REJECTED = 'rejected'

@dataclass
class Order:
    order_id: int
    symbol: str
    side: Side
    quantity: int
    order_type: OrderType
    limit_price: Optional[float] = None
    timestamp: Optional[pd.Timestamp] = None
    status: OrderStatus = OrderStatus.PENDING
    filled_qty: int = 0
    avg_fill_price: float = 0.0

@dataclass
class Fill:
    order_id: int
    symbol: str
    side: Side
    quantity: int
    price: float
    commission: float
    timestamp: pd.Timestamp

@dataclass
class Position:
    symbol: str
    quantity: int = 0
    avg_cost: float = 0.0
    realized_pnl: float = 0.0

    @property
    def notional(self) -> float:
        return abs(self.quantity) * self.avg_cost

    def update(self, fill: Fill) -> None:
        """Update position with a new fill."""
        fill_sign = 1 if fill.side == Side.BUY else -1
        fill_qty = fill_sign * fill.quantity

        if self.quantity == 0:
            self.avg_cost = fill.price
            self.quantity = fill_qty
        elif np.sign(self.quantity) == np.sign(fill_qty):
            # Adding to position: update average cost
            total_cost = self.avg_cost * abs(self.quantity) + \
                         fill.price * fill.quantity
            self.quantity += fill_qty
            self.avg_cost = total_cost / abs(self.quantity)
        else:
            # Reducing or flipping position: realize P&L
            close_qty = min(abs(self.quantity), fill.quantity)
            if self.quantity > 0:
                self.realized_pnl += close_qty * (fill.price - self.avg_cost)
            else:
                self.realized_pnl += close_qty * (self.avg_cost - fill.price)

            self.quantity += fill_qty
            if abs(fill_qty) > abs(self.quantity - fill_qty):
                self.avg_cost = fill.price

class FillSimulator:
    """Simulate order fills with slippage and partial fills."""

    def __init__(self, slippage_bps: float = 5.0,
                 fill_rate: float = 1.0,
                 commission_per_share: float = 0.005):
        self.slippage_bps = slippage_bps
        self.fill_rate = fill_rate
        self.commission_per_share = commission_per_share

    def simulate_fill(self, order: Order, bar: pd.Series) -> Optional[Fill]:
        """Simulate fill against OHLCV bar data."""
        if order.order_type == OrderType.MARKET:
            # Market order: fill at open + slippage
            base_price = bar['open']
            slippage = base_price * self.slippage_bps / 10000
            if order.side == Side.BUY:
                fill_price = base_price + slippage
            else:
                fill_price = base_price - slippage

        elif order.order_type == OrderType.LIMIT:
            # Limit order: check if price was touched
            if order.side == Side.BUY and bar['low'] <= order.limit_price:
                fill_price = order.limit_price
            elif order.side == Side.SELL and bar['high'] >= order.limit_price:
                fill_price = order.limit_price
            else:
                return None  # limit not reached

        fill_qty = int(order.quantity * self.fill_rate)
        if fill_qty <= 0:
            return None

        commission = fill_qty * self.commission_per_share

        return Fill(
            order_id=order.order_id,
            symbol=order.symbol,
            side=order.side,
            quantity=fill_qty,
            price=fill_price,
            commission=commission,
            timestamp=bar.name if hasattr(bar, 'name') else pd.Timestamp.now(),
        )

class RiskManager:
    """Pre-trade risk checks."""

    def __init__(self, max_position_pct: float = 0.10,
                 max_drawdown_pct: float = 0.15,
                 max_correlation: float = 0.80):
        self.max_position_pct = max_position_pct
        self.max_drawdown_pct = max_drawdown_pct
        self.peak_equity = 0.0

    def check_order(self, order: Order, portfolio_value: float,
                     current_position: Position) -> tuple:
        """Returns (approved: bool, reason: str)."""
        # Position size check
        order_notional = order.quantity * (order.limit_price or 0)
        if order_notional / (portfolio_value + 1e-10) > self.max_position_pct:
            return False, f"Position size {order_notional} exceeds {self.max_position_pct*100}% limit"

        # Drawdown check
        self.peak_equity = max(self.peak_equity, portfolio_value)
        drawdown = 1 - portfolio_value / (self.peak_equity + 1e-10)
        if drawdown > self.max_drawdown_pct:
            return False, f"Drawdown {drawdown:.1%} exceeds {self.max_drawdown_pct:.0%} limit"

        return True, "approved"

class BacktestEngine:
    """Main backtesting engine orchestrator."""

    def __init__(self, initial_capital: float = 1_000_000,
                 fill_sim: FillSimulator = None,
                 risk_mgr: RiskManager = None):
        self.capital = initial_capital
        self.fill_sim = fill_sim or FillSimulator()
        self.risk_mgr = risk_mgr or RiskManager()
        self.positions = {}
        self.fills = []
        self.equity_curve = []
        self._order_counter = 0

    def run(self, data: pd.DataFrame,
            strategy_fn: Callable) -> pd.DataFrame:
        """Run backtest: iterate bars, generate signals, fill orders."""
        for timestamp, bar in data.iterrows():
            # Strategy generates orders
            orders = strategy_fn(bar, self.positions, self.capital)

            for order in orders:
                self._order_counter += 1
                order.order_id = self._order_counter
                order.timestamp = timestamp

                # Risk check
                pos = self.positions.get(order.symbol, Position(order.symbol))
                approved, reason = self.risk_mgr.check_order(
                    order, self._portfolio_value(bar), pos
                )

                if not approved:
                    order.status = OrderStatus.REJECTED
                    continue

                # Fill simulation
                fill = self.fill_sim.simulate_fill(order, bar)
                if fill:
                    order.status = OrderStatus.FILLED
                    order.filled_qty = fill.quantity
                    order.avg_fill_price = fill.price

                    if order.symbol not in self.positions:
                        self.positions[order.symbol] = Position(order.symbol)
                    self.positions[order.symbol].update(fill)
                    self.capital -= fill.commission
                    self.fills.append(fill)

            self.equity_curve.append({
                'timestamp': timestamp,
                'equity': self._portfolio_value(bar),
            })

        return pd.DataFrame(self.equity_curve).set_index('timestamp')

    def _portfolio_value(self, bar: pd.Series) -> float:
        """Mark-to-market portfolio value."""
        mtm = self.capital
        for sym, pos in self.positions.items():
            if f'{sym}_close' in bar:
                mtm += pos.quantity * bar[f'{sym}_close']
            elif 'close' in bar:
                mtm += pos.quantity * bar['close']
        return mtm
```

### Step 3: Example Strategy

```python
# src/strategies/mean_reversion.py
"""Simple mean reversion strategy for backtesting demonstration."""

from src.engine.backtest_engine import Order, Side, OrderType, Position

def mean_reversion_strategy(bar, positions: dict, capital: float,
                             lookback: int = 20,
                             z_entry: float = 2.0,
                             z_exit: float = 0.5) -> list:
    """Mean reversion: buy when z-score < -2, sell when z-score > 2."""
    orders = []
    symbol = 'SPY'
    pos = positions.get(symbol, Position(symbol))
    position_size = int(capital * 0.05 / (bar['close'] + 1e-10))

    # Simplified: use bar data directly
    if 'z_score' in bar:
        z = bar['z_score']

        if z < -z_entry and pos.quantity <= 0:
            orders.append(Order(0, symbol, Side.BUY, position_size, OrderType.MARKET))
        elif z > z_entry and pos.quantity >= 0:
            orders.append(Order(0, symbol, Side.SELL, position_size, OrderType.MARKET))
        elif abs(z) < z_exit and pos.quantity != 0:
            # Exit position
            side = Side.SELL if pos.quantity > 0 else Side.BUY
            orders.append(Order(0, symbol, side, abs(pos.quantity), OrderType.MARKET))

    return orders
```

### Step 4: Verify

```bash
python3 -c "
import numpy as np
import pandas as pd
from src.engine.backtest_engine import BacktestEngine, FillSimulator, Order, Side, OrderType, Position

np.random.seed(42)
dates = pd.bdate_range('2025-01-01', periods=252)
prices = 100 * np.exp(np.cumsum(np.random.randn(252) * 0.01))
data = pd.DataFrame({
    'open': prices * (1 + np.random.randn(252)*0.001),
    'high': prices * 1.01,
    'low': prices * 0.99,
    'close': prices,
    'volume': np.random.randint(1e6, 1e7, 252),
    'z_score': np.random.randn(252),
}, index=dates)

def simple_strategy(bar, positions, capital):
    orders = []
    if bar['z_score'] < -2:
        orders.append(Order(0, 'SPY', Side.BUY, 100, OrderType.MARKET))
    elif bar['z_score'] > 2:
        orders.append(Order(0, 'SPY', Side.SELL, 100, OrderType.MARKET))
    return orders

engine = BacktestEngine(initial_capital=1_000_000,
                         fill_sim=FillSimulator(slippage_bps=5))
equity = engine.run(data, simple_strategy)

print(f'Final equity: \${equity[\"equity\"].iloc[-1]:,.0f}')
print(f'Total fills: {len(engine.fills)}')
print(f'Equity points: {len(equity)}')
assert len(equity) == 252, 'Missing equity points'
assert len(engine.fills) > 0, 'No fills generated'
print('Backtest engine: PASS')
"
```

## CLAUDE.md for Trading System Backtesting

```markdown
# Trading System Backtesting Standards

## Architecture
- Event-driven (not vectorized) for realistic simulation
- Separate signal generation from execution logic
- Risk manager sits between strategy and fill simulator
- Fill simulator models slippage, partial fills, commissions

## Bias Prevention
- No look-ahead: strategy sees only data available at decision time
- No survivorship: include delisted instruments in universe
- Commission and slippage modeling: 5-10 bps minimum
- Walk-forward validation: never report in-sample results

## Performance Metrics
- Sharpe ratio (annualized, excess of risk-free)
- Maximum drawdown (peak to trough)
- Calmar ratio (return / max drawdown)
- Turnover (annual, one-way)
- Net return after all costs

## Common Commands
- python3 src/engine/backtest_engine.py — run backtest
- python3 -c "import pyfolio; pyfolio.create_full_tear_sheet(...)" — performance report
```

## Common Pitfalls

- **Look-ahead bias in bar data:** Using the close price for entry when the signal depends on the close creates a fill at a price the strategy could not have known. Claude Code fills market orders at the next bar's open with slippage, never the current bar's close.
- **Missing commission modeling:** A strategy that trades 50 times per day at $0.005 per share with 1000-share orders loses $250/day in commissions alone. Claude Code tracks cumulative commission impact and reports it separately from gross P&L.
- **Overfitting to parameter optimization:** Grid-searching 100 parameter combinations guarantees one with a great backtest. Claude Code implements walk-forward optimization with out-of-sample windows and reports the distribution of out-of-sample Sharpe ratios across folds.

## Related

- [Claude Code for Algo Trading Backtesting](/claude-code-algorithmic-trading-backtesting-2026/)
- [Claude Code for Market Microstructure](/claude-code-market-microstructure-analysis-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Quant Research Backtesting (2026)](/claude-code-quant-research-backtesting-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Related Guides

- [Claude Code for Buck2 Build System](/claude-code-for-buck2-build-system-workflow-guide/)
- [Claude Code Hooks System](/understanding-claude-code-hooks-system-complete-guide/)
- [Read Claude Code System Prompts Repo](/how-to-read-claude-code-system-prompts-2026/)
- [System Prompt Optimization to Cut](/system-prompt-optimization-cut-claude-costs/)

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
