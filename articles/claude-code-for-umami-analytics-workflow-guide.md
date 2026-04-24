---
layout: default
title: "Claude Code for Umami Analytics"
description: "Add privacy-first analytics with Umami and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-umami-analytics-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, umami, workflow]
---

## The Setup

You are adding privacy-focused web analytics using Umami, the open-source, GDPR-compliant alternative to Google Analytics. Umami can be self-hosted or used via Umami Cloud, and it collects no personal data. Claude Code can instrument Umami tracking, but it generates Google Analytics patterns or adds invasive tracking that defeats Umami's privacy-first purpose.

## What Claude Code Gets Wrong By Default

1. **Generates Google Analytics gtag code.** Claude writes `gtag('config', 'G-XXXXX')` and `gtag('event', ...)` calls. Umami uses a single tracking script with `data-website-id` and custom events via `umami.track('event-name')`.

2. **Adds cookie consent banners.** Claude includes cookie consent logic. Umami does not use cookies and does not track personal data — no consent banner needed. Adding one misleads users about data collection.

3. **Tracks personally identifiable information.** Claude adds user email, name, or IP to events. Umami is designed to not collect PII. Custom event data should contain aggregate-useful properties like `{ plan: 'pro' }`, never personal identifiers.

4. **Creates complex event schemas.** Claude builds elaborate tracking frameworks with user sessions. Umami's event model is intentionally simple: event name plus optional flat properties. Keep it minimal.

## The CLAUDE.md Configuration

```
# Umami Analytics Project

## Analytics
- Platform: Umami (self-hosted or Umami Cloud)
- Script: single <script> tag with data-website-id
- Events: umami.track('event-name', { properties })
- API: Umami REST API for data access

## Umami Rules
- Add tracking script in <head>: <script src="..." data-website-id="...">
- Custom events: umami.track('button_clicked', { button: 'signup' })
- No cookies, no PII, no consent banner needed
- Self-hosted: NEXT_PUBLIC_UMAMI_URL for script source
- Website ID from Umami dashboard, stored as env var
- Track meaningful business events, not every click
- Properties are flat key-value pairs, not nested objects

## Conventions
- Tracking script in layout.tsx or _app.tsx <Head>
- Event helper in lib/analytics.ts wrapping umami.track()
- Event names use snake_case: page_view, signup_started
- Max 20 custom event types (keep it focused)
- No user identification — Umami tracks anonymously
- API queries for dashboards: GET /api/websites/{id}/stats
- Self-hosted behind reverse proxy with proper headers
```

## Workflow Example

You want to track key business metrics for a SaaS application. Prompt Claude Code:

"Add Umami analytics tracking for signup started, signup completed, plan selected, and feature used events. Create a helper module and add the tracking script to the layout."

Claude Code should add the Umami script tag to the root layout with the website ID from an env var, create `lib/analytics.ts` with typed wrapper functions like `trackSignup(method: string)` calling `umami.track('signup_completed', { method })`, and add tracking calls at the appropriate points in the signup flow and feature usage handlers.

## Common Pitfalls

1. **Script loading on client-side navigation.** Claude adds the Umami script tag, but in SPAs, Umami does not automatically track page views on client-side navigation. Use `umami.track()` without arguments on route changes, or configure the `data-auto-track` attribute.

2. **Self-hosted URL mismatch.** Claude points the script src to `localhost:3000` in production. The Umami script URL must be the publicly accessible URL of your Umami instance. Use an environment variable and ensure CORS headers allow your domain.

3. **Overtracking defeats the purpose.** Claude instruments every button click and scroll event. Umami's philosophy is minimal tracking — focus on 10-20 meaningful business events that help you make decisions, not behavioral surveillance.

## Related Guides

- [Claude Code for Amplitude Analytics Workflow](/claude-code-for-amplitude-analytics-workflow/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)

## Related Articles

- [Claude Code for Pirsch Analytics — Guide](/claude-code-for-pirsch-analytics-workflow-guide/)
- [Claude Code for Tinybird Analytics — Guide](/claude-code-for-tinybird-analytics-workflow-guide/)
- [Claude Code for Mixpanel Analytics — Guide](/claude-code-for-mixpanel-analytics-workflow-guide/)
