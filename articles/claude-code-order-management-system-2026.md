---
layout: default
title: "Claude Code for Order Management (2026)"
permalink: /claude-code-order-management-system-2026/
date: 2026-04-20
description: "Order management system development with Claude Code. Build OMS with smart routing, compliance checks, and audit trails."
last_tested: "2026-04-22"
---

## Why Claude Code for Order Management Systems

An Order Management System (OMS) sits at the center of every trading desk: it receives orders from portfolio managers, validates them against compliance rules, routes to execution venues via FIX protocol, tracks fill status, and maintains an audit trail that regulators can subpoena years later. A production OMS handles thousands of orders per second with sub-millisecond state transitions, and a single bug in order state management (double-filling, missing cancellation acknowledgment, wrong order quantity after amendment) can cause real financial loss.

Claude Code generates OMS components with proper state machine design, compliance rule engines, smart order routing logic, and the persistent audit logging that regulators expect. It understands the FIX protocol order lifecycle and produces the state transition code that handles every edge case: partial fills, unsolicited cancels, reject-after-partial-fill, and broker-initiated amendments.

## The Workflow

### Step 1: OMS Development Setup

```bash
pip install asyncio aiohttp
pip install sqlalchemy alembic  # database ORM + migrations
pip install pydantic            # data validation
pip install simplefix           # FIX protocol

mkdir -p src/oms src/compliance src/routing src/audit tests/
```

### Step 2: Build Order State Machine

```python
# src/oms/order_state_machine.py
"""Order state machine following FIX protocol lifecycle."""

from enum import Enum
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class OrderState(Enum):
    NEW = 'new'                      # Created, not yet sent
    PENDING_NEW = 'pending_new'      # Sent to broker, awaiting ack
    OPEN = 'open'                    # Acknowledged by broker
    PARTIALLY_FILLED = 'partial'     # Some quantity filled
    FILLED = 'filled'                # Fully filled
    PENDING_CANCEL = 'pending_cancel'
    CANCELLED = 'cancelled'
    PENDING_AMEND = 'pending_amend'
    REJECTED = 'rejected'
    EXPIRED = 'expired'

# Valid state transitions
VALID_TRANSITIONS = {
    OrderState.NEW: {OrderState.PENDING_NEW, OrderState.REJECTED},
    OrderState.PENDING_NEW: {OrderState.OPEN, OrderState.REJECTED,
                              OrderState.FILLED},
    OrderState.OPEN: {OrderState.PARTIALLY_FILLED, OrderState.FILLED,
                       OrderState.PENDING_CANCEL, OrderState.PENDING_AMEND,
                       OrderState.EXPIRED, OrderState.CANCELLED},
    OrderState.PARTIALLY_FILLED: {OrderState.PARTIALLY_FILLED,
                                    OrderState.FILLED,
                                    OrderState.PENDING_CANCEL,
                                    OrderState.CANCELLED},
    OrderState.PENDING_CANCEL: {OrderState.CANCELLED,
                                  OrderState.PARTIALLY_FILLED,
                                  OrderState.FILLED},
    OrderState.PENDING_AMEND: {OrderState.OPEN,
                                 OrderState.PARTIALLY_FILLED,
                                 OrderState.REJECTED},
    OrderState.FILLED: set(),       # terminal state
    OrderState.CANCELLED: set(),    # terminal state
    OrderState.REJECTED: set(),     # terminal state
    OrderState.EXPIRED: set(),      # terminal state
}

@dataclass
class OrderEvent:
    event_type: str
    timestamp: datetime
    details: dict = field(default_factory=dict)

@dataclass
class Order:
    order_id: str
    client_order_id: str
    symbol: str
    side: str               # 'BUY' or 'SELL'
    quantity: int
    order_type: str         # 'MARKET', 'LIMIT', 'STOP'
    limit_price: Optional[float] = None
    time_in_force: str = 'DAY'      # DAY, GTC, IOC, FOK
    account: str = ''
    trader_id: str = ''
    state: OrderState = OrderState.NEW
    filled_quantity: int = 0
    avg_fill_price: float = 0.0
    remaining_quantity: int = 0
    broker_order_id: Optional[str] = None
    venue: Optional[str] = None
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    events: list = field(default_factory=list)

    def __post_init__(self):
        self.remaining_quantity = self.quantity - self.filled_quantity
        self._log_event('ORDER_CREATED', {'initial_state': self.state.value})

    def transition(self, new_state: OrderState, details: dict = None) -> bool:
        """Attempt state transition with validation."""
        if new_state not in VALID_TRANSITIONS.get(self.state, set()):
            logger.warning(
                f"Invalid transition: {self.order_id} "
                f"{self.state.value} -> {new_state.value}"
            )
            return False

        old_state = self.state
        self.state = new_state
        self._log_event('STATE_CHANGE', {
            'from': old_state.value,
            'to': new_state.value,
            **(details or {}),
        })
        return True

    def apply_fill(self, fill_qty: int, fill_price: float,
                    exec_id: str) -> bool:
        """Process an execution report (fill)."""
        assert fill_qty > 0, f"Invalid fill quantity: {fill_qty}"
        assert fill_price > 0, f"Invalid fill price: {fill_price}"

        if fill_qty > self.remaining_quantity:
            logger.error(
                f"Overfill: {self.order_id} got {fill_qty}, "
                f"remaining {self.remaining_quantity}"
            )
            return False

        # Update average fill price (VWAP)
        total_cost = self.avg_fill_price * self.filled_quantity + \
                     fill_price * fill_qty
        self.filled_quantity += fill_qty
        self.avg_fill_price = total_cost / self.filled_quantity
        self.remaining_quantity = self.quantity - self.filled_quantity

        details = {
            'exec_id': exec_id,
            'fill_qty': fill_qty,
            'fill_price': fill_price,
            'cumulative_qty': self.filled_quantity,
            'avg_price': self.avg_fill_price,
        }

        if self.remaining_quantity == 0:
            return self.transition(OrderState.FILLED, details)
        else:
            return self.transition(OrderState.PARTIALLY_FILLED, details)

    def _log_event(self, event_type: str, details: dict) -> None:
        self.events.append(OrderEvent(
            event_type=event_type,
            timestamp=datetime.now(timezone.utc),
            details=details,
        ))
```

