---
layout: default
title: "Claude Code for PostHog (2026)"
description: "Claude Code for PostHog — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-posthog-analytics-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, posthog, workflow]
---

## The Setup

You are adding product analytics, feature flags, and session replay to your application using PostHog. Claude Code can instrument events, configure feature flags, and set up funnels, but it frequently confuses PostHog's API with Google Analytics patterns and misses PostHog-specific concepts like group analytics and the distinct ID system.

## What Claude Code Gets Wrong By Default

1. **Uses Google Analytics event patterns.** Claude generates `gtag('event', ...)` style calls or `analytics.track()` from Segment. PostHog uses `posthog.capture('event_name', { properties })` with its own SDK.

2. **Initializes PostHog multiple times.** Claude adds `posthog.init()` in every component file. PostHog should be initialized once — in a provider, `_app.tsx`, or layout file — and accessed via the `usePostHog()` hook or global instance.

3. **Ignores server-side event capture.** Claude only instruments client-side events. PostHog has a Node.js SDK for server-side capture that is critical for backend events like subscription changes or API usage tracking.

4. **Hardcodes feature flag values.** Claude checks feature flags with `if (FEATURE_X_ENABLED)` constants. PostHog flags should be evaluated at runtime using `posthog.isFeatureEnabled('flag-name')` or the `useFeatureFlagEnabled()` hook.

## The CLAUDE.md Configuration

```
# PostHog Analytics Project

## Architecture
- Analytics: PostHog (posthog-js for client, posthog-node for server)
- Framework: Next.js with App Router
- Provider: PostHogProvider wraps app in providers.tsx
- Feature flags evaluated at runtime, never hardcoded

## PostHog Rules
- Initialize once in PostHogProvider, access via usePostHog() hook
- Event names use snake_case: "project_created", "file_uploaded"
- Always include relevant properties with events
- Use posthog.identify() after authentication with user ID
- Feature flags: useFeatureFlagEnabled('flag-name') in components
- Server-side: import PostHog from 'posthog-node', init with API key
- Never send PII (email, name) as event properties without consent
- Group analytics: posthog.group('company', companyId) for B2B

## Conventions
- Event tracking functions in lib/analytics.ts
- Feature flag names use kebab-case: "new-dashboard-v2"
- Server PostHog client is singleton in lib/posthog-server.ts
- Flush server events with posthog.flush() in serverless functions
```

## Workflow Example

You want to track a funnel from signup to first project creation. Prompt Claude Code:

"Add PostHog event tracking for the signup flow: track when users land on the signup page, complete registration, and create their first project. Include relevant properties for each event."

Claude Code should add `posthog.capture('signup_page_viewed')` on mount, `posthog.capture('signup_completed', { method: 'email' })` after registration, and `posthog.capture('first_project_created', { project_name, template_used })` in the project creation handler, plus a `posthog.identify()` call linking the anonymous user to their new account.

## Common Pitfalls

1. **Not calling `posthog.flush()` in serverless.** Claude captures server-side events but never flushes. In serverless environments (Vercel, Lambda), the function terminates before events are sent. Always `await posthog.flush()` before returning.

2. **Feature flag flicker on page load.** Claude renders both flag variants and switches after evaluation. Use `posthog.onFeatureFlags(() => {})` or the `useFeatureFlagEnabled` hook with a loading state to prevent UI flashing.

3. **Missing `posthog.reset()` on logout.** Claude handles login identification but forgets to reset on logout. Without `posthog.reset()`, the next user inherits the previous user's identity, corrupting analytics data.



**Get started →** Generate your project setup with our [Project Starter](/starter/).

## Related Guides

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

- [Claude Code for Amplitude Analytics Workflow](/claude-code-for-amplitude-analytics-workflow/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)

## See Also

- [Claude Code for Mixpanel Analytics — Guide](/claude-code-for-mixpanel-analytics-workflow-guide/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
