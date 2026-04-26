---
layout: default
title: "Claude Code Firebase MCP Integration (2026)"
description: "Connect Claude Code to Firebase through MCP for direct Firestore queries, auth management, and Cloud Functions debugging from your terminal."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-firebase-mcp/
categories: [guides]
tags: [claude-code, claude-skills, firebase, mcp, firestore]
reviewed: true
score: 7
geo_optimized: true
---

Integrating Firebase with Claude Code through MCP gives Claude direct access to Firestore documents, Authentication records, and Cloud Functions logs. Instead of switching between the Firebase Console and your editor, Claude can query your database, check auth states, and debug function errors right from the terminal.

## The Problem

Firebase developers constantly switch between the Firebase Console, the CLI, and their code editor. When debugging a Firestore query that returns unexpected results or a Cloud Function that fails silently, you end up copy-pasting data between tools. Claude Code can read your source files, but without MCP it cannot see your live Firebase data or logs.

## Quick Solution

1. Install the Firebase MCP dependencies:

```bash
npm install -g firebase-tools
pip install mcp firebase-admin
```

2. Initialize your Firebase Admin SDK credentials:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

3. Create `firebase_mcp.py`:

```python
from mcp.server.fastmcp import FastMCP
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)
db = firestore.client()

mcp = FastMCP("firebase-tools")

@mcp.tool()
def query_collection(collection: str, limit: int = 10) -> str:
    """Query a Firestore collection and return documents."""
    docs = db.collection(collection).limit(limit).stream()
    results = []
    for doc in docs:
        results.append(f"{doc.id}: {doc.to_dict()}")
    return "\n".join(results) if results else "No documents found."

@mcp.tool()
def get_document(collection: str, doc_id: str) -> str:
    """Get a specific Firestore document by ID."""
    doc = db.collection(collection).document(doc_id).get()
    if doc.exists:
        return f"{doc.id}: {doc.to_dict()}"
    return "Document not found."
```

4. Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "firebase-tools": {
      "command": "python",
      "args": ["firebase_mcp.py"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/path/to/service-account.json"
      }
    }
  }
}
```

5. Launch Claude Code and ask it to query your Firestore collections.

## How It Works

The Firebase Admin SDK connects to your Firebase project using a service account, giving it server-level access to Firestore, Authentication, and other services. The MCP server wraps these capabilities as tools that Claude Code can invoke.

When Claude needs to debug a query, it calls the `query_collection` tool to see actual data. This eliminates the guesswork of reading Firestore rules and query code without seeing real documents. The `get_document` tool lets Claude fetch specific records by ID for targeted debugging.

CLAUDE.md should document your Firestore data model so Claude understands collection names, document structures, and security rules context. This helps Claude write better queries and suggest fixes aligned with your schema.

## Common Issues

**Service account permissions error.** Ensure your service account has the `Cloud Datastore User` role in Google Cloud IAM. The default Firebase Admin SDK service account has this, but custom accounts may not.

**MCP server crashes on startup.** The `firebase-admin` package requires `google-cloud-firestore`, which has native dependencies. If installation fails, try `pip install firebase-admin --no-binary :all:` or use a virtual environment with Python 3.10+.

**Stale data after writes.** Firestore reads through the Admin SDK are strongly consistent for document reads but eventually consistent for queries. If Claude writes a document and immediately queries the collection, the document may not appear. Add a small delay or use `get_document` directly.

## Example CLAUDE.md Section

```markdown
# Firebase Project

## Stack
- Frontend: Next.js 14 with Firebase JS SDK
- Backend: Cloud Functions (Node.js 20)
- Database: Firestore (Native mode)
- Auth: Firebase Authentication (email + Google)

## Firestore Collections
- users/{uid} — profile data, settings
- posts/{postId} — content, authorUid, createdAt
- comments/{commentId} — postId, authorUid, text

## MCP Tools
- query_collection: Read documents (read-only)
- get_document: Fetch by ID (read-only)

## Rules
- Never write to production Firestore from MCP tools
- Use emulator for write operations: firebase emulators:start
- Security rules are in firestore.rules
- Cloud Functions code is in functions/ directory
```

## Best Practices

- **Use read-only MCP tools for production** and restrict write operations to the Firebase Emulator Suite. This prevents accidental data mutations during development.
- **Add collection-specific query tools** rather than one generic tool. A `query_users` tool that returns formatted user profiles is more useful to Claude than raw document dumps.
- **Set Firestore read limits** in every MCP tool to prevent accidentally streaming thousands of documents. Always default to `limit=10`.
- **Document your security rules** in CLAUDE.md so Claude can suggest query patterns that work within your access control model.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-firebase-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)
- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


## Common Questions

### How do I get started with claude code firebase mcp integration?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Resources

- [Claude Code + Linear MCP Integration](/claude-code-linear-mcp-integration-2026/)
- [MCP Integration Guide for Claude Code](/mcp-integration-guide-for-claude-code-beginners/)
- [Best Claude Code MCP Integrations](/best-claude-code-mcp-integrations-2026/)
