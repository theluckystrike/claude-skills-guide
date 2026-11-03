---
layout: default
title: "River level MCP server (free, no API key)"
description: "Free MCP server for the current water level of a river. No API key: paste the hosted URL. Live US river levels, streamflow and NWS flood forecasts…"
permalink: /mcp/river-level-mcp/
date: 2026-11-03
---

# River level MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "River level MCP server",
   "alternateName": "river-level-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Live US river levels, streamflow and NWS flood forecasts from USGS stream gauges.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/river-level-mcp/",
   "codeRepository": "https://github.com/theluckystrike/river-level-mcp",
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
     "name": "Is there an MCP server for the current water level of a river?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. River level (river-level-mcp) is a free MCP server. Live US river levels, streamflow and NWS flood forecasts from USGS stream gauges. It is hosted at https://river-level-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/river-level-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the River level MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://waterdata.usgs.gov/monitoring-location/USGS-07010000/. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "River level",
     "item": "https://claudecodeguides.com/mcp/river-level-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the current water level of a river? `river-level-mcp` is free, MIT licensed and needs no API key and no account. Paste https://river-level-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Live US river levels, streamflow and NWS flood forecasts from USGS stream gauges.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Today's river level. Gauges report every 5 to 60 minutes and a river can rise 10 feet in a day. A model's training data is months old.
2. Whether a river is near flood stage right now, using the NWS action, minor, moderate and major flood stages for that gauge.
3. The latest NWS river forecast and its crest, reissued several times a day.
4. The new USGS Water Data API. The legacy waterservices.usgs.gov service shuts down on February 22, 2027, so code that calls it will stop working. This server already uses api.waterdata.usgs.gov.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://river-level-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http river-level https://river-level-mcp.lipmichal.workers.dev/mcp
claude mcp add river-level -- npx -y github:theluckystrike/river-level-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "river-level": { "command": "npx", "args": ["-y", "github:theluckystrike/river-level-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "river-level": { "url": "https://river-level-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `find_river_gauges` | Search USGS stream gauges nationwide by river and place name (for example "mississippi st louis", "potomac little falls"), by state, or within a radius of a latitude... |
| `get_river_level` | Current river stage (gage height in feet), streamflow (discharge in cubic feet per second) and water temperature where measured, read now from a USGS stream gauge... |
| `get_river_history` | Daily mean streamflow (default) or stage for a USGS gauge over the last 2 to 366 days, with first, last, low, high, mean and change. |
| `get_flood_forecast` | The current NOAA National Water Prediction Service river forecast for a gauge: the forecast stage and flow series, the forecast crest with its flood category, the... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is the Mississippi River level at St. Louis right now?" and the client sent this call.

```json
{"name": "get_river_level", "arguments": {"site": "07010000"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
Mississippi River at St. Louis, MO (USGS 07010000): gage height (river stage) 3.59 ft, discharge (streamflow) 126,000 ft3/s, measured 2026-11-03T08:30:00+00:00. NWS flood status: below flood stage, 26.41 ft below flood stage (30 ft). USGS real-time data are provisional and can be revised.
```

Data as of `2026-11-03T08:30:00+00:00`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the current water level of a river?

Yes. River level (river-level-mcp) is a free MCP server. Live US river levels, streamflow and NWS flood forecasts from USGS stream gauges. It is hosted at https://river-level-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/river-level-mcp.

### Does the River level MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://waterdata.usgs.gov/monitoring-location/USGS-07010000/. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/river-level-mcp](https://github.com/theluckystrike/river-level-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/river-level-mcp/](https://www.mcpstamp.com/free-servers/river-level-mcp/) on the mcpstamp.com free server list
- [Can Claude check river levels?](https://www.mcpstamp.com/can-claude/check-river-levels/) on mcpstamp.com, the plain-English answer with a live call
- [lakelevelnow.com](https://lakelevelnow.com/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=river-level-mcp), the companion site this server's results link to

## More free live-data servers

- [SAT score percentiles MCP server](/mcp/sat-score-percentiles-mcp/). SAT score percentiles and class of 2026 SAT averages and participation by state (College Board).
- [Section 179 deduction calculator MCP server](/mcp/section-179-deduction-calculator-mcp/). Section 179 limits, 100% bonus depreciation, heavy SUV caps and asset loan cost (2025-2026, IRS).
- [Silver price per gram MCP server](/mcp/silver-price-per-gram-mcp/). Live silver price per gram by fineness and currency, junk silver coin value, gold silver ratio.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
