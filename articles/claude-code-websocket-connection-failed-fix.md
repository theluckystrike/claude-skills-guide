---
layout: default
title: "Fix WebSocket Connection Failures"
description: "Resolve WebSocket connection failed errors in Claude Code projects. Debug WS handshake failures, proxy issues, and CORS configuration problems."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-websocket-connection-failed-fix/
reviewed: true
categories: [troubleshooting, claude-code]
tags: [websocket, connection, debugging, real-time, networking]
geo_optimized: true
last_tested: "2026-04-22"
---

# Fix WebSocket Connection Failures in Claude Code

## The Problem

Your application uses WebSockets and the connection fails with errors like:

```
WebSocket connection to 'ws://localhost:3001' failed:
Error during WebSocket handshake: Unexpected response code: 400
```

Or in your server logs:

```
Error: listen EADDRINUSE :::3001
WebSocket: Invalid frame header
```

You are using Claude Code to build or debug a real-time feature (chat, notifications, live updates) and the WebSocket connection refuses to establish.

## Quick Fix

Check the three most common causes:

```bash
# 1. Is the WS server running?
lsof -i :3001

# 2. Is the client connecting to the right URL?
grep -r "ws://" src/ --include="*.ts" --include="*.js"

# 3. Is a proxy interfering?
cat vite.config.ts # or next.config.js, webpack.config.js
```

If using a dev server with a proxy, add WebSocket proxy support:

```typescript
// vite.config.ts
export default defineConfig({
 server: {
 proxy: {
 '/ws': {
 target: 'ws://localhost:3001',
 ws: true,
 },
 },
 },
});
```

## What's Happening

WebSocket connections start as HTTP requests that "upgrade" to the WebSocket protocol. This upgrade handshake is where most failures occur. Common causes include:

1. **Missing upgrade handling**: The server does not handle the HTTP upgrade request
2. **Proxy stripping headers**: A reverse proxy or dev server strips the `Upgrade` and `Connection` headers
3. **CORS blocking**: The server rejects the WebSocket origin
4. **Port mismatch**: Client connects to the wrong port or the server is not listening
5. **SSL/TLS mismatch**: Using `ws://` when the page is served over HTTPS (requires `wss://`)

## Step-by-Step Fix

### Step 1: Verify the server setup

Ask Claude Code to review your WebSocket server configuration:

```
Check my WebSocket server setup. Make sure the upgrade handler is correct
and the server is listening on the expected port.
```

A correct Node.js WebSocket server looks like:

```typescript
import { WebSocketServer } from 'ws';
import { createServer } from 'http';

const server = createServer();
const wss = new WebSocketServer({ server });

wss.on('connection', (ws) => {
 console.log('Client connected');

 ws.on('message', (data) => {
 console.log('Received:', data.toString());
 ws.send(JSON.stringify({ echo: data.toString() }));
 });

 ws.on('close', () => {
 console.log('Client disconnected');
 });
});

server.listen(3001, () => {
 console.log('WebSocket server running on port 3001');
});
```

### Step 2: Fix the client connection

Ensure the client uses the correct URL and handles errors:

```typescript
function createWebSocket(): WebSocket {
 const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
 const wsUrl = `${protocol}//${window.location.host}/ws`;

 const ws = new WebSocket(wsUrl);

 ws.onopen = () => {
 console.log('WebSocket connected');
 };

 ws.onerror = (error) => {
 console.error('WebSocket error:', error);
 };

 ws.onclose = (event) => {
 console.log(`WebSocket closed: code=${event.code} reason=${event.reason}`);
 // Reconnect after delay
 setTimeout(() => createWebSocket(), 3000);
 };

 return ws;
}
```

### Step 3: Configure proxy for development

During development, your frontend dev server proxies API requests but may not proxy WebSocket connections by default.

**Vite:**

```typescript
// vite.config.ts
export default defineConfig({
 server: {
 proxy: {
 '/api': 'http://localhost:3001',
 '/ws': {
 target: 'ws://localhost:3001',
 ws: true,
 changeOrigin: true,
 },
 },
 },
});
```

**Next.js:**

```javascript
// next.config.js
module.exports = {
 async rewrites() {
 return [
 {
 source: '/ws',
 destination: 'http://localhost:3001/ws',
 },
 ];
 },
};
```

Note: Next.js rewrites do not support WebSocket upgrade. For development, connect directly to the WebSocket server port or use a custom server.

**webpack-dev-server:**

```javascript
devServer: {
 proxy: [{
 context: ['/ws'],
 target: 'ws://localhost:3001',
 ws: true,
 }],
},
```

### Step 4: Handle CORS for WebSocket

WebSockets do not use CORS in the traditional sense (no preflight requests), but servers can check the `Origin` header during the handshake:

```typescript
const wss = new WebSocketServer({
 server,
 verifyClient: (info) => {
 const origin = info.origin || info.req.headers.origin;
 const allowedOrigins = [
 'http://localhost:5173',
 'http://localhost:3000',
 'https://yourdomain.com',
 ];
 return allowedOrigins.includes(origin);
 },
});
```

### Step 5: Fix SSL/TLS issues

If your page loads over HTTPS, the browser requires `wss://` for WebSocket connections. Mixed content (HTTPS page + WS connection) is blocked:

```typescript
// Wrong - will fail on HTTPS pages
const ws = new WebSocket('ws://api.example.com/ws');

// Correct - use wss:// for HTTPS pages
const ws = new WebSocket('wss://api.example.com/ws');

// Best - auto-detect protocol
const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
const ws = new WebSocket(`${protocol}//${window.location.host}/ws`);
```

### Step 6: Add reconnection logic

WebSocket connections drop. Production code needs automatic reconnection:

```typescript
class ReconnectingWebSocket {
 private ws: WebSocket | null = null;
 private reconnectAttempts = 0;
 private maxReconnectAttempts = 10;
 private baseDelay = 1000;

 constructor(private url: string) {
 this.connect();
 }

 private connect(): void {
 this.ws = new WebSocket(this.url);

 this.ws.onopen = () => {
 this.reconnectAttempts = 0;
 };

 this.ws.onclose = () => {
 if (this.reconnectAttempts < this.maxReconnectAttempts) {
 const delay = this.baseDelay * Math.pow(2, this.reconnectAttempts);
 this.reconnectAttempts++;
 setTimeout(() => this.connect(), delay);
 }
 };
 }
}
```

## Prevention

Ask Claude Code to set up WebSocket infrastructure with error handling from the start:

```
Set up a WebSocket server with:
- Health check endpoint at /health
- Automatic heartbeat/ping-pong to detect dead connections
- Graceful shutdown handling
- Connection logging
- Client reconnection with exponential backoff
```

Test WebSocket connections with `wscat` before integrating with your frontend:

```bash
npx wscat -c ws://localhost:3001/ws
```

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-websocket-connection-failed-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---

## Related Guides

- [Claude Code Error Connection Refused Localhost Fix](/claude-code-error-connection-refused-localhost-fix/)
- [Claude Code Error Connection Timeout During Task Fix](/claude-code-error-connection-timeout-during-task-fix/)
- [Claude Code Context Window Management Guide](/claude-code-context-window-management-guide/)

## See Also

- [WebSocket Upgrade Rejected Error — Fix (2026)](/claude-code-websocket-upgrade-rejected-fix-2026/)
- [HTTP/2 Stream Error During Request -- Fix (2026)](/claude-code-http2-stream-error-fix-2026/)
