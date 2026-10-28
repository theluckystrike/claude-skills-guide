---
title: "MCP guides: real back-office jobs, one call at a time"
permalink: /mcp/guides/
---

Answer-shaped walkthroughs for the jobs people actually type into Claude or ChatGPT:
invoice PDFs, Excel edits, bank statements to CSV, Word templates, mileage, time tracking.

{% for p in site.pages %}{% if p.url contains '/mcp/guides/' and p.url != '/mcp/guides/' %}
- [{{ p.title }}]({{ p.url }})
{% endif %}{% endfor %}
