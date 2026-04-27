---
sitemap: false

layout: default
title: "Claude Code for Bandwhich Bandwidth (2026)"
description: "Learn how to integrate Claude Code with bandwhich for network bandwidth monitoring. Includes practical examples, CLI workflows, and skill integration."
date: 2026-03-15
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, bandwhich, networking, monitoring, devops, bandwidth, terminal, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-for-bandwhich-bandwidth-monitor-workflow/
reviewed: true
score: 8
geo_optimized: true
---



Network bandwidth monitoring is essential for developers debugging performance issues, identifying bandwidth-hungry processes, or optimizing application resource usage. Bandwhich, a Rust-based terminal bandwidth monitor, provides real-time visibility into network traffic organized by process, connection, and remote address. Combined with Claude Code's automation capabilities, you can create powerful workflows for network analysis, alerting, and historical tracking.

This guide shows you how to integrate Claude Code into your bandwhich workflow, from installation to automated monitoring and analysis.

## Installing and Configuring Bandwhich

Bandwhich runs on macOS, Linux, and Windows (via WSL). Installation via Homebrew is the quickest method on macOS:

```bash
brew install bandwhich
```

For other platforms, download pre-built binaries from the releases page or compile from source using Cargo. Once installed, verify the installation:

```bash
bandwhich --version
```

Bandwhich requires elevated permissions to capture network traffic. On macOS, you'll be prompted for sudo access the first time you run it. The tool uses `libpcap` for packet capture, so ensure your system allows this functionality.

## Basic Bandwhich Usage Patterns

Running bandwithout arguments displays all network activity in an interactive TUI:

```bash
sudo bandwhich
```

The interface shows processes sorted by bandwidth usage, with columns for download speed, upload speed, and total data transferred. Press `t` to toggle between total bandwidth and current speed views, `s` to sort by different columns, and `f` to filter by process name.

For scripted workflows, bandwhich supports machine-readable output formats:

```bash
JSON output for parsing
sudo bandwhich --json

CSV output for spreadsheet analysis
sudo bandwhich --csv

Narrow output (process name and bandwidth only)
sudo bandwhich --narrow
```

Claude Code can help you construct complex bandwhich commands and parse the output for specific analysis needs.

## Integrating Claude Code with Bandwhich

Claude Code enhances bandwhich workflows through several key capabilities: command construction, output parsing, automation scripting, and integration with other tools in your monitoring stack.

## Parsing Bandwhich Output

When you need to extract specific metrics from bandwhich output, Claude Code can write parsing scripts in your preferred language. Here's a Python example for extracting top bandwidth consumers:

```python
#!/usr/bin/env python3
import subprocess
import json
import sys

def get_top_bandwidth_processes(limit=10):
 result = subprocess.run(
 ["sudo", "bandwhich", "--json"],
 capture_output=True,
 text=True
 )
 
 if result.returncode != 0:
 print(f"Error: {result.stderr}", file=sys.stderr)
 sys.exit(1)
 
 data = json.loads(result.stdout)
 # Sort by total bytes transferred
 sorted_data = sorted(
 data, 
 key=lambda x: x.get('cumulative_bytes', 0), 
 reverse=True
 )
 
 for proc in sorted_data[:limit]:
 print(f"{proc['name']}: {proc['cumulative_bytes'] / 1024 / 1024:.2f} MB")

if __name__ == "__main__":
 get_top_bandwidth_processes()
```

Claude Code can generate similar parsing scripts tailored to your specific output format requirements and integration needs.

## Automated Bandwidth Monitoring

Create automated monitoring workflows that run bandwhich on a schedule and alert on anomalies. Here's a bash script for periodic bandwidth sampling:

```bash
#!/bin/bash
bandwidth-monitor.sh

THRESHOLD_MB=${1:-100} # Default 100MB threshold
LOG_FILE="/var/log/bandwidth-monitor.log"

while true; do
 OUTPUT=$(sudo bandwith --narrow --numeric 2>/dev/null)
 
 # Extract processes exceeding threshold
 HIGH_USAGE=$(echo "$OUTPUT" | awk -v threshold="$THRESHOLD_MB" '{
 if ($2 > threshold || $3 > threshold) print $1
 }')
 
 if [ -n "$HIGH_USAGE" ]; then
 echo "$(date): High bandwidth detected from: $HIGH_USAGE" >> "$LOG_FILE"
 fi
 
 sleep 60 # Check every minute
done
```

This script runs continuously, logging processes that exceed your defined threshold. Integrate with notification systems like Slack or PagerDuty by adding curl commands to send alerts.

## Creating Claude Skills for Bandwhich

Claude Skills extend Claude Code's capabilities for recurring bandwhich tasks. Create a custom skill for common bandwidth analysis workflows.

