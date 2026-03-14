---
layout: default
title: "Claude Code WebSocket Implementation: Real-Time Events Guide"
description: "Learn how to implement WebSocket connections in Claude Code skills for real-time event handling. Practical patterns for streaming data, live updates, and i"
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, websocket, real-time, events, implementation]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-websocket-implementation-real-time-events-guide/
---

# Claude Code WebSocket Implementation: Real-Time Events Guide

WebSocket connections enable bidirectional, low-latency communication between clients and servers. When building Claude Code skills that require real-time updates—such as live dashboards, notification systems, or streaming data processing—understanding [WebSocket implementation](/claude-skills-guide/claude-skills-for-websocket-realtime-app-development/) patterns becomes essential. This guide covers practical approaches for integrating WebSocket functionality into your Claude skills.

## Understanding WebSocket in the Claude Code Context

Claude Code skills execute as part of a conversational AI session, which means traditional WebSocket clients cannot run directly within the skill itself. Instead, you implement WebSocket connections through external scripts or services that your skill invokes. The skill acts as the orchestrator, coordinating between your code and the user's environment.

This architectural pattern works well with skills like the `pdf` skill for generating real-time reports, the `tdd` skill for live test feedback, and the `frontend-design` skill for hot-reloading preview updates.

## Basic WebSocket Server Implementation

Create a simple WebSocket server that your Claude skill can communicate with:

```python
# websocket-server.py
import asyncio
import websockets
import json
from datetime import datetime

async def handle_client(websocket, path):
    try:
        async for message in websocket:
            data = json.loads(message)
            
            if data.get('type') == 'subscribe':
                # Handle subscription to specific event streams
                channel = data.get('channel')
                await websocket.send(json.dumps({
                    'type': 'subscribed',
                    'channel': channel,
                    'timestamp': datetime.now().isoformat()
                }))
                
            elif data.get('type') == 'event':
                # Process incoming events
                event_type = data.get('event_type')
                payload = data.get('payload')
                print(f"Received event: {event_type}")
                
                # Broadcast to subscribers
                await broadcast_event(event_type, payload)
                
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")

async def broadcast_event(event_type, payload):
    # Implementation for broadcasting to all connected clients
    pass

async def main():
    async with websockets.serve(handle_client, "localhost", 8765):
        print("WebSocket server running on ws://localhost:8765")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())
```

Save this file and run it with `python websocket-server.py` before invoking your skill.

## Integrating with Claude Skills

Your Claude skill communicates with the WebSocket server through the `bash` tool. Here's how to structure this integration:

```markdown
# Real-Time Event Monitor Skill

You help users monitor [real-time events](/claude-skills-guide/claude-code-skills-for-backend-developers-node-and-python/) via WebSocket connections.

## Instructions

1. First, check if the WebSocket server is running on port 8765
2. If not running, start it with: python3 websocket-server.py
3. When the user requests event monitoring:
   - Use bash to run a client script that connects to ws://localhost:8765
   - Parse the output for event data
   - Present relevant events to the user in a clear format

## Event Display Format

Format events as:
```
[{timestamp}] {event_type}: {summary}
```

For critical events, prefix with 🚨 ALERT:
```

## Client-Side Connection Script

Create a client script that your skill invokes:

```javascript
// websocket-client.js
const WebSocket = require('ws');

const ws = new WebSocket('ws://localhost:8765');

ws.on('open', () => {
    console.log('Connected to WebSocket server');
    
    // Subscribe to specific channels
    ws.send(JSON.stringify({
        type: 'subscribe',
        channel: 'system-events'
    }));
});

ws.on('message', (data) => {
    const message = JSON.parse(data);
    console.log(JSON.stringify(message));
});

ws.on('error', (error) => {
    console.error('WebSocket error:', error.message);
    process.exit(1);
});
```

Run this client in your skill using: `node websocket-client.js`

## Real-Time Dashboard Pattern

