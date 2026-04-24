---
layout: default
title: "Claude Code for PartyKit (2026)"
description: "Claude Code for PartyKit — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-partykit-realtime-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, partykit, workflow]
---

## The Setup

You are building real-time multiplayer features using PartyKit, a platform for deploying collaborative servers that manage WebSocket connections, state, and room-based coordination. Claude Code can generate PartyKit servers and client integrations, but it defaults to raw WebSocket code or Socket.io patterns instead of PartyKit's server-per-room model. For a deeper dive, see [Claude Code for Kamal Deploy — Workflow Guide](/claude-code-for-kamal-deploy-workflow-guide/).

## What Claude Code Gets Wrong By Default

1. **Writes Socket.io server code.** Claude generates `io.on('connection', socket => { })` with Socket.io. PartyKit exports a `Server` class with `onConnect`, `onMessage`, and `onClose` methods — a fundamentally different API.

2. **Creates a single global WebSocket server.** Claude builds one server handling all connections. PartyKit creates isolated server instances per room — each room has its own state, its own connections, and its own lifecycle.

3. **Manages WebSocket connections manually.** Claude tracks connections in a `Set`, handles ping/pong, and writes reconnection logic. PartyKit manages connection lifecycle automatically — `this.room.getConnections()` returns all active connections for a room.

4. **Deploys on a traditional Node.js host.** Claude writes Dockerfile and deployment configs for a WebSocket server. PartyKit deploys with `npx partykit deploy` to its edge infrastructure — no Docker or server management needed.

## The CLAUDE.md Configuration

```
# PartyKit Real-Time Project

## Architecture
- Real-time: PartyKit (room-based multiplayer servers)
- Server: party/server.ts exports PartyKitServer class
- Client: PartySocket from partysocket package
- Deploy: npx partykit deploy

## PartyKit Rules
- Server exports: onConnect, onMessage, onClose, onRequest methods
- Each room is an isolated server instance with own state
- Broadcast: this.room.broadcast(message, [excludeIds])
- Get connections: this.room.getConnections()
- Persistent storage: this.room.storage.get/put (Durable Object-backed)
- Room ID from URL: partykit.io/party/[room-id]
- Client: new PartySocket({ host, room: "room-id" })

## Conventions
- Server in party/ directory (party/server.ts)
- Multiple party servers: party/chat.ts, party/cursor.ts
- Client connection in hooks: usePartySocket from partysocket/react
- Room IDs follow pattern: "doc:{docId}", "room:{roomId}"
- Messages are JSON strings: JSON.stringify/parse
- Static assets served from public/ directory
- Config in partykit.json at project root
```

## Workflow Example

You want to build a collaborative cursor tracking feature. Prompt Claude Code:

"Create a PartyKit server that tracks cursor positions for all users in a room. When a user moves their cursor, broadcast the position to all other users. Include the React hook for connecting and sending cursor updates."

Claude Code should create a `party/cursor.ts` server with `onMessage` that parses cursor positions and broadcasts to other connections using `this.room.broadcast(message, [sender.id])`, and a React hook using `usePartySocket` that sends cursor position on mouse move and maintains a map of other users' cursor positions from incoming messages.

## Common Pitfalls

1. **Stateless server assumptions.** Claude stores room state in module-level variables. PartyKit server instances can be evicted and recreated. Use `this.room.storage.put()` for state that must survive server restarts, not in-memory variables.

2. **Room naming collisions.** Claude uses simple room names like "main" or "default". In production, room IDs should include context (user ID, document ID) to prevent unrelated users from sharing state: `doc:${docId}` instead of `doc`.

3. **Message serialization issues.** Claude sends JavaScript objects directly through WebSocket. PartyKit requires string messages — always `JSON.stringify()` on send and `JSON.parse()` on receive. Sending objects silently converts them to `[object Object]`.

## Related Guides

- [Claude Code for Yjs CRDT Workflow Guide](/claude-code-for-yjs-crdt-workflow-guide/)
- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## Related Articles

- [Claude Code for Workspace Indexing Workflow Tutorial](/claude-code-for-workspace-indexing-workflow-tutorial/)
- [Claude Code For Redwood JS — Complete Developer Guide](/claude-code-for-redwood-js-fullstack-workflow-guide/)
- [Claude Code Enterprise Disaster Recovery Workflow Planning](/claude-code-enterprise-disaster-recovery-workflow-planning/)
- [Claude Code For Jmh Benchmark — Complete Developer Guide](/claude-code-for-jmh-benchmark-workflow-tutorial-guide/)
- [Claude Code Workflow for Turkish Developer Teams](/claude-code-workflow-for-turkish-developer-teams/)
- [Claude Code Git Lfs Large Files — Complete Developer Guide](/claude-code-git-lfs-large-files-workflow/)
- [Claude Code for Astro Integrations Workflow Guide](/claude-code-for-astro-integrations-workflow-guide/)
- [Claude Code for ARIA Live Regions Workflow Guide](/claude-code-for-aria-live-regions-workflow-guide/)
