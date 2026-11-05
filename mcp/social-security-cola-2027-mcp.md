---
layout: default
title: "Social Security COLA 2027 MCP server (free, no API key)"
description: "Free MCP server for the 2027 Social Security COLA and full retirement age. No API key: paste the hosted URL. Social Security COLA 2027, full…"
permalink: /mcp/social-security-cola-2027-mcp/
date: 2026-11-05
---

# Social Security COLA 2027 MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Social Security COLA 2027 MCP server",
   "alternateName": "social-security-cola-2027-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Social Security COLA 2027, full retirement age, earnings test and 2027 limits from SSA notices.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/social-security-cola-2027-mcp/",
   "codeRepository": "https://github.com/theluckystrike/social-security-cola-2027-mcp",
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
     "name": "Is there an MCP server for the 2027 Social Security COLA and full retirement age?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Social Security COLA 2027 (social-security-cola-2027-mcp) is a free MCP server. Social Security COLA 2027, full retirement age, earnings test and 2027 limits from SSA notices. It is hosted at https://social-security-cola-2027-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/social-security-cola-2027-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Social Security COLA 2027 MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.federalregister.gov/d/2026-21796. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Social Security COLA 2027",
     "item": "https://claudecodeguides.com/mcp/social-security-cola-2027-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the 2027 Social Security COLA and full retirement age? `social-security-cola-2027-mcp` is free, MIT licensed and needs no API key and no account. Paste https://social-security-cola-2027-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Social Security COLA 2027, full retirement age, earnings test and 2027 limits from SSA notices.

Tools 6, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The 2027 COLA (3.6 percent) and the 2027 amounts. SSA published them on 2026-10-26, after most models were trained.
2. The full retirement age rules as written. A January 1 birthday counts as the year before. You reach an age the day before your birthday. Before full retirement age you must be 62 for the whole month, so most people start the month after they turn 62.
3. The exact reduction and delayed-credit arithmetic with SSA rounding. The two worked examples in 20 CFR 404.410 and 404.313 are test fixtures.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://social-security-cola-2027-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http social-security-cola-2027 https://social-security-cola-2027-mcp.lipmichal.workers.dev/mcp
claude mcp add social-security-cola-2027 -- npx -y github:theluckystrike/social-security-cola-2027-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "social-security-cola-2027": { "command": "npx", "args": ["-y", "github:theluckystrike/social-security-cola-2027-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "social-security-cola-2027": { "url": "https://social-security-cola-2027-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_social_security_cola` | Social Security cost-of-living adjustment (COLA) for a payable year, from the SSA "Cost-of-Living Increase and Other Determinations" notice in the Federal Register. |
| `calculate_cola_increase` | Apply a year's Social Security COLA to a monthly benefit. |
| `get_full_retirement_age` | Full retirement age for Social Security from a birth date (20 CFR 404.409, including the January 1 rule and the day-before-birthday rule), the exact date and month it... |
| `calculate_claiming_age_benefit` | Monthly Social Security retirement benefit if claimed at a given age between 62 and 70, from the full-retirement-age amount (PIA). |
| `get_social_security_limits` | Social Security program amounts for 2023 to 2027 from the Federal Register notices: maximum taxable earnings (2027: $192,300), retirement earnings test limits (2027... |
| `calculate_earnings_test` | How much Social Security withholds under the retirement earnings test for a year and annual earnings: $1 for every $2 over the limit, or $1 for every $3 in the year you... |

## Example output from a live call

Called on 2026-11-05 against the hosted URL above, with no token. The prompt was "What is the Social Security COLA for 2027?" and the client sent this call.

```json
{"name": "get_social_security_cola", "arguments": {}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
The Social Security cost-of-living adjustment paid from January 2027 is 3.6 percent. It applies to December 2026 benefits and to SSI payments for January 2027. SSA published it in the Federal Register on 2026-10-26 (document 2026-21796).
```

Data as of `2026-11-05`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the 2027 Social Security COLA and full retirement age?

Yes. Social Security COLA 2027 (social-security-cola-2027-mcp) is a free MCP server. Social Security COLA 2027, full retirement age, earnings test and 2027 limits from SSA notices. It is hosted at https://social-security-cola-2027-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/social-security-cola-2027-mcp.

### Does the Social Security COLA 2027 MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-05.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.federalregister.gov/d/2026-21796. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/social-security-cola-2027-mcp](https://github.com/theluckystrike/social-security-cola-2027-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/social-security-cola-2027-mcp/](https://www.mcpstamp.com/free-servers/social-security-cola-2027-mcp/) on the mcpstamp.com free server list
- [Can Claude tell me the Social Security COLA for 2027?](https://www.mcpstamp.com/can-claude/check-the-social-security-cola-2027/) on mcpstamp.com, the plain-English answer with a live call
- [mcpstamp.com](https://www.mcpstamp.com/servers/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=social-security-cola-2027-mcp), the companion site this server's results link to

## More free live-data servers

- [Student loan RAP calculator MCP server](/mcp/student-loan-repayment-assistance-plan-calculator-mcp/). Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA).
- [Subdomain finder MCP server](/mcp/subdomain-finder-mcp/). Passive subdomain enumeration from certificate transparency (certspotter, crt.sh) with DNS checks.
- [UK income tax and salary MCP server](/mcp/uk-income-tax-salary-mcp/). UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