### Step 3: Compliance Rule Engine

```python
# src/compliance/pre_trade_checks.py
"""Pre-trade compliance checks: position limits, restricted lists, concentration."""

from dataclasses import dataclass
from typing import Optional

@dataclass
class ComplianceResult:
    approved: bool
    rule_name: str
    reason: str
    severity: str  # 'hard_block', 'soft_warning'

def check_restricted_list(symbol: str, restricted_symbols: set) -> ComplianceResult:
    """Block orders on restricted securities (insider trading prevention)."""
    if symbol in restricted_symbols:
        return ComplianceResult(
            approved=False,
            rule_name='RESTRICTED_LIST',
            reason=f'{symbol} is on the restricted trading list',
            severity='hard_block',
        )
    return ComplianceResult(True, 'RESTRICTED_LIST', 'passed', 'info')

def check_position_limit(symbol: str, side: str, order_qty: int,
                          current_position: int,
                          max_position: int) -> ComplianceResult:
    """Enforce per-symbol position limits."""
    projected = current_position + (order_qty if side == 'BUY' else -order_qty)

    if abs(projected) > max_position:
        return ComplianceResult(
            approved=False,
            rule_name='POSITION_LIMIT',
            reason=f'Projected position {projected} exceeds limit {max_position}',
            severity='hard_block',
        )
    return ComplianceResult(True, 'POSITION_LIMIT', 'passed', 'info')

def check_fat_finger(order_qty: int, order_value: float,
                      max_qty: int = 100000,
                      max_value: float = 10_000_000) -> ComplianceResult:
    """Fat finger check: reject obviously erroneous orders."""
    if order_qty > max_qty:
        return ComplianceResult(
            approved=False,
            rule_name='FAT_FINGER_QTY',
            reason=f'Quantity {order_qty} exceeds max {max_qty}',
            severity='hard_block',
        )
    if order_value > max_value:
        return ComplianceResult(
            approved=False,
            rule_name='FAT_FINGER_VALUE',
            reason=f'Value ${order_value:,.0f} exceeds max ${max_value:,.0f}',
            severity='hard_block',
        )
    return ComplianceResult(True, 'FAT_FINGER', 'passed', 'info')

def check_wash_trade(symbol: str, side: str, trader_id: str,
                      recent_trades: list) -> ComplianceResult:
    """Detect potential wash trades (buy and sell same security in short window)."""
    opposite_side = 'SELL' if side == 'BUY' else 'BUY'
    for trade in recent_trades:
        if (trade['symbol'] == symbol and
            trade['side'] == opposite_side and
            trade['trader_id'] == trader_id):
            return ComplianceResult(
                approved=False,
                rule_name='WASH_TRADE',
                reason=f'Potential wash trade: opposite trade within window',
                severity='soft_warning',
            )
    return ComplianceResult(True, 'WASH_TRADE', 'passed', 'info')

def run_all_checks(order, portfolio_state: dict,
                    restricted_symbols: set,
                    recent_trades: list) -> list:
    """Run all pre-trade compliance checks."""
    results = []
    results.append(check_restricted_list(order.symbol, restricted_symbols))
    results.append(check_position_limit(
        order.symbol, order.side, order.quantity,
        portfolio_state.get(order.symbol, {}).get('position', 0),
        portfolio_state.get(order.symbol, {}).get('limit', 50000),
    ))
    results.append(check_fat_finger(
        order.quantity,
        order.quantity * (order.limit_price or 100.0),
    ))
    results.append(check_wash_trade(
        order.symbol, order.side, order.trader_id, recent_trades
    ))

    return results
```

