---
layout: default
title: "FDA drug shortage list MCP server (free, no API key)"
description: "Free MCP server that checks the FDA drug shortage list. No API key: paste the hosted URL. FDA drug shortage list: is a drug in shortage now, by name…"
permalink: /mcp/drug-shortage-list-mcp/
date: 2026-11-05
---

# FDA drug shortage list MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "FDA drug shortage list MCP server",
   "alternateName": "drug-shortage-list-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "FDA drug shortage list: is a drug in shortage now, by name or NDC, with status and reason.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/drug-shortage-list-mcp/",
   "codeRepository": "https://github.com/theluckystrike/drug-shortage-list-mcp",
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
     "name": "Is there an MCP server that checks the FDA drug shortage list?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. FDA drug shortage list (drug-shortage-list-mcp) is a free MCP server. FDA drug shortage list: is a drug in shortage now, by name or NDC, with status and reason. It is hosted at https://drug-shortage-list-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/drug-shortage-list-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the FDA drug shortage list MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://api.fda.gov/drug/shortages.json?search=(generic_name:%22Adderall%22+openfda.brand_name:%22Adderall%22+openfda.generic_name:%22Adderall%22+openfda.substance_name:%22Adderall%22)&limit=100. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "FDA drug shortage list",
     "item": "https://claudecodeguides.com/mcp/drug-shortage-list-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that checks the FDA drug shortage list? `drug-shortage-list-mcp` is free, MIT licensed and needs no API key and no account. Paste https://drug-shortage-list-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. FDA drug shortage list: is a drug in shortage now, by name or NDC, with status and reason.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Which drugs FDA lists as in shortage today. Shortages start and end every week, and openFDA refreshes the list daily.
2. Package level detail. Each listing is one NDC from one company, with its own availability and update date.
3. Whether a shortage was resolved or the product is being discontinued, with the date and the FDA note.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://drug-shortage-list-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http drug-shortage-list https://drug-shortage-list-mcp.lipmichal.workers.dev/mcp
claude mcp add drug-shortage-list -- npx -y github:theluckystrike/drug-shortage-list-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "drug-shortage-list": { "command": "npx", "args": ["-y", "github:theluckystrike/drug-shortage-list-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "drug-shortage-list": { "url": "https://drug-shortage-list-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `search_drug_shortages` | Is a drug in shortage now? |
| `get_drug_shortage_by_ndc` | FDA shortage status for one National Drug Code, either a package NDC (0641-6059-01) or a product NDC (0641-6059), in the dashed form printed on the label. |
| `list_recent_drug_shortages` | The FDA drug shortage list, most recently updated listings first. |
| `count_drug_shortages` | How many FDA drug shortage listings there are now, grouped by status, therapeutic_category, shortage_reason or drug (distinct products). |

## Example output from a live call

Called on 2026-11-05 against the hosted URL above, with no token. The prompt was "Is Adderall on the FDA drug shortage list right now?" and the client sent this call.

```json
{"name": "search_drug_shortages", "arguments": {"drug": "Adderall"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
FDA lists 73 shortage listings matching "Adderall" across 1 product, 73 with status Current. Amphetamine Aspartate Monohydrate, Amphetamine Sulfate, Dextroamphetamine Saccharate, Dextroamphetamine Sulfate Tablet: 73 Current; availability 10 Limited Availability, 44 Available, 19 Unavailable; reason Shortage of an active ingredient, Other, Demand increase for the drug; last updated 2026-11-03.
```

Data as of `2026-11-05T14:15:08.441Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that checks the FDA drug shortage list?

Yes. FDA drug shortage list (drug-shortage-list-mcp) is a free MCP server. FDA drug shortage list: is a drug in shortage now, by name or NDC, with status and reason. It is hosted at https://drug-shortage-list-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/drug-shortage-list-mcp.

### Does the FDA drug shortage list MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-05.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://api.fda.gov/drug/shortages.json?search=(generic_name:%22Adderall%22+openfda.brand_name:%22Adderall%22+openfda.generic_name:%22Adderall%22+openfda.substance_name:%22Adderall%22)&limit=100. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/drug-shortage-list-mcp](https://github.com/theluckystrike/drug-shortage-list-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/drug-shortage-list-mcp/](https://www.mcpstamp.com/free-servers/drug-shortage-list-mcp/) on the mcpstamp.com free server list
- [Can Claude check if a drug is on the FDA shortage list?](https://www.mcpstamp.com/can-claude/check-the-fda-drug-shortage-list/) on mcpstamp.com, the plain-English answer with a live call
- [mcpstamp.com](https://www.mcpstamp.com/servers/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=drug-shortage-list-mcp), the companion site this server's results link to

## More free live-data servers

- [DSCR loan calculator MCP server](/mcp/dscr-loan-calculator-mcp/). DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization.
- [Estate and gift tax exemption calculator MCP server](/mcp/estate-gift-tax-exemption-calculator-mcp/). 2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE.
- [Gold price per gram MCP server](/mcp/gold-price-per-gram-mcp/). Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
