---
layout: default
title: "CPI inflation calculator MCP server (free, no API key)"
description: "Free MCP server that adjusts a dollar amount for inflation with official CPI data. No API key: paste the hosted URL. Inflation calculator with…"
permalink: /mcp/cpi-inflation-calculator-mcp/
date: 2026-11-03
---

# CPI inflation calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "CPI inflation calculator MCP server",
   "alternateName": "cpi-inflation-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Inflation calculator with official BLS CPI 1913 to the latest month, raise vs inflation, SS COLA.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/cpi-inflation-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/cpi-inflation-calculator-mcp",
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
     "name": "Is there an MCP server that adjusts a dollar amount for inflation with official CPI data?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. CPI inflation calculator (cpi-inflation-calculator-mcp) is a free MCP server. Inflation calculator with official BLS CPI 1913 to the latest month, raise vs inflation, SS COLA. It is hosted at https://cpi-inflation-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/cpi-inflation-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the CPI inflation calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://data.bls.gov/timeseries/CUUR0000SA0 (BLS Public Data API https://api.bls.gov/publicAPI/v1/timeseries/data/). The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "CPI inflation calculator",
     "item": "https://claudecodeguides.com/mcp/cpi-inflation-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that adjusts a dollar amount for inflation with official CPI data? `cpi-inflation-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://cpi-inflation-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Inflation calculator with official BLS CPI 1913 to the latest month, raise vs inflation, SS COLA.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. CPI index values through September 2026 (CPI-U 336.940), with a live check for anything newer.
2. Inflation was 3.7% over the 12 months to September 2026 (CPI-U, not seasonally adjusted). Core CPI was 2.6%.
3. BLS published no October 2025 CPI. Data were not collected during the 2025 lapse in appropriations. The tools say so instead of inventing a value, and still use the official 2025 annual average (321.943, 2.6% inflation).
4. The 2027 Social Security COLA is 3.6%. The tool reproduces it from Q3 2026 CPI-W (average 328.746 against 317.265), and also reproduces 2023 to 2026.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://cpi-inflation-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http cpi-inflation-calculator https://cpi-inflation-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add cpi-inflation-calculator -- npx -y github:theluckystrike/cpi-inflation-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "cpi-inflation-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/cpi-inflation-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "cpi-inflation-calculator": { "url": "https://cpi-inflation-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_inflation` | Adjusts a dollar amount for inflation between any two periods from 1913 to the latest month the U.S. Bureau of Labor Statistics has published, using the official CPI-U... |
| `get_latest_cpi` | Returns the most recent CPI index values published by the Bureau of Labor Statistics, checked live against the BLS Public Data API: the latest month, the 12-month... |
| `get_inflation_rate` | Returns the official U.S. inflation rate for a calendar year from BLS CPI data: annual-average change (BLS annual averages, including the 2025 average published despite... |
| `compare_raise_to_inflation` | Compares a pay change with CPI inflation over the same period using official BLS data through the latest published month (checked live). |
| `calculate_social_security_cola` | Computes the Social Security cost-of-living adjustment for a year with the statutory formula: average CPI-W for July-September of the prior year over the same quarter a... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is $1,000 from January 2000 worth today, using official CPI data?" and the client sent this call.

```json
{"name": "calculate_inflation", "arguments": {"amount": 1000, "from": "2000-01", "to": "latest"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
$1,000.00 in January 2000 has the same buying power as $1,996.09 in September 2026 (CPI-U 168.8 to 336.94). Cumulative inflation 99.61%, about 2.63% a year over 26.67 years. Note: Live BLS API check failed (BLS API REQUEST_NOT_PROCESSED: Request could not be serviced, as the daily threshold for total number of requests allocated to the user with registration key  has been reached.). Using bundled BLS data through September 2026, fetched 2026-11-03. Newer months, if any, are not included.

Index values from the U.S. Bureau of Labor Statistics. General information, not financial advice.
```

Data as of `2026-11-03`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that adjusts a dollar amount for inflation with official CPI data?

Yes. CPI inflation calculator (cpi-inflation-calculator-mcp) is a free MCP server. Inflation calculator with official BLS CPI 1913 to the latest month, raise vs inflation, SS COLA. It is hosted at https://cpi-inflation-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/cpi-inflation-calculator-mcp.

### Does the CPI inflation calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://data.bls.gov/timeseries/CUUR0000SA0 (BLS Public Data API https://api.bls.gov/publicAPI/v1/timeseries/data/). The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/cpi-inflation-calculator-mcp](https://github.com/theluckystrike/cpi-inflation-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/cpi-inflation-calculator-mcp/](https://www.mcpstamp.com/free-servers/cpi-inflation-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude adjust a price for inflation?](https://www.mcpstamp.com/can-claude/adjust-for-inflation/) on mcpstamp.com, the plain-English answer with a live call
- [statewage.com](https://statewage.com/pay-raise-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=cpi-inflation-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Cups to grams converter MCP server](/mcp/cups-to-grams-mcp/). Cups to grams for 271 ingredients with USDA and King Arthur densities, recipe scaling, oven temps.
- [DSCR loan calculator MCP server](/mcp/dscr-loan-calculator-mcp/). DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization.
- [Estate and gift tax exemption calculator MCP server](/mcp/estate-gift-tax-exemption-calculator-mcp/). 2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE.
- [Currency MCP server](/mcp/currency/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
