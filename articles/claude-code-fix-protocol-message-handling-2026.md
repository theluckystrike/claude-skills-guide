---
title: "Claude Code for FIX Protocol Message Handling (2026)"
description: "FIX protocol message parsing and order routing with Claude Code. Build compliant FIX 4.4 engines and session logic."
permalink: /claude-code-fix-protocol-message-handling-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for FIX Protocol

The Financial Information eXchange (FIX) protocol carries the majority of global equities order flow. Building a FIX engine means implementing session-layer logic (logon, heartbeat, sequence number management, gap fill), application-layer message construction (NewOrderSingle, ExecutionReport, OrderCancelRequest), and the tag-value encoding that every broker requires slightly differently.

Claude Code understands FIX 4.2/4.4/5.0 tag dictionaries, generates message constructors with correct tag types (string vs int vs float vs UTCTimestamp), and builds session handlers that manage sequence numbers and resend requests. It catches the tag ordering and conditional field requirements that cause broker rejects.

## The Workflow

### Step 1: Setup

```bash
pip install quickfix simplefix
# quickfix: full FIX engine (C++ core with Python binding)
# simplefix: lightweight message parser

mkdir -p fix_engine/{config,messages,session,tests}
```

### Step 2: FIX Message Builder and Parser

```python
# fix_engine/messages/order_builder.py
"""Build and parse FIX 4.4 order messages with validation."""
import simplefix
import time
from datetime import datetime, timezone
from dataclasses import dataclass

# FIX 4.4 tag constants
TAG_BEGIN_STRING = 8
TAG_BODY_LENGTH = 9
TAG_MSG_TYPE = 35
TAG_SENDER_COMP_ID = 49
TAG_TARGET_COMP_ID = 56
TAG_MSG_SEQ_NUM = 34
TAG_SENDING_TIME = 52
TAG_CHECKSUM = 10
TAG_CL_ORD_ID = 11
TAG_SYMBOL = 55
TAG_SIDE = 54
TAG_ORDER_QTY = 38
TAG_ORD_TYPE = 40
TAG_PRICE = 44
TAG_TIME_IN_FORCE = 59
TAG_TRANSACT_TIME = 60
TAG_EXEC_ID = 17
TAG_ORD_STATUS = 39
TAG_EXEC_TYPE = 150
TAG_LEAVES_QTY = 151
TAG_CUM_QTY = 14
TAG_AVG_PX = 6

MAX_ORDER_QTY = 1_000_000
MAX_PRICE = 1_000_000.0


@dataclass
class Order:
    cl_ord_id: str
    symbol: str
    side: str       # "1" = Buy, "2" = Sell
    quantity: int
    ord_type: str   # "1" = Market, "2" = Limit
    price: float    # 0 for market orders
    tif: str        # "0" = Day, "1" = GTC, "3" = IOC


def new_order_single(order: Order, sender: str,
                     target: str, seq_num: int) -> bytes:
    """Build FIX 4.4 NewOrderSingle (MsgType=D)."""
    assert order.cl_ord_id, "ClOrdID required"
    assert order.symbol, "Symbol required"
    assert order.side in ("1", "2"), f"Invalid side: {order.side}"
    assert 0 < order.quantity <= MAX_ORDER_QTY, \
        f"Quantity out of range: {order.quantity}"
    assert order.ord_type in ("1", "2"), \
        f"Invalid OrdType: {order.ord_type}"
    if order.ord_type == "2":
        assert 0 < order.price <= MAX_PRICE, \
            f"Limit order requires valid price: {order.price}"
    assert seq_num > 0, "Sequence number must be positive"

    msg = simplefix.FixMessage()
    msg.append_pair(TAG_BEGIN_STRING, "FIX.4.4")
    msg.append_pair(TAG_MSG_TYPE, "D")  # NewOrderSingle
    msg.append_pair(TAG_SENDER_COMP_ID, sender)
    msg.append_pair(TAG_TARGET_COMP_ID, target)
    msg.append_pair(TAG_MSG_SEQ_NUM, seq_num)
    msg.append_utc_timestamp(TAG_SENDING_TIME)
    msg.append_pair(TAG_CL_ORD_ID, order.cl_ord_id)
    msg.append_pair(TAG_SYMBOL, order.symbol)
    msg.append_pair(TAG_SIDE, order.side)
    msg.append_pair(TAG_ORDER_QTY, order.quantity)
    msg.append_pair(TAG_ORD_TYPE, order.ord_type)

    if order.ord_type == "2":
        msg.append_pair(TAG_PRICE, f"{order.price:.2f}")

    msg.append_pair(TAG_TIME_IN_FORCE, order.tif)
    msg.append_utc_timestamp(TAG_TRANSACT_TIME)

    return msg.encode()


def parse_execution_report(raw: bytes) -> dict:
    """Parse FIX ExecutionReport (MsgType=8) into dict."""
    assert raw and len(raw) > 0, "Empty message"

    parser = simplefix.FixParser()
    parser.append_buffer(raw)
    msg = parser.get_message()
    assert msg is not None, "Failed to parse FIX message"

    msg_type = msg.get(TAG_MSG_TYPE)
    assert msg_type == b"8", f"Expected MsgType=8, got {msg_type}"

    report = {
        "cl_ord_id": msg.get(TAG_CL_ORD_ID, b"").decode(),
        "exec_id": msg.get(TAG_EXEC_ID, b"").decode(),
        "ord_status": msg.get(TAG_ORD_STATUS, b"").decode(),
        "exec_type": msg.get(TAG_EXEC_TYPE, b"").decode(),
        "symbol": msg.get(TAG_SYMBOL, b"").decode(),
        "side": msg.get(TAG_SIDE, b"").decode(),
        "leaves_qty": int(msg.get(TAG_LEAVES_QTY, b"0")),
        "cum_qty": int(msg.get(TAG_CUM_QTY, b"0")),
        "avg_px": float(msg.get(TAG_AVG_PX, b"0")),
    }

    return report


def build_cancel_request(orig_cl_ord_id: str, new_cl_ord_id: str,
                         symbol: str, side: str,
                         sender: str, target: str,
                         seq_num: int) -> bytes:
    """Build OrderCancelRequest (MsgType=F)."""
    assert orig_cl_ord_id, "Original ClOrdID required"
    assert new_cl_ord_id, "New ClOrdID required"
    assert seq_num > 0

    msg = simplefix.FixMessage()
    msg.append_pair(TAG_BEGIN_STRING, "FIX.4.4")
    msg.append_pair(TAG_MSG_TYPE, "F")  # OrderCancelRequest
    msg.append_pair(TAG_SENDER_COMP_ID, sender)
    msg.append_pair(TAG_TARGET_COMP_ID, target)
    msg.append_pair(TAG_MSG_SEQ_NUM, seq_num)
    msg.append_utc_timestamp(TAG_SENDING_TIME)
    msg.append_pair(TAG_CL_ORD_ID, new_cl_ord_id)
    msg.append_pair(41, orig_cl_ord_id)  # OrigClOrdID
    msg.append_pair(TAG_SYMBOL, symbol)
    msg.append_pair(TAG_SIDE, side)
    msg.append_utc_timestamp(TAG_TRANSACT_TIME)

    return msg.encode()


if __name__ == "__main__":
    # Build a limit buy order
    order = Order(
        cl_ord_id="ORD-20260421-001",
        symbol="AAPL",
        side="1",        # Buy
        quantity=100,
        ord_type="2",    # Limit
        price=185.50,
        tif="0",         # Day
    )

    raw = new_order_single(order, "MYCOMP", "EXCHANGE", 42)
    print(f"NewOrderSingle ({len(raw)} bytes):")
    print(raw.decode("ascii", errors="replace"))

    # Build cancel
    cancel = build_cancel_request(
        "ORD-20260421-001", "CXL-20260421-001",
        "AAPL", "1", "MYCOMP", "EXCHANGE", 43)
    print(f"\nOrderCancelRequest ({len(cancel)} bytes):")
    print(cancel.decode("ascii", errors="replace"))
```

