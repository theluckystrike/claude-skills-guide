---
title: "Claude Code for Bloomberg Data"
description: "Bloomberg terminal data extraction with Claude Code. Automate BQL queries, DAPI pulls, and Excel add-in workflows."
permalink: /claude-code-bloomberg-terminal-data-extraction-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for Bloomberg Data

Bloomberg terminals cost $24,000/year per seat. Every analyst manually pulling data through the Excel add-in or typing BQL queries is burning expensive terminal time. The Bloomberg Python API (blpapi) and BQuant platform enable programmatic data extraction, but the API is poorly documented, uses an event-driven architecture that confuses most developers, and has quirks around session handling and field naming.

Claude Code generates blpapi code that handles session lifecycle, subscription management, and the specific Bloomberg field names (PX_LAST, BEST_BID, IVOL_MID) that analysts need. It turns a 30-minute manual Excel workflow into a 30-second script.

## The Workflow

### Step 1: Environment Setup

```bash
# Bloomberg API (requires Bloomberg terminal or B-PIPE)
pip install blpapi  # official Bloomberg Python API
# Alternative: xbbg (open-source wrapper)
pip install xbbg pandas openpyxl

# BQuant environment (if using Bloomberg's Jupyter)
# Pre-installed on BQuant terminals

mkdir -p bloomberg/{queries,output,templates}
```

### Step 2: Programmatic Data Extraction

```python
# bloomberg/queries/reference_data.py
"""Extract reference and historical data from Bloomberg via blpapi."""
import blpapi
import pandas as pd
from datetime import datetime, timedelta

MAX_SECURITIES = 500
MAX_FIELDS = 50
SESSION_TIMEOUT = 30000  # ms


def create_session(host: str = "localhost",
                   port: int = 8194) -> blpapi.Session:
    """Create and start Bloomberg API session."""
    options = blpapi.SessionOptions()
    options.setServerHost(host)
    options.setServerPort(port)

    session = blpapi.Session(options)
    started = session.start()
    assert started, "Failed to start Bloomberg session — is terminal running?"

    opened = session.openService("//blp/refdata")
    assert opened, "Failed to open //blp/refdata service"

    return session


def reference_data(session: blpapi.Session,
                   securities: list,
                   fields: list) -> pd.DataFrame:
    """Pull current reference data for a list of securities."""
    assert 0 < len(securities) <= MAX_SECURITIES, \
        f"Securities count {len(securities)} out of range"
    assert 0 < len(fields) <= MAX_FIELDS, \
        f"Fields count {len(fields)} out of range"

    service = session.getService("//blp/refdata")
    request = service.createRequest("ReferenceDataRequest")

    for sec in securities:
        request.append("securities", sec)
    for fld in fields:
        request.append("fields", fld)

    session.sendRequest(request)

    rows = []
    while True:
        event = session.nextEvent(SESSION_TIMEOUT)
        for msg in event:
            if msg.messageType() == blpapi.Name("ReferenceDataResponse"):
                security_data = msg.getElement("securityData")
                for i in range(security_data.numValues()):
                    sec_elem = security_data.getValueAsElement(i)
                    sec_name = sec_elem.getElementAsString("security")
                    field_data = sec_elem.getElement("fieldData")

                    row = {"security": sec_name}
                    for fld in fields:
                        try:
                            row[fld] = field_data.getElementAsFloat(fld)
                        except Exception:
                            try:
                                row[fld] = field_data.getElementAsString(fld)
                            except Exception:
                                row[fld] = None
                    rows.append(row)

        if event.eventType() == blpapi.Event.RESPONSE:
            break

    df = pd.DataFrame(rows)
    assert len(df) > 0, "No data returned from Bloomberg"
    return df


def historical_data(session: blpapi.Session,
                    security: str, fields: list,
                    start_date: str, end_date: str,
                    periodicity: str = "DAILY") -> pd.DataFrame:
    """Pull historical time series data."""
    assert periodicity in ("DAILY", "WEEKLY", "MONTHLY"), \
        f"Invalid periodicity: {periodicity}"

    service = session.getService("//blp/refdata")
    request = service.createRequest("HistoricalDataRequest")
    request.append("securities", security)

    for fld in fields:
        request.append("fields", fld)

    request.set("startDate", start_date)
    request.set("endDate", end_date)
    request.set("periodicitySelection", periodicity)

    session.sendRequest(request)

    rows = []
    while True:
        event = session.nextEvent(SESSION_TIMEOUT)
        for msg in event:
            if msg.messageType() == blpapi.Name("HistoricalDataResponse"):
                sec_data = msg.getElement("securityData")
                field_data = sec_data.getElement("fieldData")
                for i in range(field_data.numValues()):
                    bar = field_data.getValueAsElement(i)
                    row = {"date": bar.getElementAsString("date")}
                    for fld in fields:
                        try:
                            row[fld] = bar.getElementAsFloat(fld)
                        except Exception:
                            row[fld] = None
                    rows.append(row)

        if event.eventType() == blpapi.Event.RESPONSE:
            break

    df = pd.DataFrame(rows)
    if len(df) > 0:
        df["date"] = pd.to_datetime(df["date"])
        df.set_index("date", inplace=True)
    return df


def portfolio_snapshot(session: blpapi.Session,
                       tickers: list) -> pd.DataFrame:
    """Pull a complete portfolio snapshot with key metrics."""
    fields = [
        "PX_LAST", "CHG_PCT_1D", "VOLUME",
        "CUR_MKT_CAP", "PE_RATIO", "DVD_YLD_IND",
        "BEST_EPS", "BEST_TARGET_PRICE",
        "RSI_14D", "VOLATILITY_30D",
    ]
    return reference_data(session, tickers, fields)


# Alternative: using xbbg (no terminal required for testing)
def xbbg_reference(tickers: list, fields: list) -> pd.DataFrame:
    """Pull data using xbbg wrapper (simpler API)."""
    from xbbg import blp
    assert len(tickers) > 0, "Empty ticker list"

    df = blp.bdp(tickers=tickers, flds=fields)
    assert len(df) > 0, "No data returned"
    return df


if __name__ == "__main__":
    # Example: Tech portfolio snapshot
    tickers = [
        "AAPL US Equity", "MSFT US Equity", "GOOGL US Equity",
        "AMZN US Equity", "NVDA US Equity",
    ]

    # Using xbbg (works without terminal for cached data)
    try:
        from xbbg import blp
        df = blp.bdp(tickers, ["PX_LAST", "PE_RATIO", "CUR_MKT_CAP"])
        print(df.to_string())
    except Exception as e:
        print(f"Bloomberg not available: {e}")
        print("Run this script on a machine with Bloomberg terminal access")
```

