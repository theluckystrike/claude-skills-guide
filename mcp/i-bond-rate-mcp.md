---
layout: default
title: "I bond rate MCP server (free, no API key)"
description: "Free MCP server for the current I bond rate. No API key: paste the hosted URL. Current I bond rate, what your I bond earns by issue month, and value…"
permalink: /mcp/i-bond-rate-mcp/
date: 2026-11-05
---

# I bond rate MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "I bond rate MCP server",
   "alternateName": "i-bond-rate-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Current I bond rate, what your I bond earns by issue month, and value estimates from TreasuryDirect.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/i-bond-rate-mcp/",
   "codeRepository": "https://github.com/theluckystrike/i-bond-rate-mcp",
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
     "name": "Is there an MCP server for the current I bond rate?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. I bond rate (i-bond-rate-mcp) is a free MCP server. Current I bond rate, what your I bond earns by issue month, and value estimates from TreasuryDirect. It is hosted at https://i-bond-rate-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/i-bond-rate-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the I bond rate MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.treasurydirect.gov/savings-bonds/i-bonds/i-bonds-interest-rates/. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "I bond rate",
     "item": "https://claudecodeguides.com/mcp/i-bond-rate-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the current I bond rate? `i-bond-rate-mcp` is free, MIT licensed and needs no API key and no account. Paste https://i-bond-rate-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Current I bond rate, what your I bond earns by issue month, and value estimates from TreasuryDirect.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The November 2026 rates (5.51 percent composite, 1.40 percent fixed, 2.04 percent semiannual inflation). Treasury announced them on November 1, 2026.
2. That an existing bond does not earn the new-bond rate. It keeps its own fixed rate and gets a new inflation rate every 6 months from its issue month, so a bond bought in April 2022 earns 3.34 percent from October 2026 while a bond bought in January 2023 earns 3.75 percent until January 2027.
3. The exact rounding and the zero floor. The formula reproduces all 1,711 composite rates in the Treasury chart.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://i-bond-rate-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http i-bond-rate https://i-bond-rate-mcp.lipmichal.workers.dev/mcp
claude mcp add i-bond-rate -- npx -y github:theluckystrike/i-bond-rate-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "i-bond-rate": { "command": "npx", "args": ["-y", "github:theluckystrike/i-bond-rate-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "i-bond-rate": { "url": "https://i-bond-rate-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_current_i_bond_rate` | Current Series I savings bond composite rate, fixed rate and semiannual inflation rate for new purchases, read at call time from the TreasuryDirect "I bonds interest... |
| `get_i_bond_rate_for_issue_date` | For an I bond bought in a given month: its fixed rate, the composite rate it earns in the current (or given) 6-month period, the months its rate changes, whether it can... |
| `estimate_i_bond_value` | Estimate what I bonds are worth for an issue month and purchase amount at the start of a month: value with all interest and the redemption value after the 3-month... |
| `calculate_i_bond_composite_rate` | Apply the Treasury formula fixed + 2 x semiannual inflation + fixed x semiannual inflation, rounded to 0.01 percent with a floor of zero. |
| `get_i_bond_rate_history` | Fixed rate for new bonds, semiannual inflation rate and composite rate for every May and November announcement since September 1998, newest first, from the... |

## Example output from a live call

Called on 2026-11-05 against the hosted URL above, with no token. The prompt was "What is the I bond rate for bonds bought in November 2026?" and the client sent this call.

```json
{"name": "get_current_i_bond_rate", "arguments": {}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
I bonds bought from November 2026 through April 2027 earn 5.51% a year for their first 6 months: a 1.40% fixed rate that lasts for the life of the bond plus 2.04% semiannual inflation rate. Treasury sets the next rates on May 1, 2027. Limit $10,000 in electronic I bonds per Social Security number per calendar year, $25 minimum, held at least 12 months, last 3 months of interest lost if cashed before 5 years.
```

Data as of `2026-11-05T14:15:34.347Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the current I bond rate?

Yes. I bond rate (i-bond-rate-mcp) is a free MCP server. Current I bond rate, what your I bond earns by issue month, and value estimates from TreasuryDirect. It is hosted at https://i-bond-rate-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/i-bond-rate-mcp.

### Does the I bond rate MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-05.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.treasurydirect.gov/savings-bonds/i-bonds/i-bonds-interest-rates/. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/i-bond-rate-mcp](https://github.com/theluckystrike/i-bond-rate-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/i-bond-rate-mcp/](https://www.mcpstamp.com/free-servers/i-bond-rate-mcp/) on the mcpstamp.com free server list
- [Can Claude tell me the current I bond rate?](https://www.mcpstamp.com/can-claude/check-the-i-bond-rate/) on mcpstamp.com, the plain-English answer with a live call
- [mcpstamp.com](https://www.mcpstamp.com/servers/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=i-bond-rate-mcp), the companion site this server's results link to

## More free live-data servers

- [IRS mileage rate and per diem MCP server](/mcp/irs-mileage-rate-per-diem-mcp/). IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low.
- [Lake level MCP server](/mcp/lake-level-mcp/). Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges.
- [Minimum wage MCP server](/mcp/minimum-wage-mcp/). US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
