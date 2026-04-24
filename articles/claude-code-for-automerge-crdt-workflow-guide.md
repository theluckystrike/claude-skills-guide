---
layout: default
title: "Claude Code for Automerge CRDT"
description: "Build real-time collaboration with Automerge and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-automerge-crdt-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, automerge, workflow]
---

## The Setup

You are building collaborative applications with Automerge, a CRDT (Conflict-free Replicated Data Type) library for building local-first software. Automerge lets multiple users edit the same data simultaneously without a central server — changes merge automatically without conflicts. Claude Code can implement real-time collaboration, but it generates WebSocket-based operational transform code instead of Automerge's CRDT approach.

## What Claude Code Gets Wrong By Default

1. **Creates WebSocket server for synchronization.** Claude builds a central WebSocket server that broadcasts changes. Automerge is peer-to-peer capable — changes are encoded as binary messages that can sync over any transport, not just WebSockets.

2. **Implements operational transform logic.** Claude writes custom conflict resolution with OT algorithms. Automerge handles conflict resolution automatically using CRDTs — there are no conflicts to resolve manually.

3. **Uses a central database as source of truth.** Claude writes to PostgreSQL and broadcasts updates. Automerge documents are the source of truth — each client has a full copy, and changes merge regardless of network conditions.

4. **Stores data as JSON snapshots.** Claude saves the entire state as JSON on every change. Automerge has its own binary format with incremental changes — save the Automerge document, not JSON snapshots.

## The CLAUDE.md Configuration

```
# Automerge Collaboration Project

## Data Layer
- Library: Automerge (CRDT for local-first apps)
- Sync: peer-to-peer, any transport
- Conflicts: automatic resolution (no manual merge)
- Storage: binary Automerge documents

## Automerge Rules
- Document: Automerge.init() or Automerge.from(data)
- Change: Automerge.change(doc, d => { d.field = value })
- Merge: Automerge.merge(doc1, doc2)
- Sync: generateSyncMessage/receiveSyncMessage protocol
- Save: Automerge.save(doc) returns binary
- Load: Automerge.load(binary) restores document
- History: Automerge.getHistory(doc) for change log

## Conventions
- Initialize document with schema shape
- Changes wrapped in Automerge.change callback
- Use sync protocol for network transfer
- Store Automerge binary, not JSON
- Handle connection/disconnection gracefully
- Use automerge-repo for high-level networking
- Each document has a URL-like identifier
```

## Workflow Example

You want to build a collaborative text editor with offline support. Prompt Claude Code:

"Create a collaborative text editor using Automerge with automerge-repo for networking. Support multiple users editing simultaneously, automatic merge of offline changes when reconnecting, and persistent storage using IndexedDB. Use React for the UI."

Claude Code should create an Automerge Repo with IndexedDB storage adapter, a `BrowserWebSocketClientAdapter` for networking, a React component that renders the document text, change handlers that call `doc.text.insertAt()` and `doc.text.deleteAt()`, and handle reconnection by letting Automerge sync protocol merge divergent changes.

## Common Pitfalls

1. **Mutating Automerge documents directly.** Claude writes `doc.title = "New"` outside of `Automerge.change()`. Automerge documents are immutable — all changes must go through the change callback to track operations properly.

2. **Not using automerge-repo for networking.** Claude implements raw sync protocol manually. The `automerge-repo` library handles connection management, storage, and synchronization — building raw sync is error-prone and unnecessary.

3. **Storing large binary blobs in documents.** Claude puts images and files in Automerge documents. CRDTs track every change — large binary data inflates the change history. Store file references in Automerge and files in a separate blob store.

## Related Guides

- [Claude Code for Yjs CRDT Workflow Guide](/claude-code-for-yjs-crdt-workflow-guide/)
- [Claude Code for Liveblocks Collab Workflow Guide](/claude-code-for-liveblocks-collab-workflow-guide/)
- [Claude Code for PowerSync Offline Workflow Guide](/claude-code-for-powersync-offline-workflow-guide/)