### Step 3: Verify and Export

```bash
python3 bloomberg/queries/reference_data.py
# Expected: DataFrame with current prices and fundamentals
# Requires active Bloomberg terminal or B-PIPE connection

# Export to Excel for non-technical team members
python3 -c "
import pandas as pd
# df = ... (from Bloomberg query above)
# df.to_excel('output/portfolio_snapshot.xlsx', index=False)
print('Export workflow ready — run on Bloomberg terminal')
"
```

## CLAUDE.md for Bloomberg Data

```markdown
# Bloomberg Data Extraction Rules

## Standards
- Bloomberg Open API (BLPAPI) 3.x
- BQL (Bloomberg Query Language) syntax
- Bloomberg field mnemonics (PX_LAST, not "price")

## File Formats
- .py (extraction scripts)
- .xlsx (output for analysts)
- .csv / .parquet (archival storage)

## Libraries
- blpapi 3.x (official Bloomberg Python SDK)
- xbbg 0.7+ (community wrapper)
- pandas, openpyxl (data handling, Excel export)

## Testing
- Always check session.start() return value
- Validate field names against FLDS<GO> in terminal
- Rate limit: max 500 securities per ReferenceDataRequest
- Historical requests: max 10 years per single request

## Compliance
- Bloomberg data redistribution rules apply
- Do not store raw Bloomberg data beyond license terms
- API usage must comply with firm's Bloomberg license agreement
```

## Common Pitfalls

- **Session not started:** blpapi silently returns empty data if the session is not connected. Claude Code adds explicit assertions on session.start() and service.openService() return values.
- **Wrong field names:** Bloomberg uses mnemonics (PX_LAST not "last_price"). A typo returns null with no error. Claude Code validates field names against a known-good list before querying.
- **Event loop not drained:** The blpapi event model requires reading ALL events until RESPONSE type. Stopping early loses partial data. Claude Code loops until event.eventType() == RESPONSE.

## Related

- [Claude Code for Options Pricing](/claude-code-options-pricing-black-scholes-2026/)
- [Claude Code for Algo Trading](/claude-code-algorithmic-trading-backtesting-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
