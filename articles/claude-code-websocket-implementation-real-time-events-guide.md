---
layout: default
title: "Claude Code WebSocket Implementation: Real-Time Events Guide"
description: "How to use Claude Code to implement WebSocket connections for real-time event handling. Covers server setup, client integration, and error handling patterns."
date: 2026-03-14
categories: [guides]
tags: [claude-code, websocket, real-time, backend]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-websocket-implementation-real-time-events-guide/
---

# Claude Code WebSocket Implementation: Real-Time Events Guide

WebSockets enable true bidirectional communication between clients and servers, making them essential for real-time applications. Unlike traditional HTTP polling, WebSockets maintain a persistent connection, allowing instant event propagation with minimal latency and reduced bandwidth consumption. This guide walks you through implementing production-ready WebSocket systems using Claude Code.

## Why WebSockets Over HTTP Polling

HTTP polling creates a new connection for every data request, wasting bandwidth and creating artificial delays. You typically set a polling interval—5 seconds, 10 seconds, or longer—which means users experience stale data between requests. For every poll, the server processes the request even if nothing has changed.

WebSockets solve this by establishing a single persistent connection. The server pushes updates instantly whenever events occur. This approach is vastly more efficient for applications requiring live notifications, collaborative editing, real-time dashboards, gaming, or chat systems. The initial WebSocket handshake uses standard HTTP, making it compatible with existing infrastructure and proxies.

The trade-off is slightly increased server complexity. You need to manage persistent connections, handle reconnections gracefully, and broadcast messages to multiple clients efficiently. Claude Code excels at generating this infrastructure code.

## Setting Up a WebSocket Server

Here's a production-ready WebSocket server using Node.js with the `ws` library:

```javascript
const WebSocket = require('ws');
const http = require('http');
const EventEmitter = require('events');

class WebSocketServer extends EventEmitter {
  constructor(port = 8080) {
    super();
    this.server = http.createServer();
    this.wss = new WebSocket.Server({ server: this.server });
    this.clients = new Set();
    this.port = port;
    this.setupHandlers();
  }

  setupHandlers() {
    this.wss.on('connection', (ws) => {
      console.log('Client connected');
      this.clients.add(ws);

      ws.on('message', (data) => {
        try {
          const message = JSON.parse(data);
          this.handleMessage(ws, message);
        } catch (error) {
          console.error('Invalid message format:', error);
          ws.send(JSON.stringify({
            type: 'error',
            message: 'Invalid message format'
          }));
        }
      });

      ws.on('close', () => {
        console.log('Client disconnected');
        this.clients.delete(ws);
        this.emit('clientDisconnected');
      });

      ws.on('error', (error) => {
        console.error('WebSocket error:', error);
        this.clients.delete(ws);
      });
    });
  }

  handleMessage(ws, message) {
    const { type, payload } = message;

    if (type === 'subscribe') {
      ws.userId = payload.userId;
      ws.topics = payload.topics || [];
      ws.send(JSON.stringify({ type: 'subscribed', topics: ws.topics }));
    } else if (type === 'unsubscribe') {
      ws.topics = ws.topics.filter(t => t !== payload.topic);
    } else {
      this.emit('message', { sender: ws, type, payload });
    }
  }

  broadcast(message, filter = null) {
    const data = JSON.stringify(message);
    this.clients.forEach((client) => {
      if (!filter || filter(client)) {
        if (client.readyState === WebSocket.OPEN) {
          client.send(data);
        }
      }
    });
  }

  broadcastToTopic(topic, message) {
    this.broadcast(message, (client) =>
      client.topics && client.topics.includes(topic)
    );
  }

  start() {
    this.server.listen(this.port, () => {
      console.log(`WebSocket server running on port ${this.port}`);
    });
  }

  stop() {
    this.wss.clients.forEach(client => client.close());
    this.server.close();
  }
}

module.exports = WebSocketServer;
```

This server handles client connections, message parsing, topic subscriptions, and targeted broadcasting. The `Set` data structure efficiently tracks active connections.

## Client Connection Handling

WebSocket clients need robust connection management, including automatic reconnection on failure:

