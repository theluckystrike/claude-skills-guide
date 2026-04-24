---
layout: default
title: "Claude Code for Yjs CRDT"
description: "Build collaborative apps with Yjs CRDT and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-yjs-crdt-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, yjs, workflow]
---

## The Setup

You are building a collaborative application using Yjs, the CRDT framework that enables real-time document editing with automatic conflict resolution. Yjs works with any network transport and integrates with popular editors (TipTap, ProseMirror, Monaco, CodeMirror). Claude Code can implement Yjs collaboration, but it defaults to manual OT (Operational Transform) logic or simple WebSocket broadcasting.

## What Claude Code Gets Wrong By Default

1. **Implements manual conflict resolution.** Claude writes last-write-wins merge logic with timestamps. Yjs is a CRDT — conflicts are resolved automatically by the data structure itself. No merge logic needed.

2. **Broadcasts full document state.** Claude sends the entire document on every change. Yjs syncs incremental updates — small binary diffs that are much more efficient than full state broadcasts.

3. **Uses plain JavaScript objects for shared state.** Claude stores collaborative data in regular objects and syncs them via WebSocket. Yjs requires its own types: `Y.Map`, `Y.Array`, `Y.Text`, `Y.XmlFragment` for conflict-free collaboration.

4. **Creates a custom sync protocol.** Claude builds WebSocket message handling from scratch. Yjs provides `y-websocket` with a ready-to-use sync protocol and server implementation.

## The CLAUDE.md Configuration

```
# Yjs Collaborative Application

## CRDT Framework
- Library: Yjs (yjs package)
- Transport: y-websocket (WebSocket provider)
- Persistence: y-indexeddb (local) or database adapter
- Editor: TipTap with @tiptap/extension-collaboration

## Yjs Rules
- Shared types: Y.Doc, Y.Map, Y.Array, Y.Text, Y.XmlFragment
- Create doc: const ydoc = new Y.Doc()
- Shared map: ydoc.getMap('shared-state')
- Shared text: ydoc.getText('document')
- Provider: new WebsocketProvider('ws://...', 'room', ydoc)
- Observe changes: ymap.observe(event => { })
- Transactions: ydoc.transact(() => { batch changes })
- Never modify Y types outside transactions

## Conventions
- Y.Doc per collaborative document/room
- Provider handles sync — do not manually send updates
- Use awareness protocol for cursor/presence (provider.awareness)
- Persist with y-indexeddb for offline support
- Undo manager: new Y.UndoManager(sharedType)
- Binary encoding: Y.encodeStateAsUpdate(ydoc) for snapshots
- Subdocuments for large document hierarchies
```

## Workflow Example

You want to add collaborative rich text editing to your app. Prompt Claude Code:

"Add real-time collaborative editing to the document editor using Yjs and TipTap. Set up the Y.Doc with WebSocket sync, integrate TipTap's collaboration extension, add cursor awareness showing other users' positions, and enable offline persistence with IndexedDB."

Claude Code should create a `Y.Doc`, connect it with `WebsocketProvider`, configure TipTap with `Collaboration` and `CollaborationCursor` extensions bound to the Y.Doc, set up awareness for cursor sharing with user color and name, and add `IndexeddbPersistence` for offline support.

## Common Pitfalls

1. **Modifying Y types without transactions.** Claude sets values on Y.Map one at a time. Multiple changes should be wrapped in `ydoc.transact(() => { })` to batch them as a single update event, reducing network messages and observer calls.

2. **Memory leaks from unremoved observers.** Claude adds `ymap.observe()` but never calls `ymap.unobserve()` on cleanup. In React, clean up Yjs observers in the useEffect cleanup function to prevent memory leaks when components unmount.

3. **Awareness state not cleared on disconnect.** Claude sets awareness state but does not clear it when the user disconnects. Use `provider.on('status', ({ status }) => { if (status === 'disconnected') provider.awareness.setLocalState(null) })` to clean up presence data.

## Related Guides

- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