## Skill Structure

Place your skill in the Claude skills directory:

```bash
mkdir -p ~/claude-skills/bandwhich-monitor
```

Create the skill file:

```markdown
bandwhich-monitor skill

Overview
This skill helps analyze network bandwidth usage using bandwhich.

Commands

analyze-bandwidth
Analyzes current bandwidth usage and identifies top consumers.

monitor-process <process-name>
Continuously monitors a specific process's bandwidth usage.

bandwidth-report
Generates a comprehensive bandwidth report with historical context.

Examples

Run: sudo bandwhich --json | jq '.'
```

The skill file defines available commands and provides examples. Claude Code reads this to understand when to invoke bandwhich-related workflows.

## Interactive Monitoring Workflow

When you need real-time bandwidth analysis during development, describe your requirements to Claude:

> "Monitor the bandwidth usage of my Node.js development server and alert me if it exceeds 10MB in any 5-minute window"

Claude Code can construct monitoring scripts, explain the output, and help you interpret bandwidth patterns in context of your application architecture.

## Practical Examples and Use Cases

## Debugging High Bandwidth Usage

When experiencing network performance issues, use bandwhich to identify culprits:

```bash
Quick snapshot of current bandwidth
sudo bandwhich

Export data for detailed analysis
sudo bandwhich --json > bandwidth-$(date +%Y%m%d-%H%M%S).json
```

Import the JSON into Claude Code for analysis:

```python
import json
from collections import defaultdict

def analyze_bandwidth_patterns(json_file):
 with open(json_file) as f:
 data = json.load(f)
 
 # Group by remote address
 by_remote = defaultdict(int)
 for entry in data:
 remote = entry.get('remote_address', 'unknown')
 bytes_sent = entry.get('cumulative_bytes_sent', 0)
 bytes_received = entry.get('cumulative_bytes_received', 0)
 by_remote[remote] += bytes_sent + bytes_received
 
 # Show top consumers
 for remote, total in sorted(by_remote.items(), key=lambda x: x[1], reverse=True)[:10]:
 print(f"{remote}: {total / 1024 / 1024:.2f} MB")
```

## Continuous Monitoring in Development

For development environments where you want ongoing visibility, run bandwhich in the background:

```bash
Run in background, output to file
sudo bandwhich --json > /tmp/bandwidth-stream.json &

Watch the stream in real-time
tail -f /tmp/bandwidth-stream.json | jq '.'
```

Combine this with Claude Code's ability to analyze streaming data and provide insights about traffic patterns.

## Integrating with System Monitoring

Bandwhich output integrates well with other monitoring tools. Export to Prometheus format:

```bash
#!/bin/bash
bandwhich-to-prometheus.sh

while true; do
 sudo bandwhich --csv | tail -n +2 | while IFS=, read -r name download upload total; do
 echo "bandwidth_download{name=\"$name\"} $download"
 echo "bandwidth_upload{name=\"$name\"} $upload"
 echo "bandwidth_total{name=\"$name\"} $total"
 done
 sleep 15
done
```

This Prometheus-compatible output can be scraped by Prometheus for long-term storage and visualization in Grafana.

## Best Practices for Bandwidth Monitoring

Effective bandwidth monitoring requires thoughtful configuration and regular analysis. Here are key practices:

Define thresholds based on baseline behavior. Monitor your application under normal conditions first, then set alerts for deviations beyond 2-3x baseline.

Focus on process-level visibility. Bandwhich's strength is showing which specific processes consume bandwidth. Use this to identify unexpected processes or confirm expected behavior.

Correlate with application logs. When you identify high-bandwidth processes, cross-reference with application logs to understand why. Claude Code can help correlate these data sources.

Automate routine analysis. Create Claude Skills for common queries like "show me bandwidth for API requests" or "compare today's traffic to yesterday."

Monitor during specific events. Run targeted monitoring sessions during deployments, load testing, or user acceptance testing to capture relevant data.

## Building Your Network Monitoring Toolkit

Bandwhich combined with Claude Code creates a powerful network monitoring foundation. The CLI tool provides real-time visibility, while Claude Code adds automation, analysis, and integration capabilities.

Start with basic bandwhich usage to understand your network patterns, then layer in Claude Code for automated monitoring, alerting, and historical analysis. Skills for common workflows reduce repetitive tasks, and integration with broader monitoring stacks enables comprehensive observability.

The key is starting simple, run bandwhich interactively, explore your network traffic, then progressively add automation for the insights that matter most to your applications.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-bandwhich-bandwidth-monitor-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Kubernetes Monitoring with Prometheus](/claude-code-kubernetes-monitoring-prometheus/)
- Claude Code for Network Security Analysis
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

