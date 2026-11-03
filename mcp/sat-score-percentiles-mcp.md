---
layout: default
title: "SAT score percentiles MCP server (free, no API key)"
description: "Free MCP server that looks up SAT score percentiles. No API key: paste the hosted URL. SAT score percentiles and class of 2026 SAT averages and…"
permalink: /mcp/sat-score-percentiles-mcp/
date: 2026-11-03
---

# SAT score percentiles MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "SAT score percentiles MCP server",
   "alternateName": "sat-score-percentiles-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "SAT score percentiles and class of 2026 SAT averages and participation by state (College Board).",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/sat-score-percentiles-mcp/",
   "codeRepository": "https://github.com/theluckystrike/sat-score-percentiles-mcp",
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
     "name": "Is there an MCP server that looks up SAT score percentiles?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. SAT score percentiles (sat-score-percentiles-mcp) is a free MCP server. SAT score percentiles and class of 2026 SAT averages and participation by state (College Board). It is hosted at https://sat-score-percentiles-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/sat-score-percentiles-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the SAT score percentiles MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://research.collegeboard.org/reports/sat-suite/understanding-scores/sat. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "SAT score percentiles",
     "item": "https://claudecodeguides.com/mcp/sat-score-percentiles-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that looks up SAT score percentiles? `sat-score-percentiles-mcp` is free, MIT licensed and needs no API key and no account. Paste https://sat-score-percentiles-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. SAT score percentiles and class of 2026 SAT averages and participation by state (College Board).

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Class of 2026 SAT results, published by College Board in fall 2026: 1,954,833 test takers nationally with a mean total of 1045 (528 Reading and Writing, 517 Math), and the same figures for every state.
2. Each state's participation rate, which explains most of the gap between state averages. States that test every 11th grader have lower means than states where only college-bound students test.
3. The 25th, 50th and 75th percentile SAT scores for each state's class of 2026.
4. The exact College Board percentile for every 10-point score, in both reference groups, instead of a rounded guess.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://sat-score-percentiles-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http sat-score-percentiles https://sat-score-percentiles-mcp.lipmichal.workers.dev/mcp
claude mcp add sat-score-percentiles -- npx -y github:theluckystrike/sat-score-percentiles-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "sat-score-percentiles": { "command": "npx", "args": ["-y", "github:theluckystrike/sat-score-percentiles-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "sat-score-percentiles": { "url": "https://sat-score-percentiles-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_sat_percentile` | Percentile rank of a digital SAT total score (400-1600) or section score (200-800, Reading and Writing or Math), from the College Board percentile tables: the user... |
| `get_score_for_sat_percentile` | The lowest SAT total or section score whose College Board percentile is at or above a target (for example the 75th or 90th percentile), for the user group (SAT takers)... |
| `get_sat_scores_by_state` | Class of 2026 SAT results for one state, DC, Puerto Rico or the US Virgin Islands from the College Board 2026 SAT Suite Annual Report state supplement: test takers... |
| `rank_states_by_sat` | Rank the 50 states and DC by class of 2026 SAT mean total, mean Math, mean Reading and Writing, participation rate, percent meeting both benchmarks, or number of test... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What percentile is a 1350 on the SAT?" and the client sent this call.

```json
{"name": "get_sat_percentile", "arguments": {"score": 1350, "section": "total"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
An SAT total score of 1350 is at the 89th percentile of recent SAT takers (College Board user group percentile) and the 94th percentile of all US 11th and 12th graders (nationally representative percentile). It is 305 points above the class of 2026 mean of 1045 (1,954,833 test takers). 19% of the class of 2026 (377,381 students) scored 1200-1390.
```

Data as of `2026-11-03`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that looks up SAT score percentiles?

Yes. SAT score percentiles (sat-score-percentiles-mcp) is a free MCP server. SAT score percentiles and class of 2026 SAT averages and participation by state (College Board). It is hosted at https://sat-score-percentiles-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/sat-score-percentiles-mcp.

### Does the SAT score percentiles MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://research.collegeboard.org/reports/sat-suite/understanding-scores/sat. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/sat-score-percentiles-mcp](https://github.com/theluckystrike/sat-score-percentiles-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/sat-score-percentiles-mcp/](https://www.mcpstamp.com/free-servers/sat-score-percentiles-mcp/) on the mcpstamp.com free server list
- [Can Claude tell me my SAT percentile?](https://www.mcpstamp.com/can-claude/look-up-sat-percentiles/) on mcpstamp.com, the plain-English answer with a live call
- [examscorecalc.com](https://examscorecalc.com/digital-sat-score-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=sat-score-percentiles-mcp), the companion site this server's results link to

## More free live-data servers

- [Section 179 deduction calculator MCP server](/mcp/section-179-deduction-calculator-mcp/). Section 179 limits, 100% bonus depreciation, heavy SUV caps and asset loan cost (2025-2026, IRS).
- [Silver price per gram MCP server](/mcp/silver-price-per-gram-mcp/). Live silver price per gram by fineness and currency, junk silver coin value, gold silver ratio.
- [Student loan RAP calculator MCP server](/mcp/student-loan-repayment-assistance-plan-calculator-mcp/). Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA).

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
