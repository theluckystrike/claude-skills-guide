---
layout: default
title: "Claude Code Server Sent Events API Guide"
description: "A practical guide to building and consuming Server-Sent Events APIs with Claude Code. Includes code examples, real-world patterns, and integration tips."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-server-sent-events-api-guide/
---

# Claude Code Server Sent Events API Guide

Server-Sent Events (SSE) provide a simple way to push real-time updates from a server to a client over HTTP. Unlike WebSockets, SSE works over a single bidirectional connection and automatically handles reconnection. This guide shows you how to build and consume SSE endpoints using Claude Code, with practical examples and patterns you can apply to your projects.

## What Are Server-Sent Events

Server-Sent Events allow a server to send data to a client automatically. The client establishes a connection once, and the server pushes updates as they occur. The browser automatically reconnects if the connection drops, making SSE ideal for live dashboards, notifications, and streaming data feeds.

The key advantages of SSE over WebSockets include simpler implementation, built-in reconnection, and compatibility with HTTP/2. The tradeoff is that SSE is one-way—data flows only from server to client.

## Building an SSE Endpoint

Creating an SSE endpoint requires setting the correct content type and formatting messages according to the SSE specification. Here is a basic Express.js endpoint:

```javascript
app.get('/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  const sendEvent = (data) => {
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };

  // Send initial data
  sendEvent({ type: 'connected', timestamp: Date.now() });

  // Simulate periodic updates
  const interval = setInterval(() => {
    sendEvent({ 
      type: 'update', 
      message: 'New data available',
      timestamp: Date.now() 
    });
  }, 5000);

  req.on('close', () => {
    clearInterval(interval);
    res.end();
  });
});
```

This endpoint sends a connection confirmation followed by updates every five seconds. The double newline after each message is critical—it signals the end of an event to the browser.

## Consuming SSE in the Browser

On the client side, the EventSource API provides a straightforward way to receive SSE:

```javascript
const eventSource = new EventSource('/events');

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Received:', data);
  
  if (data.type === 'update') {
    updateDashboard(data);
  }
};

eventSource.onerror = (error) => {
  console.error('SSE connection error:', error);
  eventSource.close();
};
```

The EventSource automatically handles reconnection. If the server returns a custom event, you can listen for it specifically using `eventSource.addEventListener('eventName', handler)`.

## Using Claude Code with SSE Projects

When working on SSE implementations, Claude Code accelerates development through several approaches. The `/tdd` skill helps you write tests before implementing endpoints:

```
/tdd
Create tests for an SSE endpoint that streams log updates. Test connection handling, message formatting, and cleanup on disconnect.
```

The tests will verify that your endpoint sends properly formatted events and cleans up resources when clients disconnect.

For frontend components that display streaming data, the `/frontend-design` skill generates appropriate UI patterns:

```
/frontend-design
Create a dashboard component that displays live updates from an EventSource. Include a connection status indicator and a scrolling log viewer.
```

The skill produces clean, responsive code following current best practices.

## Handling Authentication

SSE endpoints often need authentication. Pass tokens via query parameters or headers:

```javascript
app.get('/events', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token || !validateToken(token)) {
    return res.status(401).end();
  }

  res.setHeader('Content-Type', 'text/event-stream');
  // ... rest of handler
});
```

For the client, include credentials in the EventSource initialization:

```javascript
const eventSource = new EventSource('/events?token=your-jwt-token');
```

Be cautious with tokens in URLs. For production, consider using cookies with the `withCredentials` flag:

```javascript
const eventSource = new EventSource('/events', {
  withCredentials: true
});
```

## Error Handling and Retry Logic

The SSE specification supports custom retry intervals. Set a retry timeout on the server:

```javascript
res.write(`retry: 3000\n\n`);
```

This tells the client to wait three seconds before attempting to reconnect after a disconnect. You can dynamically adjust this based on server load:

```javascript
const retryMs = serverBusy ? 10000 : 3000;
res.write(`retry: ${retryMs}\n\n`);
```

On the client, listen for error events to implement custom recovery logic:

```javascript
eventSource.addEventListener('error', (event) => {
  if (event.readyState === EventSource.CLOSED) {
    console.log('Connection closed, attempting reconnect...');
  }
});
```

## Integrating with Claude Skills Workflow

Combine multiple skills for a complete SSE development workflow. Use `/tdd` for test-driven endpoint development, `/frontend-design` for streaming UI components, and `/pdf` to generate API documentation:

```
/pdf
Generate API documentation for our SSE endpoints including connection setup, event types, and error handling.
```

Store connection patterns and troubleshooting notes in `/supermemory` for team reference:

```
/supermemory
Remember that our production SSE endpoint requires a valid JWT token and sends retry: 5000 on server errors.
```

This creates a searchable knowledge base of your SSE implementation details.

## Common Pitfalls

Several issues frequently arise with SSE implementations. First, always include the double newline (`\n\n`) after each message—without it, the browser waits indefinitely for more data. Second, remember that EventSource only works over HTTP/1.1 by default; HTTP/2 support varies by browser. Third, server proxies such as Nginx require configuration to support long-lived connections:

```nginx
location /events {
  proxy_pass http://backend;
  proxy_http_version 1.1;
  proxy_set_header Connection '';
  proxy_cache off;
}
```

Fourth, avoid sending large amounts of data in each event. Chunk data into manageable pieces for smoother streaming.

## Testing SSE Endpoints

Automated testing of SSE requires checking both the initial connection and the event stream. Here is a Node.js test example:

```javascript
const http = require('http');

test('SSE endpoint sends events', (done) => {
  const req = http.get('/events', (res) => {
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/event-stream');
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
      if (data.includes('data:')) {
        const event = JSON.parse(data.match(/data: (.+)/)[1]);
        expect(event.type).toBe('connected');
        req.destroy();
        done();
      }
    });
  });
});
```

Use the `/tdd` skill to generate comprehensive test suites covering connection handling, event formatting, authentication, and cleanup.

## Conclusion

Server-Sent Events provide a lightweight solution for server-to-client streaming. The pattern works especially well when you need reliable, automatic reconnection without the complexity of WebSockets. Claude Code streamlines SSE development through the `/tdd`, `/frontend-design`, `/pdf`, and `/supermemory` skills, helping you build, test, document, and maintain streaming functionality efficiently.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
