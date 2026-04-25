---

layout: default
title: "Claude Code Server-Sent Events API"
description: "A practical guide to implementing Server-Sent Events (SSE) with Claude Code. Learn how to build real-time streaming features using event-driven."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
author: theluckystrike
permalink: /claude-code-server-sent-events-api-guide/
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Server-Sent Events (SSE) provide a simple, standards-based way to push real-time updates from a server to a client over HTTP. Unlike WebSockets, SSE works over a single persistent connection and automatically handles reconnection, making it ideal for streaming logs, live dashboards, and notification systems. This guide shows you how to implement SSE with Claude Code, with practical examples you can apply to your projects.

## How Server-Sent Events Work

SSE relies on the `Content-Type: text/event-stream` header. The server sends events in a specific format:

```
data: {"message": "processing"}

data: {"message": "complete"}
event: done
```

Each event consists of optional fields: `event`, `data`, `id`, and `retry`. The `data` field contains your payload, and the `event` field lets you name events for routing on the client. A blank line separates events. this double newline is the signal to the browser that one event has ended and the next can begin.

The protocol is intentionally minimal. A fully-formed SSE event with all optional fields looks like this:

```
id: 42
event: progress
data: {"percent": 75, "stage": "indexing"}
retry: 3000

```

- `id` allows the server to track which events a client has received; if the connection drops, the client sends the last known ID via the `Last-Event-ID` header on reconnect
- `retry` tells the browser how many milliseconds to wait before reconnecting after a failure
- `event` names the event type for client-side routing
- `data` carries your payload. multiple `data:` lines are concatenated with a newline before delivery

## SSE vs. WebSockets vs. Long Polling

Before committing to SSE, understand where it fits among competing real-time approaches:

| Feature | SSE | WebSockets | Long Polling |
|---|---|---|---|
| Direction | Server to client only | Bidirectional | Server to client (simulated) |
| Protocol | HTTP | ws:// or wss:// | HTTP |
| Auto-reconnect | Built-in | Manual | Manual |
| Browser support | All modern browsers | All modern browsers | All browsers |
| Proxy/firewall friendly | Yes (standard HTTP) | Sometimes problematic | Yes |
| Multiplexing | Single connection per stream | Single connection, full duplex | New request per poll |
| Overhead | Low | Very low | High |
| Best for | Logs, notifications, AI responses | Chat, games, collaborative editing | Legacy environments |

SSE is the right choice when data flows in one direction only. from server to client. If your application also needs to push messages from client to server in real time (for example, a live collaborative editor), reach for WebSockets instead.

## Basic Server Implementation

Create a simple SSE endpoint using any backend framework. Here's a Python Flask example:

```python
from flask import Flask, Response, stream_with_context
import time

app = Flask(__name__)

@app.route('/stream')
def stream():
 def generate():
 for i in range(10):
 yield f"data: {i}\n\n"
 time.sleep(1)

 return Response(generate(), mimetype='text/event-stream')
```

The `yield` pattern streams each message immediately rather than waiting for the full response. For production use with the pdf skill or other document processing workflows, you might stream progress updates as files are processed.

## Node.js / Express Implementation

If your stack is Node.js, the pattern is equally straightforward:

```javascript
const express = require('express');
const app = express();

app.get('/stream', (req, res) => {
 res.setHeader('Content-Type', 'text/event-stream');
 res.setHeader('Cache-Control', 'no-cache');
 res.setHeader('Connection', 'keep-alive');

 const sendEvent = (eventName, data) => {
 res.write(`event: ${eventName}\n`);
 res.write(`data: ${JSON.stringify(data)}\n\n`);
 };

 // Send a heartbeat every 15 seconds to keep the connection alive
 const heartbeat = setInterval(() => {
 res.write(': heartbeat\n\n'); // Comment line. browsers ignore it
 }, 15000);

 // Send some data
 sendEvent('status', { stage: 'started' });
 setTimeout(() => sendEvent('progress', { percent: 50 }), 1000);
 setTimeout(() => {
 sendEvent('complete', { result: 'done' });
 clearInterval(heartbeat);
 res.end();
 }, 2000);

 req.on('close', () => {
 clearInterval(heartbeat);
 });
});
```

Note the `Cache-Control: no-cache` header. without it, intermediary proxies can buffer your stream, destroying the real-time behavior. The comment line (`: heartbeat`) is a common technique to prevent idle connection timeouts on load balancers and CDNs that aggressively close quiet connections.

## Client-Side Consumption

On the client side, use the native `EventSource` API:

