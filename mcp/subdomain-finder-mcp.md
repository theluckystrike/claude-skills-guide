---
layout: default
title: "Subdomain finder MCP server (free, no API key)"
description: "Free MCP server that finds subdomains from certificate transparency logs. No API key: paste the hosted URL. Passive subdomain enumeration from…"
permalink: /mcp/subdomain-finder-mcp/
date: 2026-11-03
---

# Subdomain finder MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Subdomain finder MCP server",
   "alternateName": "subdomain-finder-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Passive subdomain enumeration from certificate transparency (certspotter, crt.sh) with DNS checks.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/subdomain-finder-mcp/",
   "codeRepository": "https://github.com/theluckystrike/subdomain-finder-mcp",
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
     "name": "Is there an MCP server that finds subdomains from certificate transparency logs?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Subdomain finder (subdomain-finder-mcp) is a free MCP server. Passive subdomain enumeration from certificate transparency (certspotter, crt.sh) with DNS checks. It is hosted at https://subdomain-finder-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/subdomain-finder-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Subdomain finder MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://api.certspotter.com/v1/issuances?domain=zovo.one&include_subdomains=true&expand=dns_names&expand=issuer. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Subdomain finder",
     "item": "https://claudecodeguides.com/mcp/subdomain-finder-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that finds subdomains from certificate transparency logs? `subdomain-finder-mcp` is free, MIT licensed and needs no API key and no account. Paste https://subdomain-finder-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Passive subdomain enumeration from certificate transparency (certspotter, crt.sh) with DNS checks.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. A domain's current subdomains. New hosts appear in CT logs within minutes of getting a certificate; a model's training data is months old and never had most of them.
2. Which hosts resolve right now, which CNAMEs point at a deleted cloud resource, and whether the zone has wildcard DNS.
3. Certificate history: when each name first got a certificate, which CAs issued it, and when the current one expires.
4. How to read CT data cleanly: precertificate and certificate rows merged, e-mail SANs and out-of-scope names dropped, `*.` entries reported as wildcards instead of hosts.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://subdomain-finder-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http subdomain-finder https://subdomain-finder-mcp.lipmichal.workers.dev/mcp
claude mcp add subdomain-finder -- npx -y github:theluckystrike/subdomain-finder-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "subdomain-finder": { "command": "npx", "args": ["-y", "github:theluckystrike/subdomain-finder-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "subdomain-finder": { "url": "https://subdomain-finder-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `find_subdomains` | Passive subdomain enumeration for a domain from live certificate transparency logs: certspotter (unexpired certificates) with crt.sh as fallback or for expired history. |
| `resolve_subdomains` | Resolve up to 40 hostnames now through Cloudflare DNS over HTTPS (A, AAAA and the CNAME chain). |
| `get_certificate_history` | Certificates logged in certificate transparency for one hostname (or a whole domain with include_subdomains): issuer organisation and DN, not_before and not_after... |
| `summarize_attack_surface` | Reads a domain's subdomains from live certificate transparency and groups them for recon triage: development and test, staging, admin and internal tools, APIs... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "Which subdomains of zovo.one show up in certificate transparency logs?" and the client sent this call.

```json
{"name": "find_subdomains", "arguments": {"domain": "zovo.one", "limit": 20}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
101 unique hostnames under zovo.one in 218 certificates from certspotter (first 3 pages only; raise max_pages for more). 100 wildcard entries (*.anon.zovo.one, *.ar-aging.zovo.one, *.avery-labels.zovo.one, ...), so some hosts will never appear in CT. Newest: ar-aging.zovo.one (2026-10-26), cap-table.zovo.one (2026-10-26), client-report.zovo.one (2026-10-26), depreciation.zovo.one (2026-10-26), gradebook.zovo.one (2026-10-26). Showing 20 of 101. certspotter lists unexpired certificates only. Use source "crtsh" with include_expired for older names.
```

Data as of `2026-11-03T09:02:59.727Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that finds subdomains from certificate transparency logs?

Yes. Subdomain finder (subdomain-finder-mcp) is a free MCP server. Passive subdomain enumeration from certificate transparency (certspotter, crt.sh) with DNS checks. It is hosted at https://subdomain-finder-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/subdomain-finder-mcp.

### Does the Subdomain finder MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://api.certspotter.com/v1/issuances?domain=zovo.one&include_subdomains=true&expand=dns_names&expand=issuer. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/subdomain-finder-mcp](https://github.com/theluckystrike/subdomain-finder-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/subdomain-finder-mcp/](https://www.mcpstamp.com/free-servers/subdomain-finder-mcp/) on the mcpstamp.com free server list
- [Can Claude find the subdomains of a website?](https://www.mcpstamp.com/can-claude/find-subdomains/) on mcpstamp.com, the plain-English answer with a live call
- [bugbountyreality.com](https://bugbountyreality.com/tools/subdomain-finder-real/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=subdomain-finder-mcp), the companion site this server's results link to

## More free live-data servers

- [UK income tax and salary MCP server](/mcp/uk-income-tax-salary-mcp/). UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap.
- [UK Statutory Sick Pay and Maternity Pay MCP server](/mcp/uk-statutory-sick-pay-maternity-pay-calculator-mcp/). UK Statutory Sick Pay (April 2026 rules), Maternity Pay and National Living Wage from gov.uk.
- [US federal holidays and business days MCP server](/mcp/us-federal-holidays-business-days-mcp/). Exact U.S. federal holidays and business days 1971-2100, OPM and Federal Reserve observance.
- [Backlink Checker MCP server](/mcp/backlink-checker/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
