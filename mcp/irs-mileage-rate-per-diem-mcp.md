---
layout: default
title: "IRS mileage rate and per diem MCP server (free, no API key)"
description: "Free MCP server for the 2026 IRS mileage rate and current per diem rates. No API key: paste the hosted URL. IRS mileage rates 2011-2026 (76 cents…"
permalink: /mcp/irs-mileage-rate-per-diem-mcp/
date: 2026-11-03
---

# IRS mileage rate and per diem MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "IRS mileage rate and per diem MCP server",
   "alternateName": "irs-mileage-rate-per-diem-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/irs-mileage-rate-per-diem-mcp/",
   "codeRepository": "https://github.com/theluckystrike/irs-mileage-rate-per-diem-mcp",
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
     "name": "Is there an MCP server for the 2026 IRS mileage rate and current per diem rates?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. IRS mileage rate and per diem (irs-mileage-rate-per-diem-mcp) is a free MCP server. IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low. It is hosted at https://irs-mileage-rate-per-diem-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/irs-mileage-rate-per-diem-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the IRS mileage rate and per diem MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/n-26-10.pdf ; https://www.irs.gov/irb/2026-29_irb ; https://www.irs.gov/tax-professionals/standard-mileage-rates. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "IRS mileage rate and per diem",
     "item": "https://claudecodeguides.com/mcp/irs-mileage-rate-per-diem-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the 2026 IRS mileage rate and current per diem rates? `irs-mileage-rate-per-diem-mcp` is free, MIT licensed and needs no API key and no account. Paste https://irs-mileage-rate-per-diem-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The IRS raised the 2026 business mileage rate mid-year: 72.5 cents a mile from Jan. 1 to June 30, 2026 and 76 cents from July 1, 2026 (Announcement 2026-11). Medical and military moving went from 20.5 to 23.5 cents. Charity stays at 14 cents.
2. The depreciation part of the 2026 business rate is 35 cents a mile. The FAVR and employer-vehicle maximum value for 2026 is $61,700 (Notice 2026-10).
3. FY2027 GSA per diem (from Oct. 1, 2026): standard CONUS rate $113 lodging and $68 M&IE, and the rates for 295 named destinations by month.
4. IRS high-low method from Oct. 1, 2026: $329 high and $230 low, with $86 and $74 treated as meals (Notice 2026-60). Tucson, San Mateo, Albuquerque and Cody were added; Panama City was removed.
5. The IRS had not announced the 2027 mileage rates on 2026-11-03. The tools say so.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://irs-mileage-rate-per-diem-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http irs-mileage-rate-per-diem https://irs-mileage-rate-per-diem-mcp.lipmichal.workers.dev/mcp
claude mcp add irs-mileage-rate-per-diem -- npx -y github:theluckystrike/irs-mileage-rate-per-diem-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "irs-mileage-rate-per-diem": { "command": "npx", "args": ["-y", "github:theluckystrike/irs-mileage-rate-per-diem-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "irs-mileage-rate-per-diem": { "url": "https://irs-mileage-rate-per-diem-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_mileage_rate` | Returns the official IRS standard mileage rates in cents per mile for business, medical, charity and military moving use, for a year or a specific date. |
| `calculate_mileage_deduction` | Calculates the deduction or tax-free reimbursement for driven miles at the IRS standard mileage rates, splitting by the date each trip was driven. |
| `get_per_diem_rates` | Returns the official GSA federal per diem rates for a U.S. (CONUS) destination by ZIP code or city/state: maximum lodging per night by month and the meals and... |
| `calculate_trip_per_diem` | Calculates the maximum federal per diem for a business trip: lodging for each night at that month's GSA rate (crossing seasons and the Oct. 1 fiscal year change), M&IE... |
| `get_high_low_per_diem` | Returns the IRS high-low substantiation method rates for a date and whether a city is a high-cost locality then: from Oct. 1, 2026 $329 high / $230 low with $86 / $74... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is the IRS standard mileage rate for 2026?" and the client sent this call.

```json
{"name": "get_mileage_rate", "arguments": {"year": 2026}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
IRS standard mileage rates for 2026: Jan. 1 - June 30, 2026: business 72.5 cents, medical/moving 20.5 cents, charity 14 cents (Notice 2026-10, IR-2025-128); July 1 - Dec. 31, 2026: business 76 cents, medical/moving 23.5 cents, charity 14 cents (Announcement 2026-11 (IRB 2026-29)). The rate changed mid-year, so split miles by date. Depreciation part of the business rate: 35 cents a mile.

Rates from IRS and GSA publications. General information, not tax advice.
```

Data as of `2026-11-03`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the 2026 IRS mileage rate and current per diem rates?

Yes. IRS mileage rate and per diem (irs-mileage-rate-per-diem-mcp) is a free MCP server. IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low. It is hosted at https://irs-mileage-rate-per-diem-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/irs-mileage-rate-per-diem-mcp.

### Does the IRS mileage rate and per diem MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/n-26-10.pdf ; https://www.irs.gov/irb/2026-29_irb ; https://www.irs.gov/tax-professionals/standard-mileage-rates. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/irs-mileage-rate-per-diem-mcp](https://github.com/theluckystrike/irs-mileage-rate-per-diem-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/irs-mileage-rate-per-diem-mcp/](https://www.mcpstamp.com/free-servers/irs-mileage-rate-per-diem-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate a 2026 mileage deduction?](https://www.mcpstamp.com/can-claude/calculate-mileage-deduction/) on mcpstamp.com, the plain-English answer with a live call
- [Can Claude look up GSA per diem rates?](https://www.mcpstamp.com/can-claude/look-up-per-diem-rates/) on mcpstamp.com, the plain-English answer with a live call
- [taxbreakcalc.com](https://taxbreakcalc.com/self-employed-set-aside-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=irs-mileage-rate-per-diem-mcp), the companion site this server's results link to

## More free live-data servers

- [Lake level MCP server](/mcp/lake-level-mcp/). Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges.
- [Minimum wage MCP server](/mcp/minimum-wage-mcp/). US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC.
- [Mortgage rates today MCP server](/mcp/mortgage-rates-today-mcp/). Mortgage rates today: Freddie Mac weekly 30 and 15 year fixed averages, history and payment math.
- [Mileage Log MCP server](/mcp/mileage-log/) from the back-office collection
- [Per Diem MCP server](/mcp/per-diem/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
