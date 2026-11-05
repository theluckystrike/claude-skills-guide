---
layout: default
title: "Lake level MCP server (free, no API key)"
description: "Free MCP server for current lake and reservoir water levels. No API key: paste the hosted URL. Live US lake and reservoir water levels from USGS…"
permalink: /mcp/lake-level-mcp/
date: 2026-11-03
---

# Lake level MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Lake level MCP server",
   "alternateName": "lake-level-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/lake-level-mcp/",
   "codeRepository": "https://github.com/theluckystrike/lake-level-mcp",
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
     "name": "Is there an MCP server for current lake and reservoir water levels?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Lake level (lake-level-mcp) is a free MCP server. Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges. It is hosted at https://lake-level-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/lake-level-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Lake level MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://waterdata.usgs.gov/monitoring-location/USGS-08154500/. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Lake level",
     "item": "https://claudecodeguides.com/mcp/lake-level-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for current lake and reservoir water levels? `lake-level-mcp` is free, MIT licensed and needs no API key and no account. Paste https://lake-level-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Today's water level. Lakes move every hour and a model's training data is months old.
2. Which gauge to read for each lake. The bindings (USGS site and parameter, CDEC station, Reclamation RISE item, TWDB reservoir, USACE CWMS time series) are the verified set lakelevelnow.com uses.
3. Full-pool elevations and published seasonal guide curves (USACE, TVA, Alabama Power), so "8 ft low" can be read against the winter target, not only against summer full pool.
4. How to handle feed quirks: unpadded CDEC dates, CWMS loggers that stamp local time as UTC, USGS 15-minute data collapsed to one reading per day.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://lake-level-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http lake-level https://lake-level-mcp.lipmichal.workers.dev/mcp
claude mcp add lake-level -- npx -y github:theluckystrike/lake-level-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "lake-level": { "command": "npx", "args": ["-y", "github:theluckystrike/lake-level-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "lake-level": { "url": "https://lake-level-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `search_lakes` | List the 44 US lakes and reservoirs this server reads live (Lake Mead, Lake Powell, Lake Travis, Shasta, Oroville, Lanier, Texoma, Kentucky Lake and more) by name... |
| `get_lake_level` | Current water surface elevation (ft above sea level) of a US lake or reservoir, read now from its government gauge (USGS, USACE CWMS, CDEC, Reclamation or TWDB). |
| `get_lake_history` | Daily (or weekly) water elevation series for a US lake or reservoir over the last 2 to 365 days, from the same government gauge as get_lake_level, one reading per day. |
| `compare_lakes` | Current levels of 2 to 10 US lakes side by side, read live from their gauges: elevation, feet below full pool, percent full, seasonal target and 24 h / 7 day / 30 day... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is the water level of Lake Travis right now?" and the client sent this call.

```json
{"name": "get_lake_level", "arguments": {"lake": "Lake Travis"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
Lake Travis (TX) is at 677.09 ft above sea level per the USGS gauge, measured 2026-11-03T02:30:00-06:00. That is 3.91 ft below full pool (681.0 ft). Change: -0.02 ft in 24 h, -0.05 ft in 7 days, -0.72 ft in 30 days.
```

Data as of `2026-11-03T09:01:34.878Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for current lake and reservoir water levels?

Yes. Lake level (lake-level-mcp) is a free MCP server. Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges. It is hosted at https://lake-level-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/lake-level-mcp.

### Does the Lake level MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://waterdata.usgs.gov/monitoring-location/USGS-08154500/. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/lake-level-mcp](https://github.com/theluckystrike/lake-level-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/lake-level-mcp/](https://www.mcpstamp.com/free-servers/lake-level-mcp/) on the mcpstamp.com free server list
- [Can Claude check lake levels?](https://www.mcpstamp.com/can-claude/check-lake-levels/) on mcpstamp.com, the plain-English answer with a live call
- [lakelevelnow.com](https://lakelevelnow.com/lake/lake-travis/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=lake-level-mcp), the companion site this server's results link to

## More free live-data servers

- [Minimum wage MCP server](/mcp/minimum-wage-mcp/). US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC.
- [Mortgage rates today MCP server](/mcp/mortgage-rates-today-mcp/). Mortgage rates today: Freddie Mac weekly 30 and 15 year fixed averages, history and payment math.
- [No tax on overtime calculator MCP server](/mcp/no-tax-on-overtime-mcp/). No tax on overtime, tips and senior deductions for 2025-2028 (OBBBA), with IRS caps and phase-outs.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