For skills that require live visual updates—such as those using `frontend-design` or data visualization tools—consider this pattern:

```python
# dashboard-updater.py
import websocket
import json
import time

def on_message(ws, message):
    data = json.loads(message)
    
    if data['type'] == 'update':
        # Write update to a file that a frontend polls
        with open('./public/live-data.json', 'w') as f:
            json.dump(data['payload'], f)
        
        print(f"Updated dashboard at {data['timestamp']}")

def on_error(ws, error):
    print(f"Error: {error}")

def on_close(ws, close_status_code, close_msg):
    print("Connection closed")

def on_open(ws):
    def send_subscription():
        ws.send(json.dumps({
            'type': 'subscribe',
            'channel': 'metrics'
        }))
    
    send_subscription()

if __name__ == "__main__":
    ws = websocket.WebSocketApp(
        "ws://localhost:8765",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    
    ws.run_forever()
```

The `frontend-design` skill can then generate a dashboard that polls this file for updates, creating a near-real-time experience.

## Handling Connection Failures Gracefully

Production implementations require reconnection logic:

```python
import websocket
import time
import json

class ReconnectingClient:
    def __init__(self, url, max_retries=5):
        self.url = url
        self.max_retries = max_retries
        self.ws = None
        
    def connect(self):
        retries = 0
        while retries < self.max_retries:
            try:
                self.ws = websocket.WebSocketApp(
                    self.url,
                    on_message=self.on_message,
                    on_error=self.on_error,
                    on_close=self.on_close
                )
                self.ws.on_open = self.on_open
                self.ws.run_forever()
            except Exception as e:
                retries += 1
                wait_time = min(2 ** retries, 30)
                print(f"Reconnecting in {wait_time}s (attempt {retries})")
                time.sleep(wait_time)
                
        print("Max retries exceeded")
        
    def on_message(self, ws, message):
        data = json.loads(message)
        # Process message
        
    def on_open(self, ws):
        ws.send(json.dumps({'type': 'subscribe', 'channel': 'events'}))
        
    def on_error(self, ws, error):
        print(f"Error: {error}")
        
    def on_close(self, ws, close_status_code, close_msg):
        print("Connection closed, attempting reconnect...")
```

## Practical Use Cases

The `supermemory` skill benefits from WebSocket connections when syncing memories across devices in real-time. The `tdd` skill can stream test results as they execute, providing immediate feedback. For documentation generation with the `docx` skill, WebSocket connections enable progress updates during lengthy document assembly.

## Security Considerations

When deploying WebSocket servers in production:

- Use WSS (WebSocket Secure) for encrypted connections
- Implement authentication tokens in the connection handshake
- Validate all incoming messages to prevent injection attacks
- Set appropriate connection timeouts

## Summary

WebSocket implementation in Claude Code skills requires an external server-client architecture. Your skill orchestrates the connection through bash commands, while dedicated scripts handle the WebSocket protocol. This separation keeps your skill logic clean while enabling powerful real-time capabilities.

Start with the basic server and client examples above, then extend based on your specific use case. The key is keeping the skill focused on high-level coordination while offloading continuous connection management to purpose-built scripts.

---

## Related Reading

- [Claude Skills for WebSocket Real-Time App Development](/claude-skills-guide/claude-skills-for-websocket-realtime-app-development/) — Build complete real-time applications using Claude skills for both client and server
- [Can Claude Code Skills Call External APIs Automatically](/claude-skills-guide/can-claude-code-skills-call-external-apis-automatically/) — Extend WebSocket patterns to REST and streaming API integrations
- [Claude Code Skills for Scientific Python NumPy SciPy](/claude-skills-guide/claude-code-skills-for-scientific-python-numpy-scipy/) — Process real-time data streams from WebSocket connections with numerical computing
- [Claude Skills Hub](/claude-skills-guide/use-cases-hub/) — Explore real-time and event-driven application use cases for Claude Code

Built by theluckystrike — More at [zovo.one](https://zovo.one)