```javascript
const source = new EventSource('/stream');

source.onmessage = (event) => {
 console.log('Received:', event.data);
};

source.addEventListener('progress', (event) => {
 updateProgressBar(JSON.parse(event.data));
});

source.onerror = () => {
 console.log('Connection lost, reconnecting...');
};
```

The `EventSource` API automatically handles reconnection and sends the last event ID, allowing your server to resume from where the connection dropped. This makes SSE particularly reliable for long-running operations.

## Handling Authenticated Endpoints

A significant limitation of the native `EventSource` API is that it does not support custom request headers, which makes authenticated endpoints tricky. There are two practical workarounds.

Option 1. Pass tokens as query parameters (simple but leaks tokens into logs):

```javascript
const token = localStorage.getItem('auth_token');
const source = new EventSource(`/stream?token=${token}`);
```

Option 2. Use `fetch` with a `ReadableStream` (recommended for production):

```javascript
async function connectToStream(token) {
 const response = await fetch('/stream', {
 headers: {
 'Authorization': `Bearer ${token}`,
 'Accept': 'text/event-stream'
 }
 });

 if (!response.ok) throw new Error(`HTTP ${response.status}`);

 const reader = response.body.getReader();
 const decoder = new TextDecoder();
 let buffer = '';

 while (true) {
 const { done, value } = await reader.read();
 if (done) break;

 buffer += decoder.decode(value, { stream: true });

 // Split on double newline (event boundary)
 const parts = buffer.split('\n\n');
 buffer = parts.pop(); // Keep incomplete last part

 for (const part of parts) {
 const dataLine = part.split('\n').find(l => l.startsWith('data:'));
 if (dataLine) {
 const payload = JSON.parse(dataLine.slice(5).trim());
 handleEvent(payload);
 }
 }
 }
}
```

This approach gives you full control over headers, including `Authorization`, `X-Request-ID`, and any other custom headers your API requires.

## Combining SSE with Claude Skills

When building AI-powered applications with Claude Code, SSE becomes valuable for streaming responses. Many Claude skills work well with streaming architectures:

- The webapp-testing skill can validate SSE endpoints, checking that connections open correctly and events stream as expected
- The tdd skill helps you write integration tests for your streaming endpoints, ensuring events fire in the correct order
- The frontend-design skill can suggest UI patterns for displaying real-time updates from SSE streams

Here's how you might stream Claude Code responses to a client:

```javascript
async function streamClaudeResponse(prompt) {
 const response = await fetch('/api/claude/stream', {
 method: 'POST',
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify({ prompt })
 });

 const reader = response.body.getReader();
 const decoder = new TextDecoder();

 while (true) {
 const { done, value } = await reader.read();
 if (done) break;

 const chunk = decoder.decode(value);
 // Parse SSE format and append to UI
 displayChunk(chunk);
 }
}
```

## Streaming AI Responses in Practice

A complete server-side handler that proxies a streaming AI response to an SSE client looks like this in Python:

```python
import anthropic
from flask import Flask, Response, request

app = Flask(__name__)
client = anthropic.Anthropic()

@app.route('/api/claude/stream', methods=['POST'])
def claude_stream():
 prompt = request.json.get('prompt', '')

 def generate():
 with client.messages.stream(
 model="claude-opus-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": prompt}]
 ) as stream:
 for text in stream.text_stream:
 # Escape newlines in JSON payload so SSE parser doesn't split on them
 import json
 yield f"data: {json.dumps({'text': text})}\n\n"
 yield "event: done\ndata: {}\n\n"

 return Response(generate(), mimetype='text/event-stream',
 headers={'Cache-Control': 'no-cache'})
```

The client side then renders tokens as they arrive, giving users the familiar typewriter-style experience rather than waiting for a full response.

## Event Routing and Filtering

For complex applications, use named events to route messages to different handlers:

```python
@app.route('/updates')
def updates():
 def generate():
 # Send status updates
 yield "event: status\ndata: {\"stage\": \"loading\"}\n\n"

 # Send progress
 for i in range(100):
 yield f"event: progress\ndata: {i}\n\n"

 # Send completion
 yield "event: complete\ndata: {}\n\n"

 return Response(generate(), mimetype='text/event-stream')
```

Client-side routing:

```javascript
source.addEventListener('status', (e) => updateStatus(e.data));
source.addEventListener('progress', (e) => updateProgress(e.data));
source.addEventListener('complete', (e) => finishTask(e.data));
```

This pattern keeps your client code organized when multiple event types flow through a single connection. Compare this to the alternative of embedding a `type` field in every message and running a switch statement in `onmessage`. named events produce cleaner, more maintainable code with no runtime dispatch logic.

