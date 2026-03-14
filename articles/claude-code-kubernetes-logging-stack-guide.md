---

layout: default
title: "Claude Code Kubernetes Logging Stack Guide"
description: "A practical guide to building a Kubernetes logging stack with Claude Code. Learn how to configure Fluent Bit, Loki, and Grafana while leveraging Claude skills for automation."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-kubernetes-logging-stack-guide/
categories: [guides]
tags: [claude-code, kubernetes, logging, observability, devops, claude-skills]
reviewed: true
score: 7
---

{% raw %}

# Claude Code Kubernetes Logging Stack Guide

Setting up a robust logging stack in Kubernetes doesn't have to be overwhelming. This guide walks you through building a production-ready logging pipeline using Fluent Bit, Loki, and Grafana—while showing how Claude Code and its skills accelerate every step of the process.

## Understanding the Logging Stack Components

A complete Kubernetes logging solution requires three layers: collection, aggregation, and visualization. Fluent Bit runs as a DaemonSet on each node, collecting logs from containers and forwarding them to Loki. Loki then indexes and stores these logs efficiently, while Grafana provides the querying and dashboarding interface.

This separation of concerns keeps the system scalable. Fluent Bit handles the high-volume ingestion, Loki provides cost-effective storage with label-based indexing, and Grafana connects everything with powerful visualization tools.

When you're configuring this stack, Claude Code becomes invaluable for generating YAML manifests, debugging configuration issues, and explaining how each component fits together. The kubernetes-mcp-server skill can also help manage cluster interactions directly from your terminal.

## Setting Up Fluent Bit with Claude Code

Fluent Bit configuration involves creating a ConfigMap for the Fluent Bit daemon and a DaemonSet to deploy it across your nodes. Here's a practical starting point:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: logging
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         5
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf

    [INPUT]
        Name              tail
        Path              /var/log/containers/*.log
        Parser            docker
        Tag               kube.*
        Refresh_Interval  5

    [OUTPUT]
        Name        loki
        Match       kube.*
        Host        loki.logging.svc.cluster.local
        Port        3100
        Labels      {job="fluent-bit"}
```

Claude Code can generate this configuration and customize it for your specific needs. For example, you might need to add custom parsers for application-specific log formats or configure buffering for high-throughput scenarios.

The parsers.conf section deserves special attention. Without proper parsing, your logs remain unstructured text:

```conf
[PARSER]
    Name        docker
    Format      json
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L
    Time_Keep   On
```

When Claude Code helps you configure Fluent Bit, it can analyze your existing log formats and suggest appropriate parser configurations. This is particularly useful when dealing with applications that don't output JSON logs by default.

## Deploying Loki for Log Aggregation

Loki differs from traditional log databases by only indexing metadata labels rather than full log content. This approach dramatically reduces storage costs while maintaining fast query performance. Deploy Loki with a simple Helm chart or manual YAML manifests.

The Loki configuration focuses on storage and schema:

```yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

schema_config:
  configs:
    - from: 2026-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v12
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb:
    directory: /loki/index
  filesystem:
    directory: /loki/chunks

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

For production environments, you'll want to configure object storage like S3 or GCS instead of the filesystem backend. Claude Code can help you translate this configuration for your specific cloud provider.

The schema_config section defines how Loki indexes your logs. Starting with v12 schema provides better compression and query performance. If you're migrating from an older Loki version, the ttd skill can assist with schema migrations.

## Connecting Grafana for Visualization

Grafana completes the stack by providing powerful querying and visualization capabilities. Add Loki as a data source using the HTTP endpoint:

```
http://loki.logging.svc.cluster.local:3100
```

Build queries using LogQL, Loki's query language. The basics work like PromQL:

```logql
{app="my-service"} |= "error" | json | level="error"
```

This query filters logs from the my-service application containing the word "error", parses JSON fields, and filters for entries where the level field equals "error".

Grafana dashboards become more powerful when you combine logs with metrics. Create panels that show error rates alongside the actual error messages, giving you immediate context when incidents occur.

## Automating with Claude Skills

Several Claude skills accelerate logging stack management. The grafana-mcp-server skill lets you create dashboards programmatically. The pdf skill helps generate incident reports from log queries. For debugging, the supermemory skill maintains context across complex troubleshooting sessions.

When investigating production issues, chain multiple skills together:

1. Query Loki for error patterns using LogQL
2. Export relevant timeframes to PDF for stakeholders
3. Store findings in supermemory for future reference

The tdd skill proves useful when writing tests for log parsing logic or building custom Fluent Bit filters that handle your application's specific log format.

## Common Pitfalls and Solutions

The most frequent issue involves Fluent Bit not collecting logs from specific namespaces. This usually stems from RBAC permissions. Ensure your Fluent Bit service account has cluster-reader permissions:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluent-bit-reader
rules:
- apiGroups: [""]
  resources:
  - pods
  - namespaces
  verbs: ["get", "list", "watch"]
```

Another common problem involves Loki memory usage with high-volume logs. Adjust the ingestion limits and chunk configuration:

```yaml
limits_config:
  ingestion_rate_mb: 50
  ingestion_burst_size_mb: 100
  per_stream_rate_limit: 10MB
```

Claude Code can analyze your current resource usage and suggest appropriate limits for your cluster's scale.

## Production Recommendations

For production environments, implement log retention policies that balance storage costs with compliance requirements. Loki supports configurable retention through the table_manager:

```yaml
table_manager:
  retention_deletes_enabled: true
  retention_period: 672h  # 28 days
```

Consider enabling tail-based logging in Fluent Bit for real-time debugging capabilities. This feature maintains a small database of recent logs that enables queries on live data:

```ini
[INPUT]
    Name              tail
    Path              /var/log/containers/*.log
    DB                /var/log/flb_kube.db
    Skip_Long_Lines   On
    Refresh_Interval  10
```

Monitoring the monitoring stack itself matters. Create dashboards that track Fluent Bit throughput, Loki ingestion rates, and Grafana query performance. Claude Code's monitoring skills can generate these automatically based on your current setup.

## Conclusion

Building a Kubernetes logging stack requires careful coordination between collection, storage, and visualization layers. Fluent Bit handles high-volume ingestion efficiently, Loki provides cost-effective log storage, and Grafana delivers powerful analysis capabilities. Claude Code accelerates every phase—from initial configuration generation to ongoing maintenance and troubleshooting.

The skills ecosystem amplifies this workflow. Use the grafana-mcp-server for programmatic dashboard creation, the pdf skill for incident documentation, and supermemory for maintaining investigation context across complex incidents.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
