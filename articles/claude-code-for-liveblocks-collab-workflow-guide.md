---
layout: default
title: "Claude Code for Liveblocks — Workflow Guide"
description: "Add real-time collaboration with Liveblocks and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-liveblocks-collab-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, liveblocks, workflow]
---

## The Setup

You are adding real-time collaborative features to a React application using Liveblocks. This means presence indicators, live cursors, and shared document state that syncs between users without manual WebSocket management. Claude Code can generate the room setup, presence hooks, and storage mutations, but it tends to reinvent WebSocket plumbing instead of using the Liveblocks abstractions. See also [Claude Code for React Aria Components — Guide](/claude-code-for-react-aria-components-workflow-guide/) for more on this topic.

## What Claude Code Gets Wrong By Default

1. **Builds custom WebSocket connections.** When asked for real-time features, Claude writes raw `ws://` connection code. Liveblocks handles all transport internally through its `RoomProvider` and hooks.

2. **Uses wrong hook names.** Claude generates `useLiveblocks()` or `useRoom()` calls that do not exist. The correct hooks are `useOthers()`, `useSelf()`, `useStorage()`, and `useMutation()` from `@liveblocks/react`.

3. **Ignores the liveblocks.config.ts file.** Liveblocks requires a typed configuration file that defines `Presence`, `Storage`, and `UserMeta` types. Claude skips this and loses all type safety.

4. **Stores collaborative state in React state.** Claude puts shared data in `useState` and tries to broadcast changes. Liveblocks uses its own CRDT-based storage accessed through `useStorage()` — React state is only for local UI.

## The CLAUDE.md Configuration

```
# Liveblocks Collaborative App

## Architecture
- Framework: Next.js 14 with App Router
- Real-time: Liveblocks (@liveblocks/react, @liveblocks/node)
- Config: liveblocks.config.ts at project root defines all types
- Auth: /api/liveblocks-auth endpoint for token generation

## Liveblocks Rules
- All collaborative state goes through useStorage(), never useState
- Presence data uses useSelf() and useOthers() hooks
- Mutations use useMutation() hook with (root, args) => signature
- RoomProvider wraps collaborative pages, not the entire app
- Storage types must be defined in liveblocks.config.ts
- Use LiveList, LiveMap, LiveObject for nested collaborative data
- Never directly modify storage objects — use .set(), .push(), .delete()

## Conventions
- Room IDs follow pattern: "project:{projectId}"
- Presence includes cursor position and user color
- Storage mutations are colocated with the component that uses them
- Never import from @liveblocks/client directly in components
```

## Workflow Example

You want to add live cursor tracking to a collaborative canvas. Prompt Claude Code:

"Add live cursor presence to the Canvas component. Show colored cursors for all connected users with their names. Update cursor position on mouse move."

Claude Code should update the `Presence` type in `liveblocks.config.ts` to include `cursor: { x: number, y: number } | null`, use `useUpdateMyPresence()` in the mouse move handler, and render other cursors using `useOthers()` with a cursor SVG component.

## Common Pitfalls

1. **Forgetting to set cursor to null on mouse leave.** Claude tracks mouse position but never clears it when the cursor leaves the canvas, causing ghost cursors that stick in the last position for other users.

2. **Throttling presence updates wrong.** Claude adds `debounce` to cursor updates, which makes cursors jump. Liveblocks already throttles internally — adding your own debounce on top creates a laggy experience.

3. **Nesting LiveObjects incorrectly.** Claude creates plain JavaScript objects inside storage mutations. Nested collaborative objects must be wrapped in `new LiveObject({})`, `new LiveList([])`, or `new LiveMap()` to be reactive.

## Related Guides

- [Claude Code for Yjs CRDT Workflow Guide](/claude-code-for-yjs-crdt-workflow-guide/)
- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)
- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
