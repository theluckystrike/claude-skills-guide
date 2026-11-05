---
layout: default
title: "Address to census tract MCP server (free, no API key)"
description: "Free MCP server that finds the census tract for a US address. No API key: paste the hosted URL. US address to census tract, block group, county FIPS…"
permalink: /mcp/address-to-census-tract-mcp/
date: 2026-11-05
---

# Address to census tract MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Address to census tract MCP server",
   "alternateName": "address-to-census-tract-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "US address to census tract, block group, county FIPS and districts, from the Census Geocoder.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/address-to-census-tract-mcp/",
   "codeRepository": "https://github.com/theluckystrike/address-to-census-tract-mcp",
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
     "name": "Is there an MCP server that finds the census tract for a US address?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Address to census tract (address-to-census-tract-mcp) is a free MCP server. US address to census tract, block group, county FIPS and districts, from the Census Geocoder. It is hosted at https://address-to-census-tract-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/address-to-census-tract-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Address to census tract MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://geocoding.geo.census.gov/geocoder/geographies/onelineaddress?address=1%20Dr%20Carlton%20B%20Goodlett%20Pl%2C%20San%20Francisco%2C%20CA%2094102&benchmark=Public_AR_Current&vintage=Current_Current&format=json. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Address to census tract",
     "item": "https://claudecodeguides.com/mcp/address-to-census-tract-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that finds the census tract for a US address? `address-to-census-tract-mcp` is free, MIT licensed and needs no API key and no account. Paste https://address-to-census-tract-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. US address to census tract, block group, county FIPS and districts, from the Census Geocoder.

Tools 3, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Which census tract a given address is in. Tract lines follow streets, rivers and rail lines, and the two sides of one street can be in different tracts. A model cannot work that out from an address.
2. The 11, 12 and 15 digit GEOIDs that census data, CRA, LIHTC and grant eligibility lists are keyed on.
3. The congressional and state legislative districts the Census Bureau currently publishes for that point.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://address-to-census-tract-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http address-to-census-tract https://address-to-census-tract-mcp.lipmichal.workers.dev/mcp
claude mcp add address-to-census-tract -- npx -y github:theluckystrike/address-to-census-tract-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "address-to-census-tract": { "command": "npx", "args": ["-y", "github:theluckystrike/address-to-census-tract-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "address-to-census-tract": { "url": "https://address-to-census-tract-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_census_tract_for_address` | Look up the census tract for a US street address with the official US Census Bureau Geocoder. |
| `get_census_tract_for_coordinates` | Census tract, block group, block, county, place and congressional and state legislative districts for a latitude and longitude, from the US Census Bureau Geocoder. |
| `explain_census_geoid` | Split a census GEOID (2 digits state, 5 county, 11 tract, 12 block group, 15 block, or with a 1400000US style prefix) into state and county FIPS, tract code, the tract... |

## Example output from a live call

Called on 2026-11-05 against the hosted URL above, with no token. The prompt was "Which census tract is San Francisco City Hall in?" and the client sent this call.

```json
{"name": "get_census_tract_for_address", "arguments": {"address": "1 Dr Carlton B Goodlett Pl, San Francisco, CA 94102"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
1 DR CARLTON P GOODLETT PL, SAN FRANCISCO, CA, 94102 is in Census Tract 124.05 (GEOID 06075012405), block group 3 (060750124053), San Francisco County, California. Congressional District 11 (120th Congressional Districts). Census vintage Current_Current.
```

Data as of `2026-11-05T14:15:18.035Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that finds the census tract for a US address?

Yes. Address to census tract (address-to-census-tract-mcp) is a free MCP server. US address to census tract, block group, county FIPS and districts, from the Census Geocoder. It is hosted at https://address-to-census-tract-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/address-to-census-tract-mcp.

### Does the Address to census tract MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-05.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://geocoding.geo.census.gov/geocoder/geographies/onelineaddress?address=1%20Dr%20Carlton%20B%20Goodlett%20Pl%2C%20San%20Francisco%2C%20CA%2094102&benchmark=Public_AR_Current&vintage=Current_Current&format=json. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/address-to-census-tract-mcp](https://github.com/theluckystrike/address-to-census-tract-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/address-to-census-tract-mcp/](https://www.mcpstamp.com/free-servers/address-to-census-tract-mcp/) on the mcpstamp.com free server list
- [Can Claude find the census tract for an address?](https://www.mcpstamp.com/can-claude/find-the-census-tract-for-an-address/) on mcpstamp.com, the plain-English answer with a live call
- [mcpstamp.com](https://www.mcpstamp.com/servers/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=address-to-census-tract-mcp), the companion site this server's results link to

## More free live-data servers

- [AP score distributions MCP server](/mcp/ap-score-distributions-mcp/). Official College Board AP score distributions 2026, 2025, 2024: percentiles, pass rates.
- [Car loan interest deduction calculator MCP server](/mcp/car-loan-interest-deduction-calculator-mcp/). 2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS).
- [CPI inflation calculator MCP server](/mcp/cpi-inflation-calculator-mcp/). Inflation calculator with official BLS CPI 1913 to the latest month, raise vs inflation, SS COLA.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
