---
layout: default
title: "Claude Code For Pixie K8S (2026)"
description: "Learn how to use Claude Code with Pixie for powerful Kubernetes observability. This guide covers practical workflows, code examples, and."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-pixie-k8s-observability-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---
## Introduction to Kubernetes Observability with Pixie and Claude Code

Kubernetes observability has become essential for maintaining healthy microservices architectures. Pixie offers an open-source observability platform that provides automatic instrumentation, allowing developers to collect metrics, traces, and logs without manual setup. When combined with Claude Code's AI capabilities, you get a powerful workflow for debugging, monitoring, and optimizing your Kubernetes clusters.

This guide demonstrates practical approaches to integrating Claude Code with Pixie for effective Kubernetes observability. from initial deployment through incident response and ongoing baseline management.

## Setting Up Pixie in Your Kubernetes Cluster

Before diving into the Claude Code workflow, ensure Pixie is deployed in your cluster. The most straightforward method uses the Pixie CLI:

```bash
Install Pixie using the official CLI
px deploy --pixie-cloud-address cloud.px.dev --deploy-key your-deploy-key
```

For custom deployments, you can modify the Helm values:

```yaml
pixie-values.yaml
deployKey: your-deploy-key
clusterName: production-cluster
enablePEM: true
enableEEE: false
```

After deployment, verify the Pixie pods are running:

```bash
kubectl get pods -n px-operator
kubectl get pods -n pl
```

Expect to see pods for the Pixie operator, Pixie Edge Module (PEM), and cloud connector components. If any remain in `Pending` or `CrashLoopBackOff`, check that your nodes have sufficient memory. PEM requires at least 2Gi per node.

## Configuring Pixie Data Retention

By default, Pixie stores observability data in memory with a short retention window. For production use, configure the data table sizes to match your traffic volume:

```bash
Increase the HTTP events table size for high-traffic clusters
px config set table_store_data_limit_mb 1024
```

This matters for Claude Code workflows because larger retention windows let you query further back when investigating incidents. When you ask Claude to analyze a performance regression, a longer data window gives it more historical context to work with.

## Claude Code Integration Strategies

