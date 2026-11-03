---
layout: default
title: "AP score distributions MCP server (free, no API key)"
description: "Free MCP server with the 2026 AP score distributions. No API key: paste the hosted URL. Official College Board AP score distributions 2026, 2025…"
permalink: /mcp/ap-score-distributions-mcp/
date: 2026-11-03
---

# AP score distributions MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "AP score distributions MCP server",
   "alternateName": "ap-score-distributions-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Official College Board AP score distributions 2026, 2025, 2024: percentiles, pass rates.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/ap-score-distributions-mcp/",
   "codeRepository": "https://github.com/theluckystrike/ap-score-distributions-mcp",
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
     "name": "Is there an MCP server with the 2026 AP score distributions?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. AP score distributions (ap-score-distributions-mcp) is a free MCP server. Official College Board AP score distributions 2026, 2025, 2024: percentiles, pass rates. It is hosted at https://ap-score-distributions-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/ap-score-distributions-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the AP score distributions MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://apstudents.collegeboard.org/about-ap-scores/score-distributions. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "AP score distributions",
     "item": "https://claudecodeguides.com/mcp/ap-score-distributions-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server with the 2026 AP score distributions? `ap-score-distributions-mcp` is free, MIT licensed and needs no API key and no account. Paste https://ap-score-distributions-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Official College Board AP score distributions 2026, 2025, 2024: percentiles, pass rates.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The May 2026 results. College Board posted the 2026 AP Score Distributions after the 2026 exams, which is newer than most model training data. For example, 46% of AP Calculus BC students scored a 5 in 2026, and AP Biology's pass rate was 71%.
2. Exact 2024 and 2025 counts. 287,232 students took AP Biology in May 2025 and 70.4% scored 3 or higher, with a mean of 3.24. All 49 rows per year (40 exams, 3 subscores, 6 Standard Group language rows) pass a check that counts add to the printed total and 5 + 4 + 3 equals the printed 3 or higher count.
3. Which cut charts exist. College Board does not publish cut scores for live exams. The estimator uses only the 7 conversion charts College Board printed in its practice exams (Calculus AB 2012, Biology 2013, Statistics 2012, World History 2013, Psychology 2012, Macroeconomics 2012, Microeconomics 2012) and refuses every other exam rather than invent a cut.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://ap-score-distributions-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http ap-score-distributions https://ap-score-distributions-mcp.lipmichal.workers.dev/mcp
claude mcp add ap-score-distributions -- npx -y github:theluckystrike/ap-score-distributions-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "ap-score-distributions": { "command": "npx", "args": ["-y", "github:theluckystrike/ap-score-distributions-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "ap-score-distributions": { "url": "https://ap-score-distributions-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_ap_score_distribution` | Returns the College Board score distribution (percent of students scoring 5, 4, 3, 2, 1 and 3 or higher) for an AP exam and year, plus student counts, mean and standard... |
| `estimate_ap_percentile` | For an AP exam, year and score from 1 to 5, returns the percent of test takers who scored lower, the same and higher, and the midpoint percentile rank, from the... |
| `compare_ap_exams` | Ranks AP exams for one year by pass rate (share scoring 3 or higher), share of 5s, mean score or number of test takers (mean and test takers for 2024 and 2025 only)... |
| `list_ap_exams` | Lists every AP exam with College Board score distributions in this server, the years available for each, the source of each year, and which exams have a College Board... |
| `estimate_ap_score_from_composite` | Converts multiple-choice correct answers and free-response points into a weighted composite and an estimated AP score, using the scoring worksheet and conversion chart... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What were the AP Calculus AB score distributions in 2026?" and the client sent this call.

```json
{"name": "get_ap_score_distribution", "arguments": {"exam": "AP Calculus AB", "year": 2026}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
AP Calculus AB, May 2026: 20% scored 5, 28% 4, 17% 3, 24% 2, 11% 1; 65% scored 3 or higher. 2026 figures are the whole-number percentages College Board posted on its 2026 AP Score Distributions page; College Board has not published 2026 student counts, means or standard deviations.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server with the 2026 AP score distributions?

Yes. AP score distributions (ap-score-distributions-mcp) is a free MCP server. Official College Board AP score distributions 2026, 2025, 2024: percentiles, pass rates. It is hosted at https://ap-score-distributions-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/ap-score-distributions-mcp.

### Does the AP score distributions MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://apstudents.collegeboard.org/about-ap-scores/score-distributions. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/ap-score-distributions-mcp](https://github.com/theluckystrike/ap-score-distributions-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/ap-score-distributions-mcp/](https://www.mcpstamp.com/free-servers/ap-score-distributions-mcp/) on the mcpstamp.com free server list
- [Can Claude look up 2026 AP score distributions?](https://www.mcpstamp.com/can-claude/look-up-ap-score-distributions/) on mcpstamp.com, the plain-English answer with a live call
- [examscorecalc.com](https://examscorecalc.com/ap/ap-calculus-ab/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=ap-score-distributions-mcp), the companion site this server's results link to

## More free live-data servers

- [Car loan interest deduction calculator MCP server](/mcp/car-loan-interest-deduction-calculator-mcp/). 2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS).
- [CPI inflation calculator MCP server](/mcp/cpi-inflation-calculator-mcp/). Inflation calculator with official BLS CPI 1913 to the latest month, raise vs inflation, SS COLA.
- [Cups to grams converter MCP server](/mcp/cups-to-grams-mcp/). Cups to grams for 271 ingredients with USDA and King Arthur densities, recipe scaling, oven temps.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
