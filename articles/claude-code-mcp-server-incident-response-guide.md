---
layout: default
title: "Claude Code MCP Server Incident Response Guide"
description: "Learn how to build incident response workflows for Claude Code MCP servers. Detect failures, automate recovery, and maintain reliable AI agent operations."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, mcp, incident-response, devops, reliability]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code MCP Server Incident Response Guide

[When your MCP servers fail during a critical workflow](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/), the impact ripples through your entire AI-assisted development process. Whether it's a database connection timeout, an API rate limit, or a crashed subprocess, incidents happen. This guide shows you how to build reliable incident detection, alerting, and recovery systems for your MCP server infrastructure.

## Identifying Common MCP Server Failure Modes

MCP servers can fail in several distinct ways, and recognizing these patterns helps you design targeted responses.

**Connection timeouts** occur when your MCP server cannot reach its backend service within the expected window. This often happens with external APIs or database servers under load.

**Process crashes** happen when the underlying server executable terminates unexpectedly. [The `tdd` skill or any skill running test suites frequently encounters this](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) when tests consume too much memory.

**Permission errors** surface when file system access or network permissions change—particularly relevant when using skills like `frontend-design` that generate files across multiple directories.

**Resource exhaustion** manifests as out-of-memory errors or disk full conditions. The `pdf` skill, for example, can consume significant memory when processing large documents.

## Setting Up Health Check Endpoints

The first line of defense involves implementing health checks that Claude Code can query. Most MCP servers support stdio communication, but adding a dedicated health endpoint provides better observability.

Create a simple health check using a shell script:

```bash
#!/bin/bash
# mcp-health-check.sh

# Check if MCP server process is running
if ! pgrep -f "my-mcp-server" > /dev/null; then
    echo "{\"status\": \"down\", \"reason\": \"process_not_found\"}"
    exit 1
fi

# Check memory usage (exit if over 80% of 2GB limit)
MEMORY_USAGE=$(ps -o rss= -p $(pgrep -f "my-mcp-server") | awk '{print $1/1024}')
if (( $(echo "$MEMORY_USAGE > 1638" | bc -l) )); then
    echo "{\"status\": \"degraded\", \"reason\": \"high_memory\", \"usage_mb\": $MEMORY_USAGE}"
    exit 1
fi

echo "{\"status\": \"healthy\", \"uptime_seconds\": $(uptime -p)}"
```

Integrate this into your MCP server configuration:

```json
{
  "mcpServers": {
    "custom-api": {
      "command": "node",
      "args": ["/path/to/server/index.js"],
      "env": {
        "PORT": "3000"
      },
      "healthCheck": {
        "command": "/path/to/mcp-health-check.sh",
        "interval": 60,
        "timeout": 10
      }
    }
  }
}
```

## Building Automatic Recovery Mechanisms

Recovery automation reduces manual intervention and keeps your AI workflows running. The key is implementing idempotent restart logic that handles various failure scenarios gracefully.

For process restarts, use a supervisor pattern:

```javascript
// mcp-supervisor.js
const { spawn } = require('child_process');
const MAX_RESTARTS = 3;
const RESTART_WINDOW = 60000; // 1 minute

class MCPSupervisor {
  constructor(serverName, command, args) {
    this.serverName = serverName;
    this.command = command;
    this.args = args;
    this.restarts = [];
    this.process = null;
  }

  start() {
    this.process = spawn(this.command, this.args, {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    this.process.on('exit', (code, signal) => {
      this.handleExit(code, signal);
    });

    this.process.on('error', (err) => {
      console.error(`[${this.serverName}] Process error:`, err.message);
    });
  }

  handleExit(code, signal) {
    const now = Date.now();
    this.restarts.push(now);
    
    // Clean old restart records outside the window
    this.restarts = this.restarts.filter(t => now - t < RESTART_WINDOW);

    if (this.restarts.length > MAX_RESTARTS) {
      console.error(`[${this.serverName}] Too many restarts, giving up`);
      this.alertOnCall("MCP server crashing repeatedly");
      return;
    }

    console.log(`[${this.serverName}] Restarting (attempt ${this.restarts.length})`);
    setTimeout(() => this.start(), Math.min(1000 * Math.pow(2, this.restarts.length), 30000));
  }

  alertOnCall(message) {
    // Integrate with PagerDuty, Slack, or custom webhook
    fetch(process.env.ALERT_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: `[MCP] ${this.serverName}: ${message}` })
    });
  }
}
```

