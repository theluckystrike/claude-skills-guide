---
layout: default
title: "Claude Code for Activepieces"
description: "Build automation flows with Activepieces and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-activepieces-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, activepieces, workflow]
---

## The Setup

You are building automation workflows using Activepieces, the open-source Zapier alternative that lets you create custom pieces (integrations) with TypeScript. Claude Code can generate Activepieces custom pieces and flow configurations, but it defaults to Zapier's terminology and webhook patterns.

## What Claude Code Gets Wrong By Default

1. **Uses Zapier's "zap" terminology and trigger format.** Claude writes "Create a zap that triggers on..." — Activepieces calls them "flows" with "triggers" and "actions" as pieces. The code structure and API differ completely.

2. **Generates n8n or Zapier webhook handlers.** Claude writes generic webhook handlers. Activepieces has a structured piece framework with `createTrigger()`, `createAction()`, and `createPiece()` functions from `@activepieces/pieces-framework`.

3. **Ignores the piece development framework.** Claude writes standalone Node.js scripts for integrations. Activepieces pieces follow a specific structure with property definitions, authentication handling, and test functions.

4. **Skips authentication piece config.** Claude hardcodes API keys in action code. Activepieces has a built-in auth system where pieces declare their auth requirements and users configure credentials through the UI.

## The CLAUDE.md Configuration

```
# Activepieces Custom Pieces Project

## Platform
- Automation: Activepieces (open-source, self-hosted or cloud)
- Pieces: Custom TypeScript integrations
- Framework: @activepieces/pieces-framework
- Dev: npx activepieces-cli create-piece

## Activepieces Rules
- Pieces created with createPiece() from framework
- Actions: createAction() with props, auth, and run function
- Triggers: createTrigger() with polling or webhook type
- Props: Property.ShortText(), Property.Number(), etc.
- Auth: PieceAuth.SecretText(), PieceAuth.OAuth2()
- Test with: npm run dev in pieces directory
- Never hardcode API keys — use auth prop system

## Conventions
- One piece per integration (e.g., pieces/custom-crm/)
- Actions in src/lib/actions/ directory
- Triggers in src/lib/triggers/ directory
- Auth configuration in piece definition
- Use Property builders for type-safe configuration
- Error handling: throw new Error() with clear messages
```

## Workflow Example

You want to create a custom Activepieces piece for your internal API. Prompt Claude Code:

"Create an Activepieces custom piece for our internal CRM API. Include an action to create a contact with name, email, and company fields, and a polling trigger that checks for new contacts every 5 minutes."

Claude Code should scaffold a piece with `createPiece()`, define auth using `PieceAuth.SecretText()` for the API key, create the `createContact` action with `Property.ShortText()` props, and create a polling trigger with `createTrigger()` that stores the last poll timestamp in the store.

## Common Pitfalls

1. **Polling trigger without deduplication.** Claude fetches all records on each poll. Activepieces triggers must track what they have already processed using the built-in store: `ctx.store.get('lastId')` and `ctx.store.put('lastId', newId)`.

2. **Missing piece manifest fields.** Claude creates the piece code but skips required fields like `displayName`, `logoUrl`, `description`, and `version` in `createPiece()`. The piece will not load in the Activepieces UI without these.

3. **Property type mismatches.** Claude uses `Property.ShortText()` for fields that should be `Property.Dropdown()` or `Property.MultiSelect()`. Using the wrong property type creates a poor UX in the flow builder where users must type values instead of selecting from options.

## Related Guides

- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
