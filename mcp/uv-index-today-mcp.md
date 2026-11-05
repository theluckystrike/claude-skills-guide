---
layout: default
title: "UV index today MCP server (free, no API key)"
description: "Free MCP server for the UV index today by ZIP code. No API key: paste the hosted URL. Today's UV Index forecast by US ZIP code or city, with hourly…"
permalink: /mcp/uv-index-today-mcp/
date: 2026-11-05
---

# UV index today MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "UV index today MCP server",
   "alternateName": "uv-index-today-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Today's UV Index forecast by US ZIP code or city, with hourly peak and UV Alert, from EPA and NWS.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/uv-index-today-mcp/",
   "codeRepository": "https://github.com/theluckystrike/uv-index-today-mcp",
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
     "name": "Is there an MCP server for the UV index today by ZIP code?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. UV index today (uv-index-today-mcp) is a free MCP server. Today's UV Index forecast by US ZIP code or city, with hourly peak and UV Alert, from EPA and NWS. It is hosted at https://uv-index-today-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/uv-index-today-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the UV index today MCP server need an API key?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-05."
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://data.epa.gov/dmapservice/getEnvirofactsUVDAILY/ZIP/33101/JSON. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "UV index today",
     "item": "https://claudecodeguides.com/mcp/uv-index-today-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the UV index today by ZIP code? `uv-index-today-mcp` is free, MIT licensed and needs no API key and no account. Paste https://uv-index-today-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Today's UV Index forecast by US ZIP code or city, with hourly peak and UV Alert, from EPA and NWS.

Tools 3, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Today's UV Index for your ZIP code. It changes every day with season, cloud cover and ozone, so a model's training data cannot know it.
2. The hour when the sun is strongest today and the hours when EPA says protection is needed.
3. Whether NWS and EPA have issued a UV Alert for the place today.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://uv-index-today-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http uv-index-today https://uv-index-today-mcp.lipmichal.workers.dev/mcp
claude mcp add uv-index-today -- npx -y github:theluckystrike/uv-index-today-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "uv-index-today": { "command": "npx", "args": ["-y", "github:theluckystrike/uv-index-today-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "uv-index-today": { "url": "https://uv-index-today-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_uv_index_today` | Today's UV Index forecast for a US ZIP code or city and state, read now from EPA (the NWS daily forecast). |
| `get_uv_index_hourly` | Hour by hour UV Index forecast for a US ZIP code or city and state, in the local time of that place, read now from EPA. Returns each hour with its EPA band, the peak... |
| `explain_uv_index` | What a UV Index number means on the EPA scale (0 to 2 Low, 3 to 7 Moderate to High, 8 and above Very High to Extreme) and the EPA sun protection advice for it, plus the... |

## Example output from a live call

Called on 2026-11-05 against the hosted URL above, with no token. The prompt was "What is the UV Index today in Miami, ZIP 33101?" and the client sent this call.

```json
{"name": "get_uv_index_today", "arguments": {"zip": "33101"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
EPA UV Index forecast for Miami, FL (ZIP 33101) on 2026-11-05 is 5, Moderate to High (3 to 7). Protection needed. The hourly forecast peaks at 6 at 1 PM local time, and is 3 or higher from 10 AM to 3 PM. No UV Alert is in effect.
```

Data as of `2026-11-05T14:14:57.128Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the UV index today by ZIP code?

Yes. UV index today (uv-index-today-mcp) is a free MCP server. Today's UV Index forecast by US ZIP code or city, with hourly peak and UV Alert, from EPA and NWS. It is hosted at https://uv-index-today-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/uv-index-today-mcp.

### Does the UV index today MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-05.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://data.epa.gov/dmapservice/getEnvirofactsUVDAILY/ZIP/33101/JSON. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/uv-index-today-mcp](https://github.com/theluckystrike/uv-index-today-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/uv-index-today-mcp/](https://www.mcpstamp.com/free-servers/uv-index-today-mcp/) on the mcpstamp.com free server list
- [Can Claude check the UV index today?](https://www.mcpstamp.com/can-claude/check-the-uv-index-today/) on mcpstamp.com, the plain-English answer with a live call
- [mcpstamp.com](https://www.mcpstamp.com/servers/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=uv-index-today-mcp), the companion site this server's results link to

## More free live-data servers

- [Vegetable yield percentage MCP server](/mcp/vegetable-yield-percentage-mcp/). Vegetable and fruit yield percentage, trim waste and how much produce to buy, from USDA refuse data.
- [A/B test sample size calculator MCP server](/mcp/ab-test-sample-size-calculator-mcp/). Exact A/B test sample size, duration, z-test, chi-square, Fisher-Freeman-Halton and peeking risk.
- [ACA premium tax credit calculator MCP server](/mcp/aca-premium-tax-credit-calculator-mcp/). 2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
