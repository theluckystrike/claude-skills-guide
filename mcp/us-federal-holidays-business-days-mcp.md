---
layout: default
title: "US federal holidays and business days MCP server (free, no API key)"
description: "Free MCP server that counts business days excluding US federal holidays. No API key: paste the hosted URL. Exact U.S. federal holidays and business…"
permalink: /mcp/us-federal-holidays-business-days-mcp/
date: 2026-11-03
---

# US federal holidays and business days MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "US federal holidays and business days MCP server",
   "alternateName": "us-federal-holidays-business-days-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Exact U.S. federal holidays and business days 1971-2100, OPM and Federal Reserve observance.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/us-federal-holidays-business-days-mcp/",
   "codeRepository": "https://github.com/theluckystrike/us-federal-holidays-business-days-mcp",
   "license": "https://opensource.org/licenses/MIT",
   "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD",
    "description": "Free. Hosted endpoint with no API key, or run locally with npx."
   },
   "isPartOf": {
    "@type": "ItemList",
    "name": "Free live-data MCP servers (no key)",
    "url": "https://claudecodeguides.com/mcp/#free-live-data-mcp-servers-no-key"
   }
  },
  {
   "@type": "FAQPage",
   "mainEntity": [
    {
     "@type": "Question",
     "name": "Is there an MCP server that counts business days excluding US federal holidays?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. US federal holidays and business days (us-federal-holidays-business-days-mcp) is a free MCP server. Exact U.S. federal holidays and business days 1971-2100, OPM and Federal Reserve observance. It is hosted at https://us-federal-holidays-business-days-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/us-federal-holidays-business-days-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the US federal holidays and business days MCP server need an API key?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03."
     }
    },
    {
     "@type": "Question",
     "name": "Is it free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all."
     }
    },
    {
     "@type": "Question",
     "name": "Where do the numbers come from?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays/. The full source list is in DATA_SOURCES.md in the repository."
     }
    }
   ]
  },
  {
   "@type": "BreadcrumbList",
   "itemListElement": [
    {
     "@type": "ListItem",
     "position": 1,
     "name": "Home",
     "item": "https://claudecodeguides.com/"
    },
    {
     "@type": "ListItem",
     "position": 2,
     "name": "MCP servers",
     "item": "https://claudecodeguides.com/mcp/"
    },
    {
     "@type": "ListItem",
     "position": 3,
     "name": "US federal holidays and business days",
     "item": "https://claudecodeguides.com/mcp/us-federal-holidays-business-days-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that counts business days excluding US federal holidays? `us-federal-holidays-business-days-mcp` is free, MIT licensed and needs no API key and no account. Paste https://us-federal-holidays-business-days-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Exact U.S. federal holidays and business days 1971-2100, OPM and Federal Reserve observance.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The observance rule. A Saturday holiday is observed on Friday by federal employees (5 U.S.C. 6103(b)). A Sunday holiday is observed on Monday (E.O. 11582). The Friday can fall in the previous year.
2. The Federal Reserve rule is different. When a holiday falls on Saturday, Reserve Banks are open on Friday (K.8). So 2026-07-03 is a federal holiday but a banking day. Use `calendar: "fed_banking"` for ACH, wire and settlement dates.
3. The rule history. Juneteenth from 2021. MLK Day from 1986. Veterans Day was the fourth Monday in October from 1971 to 1977.
4. Inauguration Day. It applies only to DC-area federal employees, every four years. It moves to Monday when January 20 is a Sunday and has no substitute day when it is a Saturday (2029).
5. All 212 holiday rows in OPM's published tables for 2011-2030 match this server's output. A test checks this.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://us-federal-holidays-business-days-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http us-federal-holidays-business-days https://us-federal-holidays-business-days-mcp.lipmichal.workers.dev/mcp
claude mcp add us-federal-holidays-business-days -- npx -y github:theluckystrike/us-federal-holidays-business-days-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "us-federal-holidays-business-days": { "command": "npx", "args": ["-y", "github:theluckystrike/us-federal-holidays-business-days-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "us-federal-holidays-business-days": { "url": "https://us-federal-holidays-business-days-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `list_federal_holidays` | Exact U.S. federal holidays for any year 1971-2100 under 5 U.S.C. 6103: legal date, OPM observed date (Saturday -> Friday, Sunday -> Monday, so New Year's Day 2022 is... |
| `is_business_day` | Says whether a date (1971-2100) is a business day on the U.S. federal (OPM) calendar or the Federal Reserve banking calendar, names the holiday if any, and returns the... |
| `add_business_days` | Adds (or with a negative number subtracts) N business days to a date, skipping weekends and observed U.S. federal or Federal Reserve holidays exactly. |
| `count_business_days` | Counts business days between two dates (1971-2100) on the U.S. federal or Federal Reserve calendar, excluding weekends and observed holidays. include_start and... |
| `invoice_due_date` | Computes an invoice due date from an issue date and net terms in calendar days (Net 30 = 30), then optionally rolls a weekend or U.S. holiday due date: following (next... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "How many business days are there from December 1, 2026 to January 15, 2027, excluding US federal holidays?" and the client sent this call.

```json
{"name": "count_business_days", "arguments": {"start_date": "2026-12-01", "end_date": "2027-01-15"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
There are 32 business days from 2026-12-01 to 2027-01-15 (start included, end included) on the federal calendar: 46 calendar days, 12 weekend days. Excluded weekday holidays: 2026-12-25 Christmas Day; 2027-01-01 New Year's Day.
```

Data as of `2026-10-30`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that counts business days excluding US federal holidays?

Yes. US federal holidays and business days (us-federal-holidays-business-days-mcp) is a free MCP server. Exact U.S. federal holidays and business days 1971-2100, OPM and Federal Reserve observance. It is hosted at https://us-federal-holidays-business-days-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/us-federal-holidays-business-days-mcp.

### Does the US federal holidays and business days MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays/. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/us-federal-holidays-business-days-mcp](https://github.com/theluckystrike/us-federal-holidays-business-days-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/us-federal-holidays-business-days-mcp/](https://www.mcpstamp.com/free-servers/us-federal-holidays-business-days-mcp/) on the mcpstamp.com free server list
- [Can Claude count business days?](https://www.mcpstamp.com/can-claude/count-business-days/) on mcpstamp.com, the plain-English answer with a live call
- [mcp.zovo.one](https://mcp.zovo.one/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=us-federal-holidays-business-days-mcp), the companion site this server's results link to

## More free live-data servers

- [Vegetable yield percentage MCP server](/mcp/vegetable-yield-percentage-mcp/). Vegetable and fruit yield percentage, trim waste and how much produce to buy, from USDA refuse data.
- [A/B test sample size calculator MCP server](/mcp/ab-test-sample-size-calculator-mcp/). Exact A/B test sample size, duration, z-test, chi-square, Fisher-Freeman-Halton and peeking risk.
- [ACA premium tax credit calculator MCP server](/mcp/aca-premium-tax-credit-calculator-mcp/). 2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules.
- [Calendar MCP server](/mcp/calendar/) from the back-office collection
- [Recurring MCP server](/mcp/recurring/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