## Error Handling and Reconnection

SSE handles reconnection automatically, but you should implement graceful degradation:

```javascript
source.onerror = (error) => {
 if (source.readyState === EventSource.CLOSED) {
 // Manual reconnect after delay
 setTimeout(() => {
 source = new EventSource('/stream');
 }, 5000);
 }
};
```

For critical applications, the supermemory skill can help you track connection health metrics and alert you when streams fail unexpectedly.

## Server-Side Reconnection Support

When a client reconnects, it sends the `Last-Event-ID` header. Your server should honor it:

```python
from flask import request

@app.route('/stream')
def stream():
 last_event_id = request.headers.get('Last-Event-ID', '0')
 start_from = int(last_event_id)

 def generate():
 event_id = start_from
 for item in get_events_since(event_id):
 event_id += 1
 yield f"id: {event_id}\ndata: {item}\n\n"

 return Response(generate(), mimetype='text/event-stream')
```

This pattern ensures no events are lost during network hiccups, which is critical for audit logs, progress tracking, and notification systems where gaps in the event stream cause user confusion.

## Performance Considerations

SSE connections consume server resources. For high-traffic applications:

- Limit concurrent connections per user
- Implement connection timeouts and periodic heartbeats
- Use a message queue to decouple event generation from delivery

```python
import redis

@app.route('/stream')
def stream():
 pubsub = redis.pubsub()
 pubsub.subscribe('updates')

 for message in pubsub.listen():
 if message['type'] == 'message':
 yield f"data: {message['data']}\n\n"
```

This Redis-backed approach scales horizontally and handles thousands of simultaneous connections efficiently.

## Connection Limits and Load Testing

Before shipping, load-test your SSE endpoint. Each open SSE connection holds a file descriptor, an open socket, and server memory for the response buffer. A naive Flask development server will buckle under a few hundred simultaneous connections. For production:

- Use an async server like `gunicorn` with `gevent` workers or `uvicorn` with FastAPI
- Set a maximum connection lifetime (for example, close and reopen after 30 minutes) to prevent resource leaks from clients that never disconnect cleanly
- Route SSE traffic through nginx with `proxy_buffering off`. without this, nginx will buffer your stream and clients will never see events

```nginx
location /stream {
 proxy_pass http://backend;
 proxy_buffering off;
 proxy_cache off;
 proxy_set_header Connection '';
 proxy_http_version 1.1;
 chunked_transfer_encoding on;
}
```

## Testing Your SSE Endpoints

Use the tdd skill to write comprehensive tests for your streaming endpoints:

```python
def test_sse_endpoint():
 response = client.get('/stream')

 assert response.status_code == 200
 assert response.content_type == 'text/event-stream'

 # Read streamed content
 lines = response.response
 assert any(b'data:' in line for line in lines)
```

The webapp-testing skill can also validate SSE behavior in browser environments, checking that events arrive within expected timeframes and that reconnection works after network interruptions.

## Integration Test with Timing Assertions

For production confidence, test not just that events arrive but that they arrive on schedule:

```python
import time
import threading

def test_sse_event_timing():
 received = []
 def collect(client):
 for event in client.get('/stream', stream=True):
 received.append((event.data, time.time()))

 t = threading.Thread(target=collect, args=(client,))
 t.start()
 t.join(timeout=15)

 assert len(received) >= 3
 # Events should arrive roughly 1 second apart
 gaps = [received[i+1][1] - received[i][1] for i in range(len(received)-1)]
 assert all(0.8 < g < 1.5 for g in gaps)
```

## Conclusion

Server-Sent Events offer a straightforward solution for real-time streaming in web applications. The protocol is simple, works natively in browsers, and handles reconnection automatically. By combining SSE with Claude Code skills like tdd, webapp-testing, frontend-design, and supermemory, you can build solid real-time features while maintaining code quality and user experience.

Whether you're streaming AI responses, live logs, or notification updates, SSE provides a reliable foundation that integrates well with modern development workflows. The key operational details. cache control headers, nginx buffering configuration, authenticated fetch streams, and reconnection ID tracking. are where most real-world SSE implementations succeed or fail. Get those details right from the start and SSE will serve you well at scale.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-server-sent-events-api-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- Claude Code WebSocket API Implementation
- [Claude Code gRPC API Development Guide](/claude-code-grpc-api-development-guide/)
- [Claude Code REST API Design Best Practices](/claude-code-rest-api-design-best-practices/)
- [Claude Skills Integrations Hub](/integrations-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


