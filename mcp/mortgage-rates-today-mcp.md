---
layout: default
title: "Mortgage rates today MCP server (free, no API key)"
description: "Free MCP server for mortgage rates today from Freddie Mac. No API key: paste the hosted URL. Mortgage rates today: Freddie Mac weekly 30 and 15 year…"
permalink: /mcp/mortgage-rates-today-mcp/
date: 2026-11-05
---

# Mortgage rates today MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Mortgage rates today MCP server",
   "alternateName": "mortgage-rates-today-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Mortgage rates today: Freddie Mac weekly 30 and 15 year fixed averages, history and payment math.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/mortgage-rates-today-mcp/",
   "codeRepository": "https://github.com/theluckystrike/mortgage-rates-today-mcp",
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
     "name": "Is there an MCP server for mortgage rates today from Freddie Mac?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Mortgage rates today (mortgage-rates-today-mcp) is a free MCP server. Mortgage rates today: Freddie Mac weekly 30 and 15 year fixed averages, history and payment math. It is hosted at https://mortgage-rates-today-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/mortgage-rates-today-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Mortgage rates today MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.freddiemac.com/pmms. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Mortgage rates today",
     "item": "https://claudecodeguides.com/mcp/mortgage-rates-today-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for mortgage rates today from Freddie Mac? `mortgage-rates-today-mcp` is free, MIT licensed and needs no API key and no account. Paste https://mortgage-rates-today-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Mortgage rates today: Freddie Mac weekly 30 and 15 year fixed averages, history and payment math.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. This week's rate. Freddie Mac publishes a new national average every Thursday at noon Eastern, so any number in a model's training data is out of date.
2. The exact weekly history since 1971, for questions like "what was the rate when I bought in March 2021".
3. Payment math tied to the current average, so the comparison with a year ago uses real numbers.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://mortgage-rates-today-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http mortgage-rates-today https://mortgage-rates-today-mcp.lipmichal.workers.dev/mcp
claude mcp add mortgage-rates-today -- npx -y github:theluckystrike/mortgage-rates-today-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "mortgage-rates-today": { "command": "npx", "args": ["-y", "github:theluckystrike/mortgage-rates-today-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "mortgage-rates-today": { "url": "https://mortgage-rates-today-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_mortgage_rates_today` | Latest Freddie Mac PMMS weekly average 30-year and 15-year fixed mortgage rates, read at call time from freddiemac.com: rate, week-over-week change, rate a year ago... |
| `get_mortgage_rate_on_date` | The Freddie Mac PMMS weekly average 30-year and 15-year fixed rates (plus 5/1 ARM and points where published) in force on a date, from 1971-04-02 to today. |
| `get_mortgage_rate_history` | Freddie Mac PMMS 30-year or 15-year fixed averages between two dates as weekly rows or monthly or annual averages, with the high, low and change over the range. |
| `calculate_mortgage_payment` | Monthly principal and interest and total interest for a fixed-rate loan. |

## Example output from a live call

Called on 2026-11-05 against the hosted URL above, with no token. The prompt was "What are mortgage rates today?" and the client sent this call.

```json
{"name": "get_mortgage_rates_today", "arguments": {}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
The Freddie Mac average 30-year fixed mortgage rate is 7.24% for the week of 2026-10-29 (down 0.08 points from the week before, 6.17% a year ago). The 15-year fixed average is 6.60%. These are national averages for well-qualified borrowers, released on Thursdays; the next release is due 2026-11-05. Source: Freddie Mac Primary Mortgage Market Survey (PMMS), U.S. weekly averages.
```

Data as of `2026-11-05T14:15:50.572Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for mortgage rates today from Freddie Mac?

Yes. Mortgage rates today (mortgage-rates-today-mcp) is a free MCP server. Mortgage rates today: Freddie Mac weekly 30 and 15 year fixed averages, history and payment math. It is hosted at https://mortgage-rates-today-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/mortgage-rates-today-mcp.

### Does the Mortgage rates today MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-05.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.freddiemac.com/pmms. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/mortgage-rates-today-mcp](https://github.com/theluckystrike/mortgage-rates-today-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/mortgage-rates-today-mcp/](https://www.mcpstamp.com/free-servers/mortgage-rates-today-mcp/) on the mcpstamp.com free server list
- [Can Claude check mortgage rates today?](https://www.mcpstamp.com/can-claude/check-mortgage-rates-today/) on mcpstamp.com, the plain-English answer with a live call
- [mcpstamp.com](https://www.mcpstamp.com/servers/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=mortgage-rates-today-mcp), the companion site this server's results link to

## More free live-data servers

- [No tax on overtime calculator MCP server](/mcp/no-tax-on-overtime-mcp/). No tax on overtime, tips and senior deductions for 2025-2028 (OBBBA), with IRS caps and phase-outs.
- [Paycheck calculator MCP server](/mcp/paycheck-calculator-mcp/). Take-home pay for 2025-2026: IRS brackets, FICA wage base and state income tax for 50 states + DC.
- [Raw to cooked weight MCP server](/mcp/raw-to-cooked-weight-mcp/). Raw to cooked weight of meat and poultry by cut and cooking method from USDA cooking yields.
- [Amortization MCP server](/mcp/amortization/) from the back-office collection
- [Loan Calculator MCP server](/mcp/loan-calculator/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