```javascript
class WebSocketClient {
  constructor(url, options = {}) {
    this.url = url;
    this.maxRetries = options.maxRetries || 5;
    this.retryDelay = options.retryDelay || 3000;
    this.retryAttempts = 0;
    this.ws = null;
    this.messageQueue = [];
    this.listeners = {};
    this.heartbeatInterval = options.heartbeatInterval || 30000;
  }

  connect() {
    return new Promise((resolve, reject) => {
      try {
        this.ws = new WebSocket(this.url);

        this.ws.onopen = () => {
          console.log('Connected to WebSocket');
          this.retryAttempts = 0;
          this.flushMessageQueue();
          this.startHeartbeat();
          this.emit('connect');
          resolve();
        };

        this.ws.onmessage = (event) => {
          try {
            const message = JSON.parse(event.data);
            this.handleMessage(message);
          } catch (error) {
            console.error('Failed to parse message:', error);
          }
        };

        this.ws.onerror = (error) => {
          console.error('WebSocket error:', error);
          this.emit('error', error);
          reject(error);
        };

        this.ws.onclose = () => {
          console.log('Disconnected from WebSocket');
          this.stopHeartbeat();
          this.emit('disconnect');
          this.attemptReconnect();
        };
      } catch (error) {
        reject(error);
      }
    });
  }

  send(message) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    } else {
      this.messageQueue.push(message);
    }
  }

  flushMessageQueue() {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      this.send(message);
    }
  }

  attemptReconnect() {
    if (this.retryAttempts < this.maxRetries) {
      this.retryAttempts++;
      const delay = this.retryDelay * Math.pow(2, this.retryAttempts - 1);
      console.log(`Reconnecting in ${delay}ms (attempt ${this.retryAttempts})`);
      setTimeout(() => this.connect().catch(console.error), delay);
    } else {
      console.error('Max reconnection attempts reached');
      this.emit('maxRetriesExceeded');
    }
  }

  handleMessage(message) {
    const { type } = message;
    if (this.listeners[type]) {
      this.listeners[type].forEach(callback => callback(message));
    }
    this.emit('message', message);
  }

  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(callback);
  }

  emit(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(callback => callback(data));
    }
  }

  startHeartbeat() {
    this.heartbeat = setInterval(() => {
      this.send({ type: 'ping' });
    }, this.heartbeatInterval);
  }

  stopHeartbeat() {
    clearInterval(this.heartbeat);
  }

  disconnect() {
    this.stopHeartbeat();
    if (this.ws) {
      this.ws.close();
    }
  }
}
```

This client implementation features automatic exponential backoff reconnection, message queuing for offline scenarios, heartbeat monitoring, and event listener patterns.

## Event Broadcasting and Room Management

For applications with multiple rooms or channels, implement targeted broadcasting:

```javascript
class ChatRoom {
  constructor(roomId, server) {
    this.roomId = roomId;
    this.server = server;
    this.members = new Map();
    this.messageHistory = [];
    this.maxHistory = 100;
  }

  addMember(ws, userId, username) {
    this.members.set(ws, { userId, username, joinedAt: Date.now() });
    this.broadcast({
      type: 'userJoined',
      userId,
      username,
      memberCount: this.members.size
    });
    this.sendHistoryTo(ws);
  }

  removeMember(ws) {
    const member = this.members.get(ws);
    if (member) {
      this.members.delete(ws);
      this.broadcast({
        type: 'userLeft',
        userId: member.userId,
        username: member.username,
        memberCount: this.members.size
      });
    }
  }

  handleMessage(ws, content) {
    const member = this.members.get(ws);
    if (!member) return;

    const message = {
      type: 'message',
      userId: member.userId,
      username: member.username,
      content,
      timestamp: Date.now()
    };

    this.messageHistory.push(message);
    if (this.messageHistory.length > this.maxHistory) {
      this.messageHistory.shift();
    }

    this.broadcast(message);
  }

  broadcast(message) {
    const data = JSON.stringify(message);
    this.members.forEach((member, ws) => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(data);
      }
    });
  }

  sendHistoryTo(ws) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'history',
        messages: this.messageHistory
      }));
    }
  }
}
```

This room manager maintains message history, tracks members, and broadcasts events only to relevant clients.

## Error Handling and Reconnection Patterns

Robust error handling distinguishes production systems from prototypes. Handle connection timeouts, invalid messages, and graceful degradation:

```javascript
class ResilientWebSocketClient extends WebSocketClient {
  constructor(url, options = {}) {
    super(url, options);
    this.requestTimeout = options.requestTimeout || 5000;
    this.pendingRequests = new Map();
    this.requestId = 0;
  }

  requestResponse(message, timeout = this.requestTimeout) {
    return new Promise((resolve, reject) => {
      const requestId = ++this.requestId;
      const timer = setTimeout(() => {
        this.pendingRequests.delete(requestId);
        reject(new Error('Request timeout'));
      }, timeout);

      this.pendingRequests.set(requestId, { resolve, reject, timer });
      this.send({ ...message, requestId });
    });
  }

  handleMessage(message) {
    if (message.requestId && this.pendingRequests.has(message.requestId)) {
      const { resolve, timer } = this.pendingRequests.get(message.requestId);
      clearTimeout(timer);
      this.pendingRequests.delete(message.requestId);
      resolve(message);
    } else {
      super.handleMessage(message);
    }
  }
}
```

This pattern enables request-response semantics over WebSockets, with automatic timeout handling.

## Best Practices and Deployment Considerations

When deploying WebSocket systems, consider these production requirements:

Implement connection limits to prevent resource exhaustion. Track concurrent connections per user and implement circuit breakers when thresholds are exceeded.

Use message compression for bandwidth-heavy applications. Most WebSocket implementations support the permessage-deflate extension automatically.

Monitor connection health with heartbeat mechanisms. Detect stale connections that appear open but aren't truly responsive.

Implement message acknowledgment systems for critical updates. Have clients confirm receipt of important events, with server-side retry logic for unacknowledged messages.

Scale horizontally with sticky sessions or Redis-backed message brokers. When traffic exceeds single-server capacity, use message queues to broadcast across multiple server instances.

Secure WebSocket connections with WSS (WebSocket Secure) and implement authentication at the handshake stage. Validate user permissions before subscribing to channels.

Test reconnection logic thoroughly. Simulate network partitions, server crashes, and connection timeouts to ensure your error handling works as designed.

## Related Reading

- [Best Claude Skills for Developers 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Guides Hub](/claude-skills-guide/guides-hub/)

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
