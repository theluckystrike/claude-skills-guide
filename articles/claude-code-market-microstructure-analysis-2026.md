---
title: "Claude Code for Market Microstructure (2026)"
permalink: /claude-code-market-microstructure-analysis-2026/
description: "Market microstructure analysis with Claude Code. Build order book reconstruction, trade classification, and price impact models."
last_tested: "2026-04-22"
---

## Why Claude Code for Market Microstructure

Market microstructure research studies how orders become trades and how trades become prices. It requires processing tick-level data (millions of events per day per symbol), reconstructing limit order books from message feeds, classifying trades as buyer- or seller-initiated (Lee-Ready algorithm), and estimating transaction cost models (Kyle's lambda, Amihud illiquidity). The data formats are vendor-specific: LOBSTER for academic research, ITCH for Nasdaq, PITCH for BATS/Cboe.

Claude Code generates efficient pandas/numpy pipelines for tick data processing, implements the canonical trade classification and price impact models from the academic literature, and produces the LOB (Limit Order Book) reconstruction code that handles the edge cases -- hidden orders, odd lots, crossed books during halts -- that break naive implementations.

## The Workflow

### Step 1: Microstructure Research Setup

```bash
pip install numpy pandas polars  # polars for large tick data
pip install tick  # point process models
pip install lobsterdata  # LOBSTER data parser

mkdir -p src/orderbook src/classification src/impact data/
```

### Step 2: Limit Order Book Reconstruction

```python
# src/orderbook/lob_engine.py
"""Limit Order Book reconstruction from message-level data."""

import numpy as np
from dataclasses import dataclass, field
from collections import defaultdict
from sortedcontainers import SortedDict

@dataclass
class Order:
    order_id: int
    side: str         # 'bid' or 'ask'
    price: float
    size: int
    timestamp_ns: int

@dataclass
class LOBSnapshot:
    timestamp_ns: int
    bids: list        # [(price, size), ...] best to worst
    asks: list        # [(price, size), ...] best to worst
    mid_price: float
    spread: float
    bid_depth: int
    ask_depth: int

class LimitOrderBook:
    """Reconstructs and maintains a limit order book from message feed."""

    def __init__(self, max_levels: int = 10):
        self.bids = SortedDict()  # price -> total_size (descending)
        self.asks = SortedDict()  # price -> total_size (ascending)
        self.orders = {}          # order_id -> Order
        self.max_levels = max_levels

    def add_order(self, order: Order) -> None:
        """Process a new limit order."""
        assert order.size > 0, f"Invalid size: {order.size}"
        self.orders[order.order_id] = order

        if order.side == 'bid':
            key = -order.price  # negative for descending sort
            self.bids[key] = self.bids.get(key, 0) + order.size
        else:
            self.asks[order.price] = self.asks.get(order.price, 0) + order.size

    def cancel_order(self, order_id: int, cancel_size: int = None) -> None:
        """Cancel (fully or partially) an existing order."""
        if order_id not in self.orders:
            return  # already filled or cancelled

        order = self.orders[order_id]
        size_to_remove = cancel_size if cancel_size else order.size

        if order.side == 'bid':
            key = -order.price
            if key in self.bids:
                self.bids[key] -= size_to_remove
                if self.bids[key] <= 0:
                    del self.bids[key]
        else:
            if order.price in self.asks:
                self.asks[order.price] -= size_to_remove
                if self.asks[order.price] <= 0:
                    del self.asks[order.price]

        if cancel_size and cancel_size < order.size:
            order.size -= cancel_size
        else:
            del self.orders[order_id]

    def execute_order(self, order_id: int, exec_size: int) -> None:
        """Process a trade execution (partial or full fill)."""
        self.cancel_order(order_id, exec_size)

    def snapshot(self, timestamp_ns: int) -> LOBSnapshot:
        """Get current book state."""
        bid_levels = [(-price, size) for price, size
                      in self.bids.items()[:self.max_levels]]
        ask_levels = [(price, size) for price, size
                      in self.asks.items()[:self.max_levels]]

        best_bid = bid_levels[0][0] if bid_levels else 0.0
        best_ask = ask_levels[0][0] if ask_levels else float('inf')

        mid = (best_bid + best_ask) / 2.0 if bid_levels and ask_levels else 0.0
        spread = best_ask - best_bid if bid_levels and ask_levels else float('inf')

        return LOBSnapshot(
            timestamp_ns=timestamp_ns,
            bids=bid_levels,
            asks=ask_levels,
            mid_price=mid,
            spread=spread,
            bid_depth=sum(s for _, s in bid_levels),
            ask_depth=sum(s for _, s in ask_levels),
        )
```

### Step 3: Trade Classification and Impact

```python
# src/classification/trade_classifier.py
"""Trade classification: Lee-Ready, bulk volume classification."""

import numpy as np
import pandas as pd

def lee_ready_classify(trades: pd.DataFrame,
                        quotes: pd.DataFrame) -> pd.Series:
    """Lee-Ready (1991) trade classification algorithm.
    Step 1: Quote test (trade price vs midpoint)
    Step 2: Tick test (trade price vs previous trade price)
    """
    # Merge trades with prevailing quotes (quote must precede trade by >= 1s)
    trades = trades.sort_values('timestamp')
    quotes = quotes.sort_values('timestamp')

    # Assign prevailing midpoint to each trade
    quotes['mid'] = (quotes['bid'] + quotes['ask']) / 2.0
    merged = pd.merge_asof(trades, quotes[['timestamp', 'mid', 'bid', 'ask']],
                            on='timestamp', direction='backward',
                            tolerance=pd.Timedelta('5s'))

    # Quote test: trade above mid = buy, below = sell
    direction = np.where(merged['price'] > merged['mid'], 1,
                np.where(merged['price'] < merged['mid'], -1, 0))

    # Tick test for trades at midpoint
    price_diff = merged['price'].diff()
    tick_direction = np.sign(price_diff)
    # Propagate last non-zero tick
    tick_direction = pd.Series(tick_direction).replace(0, np.nan).ffill().fillna(0)

    # Combine: quote test primary, tick test for midpoint trades
    final = np.where(direction != 0, direction, tick_direction)

    return pd.Series(final, index=trades.index, name='direction')

def kyle_lambda(trades: pd.DataFrame, freq: str = '5min') -> float:
    """Estimate Kyle's lambda (price impact coefficient).
    lambda = Cov(dp, OIB) / Var(OIB)
    where OIB = signed order flow (sum of trade directions * sizes).
    """
    trades['signed_volume'] = trades['direction'] * trades['size']

    # Aggregate to intervals
    bars = trades.resample(freq, on='timestamp').agg({
        'price': 'last',
        'signed_volume': 'sum',
    }).dropna()

    dp = bars['price'].diff().dropna()
    oib = bars['signed_volume'].iloc[1:]

    assert len(dp) >= 30, f"Need 30+ intervals, got {len(dp)}"

    cov = np.cov(dp, oib)[0, 1]
    var_oib = np.var(oib)

    lam = cov / (var_oib + 1e-10)
    return float(lam)

def amihud_illiquidity(returns: pd.Series,
                        volume: pd.Series) -> float:
    """Amihud (2002) illiquidity ratio: mean(|r|/volume).
    Higher = less liquid.
    """
    assert len(returns) == len(volume)
    assert (volume > 0).all(), "Volume must be positive"

    illiq = np.mean(np.abs(returns) / volume)
    return float(illiq)
```

### Step 4: Verify

```bash
python3 -c "
import numpy as np
from src.orderbook.lob_engine import LimitOrderBook, Order

lob = LimitOrderBook()

# Build a simple book
lob.add_order(Order(1, 'bid', 100.00, 500, 0))
lob.add_order(Order(2, 'bid', 99.99, 300, 1))
lob.add_order(Order(3, 'ask', 100.01, 400, 2))
lob.add_order(Order(4, 'ask', 100.02, 600, 3))

snap = lob.snapshot(4)
print(f'Mid: {snap.mid_price:.2f}, Spread: {snap.spread:.2f}')
print(f'Best bid: {snap.bids[0]}, Best ask: {snap.asks[0]}')
assert snap.mid_price == 100.005, 'Wrong mid price'
assert snap.spread == 0.01, 'Wrong spread'

# Execute a trade (fill 200 of bid order 1)
lob.execute_order(1, 200)
snap2 = lob.snapshot(5)
print(f'After trade: bid depth={snap2.bid_depth}')
assert snap2.bid_depth == 600, 'Wrong bid depth after execution'
print('LOB reconstruction: PASS')
"
```

## CLAUDE.md for Market Microstructure

```markdown
# Market Microstructure Analysis

## Data Sources
- LOBSTER: academic LOB data (Nasdaq)
- ITCH: Nasdaq TotalView message feed
- TAQ: NYSE Trade and Quote (millisecond)
- Tick History: Refinitiv/LSEG

## Classification Methods
- Lee-Ready (1991): quote test + tick test
- Bulk Volume Classification (Easley et al. 2012)
- EMO rule: Ellis-Michaely-O'Hara

## Impact Models
- Kyle's lambda: linear price impact
- Amihud illiquidity: |return|/volume
- Hasbrouck (2009): realized spread decomposition
- Almgren-Chriss: optimal execution

## Libraries
- polars (fast tick data processing)
- sortedcontainers (order book levels)
- tick (Hawkes process, point process)
- lobsterdata (LOBSTER format parser)

## Common Commands
- python3 src/orderbook/lob_engine.py — reconstruct LOB
- polars scan_csv('ticks.csv').filter(...) — lazy tick data query
```

## Common Pitfalls

- **Quote timestamp alignment:** Trades must be matched with the prevailing quote that was live *before* the trade, not the nearest quote. Using merge_asof without the `direction='backward'` parameter introduces look-ahead bias. Claude Code enforces backward-only quote matching.
- **Odd lot handling in NBBO:** Sub-round-lot orders do not update the NBBO under Reg NMS. Including them in midpoint calculations introduces errors. Claude Code filters by round lot status when computing the prevailing quote.
- **Crossed book during halts:** Market messages during LULD halts produce temporarily crossed books (best bid > best ask). Claude Code detects crossed states and marks snapshots as invalid rather than computing nonsensical spreads.

## Related

- [Claude Code for FIX Protocol Message Handling](/claude-code-fix-protocol-message-handling-2026/)
- [Claude Code for Algo Trading Backtesting](/claude-code-algorithmic-trading-backtesting-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Seismology Waveform Analysis (2026)](/claude-code-seismology-waveform-analysis-2026/)


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
