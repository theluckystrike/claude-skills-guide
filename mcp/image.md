---
layout: default
title: "Image MCP server: install, tools and pricing"
description: "Resize, convert, compress, crop, thumbnail and watermark images from chat: no upload, no account, no native dependency. Every file stays on your…"
permalink: /mcp/image/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Image MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Resize, convert, compress, crop, thumbnail and watermark images from chat: no upload, no account, no native dependency. Every file stays on your machine.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/image/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/image",
   "license": "https://opensource.org/licenses/MIT",
   "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD",
    "description": "Free tier: unlimited local use. Optional one-time Pro licence for the hosted endpoint."
   },
   "isPartOf": {
    "@type": "ItemList",
    "name": "Back-office MCP server collection",
    "url": "https://claudecodeguides.com/mcp/"
   }
  },
  {
   "@type": "FAQPage",
   "mainEntity": [
    {
     "@type": "Question",
     "name": "Is the Image MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Image locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Image need an API key?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "No. The server works offline against local files. If you use the hosted endpoint, the connection is authenticated with a scoped token instead of a per-tool API key."
     }
    },
    {
     "@type": "Question",
     "name": "Where does the data go?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Local installs keep everything on your machine. The hosted endpoint stores records in an isolated per-tenant namespace, and only for servers you actually call."
     }
    },
    {
     "@type": "Question",
     "name": "Which clients can use it?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Any MCP client: Claude Desktop (via the .mcpb bundle), Claude Code, Cursor, Windsurf, VS Code with an MCP extension, or your own agent over the Streamable HTTP transport."
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
     "name": "Image",
     "item": "https://claudecodeguides.com/mcp/image/"
    }
   ]
  }
 ]
}
</script>

# Image MCP server

Say "make these five photos 1200 pixels wide" or "shrink this screenshot and strip the GPS out of it" and it happens, on your machine, in a second. This MCP server does the small image jobs that otherwise send you to a web uploader: resize, convert between PNG, JPEG, BMP, GIF and TIFF, compress with a real before-and-after byte count, crop, thumbnail a folder, watermark with your business name, an

**Category:** Documents and files &middot; **Tools:** 10 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** `https://mcp.zovo.one/mcp/image` - point any MCP client at that URL (Streamable HTTP, verified with a live MCP handshake).
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/image.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/image`.
- **npm:** the package `@theluckystrike/mcp-image` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `image_info` | see tool reference |
| `image_resize` | see tool reference |
| `image_convert` | see tool reference |
| `image_compress` | see tool reference |
| `image_crop` | see tool reference |
| `image_thumbnails` | see tool reference |
| `image_watermark` | see tool reference |
| `image_strip_metadata` | see tool reference |
| `image_batch_resize` | see tool reference |
| `image_dominant_colors` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Image Pro licence — $19](https://mcp.zovo.one/buy/image&src=csg.mcp.image)

## Questions people actually ask

### Is the Image MCP server free?

Yes. Running Image locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Image need an API key?

No. The server works offline against local files. If you use the hosted endpoint, the connection is authenticated with a scoped token instead of a per-tool API key.

### Where does the data go?

Local installs keep everything on your machine. The hosted endpoint stores records in an isolated per-tenant namespace, and only for servers you actually call.

### Which clients can use it?

Any MCP client: Claude Desktop (via the .mcpb bundle), Claude Code, Cursor, Windsurf, VS Code with an MCP extension, or your own agent over the Streamable HTTP transport.


## Related servers in the same category

- [Invoice MCP server](/mcp/invoice/) — Make real, sendable PDF invoices from a sentence. Clients, numbering that never repeats, VAT lines, discounts 
- [Quotes MCP server](/mcp/quotes/) — Send a client a real quote in seconds: line items with VAT, a validity date, a plain-text version to paste int
- [Recurring MCP server](/mcp/recurring/) — Bill the same clients every month without remembering to. Define a recurring invoice once, then generate the r
- [Credit Note MCP server](/mcp/credit-note/) — Credit notes against an invoice or standalone: drafts, finalization, rendering, totals.

---

[All 58 back-office MCP servers](/mcp/) &middot; [how the collection is organised](/mcp/#how-it-fits-together)