This supervisor implements exponential backoff, preventing rapid restart cycles that could mask deeper issues. It also triggers alerts when a server enters a crash loop—useful for the `supermemory` skill or any persistent context server that must remain available.

## Implementing Circuit Breaker Patterns

When downstream services fail, your MCP server should stop hammering them and gracefully degrade. Circuit breakers provide this protection.

```python
# mcp_circuit_breaker.py
import time
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Failing, reject requests
    HALF_OPEN = "half_open"  # Testing recovery

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=30):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.state = CircuitState.CLOSED
        self.last_failure_time = None

    def call(self, func, *args, **kwargs):
        if self.state == CircuitState.OPEN:
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = CircuitState.HALF_OPEN
            else:
                raise Exception("Circuit breaker OPEN")

        try:
            result = func(*args, **kwargs)
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise e

    def on_success(self):
        self.failures = 0
        self.state = CircuitState.CLOSED

    def on_failure(self):
        self.failures += 1
        self.last_failure_time = time.time()
        if self.failures >= self.failure_threshold:
            self.state = CircuitState.OPEN
```

This pattern works well with Python-based MCP servers, especially those handling external API calls. When the `xlsx` skill calls external spreadsheet APIs or the `pdf` skill processes documents from cloud storage, circuit breakers prevent cascading failures.

## Creating Incident Response Runbooks

Every good incident response strategy includes runbooks—documented procedures your team (or automated systems) follow when issues arise.

**Runbook: MCP Server Unresponsive**

1. Check process status: `pgrep -f "server-name"`
2. Review recent logs: `tail -100 /var/log/mcp-server.log`
3. Verify network connectivity to backend services
4. If process dead, collect core dump if available
5. Restart service and monitor for 5 minutes
6. Document incident in your tracking system

**Runbook: High Memory Usage**

1. Identify process: `ps aux | grep mcp-server | sort -k4 -r`
2. Capture heap dump if applicable
3. Check for memory leaks using `memory_profiler`
4. Restart with reduced concurrent request limit
5. Consider scaling horizontally if consistent high load

## Monitoring and Alerting Integration

For production MCP server deployments, integrate with your existing monitoring stack. The `mcp-server-prometheus` community skill provides built-in metrics export:

```yaml
# skill.md
# Prompts for monitoring MCP server metrics
- Monitor: Query Prometheus metrics endpoint
- Alert: Check alertmanager for active alerts
- Metrics: Retrieve cpu, memory, request_duration histograms
```

Connect to tools like Datadog, Grafana, or custom dashboards. Set up alerts for:

- Request latency exceeding 5 seconds
- Error rate above 1% over 5 minutes
- Memory usage above 80% sustained for 2 minutes
- Process restarts exceeding 3 per hour

## Testing Your Incident Response

Use chaos engineering principles to validate your response procedures. The `chaos-engineering` skill can help simulate failures:

```bash
# Kill random MCP processes to test supervisor
pkill -f "mcp-server" --signal=KILL
# Verify recovery within expected timeframe
```

Regular testing ensures your incident response playbook remains current and your team stays practiced.

## Conclusion

Building incident response capabilities for MCP servers protects your AI-assisted development workflows from unexpected failures. Start with health checks, implement automatic recovery with supervisors, add circuit breakers for resilience, and maintain tested runbooks. These patterns work whether you're running a single `tdd` skill test server or a complex multi-service infrastructure.

The investment in thorough incident response pays dividends in reduced downtime and faster recovery when issues inevitably occur.

## Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/)
- [MCP Server Logging Audit Trail Security Guide](/claude-skills-guide/mcp-server-logging-audit-trail-security-guide/)
- [Securing MCP Servers in Production Environments](/claude-skills-guide/securing-mcp-servers-in-production-environments/)
- [Advanced Hub](/claude-skills-guide/advanced-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