### Step 3: Test with FIX Session

```bash
python3 fix_engine/messages/order_builder.py
# Expected: valid FIX message with correct tags and checksum

# Integration test with QuickFIX acceptor
# Configure acceptor in fix_engine/config/acceptor.cfg
# Run: python3 fix_engine/session/acceptor.py &
# Then: python3 fix_engine/session/initiator.py
```

## CLAUDE.md for FIX Protocol

```markdown
# FIX Protocol Rules

## Standards
- FIX 4.4 (most common for equities)
- FIX 5.0 SP2 (newer venues)
- FIX tag dictionary from fixtrading.org

## File Formats
- .cfg (QuickFIX configuration)
- .xml (FIX data dictionary)
- .log (FIX message logs, pipe-delimited)

## Libraries
- quickfix 1.15+ (full FIX engine)
- simplefix 1.0+ (lightweight parser)
- pandas (trade reporting)

## Testing
- Message checksum (tag 10) must be valid
- Sequence numbers must be monotonically increasing
- Logon/Logout handshake must complete within 30 seconds
- Resend request handling must replay exact messages

## Compliance
- All order messages must be logged with timestamps
- Reject messages (MsgType=3) must be handled, not dropped
- Session-level rejects increment sequence numbers
- Heart beat interval per exchange specification
```

## Common Pitfalls

- **Sequence number gap on reconnect:** Failing to persist sequence numbers across restarts causes the counterparty to send ResendRequest, which you must handle correctly. Claude Code generates file-based sequence stores that survive process restarts.
- **Wrong tag data type:** Tag 44 (Price) must be a decimal string, not an integer. Sending "185" instead of "185.00" causes rejects on some venues. Claude Code formats all numeric tags with explicit precision.
- **Missing conditional fields:** A Limit order (OrdType=2) requires Price (tag 44). A Stop order requires StopPx (tag 99). Claude Code validates that all conditional required fields are present before encoding.

## Related

- [Claude Code for Algo Trading](/claude-code-algorithmic-trading-backtesting-2026/)
- [Claude Code for Options Pricing](/claude-code-options-pricing-black-scholes-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
