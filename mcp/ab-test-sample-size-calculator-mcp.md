---
layout: default
title: "A/B test sample size calculator MCP server (free, no API key)"
description: "Free MCP server that calculates A/B test sample size and significance. No API key: paste the hosted URL. Exact A/B test sample size, duration…"
permalink: /mcp/ab-test-sample-size-calculator-mcp/
date: 2026-11-03
---

# A/B test sample size calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "A/B test sample size calculator MCP server",
   "alternateName": "ab-test-sample-size-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Exact A/B test sample size, duration, z-test, chi-square, Fisher-Freeman-Halton and peeking risk.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/ab-test-sample-size-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/ab-test-sample-size-calculator-mcp",
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
     "name": "Is there an MCP server that calculates A/B test sample size and significance?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. A/B test sample size calculator (ab-test-sample-size-calculator-mcp) is a free MCP server. Exact A/B test sample size, duration, z-test, chi-square, Fisher-Freeman-Halton and peeking risk. It is hosted at https://ab-test-sample-size-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/ab-test-sample-size-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the A/B test sample size calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://github.com/theluckystrike/ab-test-sample-size-calculator-mcp/blob/main/DATA_SOURCES.md. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "A/B test sample size calculator",
     "item": "https://claudecodeguides.com/mcp/ab-test-sample-size-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates A/B test sample size and significance? `ab-test-sample-size-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://ab-test-sample-size-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Exact A/B test sample size, duration, z-test, chi-square, Fisher-Freeman-Halton and peeking risk.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Exact inverse normal quantiles and the full sample size formula. Models round z-values, drop the pooled variance term or confuse relative and absolute MDE, and the answer moves by thousands of users.
2. Why calculators disagree. The result shows both the standard pooled formula (as R `power.prop.test`) and Evan Miller's published formula, so a 37,513 vs 36,314 gap has an explanation.
3. Exact hypergeometric sums. A Fisher-Freeman-Halton p-value for a 4 x 4 table needs millions of tables summed; it cannot be estimated in your head.
4. Sequential testing numbers: checking 5 times at p < 0.05 gives a 14.2% false positive rate, and the boundaries that fix it.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://ab-test-sample-size-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http ab-test-sample-size-calculator https://ab-test-sample-size-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add ab-test-sample-size-calculator -- npx -y github:theluckystrike/ab-test-sample-size-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "ab-test-sample-size-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/ab-test-sample-size-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "ab-test-sample-size-calculator": { "url": "https://ab-test-sample-size-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_sample_size` | Exact sample size per variant for an A/B test on a conversion rate (two independent proportions): baseline rate, minimum detectable effect (relative or absolute)... |
| `estimate_test_duration` | How many days an A/B test must run: from a known sample size per variant, or from baseline rate and MDE (computed as in calculate_sample_size), plus daily visitors and... |
| `test_ab_significance` | Is an A/B test result statistically significant? |
| `fisher_exact_test` | Exact p-value for a contingency table of counts. 2x2: Fisher exact test (two-sided, greater or less, as R fisher.test). |
| `check_peeking_risk` | What peeking does to an A/B test: the real false positive rate if you check a fixed-horizon test K times and stop at the first p < alpha (for example about 14% at 5... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "My checkout converts at 4%. How many users per variant do I need to detect a 10% relative lift?" and the client sent this call.

```json
{"name": "calculate_sample_size", "arguments": {"baseline_rate": 0.04, "mde": 0.1}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
To detect a change from 4.00% to 4.40% (10.0% relative MDE) with 80% power at alpha 0.05 two-sided, you need 39,475 users in control and in each variant: 78,950 in total across 2 arms. Evan Miller's calculator gives 38,210 per arm for the same inputs (it uses the baseline variance in both terms and always two-sided alpha).
```

Data as of `2026-11-03`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates A/B test sample size and significance?

Yes. A/B test sample size calculator (ab-test-sample-size-calculator-mcp) is a free MCP server. Exact A/B test sample size, duration, z-test, chi-square, Fisher-Freeman-Halton and peeking risk. It is hosted at https://ab-test-sample-size-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/ab-test-sample-size-calculator-mcp.

### Does the A/B test sample size calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://github.com/theluckystrike/ab-test-sample-size-calculator-mcp/blob/main/DATA_SOURCES.md. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/ab-test-sample-size-calculator-mcp](https://github.com/theluckystrike/ab-test-sample-size-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/ab-test-sample-size-calculator-mcp/](https://www.mcpstamp.com/free-servers/ab-test-sample-size-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate A/B test sample size?](https://www.mcpstamp.com/can-claude/calculate-ab-test-sample-size/) on mcpstamp.com, the plain-English answer with a live call
- [abwex.com](https://abwex.com/tools/sample-size-calculator.html?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=ab-test-sample-size-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [ACA premium tax credit calculator MCP server](/mcp/aca-premium-tax-credit-calculator-mcp/). 2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules.
- [AP score distributions MCP server](/mcp/ap-score-distributions-mcp/). Official College Board AP score distributions 2026, 2025, 2024: percentiles, pass rates.
- [Car loan interest deduction calculator MCP server](/mcp/car-loan-interest-deduction-calculator-mcp/). 2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS).

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
