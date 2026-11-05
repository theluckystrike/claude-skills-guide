---
layout: default
title: "Minimum wage MCP server (free, no API key)"
description: "Free MCP server that looks up the minimum wage for a US state. No API key: paste the hosted URL. US state minimum wage 2026-2027: rates, tipped…"
permalink: /mcp/minimum-wage-mcp/
date: 2026-11-03
---

# Minimum wage MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Minimum wage MCP server",
   "alternateName": "minimum-wage-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/minimum-wage-mcp/",
   "codeRepository": "https://github.com/theluckystrike/minimum-wage-mcp",
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
     "name": "Is there an MCP server that looks up the minimum wage for a US state?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Minimum wage (minimum-wage-mcp) is a free MCP server. US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC. It is hosted at https://minimum-wage-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/minimum-wage-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Minimum wage MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://dof.ca.gov/media/docs/whats-new/Minimum-Wage-Increase-Notification-Governor-and-Legislative-Letter.pdf. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Minimum wage",
     "item": "https://claudecodeguides.com/mcp/minimum-wage-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that looks up the minimum wage for a US state? `minimum-wage-mcp` is free, MIT licensed and needs no API key and no account. Paste https://minimum-wage-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Rates that changed after most training cutoffs: July 1, 2026 changes (Alaska, DC, Oregon), Florida's September 30, 2026 step to $15.00, and the January 1, 2027 increases already enacted or announced (for example Michigan to $15.00).
2. Which 2027 rates are fixed in law, which inflation-indexed rates have been published, and which are still unannounced. It never invents an unannounced number.
3. Tipped cash wages and tip credits by state, which differ widely and change with the base rate.
4. When the federal $7.25 floor overrides a lower or missing state rate (Alabama, Georgia, Wyoming and others).

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://minimum-wage-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http minimum-wage https://minimum-wage-mcp.lipmichal.workers.dev/mcp
claude mcp add minimum-wage -- npx -y github:theluckystrike/minimum-wage-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "minimum-wage": { "command": "npx", "args": ["-y", "github:theluckystrike/minimum-wage-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "minimum-wage": { "url": "https://minimum-wage-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_minimum_wage` | Minimum wage for one US state or DC on a date in 2026-2027: standard hourly rate, tipped cash wage, tip credit and the date the rate took effect. |
| `list_upcoming_increases` | Every scheduled state minimum wage change from a date (default today) through 2027-12-31, sorted by date, with the new rate, the previous rate, the change and the... |
| `compare_states` | Side-by-side minimum wages for 2 to 10 US states (or DC) on one date in 2026-2027: standard rate, tipped cash wage, tip credit, effective date and full-time annual pay... |
| `annual_income_at_minimum_wage` | Gross weekly, monthly and annual pay at a state's minimum wage on a date in 2026-2027, for given hours per week (default 40) and weeks per year (default 52). |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is the minimum wage in California today?" and the client sent this call.

```json
{"name": "get_minimum_wage", "arguments": {"state": "CA"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
California's minimum wage on 2026-11-03 is $16.90 an hour, in force since 2026-01-01. No tip credit is allowed: tipped workers get the full $16.90 in cash. State-level rates only. City and county minimum wages (for example Seattle, Denver, Chicago, San Francisco) are out of scope and can be higher.
```

Data as of `2026-10-30`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that looks up the minimum wage for a US state?

Yes. Minimum wage (minimum-wage-mcp) is a free MCP server. US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC. It is hosted at https://minimum-wage-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/minimum-wage-mcp.

### Does the Minimum wage MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://dof.ca.gov/media/docs/whats-new/Minimum-Wage-Increase-Notification-Governor-and-Legislative-Letter.pdf. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/minimum-wage-mcp](https://github.com/theluckystrike/minimum-wage-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/minimum-wage-mcp/](https://www.mcpstamp.com/free-servers/minimum-wage-mcp/) on the mcpstamp.com free server list
- [Can Claude look up the current minimum wage?](https://www.mcpstamp.com/can-claude/look-up-minimum-wage/) on mcpstamp.com, the plain-English answer with a live call
- [statewage.com](https://statewage.com/states/california/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=minimum-wage-mcp), the companion site this server's results link to

## More free live-data servers

- [Mortgage rates today MCP server](/mcp/mortgage-rates-today-mcp/). Mortgage rates today: Freddie Mac weekly 30 and 15 year fixed averages, history and payment math.
- [No tax on overtime calculator MCP server](/mcp/no-tax-on-overtime-mcp/). No tax on overtime, tips and senior deductions for 2025-2028 (OBBBA), with IRS caps and phase-outs.
- [Paycheck calculator MCP server](/mcp/paycheck-calculator-mcp/). Take-home pay for 2025-2026: IRS brackets, FICA wage base and state income tax for 50 states + DC.
- [Payroll MCP server](/mcp/payroll/) from the back-office collection
- [Hourly Rate MCP server](/mcp/hourly-rate/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
