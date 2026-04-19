---
layout: default
title: "Claude Code for Pirsch Analytics — Guide"
description: "Add privacy-first analytics with Pirsch and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-pirsch-analytics-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, pirsch, workflow]
---

## The Setup

You are tracking website analytics with Pirsch, a privacy-friendly, cookie-free analytics platform that complies with GDPR without consent banners. Pirsch uses a unique approach based on hashed fingerprints instead of cookies, providing page views, referrers, and custom events without tracking individual users. Claude Code can add analytics, but it generates Google Analytics scripts with cookie consent flows that Pirsch eliminates.

## What Claude Code Gets Wrong By Default

1. **Adds Google Analytics gtag.js script.** Claude embeds the GA4 tracking script with measurement IDs. Pirsch uses its own lightweight script (`pirsch.js`) or server-side API — no Google scripts needed.

2. **Creates cookie consent banners.** Claude implements GDPR consent flows with banner UI. Pirsch is cookie-free by design — no consent banner is required because no personal data is stored.

3. **Tracks individual user sessions.** Claude sets up user ID tracking and session management. Pirsch hashes visitor fingerprints and discards them daily — there is no individual user tracking, only aggregate statistics.

4. **Uses client-side-only tracking.** Claude relies entirely on JavaScript tracking. Pirsch supports server-side tracking via its API (`POST /api/v1/hit`) — useful for API endpoints, server-rendered pages, and environments without JavaScript.

## The CLAUDE.md Configuration

```
# Pirsch Analytics Project

## Analytics
- Platform: Pirsch (privacy-first, cookie-free)
- GDPR: compliant without consent banners
- Tracking: hashed fingerprints, no cookies
- Methods: client-side script or server-side API

## Pirsch Rules
- Script: <script src="https://api.pirsch.io/pirsch.js"...>
- Events: pirsch('Event Name', { metadata }) for custom events
- Server: POST /api/v1/hit for server-side pageview
- Server events: POST /api/v1/event for server-side events
- Auth: access token for API requests
- No cookies: no consent banner needed
- Dashboard: pirsch.io dashboard for analytics

## Conventions
- Add pirsch.js script to layout/head
- Custom events for key user actions
- Server-side tracking for API routes
- Use data-pirsch-event attribute for click tracking
- Event metadata: key-value pairs for filtering
- Exclude internal traffic with IP filtering
- Use Pirsch API for custom dashboards
```

## Workflow Example

You want to add Pirsch analytics to a Next.js site with custom event tracking. Prompt Claude Code:

"Add Pirsch analytics to our Next.js site. Include the tracking script in the layout, track custom events for button clicks (signup, download, pricing), and add server-side tracking for our API endpoints. No cookie consent banner needed."

Claude Code should add the Pirsch script to the root layout with `data-code` attribute, create a utility function for `pirsch()` custom events on signup/download/pricing buttons, add server-side hit tracking in API route middleware using `POST /api/v1/hit`, and explicitly not add any cookie consent components.

## Common Pitfalls

1. **Adding unnecessary consent banners.** Claude adds GDPR consent UI out of habit. Pirsch does not use cookies or track personal data — consent banners are unnecessary and confusing to users. Remove any existing consent flows.

2. **Missing server-side tracking for SPAs.** Claude only adds the client script. Single-page apps may not trigger new page loads on navigation. Either use Pirsch's SPA mode or track page views manually with `pirsch()` on route changes.

3. **Exposing API token in client code.** Claude puts the Pirsch API access token in frontend JavaScript. The client script uses `data-code` (safe to expose), but the server-side API uses an access token that must stay server-side — never expose API tokens in client bundles.

## Related Guides

- [Claude Code for Umami Analytics Workflow Guide](/claude-code-for-umami-analytics-workflow-guide/)
- [Claude Code for PostHog Analytics Workflow Guide](/claude-code-for-posthog-analytics-workflow-guide/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)

## Related Articles

- [Claude Code for Tinybird Analytics — Guide](/claude-code-for-tinybird-analytics-workflow-guide/)
- [Claude Code for Wiki Analytics Workflow Tutorial Guide](/claude-code-for-wiki-analytics-workflow-tutorial-guide/)
