---
layout: default
title: "Retirement contribution limits MCP server (free, no API key)"
description: "Free MCP server that knows the current 401(k) contribution limits. No API key: paste the hosted URL. 401(k), IRA, HSA limits, age 60-63 catch-up…"
permalink: /mcp/retirement-contribution-limits-2027-mcp/
date: 2026-11-03
---

# Retirement contribution limits MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Retirement contribution limits MCP server",
   "alternateName": "retirement-contribution-limits-2027-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "401(k), IRA, HSA limits, age 60-63 catch-up, Roth catch-up rule, Social Security COLA, 2025-2027.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/retirement-contribution-limits-2027-mcp/",
   "codeRepository": "https://github.com/theluckystrike/retirement-contribution-limits-2027-mcp",
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
     "name": "Is there an MCP server that knows the current 401(k) contribution limits?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Retirement contribution limits (retirement-contribution-limits-2027-mcp) is a free MCP server. 401(k), IRA, HSA limits, age 60-63 catch-up, Roth catch-up rule, Social Security COLA, 2025-2027. It is hosted at https://retirement-contribution-limits-2027-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/retirement-contribution-limits-2027-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Retirement contribution limits MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/newsroom/news-releases-for-current-month (checked 2026-11-02: no 2027 notice yet). The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Retirement contribution limits",
     "item": "https://claudecodeguides.com/mcp/retirement-contribution-limits-2027-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that knows the current 401(k) contribution limits? `retirement-contribution-limits-2027-mcp` is free, MIT licensed and needs no API key and no account. Paste https://retirement-contribution-limits-2027-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. 401(k), IRA, HSA limits, age 60-63 catch-up, Roth catch-up rule, Social Security COLA, 2025-2027.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. 2026 limits (IRS Notice 2025-67): 401(k) $24,500, catch-up $8,000, age 60-63 catch-up $11,250, IRA $7,500 plus $1,100 at 50+, 415(c) $72,000, compensation limit $360,000.
2. 2027 HSA limits (Rev. Proc. 2026-24): $4,500 self-only and $9,000 family, plus the $1,000 catch-up at 55.
3. 2027 Social Security (SSA notice, Federal Register Oct. 26, 2026): COLA 3.6%, wage base $192,300, earnings test $25,560 under full retirement age and $67,920 in the year you reach it.
4. The age 60-63 catch-up applies only if you are 60, 61, 62 or 63 on December 31. At 64 you drop back to the regular catch-up.
5. Roth catch-up rule: from 2026, if your prior-year FICA wages from the employer were over $150,000, catch-ups must be Roth. The final regulations apply from 2027 (IR-2025-91).
6. The IRS had not announced the 2027 401(k), IRA or SIMPLE limits on 2026-11-02. The tools say so and point to 2026.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://retirement-contribution-limits-2027-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http retirement-contribution-limits-2027 https://retirement-contribution-limits-2027-mcp.lipmichal.workers.dev/mcp
claude mcp add retirement-contribution-limits-2027 -- npx -y github:theluckystrike/retirement-contribution-limits-2027-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "retirement-contribution-limits-2027": { "command": "npx", "args": ["-y", "github:theluckystrike/retirement-contribution-limits-2027-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "retirement-contribution-limits-2027": { "url": "https://retirement-contribution-limits-2027-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_contribution_limits` | Returns official IRS contribution limits for 2025, 2026 and 2027: 401(k)/403(b)/TSP and 457(b) elective deferral ($24,500 for 2026), age 50+ catch-up ($8,000 for 2026)... |
| `calculate_max_contribution` | Calculates the most a person can contribute for a year given age (on Dec. 31), plans held (401k, 403b, 457b, tsp, simple, ira, hsa_self, hsa_family) and optional wages. |
| `get_social_security_cola` | Returns the Social Security cost-of-living adjustment and related figures from SSA's official annual notice in the Federal Register: 2027 COLA 3.6% (announced October... |
| `compare_years` | Shows each retirement, IRA, HSA and Social Security figure for two years side by side with the dollar and percent change: 401(k) deferral, catch-ups, 415(c)... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What are the 401(k), IRA and HSA contribution limits for 2027?" and the client sent this call.

```json
{"name": "get_contribution_limits", "arguments": {"year": 2027}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
2027 limits: HSA $4,500 self-only / $9,000 family plus $1,000 at 55+; Social Security wage base $192,300. The IRS has not announced the 2027 401(k), 403(b), 457, IRA, SIMPLE, 415(c), compensation or HCE limits. On 2026-11-02 the IRS news release list ran through IR-2026-129 (Oct. 29, 2026) with no cost-of-living notice for 2027 (the 2026 notice, IR-2025-111 / Notice 2025-67, came out in November 2025). This server does not guess or forecast. Use 2026 as the latest published year.

This is general information, not tax or financial advice. Your plan document may allow less (for example no age 60-63 catch-up). Check with your plan administrator or a tax professional.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that knows the current 401(k) contribution limits?

Yes. Retirement contribution limits (retirement-contribution-limits-2027-mcp) is a free MCP server. 401(k), IRA, HSA limits, age 60-63 catch-up, Roth catch-up rule, Social Security COLA, 2025-2027. It is hosted at https://retirement-contribution-limits-2027-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/retirement-contribution-limits-2027-mcp.

### Does the Retirement contribution limits MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/newsroom/news-releases-for-current-month (checked 2026-11-02: no 2027 notice yet). The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/retirement-contribution-limits-2027-mcp](https://github.com/theluckystrike/retirement-contribution-limits-2027-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/retirement-contribution-limits-2027-mcp/](https://www.mcpstamp.com/free-servers/retirement-contribution-limits-2027-mcp/) on the mcpstamp.com free server list
- [Can Claude look up the 2027 401(k) limits?](https://www.mcpstamp.com/can-claude/look-up-401k-limits/) on mcpstamp.com, the plain-English answer with a live call
- [statewage.com](https://statewage.com/401k-paycheck-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=retirement-contribution-limits-2027-mcp), the companion site this server's results link to

## More free live-data servers

- [River level MCP server](/mcp/river-level-mcp/). Live US river levels, streamflow and NWS flood forecasts from USGS stream gauges.
- [SAT score percentiles MCP server](/mcp/sat-score-percentiles-mcp/). SAT score percentiles and class of 2026 SAT averages and participation by state (College Board).
- [Section 179 deduction calculator MCP server](/mcp/section-179-deduction-calculator-mcp/). Section 179 limits, 100% bonus depreciation, heavy SUV caps and asset loan cost (2025-2026, IRS).
- [Payroll MCP server](/mcp/payroll/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