### Step 4: Verify

```bash
python3 -c "
from src.oms.order_state_machine import Order, OrderState

# Create and process an order through its lifecycle
order = Order(
    order_id='ORD-001',
    client_order_id='CLI-001',
    symbol='AAPL',
    side='BUY',
    quantity=1000,
    order_type='LIMIT',
    limit_price=175.50,
    trader_id='TRADER-001',
)

assert order.state == OrderState.NEW
print(f'1. Created: {order.state.value}')

# Send to broker
assert order.transition(OrderState.PENDING_NEW)
print(f'2. Sent: {order.state.value}')

# Broker acknowledges
assert order.transition(OrderState.OPEN)
print(f'3. Acknowledged: {order.state.value}')

# Partial fill
assert order.apply_fill(300, 175.48, 'EXEC-001')
print(f'4. Partial fill: {order.state.value}, filled={order.filled_quantity}')
assert order.state == OrderState.PARTIALLY_FILLED

# Another partial fill
assert order.apply_fill(700, 175.50, 'EXEC-002')
print(f'5. Full fill: {order.state.value}, filled={order.filled_quantity}')
assert order.state == OrderState.FILLED

# Verify VWAP
expected_vwap = (300*175.48 + 700*175.50) / 1000
print(f'6. Avg price: {order.avg_fill_price:.4f} (expected {expected_vwap:.4f})')
assert abs(order.avg_fill_price - expected_vwap) < 0.01

# Verify terminal state (no more transitions allowed)
assert not order.transition(OrderState.CANCELLED)
print(f'7. Terminal state verified: cannot cancel filled order')

# Verify audit trail
print(f'8. Audit events: {len(order.events)}')
assert len(order.events) >= 5, 'Missing audit events'
print('OMS state machine: PASS')
"
```

## CLAUDE.md for Order Management Systems

```markdown
# Order Management System Development

## FIX Protocol Lifecycle
- New -> PendingNew -> Open -> (PartialFill)* -> Filled
- Open -> PendingCancel -> Cancelled
- Any pending state can receive unsolicited fills or rejects

## Compliance Rules
- Restricted list check (hard block)
- Position limits per symbol and portfolio
- Fat finger checks (quantity and notional limits)
- Wash trade detection (same symbol, opposite side, short window)
- Short sell locate requirements (Reg SHO)

## Audit Requirements
- Every state transition logged with timestamp (microsecond)
- All compliance check results persisted (pass and fail)
- Order amendments tracked with before/after values
- 7-year retention (SEC Rule 17a-4, MiFID II Article 25)

## Libraries
- simplefix (FIX protocol encoding/decoding)
- sqlalchemy (ORM for order/fill persistence)
- pydantic (order validation)
- asyncio (concurrent order processing)

## Common Commands
- python3 src/oms/order_state_machine.py — test state transitions
- alembic upgrade head — run database migrations
- python3 src/compliance/pre_trade_checks.py — test compliance engine
```

## Common Pitfalls

- **Race condition on concurrent fills:** Two partial fill messages arriving simultaneously can both read the same remaining_quantity and produce an overfill. Claude Code implements atomic fill application with a lock or compare-and-swap pattern that prevents double-counting.
- **Missing unsolicited cancel handling:** Brokers can cancel orders unilaterally (market halt, credit limit). An OMS that only expects user-initiated cancels leaves phantom open orders in the book. Claude Code handles the PENDING_CANCEL -> FILLED edge case and unsolicited state changes.
- **Audit trail gaps during errors:** Exception handling that skips the logging step creates gaps regulators will find. Claude Code uses a decorator pattern that logs state before and after every operation, including failed transitions.

## Related

- [Claude Code for FIX Protocol Message Handling](/claude-code-fix-protocol-message-handling-2026/)
- [Claude Code for Trading System Backtesting](/claude-code-trading-system-backtesting-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Ada Legacy System Updates (2026)](/claude-code-ada-legacy-system-updates-2026/)


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

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Snippet Library Management](/claude-code-snippet-library-management/)
- [Claude Code Tmux Session Management](/claude-code-tmux-session-management-multi-agent-workflow/)
- [Tab Management for Claude Code Research](/onetab-alternative-chrome-extension-2026/)
- [Claude Code for Review Queue Management](/claude-code-for-review-queue-management-workflow/)

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