Claude Code can assist with several Pixie-related tasks: writing and debugging PxL scripts (Pixie's query language), analyzing observability data, generating alerts, and explaining cluster issues.

## Understanding PxL Before Writing It

PxL is a Python-like language purpose-built for Pixie. Before asking Claude Code to generate scripts, understanding its core concepts helps you write better prompts:

| PxL Concept | Description | Example Use |
|---|---|---|
| `px.DataFrame` | Query a specific Pixie data table | HTTP events, network traffic |
| `start_time` | Lookback window for the query | `'-5m'`, `'-1h'` |
| `groupby().agg()` | Aggregate metrics by dimensions | Group by service, pod, path |
| `px.quantile()` | Calculate percentile latency | p50, p95, p99 |
| `px.display()` | Render results in the Pixie UI | Named visualization panels |

The key Pixie data tables Claude Code queries most often are `http_events`, `network_traffic`, `process_stats`, and `dns_events`. Knowing these table names helps you write precise prompts.

## Writing PxL Scripts with Claude Code

Claude Code excels at generating PxL scripts for common observability scenarios. When requesting script generation, specify the exact metrics you need and any filtering criteria.

For example, to analyze HTTP service performance:

```
Generate a PxL script that:
- Lists all HTTP requests in the last 5 minutes
- Groups by HTTP path
- Shows request count, latency p50, p99, and error rate
- Filters for responses with status code >= 400
```

Claude Code produces a script like this:

```python
import px

HTTP request analysis script
df = px.DataFrame('http_events', start_time='-5m')

Filter for error responses
df = df[df.resp_status >= 400]

Group by HTTP path
df = df.groupby(['HTTP path']).agg(
 request_count=('HTTP path', px.count),
 latency_p50=('latency', px.quantile(0.5)),
 latency_p99=('latency', px.quantile(0.99)),
 error_rate=('latency', px.mean)
)

px.display(df, 'http_errors')
```

A more useful version of this script adds namespace filtering for multi-tenant clusters:

```python
import px

df = px.DataFrame('http_events', start_time='-5m')

Scope to a specific namespace
df = df[df.namespace == 'production']

Filter error responses only
df = df[df.resp_status >= 400]

Enrich with service name
df.service = df.ctx['service']

df = df.groupby(['service', 'HTTP path']).agg(
 request_count=('HTTP path', px.count),
 latency_p50=('latency', px.quantile(0.5)),
 latency_p99=('latency', px.quantile(0.99)),
 error_rate=('resp_status', px.mean)
)

Sort by error volume descending
px.display(df.sort('request_count', desc=True), 'http_errors_by_service')
```

When generating this kind of script, tell Claude Code your cluster topology. whether you use namespaces to separate environments, whether service names follow a naming convention, and what time windows matter for your SLAs.

## Debugging Service Issues

When troubleshooting production issues, Claude Code helps analyze observability data. Provide context about the problem: error messages, relevant logs, affected services, and any hypotheses you have.

For network connectivity issues between pods:

```
My frontend service can't reach the backend service.
The backend is running on pod backend-abc123 in namespace production.
Generate diagnostic PxL scripts to check:
- DNS resolution for the backend service
- TCP connection success rates
- Any dropped packets or connection timeouts
```

Claude Code generates appropriate scripts and explains what each one reveals about your network behavior.

A complete network diagnostic set from Claude Code might include three scripts that work together:

```python
Script 1: DNS resolution check
import px

df = px.DataFrame('dns_events', start_time='-10m')
df = df[df.namespace == 'production']
df.latency_ms = df.latency / 1000000

df = df.groupby(['query_name']).agg(
 query_count=('query_name', px.count),
 success_count=('rcode', lambda x: px.sum(x == 0)),
 avg_latency_ms=('latency_ms', px.mean)
)

df.success_rate = df.success_count / df.query_count
px.display(df[df.query_name.contains('backend')], 'dns_resolution')
```

```python
Script 2: TCP connection success rates
import px

df = px.DataFrame('network_traffic', start_time='-10m')
df = df[df.namespace == 'production']

df = df.groupby(['remote_addr', 'remote_port']).agg(
 bytes_sent=('bytes_sent', px.sum),
 bytes_recv=('bytes_recv', px.sum),
 retransmits=('retransmits', px.sum),
 rtt_ms=('rtt', px.mean)
)

df.rtt_ms = df.rtt_ms / 1000000
px.display(df.sort('retransmits', desc=True), 'tcp_connections')
```

Running these two scripts together gives you a complete picture: is DNS resolving correctly, and are TCP connections succeeding once the IP is known?

## Practical Workflow Examples

## Investigating High Latency

High latency complaints require systematic investigation. A practical workflow:

1. Identify the affected service using Claude to query Pixie's service-level metrics
2. Break down by endpoint to find which specific routes are slow
3. Check dependency latency to identify downstream bottlenecks
4. Analyze resource usage to spot CPU or memory constraints

Claude Code can guide you through each step, generating appropriate PxL queries:

```python
Service latency breakdown
df = px.DataFrame('http_events', start_time='-10m')
df = df[df.service == 'your-service-name']
df.latency_ms = df.latency / 1000000 # Convert nanoseconds to milliseconds

df = df.groupby(['HTTP path', 'HTTP method']).agg(
 p50_latency=('latency_ms', px.quantile(0.5)),
 p95_latency=('latency_ms', px.quantile(0.95)),
 p99_latency=('latency_ms', px.quantile(0.99)),
 throughput=('latency_ms', px.count)
)

px.display(df.sort('p99_latency', desc=True))
```

When this query surfaces a slow endpoint, the next step is checking whether the latency is in your service or a dependency. Ask Claude Code:

```
The /api/checkout endpoint is showing p99 latency of 2.3 seconds.
Generate a PxL script that shows all outbound HTTP calls made by the
checkout service, grouped by destination service, with their latency
percentiles. I want to see if a downstream call is causing the slowdown.
```

Claude Code generates a dependency latency script that maps outbound calls from your service to their destinations, letting you pinpoint whether the checkout service itself is slow or a downstream payment or inventory service is the bottleneck.

## Detecting Anomalies with Claude Code

Combine Claude Code's anomaly detection suggestions with Pixie's continuous data collection. Ask Claude to help create baseline scripts that track normal behavior, then generate alerts for deviations.

```
Create a PxL script that:
- Tracks error rates per service over the last hour
- Calculates a rolling 5-minute average error rate
- Alerts when current error rate exceeds 3x the rolling average
```

A practical implementation captures both the baseline and current state in a single script:

```python
import px

Get error rates over the past hour in 5-minute buckets
df = px.DataFrame('http_events', start_time='-1h')
df = df[df.namespace == 'production']
df.service = df.ctx['service']
df.is_error = df.resp_status >= 500

Bucket by time window
df = df.groupby(['service', px.bin(df.time_, px.minutes(5))]).agg(
 total_requests=('resp_status', px.count),
 error_requests=('is_error', px.sum)
)

df.error_rate = df.error_requests / df.total_requests

Flag buckets with anomalous error rates
(Claude Code adds the comparison logic after reviewing baseline stats)
df.is_anomaly = df.error_rate > 0.05 # Adjust threshold from baseline

px.display(df[df.is_anomaly].sort('time_', desc=True), 'error_anomalies')
```

The threshold value (0.05 in this example) comes from running the baseline version of this script during normal operation and letting Claude Code analyze the output to recommend a meaningful threshold.

## Resource Usage Investigation

When pods are OOMKilled or experiencing CPU throttling, Pixie's process stats table gives per-pod resource data that Claude Code can query efficiently:

```
A pod in the payment namespace restarted 4 times in the last 2 hours.
Generate a PxL script to show memory and CPU usage for all pods in that
namespace over the last 3 hours, sorted by peak memory usage.
```

```python
import px

df = px.DataFrame('process_stats', start_time='-3h')
df = df[df.namespace == 'payment']

df = df.groupby(['pod', 'container']).agg(
 max_memory_mb=('vsize_bytes', px.max),
 avg_memory_mb=('vsize_bytes', px.mean),
 max_cpu_pct=('cpu_utime_ns', px.max),
 avg_cpu_pct=('cpu_utime_ns', px.mean)
)

Convert bytes to MB
df.max_memory_mb = df.max_memory_mb / 1048576
df.avg_memory_mb = df.avg_memory_mb / 1048576

px.display(df.sort('max_memory_mb', desc=True), 'resource_usage')
```

This query surfaces which container hit the highest memory watermark, giving you the likely OOMKill candidate immediately.

## Actionable Advice for Effective Observability

## Best Practices

1. Start with service maps: Use Pixie's auto-instrumentation to visualize service dependencies before diving into detailed metrics

2. Create reusable scripts: Save frequently used PxL queries as templates for quick access during incidents. Ask Claude Code to generate a script library file organized by incident type.

3. Establish baselines: Work with Claude Code to define what "normal" looks like for your services. Run baseline queries during known-good periods and save the results as reference data.

4. Correlate metrics with traces: Use Pixie's unified data model to move smoothly between high-level metrics and detailed traces. A service showing high p99 latency is more actionable when you can drill into specific request traces.

5. Automate routine checks: Generate scripts for daily health checks and have Claude Code help schedule their execution. A morning health check script run via CI gives teams an immediate picture of overnight changes.

6. Document your PxL library: Ask Claude Code to add comments to generated scripts explaining what each section does. Future team members can modify scripts without needing to rediscover PxL syntax.

## Comparison: Manual Debugging vs. Claude Code-Assisted Observability

| Task | Manual Approach | Claude Code Approach |
|---|---|---|
| Write error rate query | 15-30 min learning PxL docs | 2-3 min with precise prompt |
| Debug network issue | Multiple kubectl exec sessions | Single diagnostic script set |
| Establish baseline thresholds | Spreadsheet + guesswork | Claude analyzes historical data |
| Create alert conditions | Custom alert YAML from scratch | Generated from Pixie output analysis |
| Document runbooks | Manual writing after incidents | Generated during investigation |

## Common Pitfalls to Avoid

- Over-instrumentation: Start with automatic Pixie instrumentation before adding custom traces. Pixie's eBPF-based collection captures most useful data without any code changes.
- Alert fatigue: Work with Claude to set meaningful thresholds based on actual baseline data. Static thresholds copied from blog posts rarely fit your specific traffic patterns.
- Ignoring context: Always include relevant context when asking Claude Code for help with observability issues. Cluster size, traffic volume, and recent deployments all affect what the data means.
- Single-metric debugging: Latency, error rate, and saturation usually interact. Ask Claude Code to generate scripts that capture all three for the affected service rather than investigating each in isolation.
- Not saving working scripts: When Claude Code generates a script that successfully diagnoses an issue, save it to your runbook before closing the session. Regenerating it during the next incident wastes time.

## Building a PxL Script Library with Claude Code

A systematic approach: after each incident, ask Claude Code to clean up the diagnostic scripts you used and add them to a runbook file organized by symptom type.

```
Clean up these three PxL scripts I used during today's incident and add them
to ./runbooks/latency-investigation.md with:
- A description of when to run each script
- What output to look for
- What follow-up actions the output suggests
```

Over time, this builds a team-specific observability runbook that new engineers can use immediately without needing to learn PxL from scratch.

## Conclusion

Claude Code transforms Kubernetes observability workflows by generating precise PxL scripts, guiding debugging sessions, and helping establish effective monitoring practices. Combined with Pixie's automatic instrumentation, you gain a powerful toolkit for maintaining healthy, performant Kubernetes applications.

Start by deploying Pixie in your cluster, then use Claude Code to build custom observability scripts tailored to your specific needs. The integration accelerates troubleshooting, improves understanding of system behavior, and ultimately leads to more reliable services.

The most effective teams treat Claude Code not as a one-time script generator but as an ongoing observability partner. using it to build up a script library, refine alert thresholds over time, and generate runbook documentation that captures institutional knowledge about how your specific cluster behaves.



---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-for-pixie-k8s-observability-workflow)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code Platform Engineer Observability Stack Workflow](/claude-code-platform-engineer-observability-stack-workflow/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


