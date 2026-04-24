---

layout: default
title: "Claude Code K8s Monitoring"
description: "Set up Kubernetes monitoring with Prometheus and Claude Code for custom dashboards, Alertmanager rules, and PromQL queries. Production-ready configs."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
categories: [guides]
tags: [claude-code, kubernetes, prometheus, monitoring, devops, observability, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-kubernetes-monitoring-prometheus/
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Monitoring Kubernetes clusters effectively requires the right combination of tools and automation. Prometheus has become the standard for Kubernetes observability, but configuring alerts, managing scrape targets, and debugging metrics can be time-consuming. Claude Code transforms these workflows by acting as an intelligent assistant that understands your infrastructure context and helps you write Prometheus rules, debug alerting issues, and maintain healthy monitoring configurations.

This guide shows you how to integrate Claude Code into your Kubernetes monitoring stack using Prometheus, with practical examples you can apply immediately.

Why Prometheus for Kubernetes Monitoring?

Prometheus has become the de facto standard for Kubernetes monitoring for several reasons. It uses a pull-based model that naturally fits the dynamic nature of Kubernetes workloads, supports multi-dimensional data through labels, and integrates natively with the kubernetes ecosystem. The Prometheus Operator extends this further by defining monitoring resources as Kubernetes Custom Resource Definitions (CRDs), which means you manage your monitoring configuration the same way you manage your applications, as declarative YAML.

Here's a quick comparison of popular Kubernetes monitoring approaches:

| Tool | Model | Storage | Best For |
|------|-------|---------|----------|
| Prometheus | Pull-based | Local TSDB | Standard K8s monitoring |
| Datadog | Agent push | SaaS cloud | Managed, multi-cloud |
| New Relic | Agent push | SaaS cloud | APM + infra combined |
| Victoria Metrics | Pull-based | Local/remote | High-cardinality workloads |
| Thanos | Pull-based | Object store | Multi-cluster, long-term |

Claude Code is particularly effective with Prometheus because it can read and write PromQL queries, understand the Prometheus Operator CRD schema, and reason about your alerting logic in context.

## Setting Up Prometheus Metrics Collection

Before Claude Code can assist with Prometheus, you need proper metrics collection. The prometheus-operator simplifies this significantly by defining monitoring resources through Custom Resource Definitions.

Install the Prometheus Operator using the kube-prometheus-stack Helm chart, which bundles Prometheus, Alertmanager, Grafana, and a set of default dashboards:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
 --namespace monitoring \
 --create-namespace \
 --set prometheus.prometheusSpec.retention=30d \
 --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi
```

Once deployed, you define what to scrape using ServiceMonitors. Here's a basic ServiceMonitor configuration that Claude Code might help you generate:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
 name: api-server-monitor
 namespace: monitoring
spec:
 selector:
 matchLabels:
 k8s-app: kubernetes-apiserver
 endpoints:
 - port: https
 scheme: https
 tlsConfig:
 caFile: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
 bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
```

For custom applications, you'll need a ServiceMonitor that targets your application's metrics endpoint. When you paste your service definition and deployment spec into a Claude Code conversation and ask it to generate a ServiceMonitor, it reads the port names and label selectors directly from your existing manifests to produce an accurate configuration.

Here's an example ServiceMonitor for a custom Node.js application that exposes metrics on port `metrics` at the path `/metrics`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
 name: nodejs-app-monitor
 namespace: monitoring
 labels:
 release: monitoring
spec:
 namespaceSelector:
 matchNames:
 - production
 selector:
 matchLabels:
 app: nodejs-api
 endpoints:
 - port: metrics
 path: /metrics
 interval: 30s
 scrapeTimeout: 10s
```

Claude Code can help you create ServiceMonitors for custom applications. When you describe your application architecture to Claude, it understands service relationships and can suggest appropriate labels and endpoints.

## Writing Effective Prometheus Alerting Rules

Alerting rules form the backbone of Kubernetes monitoring. Poorly written rules create alert fatigue or miss critical issues. Claude Code excels at crafting precise PromQL queries that capture actual problems without false positives.

Consider this alert for high memory usage:

```yaml
groups:
- name: kubernetes-resources
 rules:
 - alert: HighMemoryPressure
 expr: |
 (sum(container_memory_working_set_bytes{container!=""}) by (node, pod))
 / sum(container_spec_memory_limit_bytes{container!=""}) by (node, pod) > 0.85
 for: 5m
 labels:
 severity: warning
 annotations:
 summary: "Pod {{ $labels.pod }} memory usage above 85%"
 description: "Memory usage is {{ $value | humanizePercentage }}"
```

Claude Code can review your existing alerts and suggest improvements. For example, it might notice that your CPU throttling alert uses a threshold that triggers too frequently and recommend adjusting the `for` duration based on your workload patterns.

Here's a more complete set of alerting rules for production Kubernetes clusters that Claude Code can help you build incrementally:

```yaml
groups:
- name: kubernetes-nodes
 rules:
 - alert: NodeNotReady
 expr: kube_node_status_condition{condition="Ready",status="true"} == 0
 for: 2m
 labels:
 severity: critical
 annotations:
 summary: "Node {{ $labels.node }} is not ready"

 - alert: NodeHighCPU
 expr: |
 100 - (avg by(node) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
 for: 10m
 labels:
 severity: warning
 annotations:
 summary: "Node {{ $labels.node }} CPU usage above 90%"

 - alert: PersistentVolumeLowSpace
 expr: |
 kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes < 0.1
 for: 5m
 labels:
 severity: critical
 annotations:
 summary: "PV {{ $labels.persistentvolumeclaim }} has less than 10% free space"

- name: kubernetes-pods
 rules:
 - alert: PodCrashLooping
 expr: |
 rate(kube_pod_container_status_restarts_total[15m]) * 60 * 5 > 5
 for: 5m
 labels:
 severity: warning
 annotations:
 summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping"

 - alert: PodOOMKilled
 expr: |
 kube_pod_container_status_last_terminated_reason{reason="OOMKilled"} == 1
 for: 0m
 labels:
 severity: warning
 annotations:
 summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} was OOM killed"
```

When you ask Claude Code to write a new alert, give it context about your workload. Tell it the expected baseline, the traffic pattern, and how urgent the issue is. Claude uses that context to set appropriate thresholds and `for` durations rather than copying generic values that may not match your environment.

## PromQL Queries Worth Knowing

PromQL is a powerful but sometimes tricky query language. Claude Code can explain what a query does, optimize it for performance, or write one from scratch based on a plain-English description. Here are several useful queries with explanations:

Pod restart rate over the last hour:
```promql
sort_desc(increase(kube_pod_container_status_restarts_total[1h]))
```

Nodes with the highest memory pressure:
```promql
sort_desc(
 node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes
) / node_memory_MemTotal_bytes * 100
```

Top 10 pods by CPU consumption:
```promql
topk(10, sum by(pod, namespace)(
 rate(container_cpu_usage_seconds_total{container!=""}[5m])
))
```

Request error rate per service (requires istio or similar sidecar metrics):
```promql
sum by(destination_service_name)(
 rate(istio_requests_total{response_code=~"5.."}[5m])
)
/ sum by(destination_service_name)(
 rate(istio_requests_total[5m])
) > 0.01
```

If you paste one of these into Claude Code and ask "explain what this query does step by step," Claude will walk through each function and operator, which is an effective way to learn PromQL without reading dense documentation.

## Integrating Alertmanager with Notification Systems

Prometheus sends alerts to Alertmanager, which handles deduplication, grouping, and routing to appropriate receivers. Proper Alertmanager configuration ensures the right people receive the right alerts.

A practical Alertmanager configuration with routing rules:

```yaml
global:
 resolve_timeout: 5m
route:
 group_by: ['alertname', 'cluster']
 group_wait: 30s
 group_interval: 5m
 repeat_interval: 4h
 receiver: 'default-receiver'
 routes:
 - match:
 severity: critical
 receiver: 'critical-alerts'
 continue: true
 - match:
 team: platform
 receiver: 'platform-team'
receivers:
- name: 'default-receiver'
 email_configs:
 - to: 'oncall@example.com'
 send_resolved: true
- name: 'critical-alerts'
 slack_configs:
 - channel: '#critical-alerts'
 send_resolved: true
- name: 'platform-team'
 email_configs:
 - to: 'platform@example.com'
```

Alertmanager routing can become complex when you have many teams, severity levels, and on-call schedules. Claude Code helps you reason through the routing tree by simulating which receiver a given alert would match. You can describe an alert (its labels, severity, and team) and ask Claude to trace which route it would follow and which receiver would handle it.

Common Alertmanager configuration mistakes that Claude Code catches include:

- Missing `continue: true` on a route that should fan out to multiple receivers
- `group_wait` too short, causing alert storms during incidents
- `repeat_interval` so long that resolved-and-refired alerts look silent
- Routes that shadow each other due to ordering

For PagerDuty integration, which many teams use for on-call escalation:

```yaml
receivers:
- name: 'pagerduty-critical'
 pagerduty_configs:
 - routing_key: '<your-pagerduty-integration-key>'
 description: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
 severity: '{{ if eq .CommonLabels.severity "critical" }}critical{{ else }}warning{{ end }}'
```

When debugging notification issues, Claude Code can trace through your routing logic and identify why alerts is going to the wrong receiver or not being sent at all.

## Using Claude Skills for Kubernetes Monitoring

Several Claude skills enhance Kubernetes monitoring workflows. The pdf skill helps generate monitoring reports by extracting metrics data and creating documentation. If you need to analyze existing Prometheus snapshots or export dashboard data, the xlsx skill formats this information into readable spreadsheets.

For incident response, the tdd skill proves valuable when you need to write tests for alerting logic before deploying changes to production. This test-driven approach prevents misconfigured alerts from causing problems during actual incidents.

The supermemory skill integrates with your note-taking system to maintain a knowledge base of past incidents and their resolutions. When a familiar alert fires, Claude can reference previous incidents and suggest proven remediation steps.

## Debugging Common Prometheus Issues

One frequent challenge is understanding why specific metrics are missing. Claude Code helps you trace metric paths through your monitoring stack.

Start by verifying your service endpoints are exposing metrics:

```bash
kubectl port-forward -n monitoring prometheus-k8s 9090:9090
```

Then query the target in Prometheus directly. Claude can help you construct PromQL queries that identify scraping failures:

```promql
up{job="your-service"} == 0
```

For metrics that exist but show unexpected values, Claude analyzes the metric definitions in your application code and compares them against what Prometheus is collecting.

A systematic debugging workflow for missing metrics looks like this:

Step 1. Verify the Pod is exposing metrics:
```bash
kubectl exec -it <pod-name> -- curl localhost:8080/metrics | head -20
```

Step 2. Check ServiceMonitor selector matches Service labels:
```bash
kubectl get svc -n production -l app=nodejs-api -o yaml
kubectl get servicemonitor -n monitoring nodejs-app-monitor -o yaml
```

Step 3. Verify Prometheus discovered the target:
```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
Then open http://localhost:9090/targets in your browser
```

Step 4. Check for scrape errors in Prometheus logs:
```bash
kubectl logs -n monitoring prometheus-monitoring-kube-prometheus-prometheus-0 \
 | grep -i "scrape\|error" | tail -20
```

Claude Code is particularly useful at step 2, where label selector mismatches are the most common cause of missing targets. Paste your service YAML and your ServiceMonitor YAML and ask "do these selectors match?" Claude will immediately spot discrepancies.

## Setting Up Grafana Dashboards

Prometheus metrics are most useful when visualized. The kube-prometheus-stack includes a set of pre-built dashboards, but you'll want custom dashboards for your own applications. Claude Code can generate Grafana dashboard JSON from a description of what you want to display.

Here's how to import a dashboard using the Grafana API:

```bash
Export an existing dashboard
GRAFANA_URL="http://localhost:3000"
curl -s -u admin:password \
 "${GRAFANA_URL}/api/dashboards/uid/kubernetes-nodes" \
 | jq '.dashboard' > kubernetes-nodes.json

Import a modified dashboard
curl -s -X POST \
 -H "Content-Type: application/json" \
 -u admin:password \
 -d @kubernetes-nodes.json \
 "${GRAFANA_URL}/api/dashboards/import"
```

Ask Claude Code to help you write a Grafana panel query for a specific metric, and it will produce the PromQL expression along with suggested visualization settings (graph type, thresholds, unit labels).

## Automating Monitoring Configuration Updates

GitOps workflows work well for monitoring configurations. Store your Prometheus rules, Alertmanager config, and ServiceMonitors in a Git repository, then use ArgoCD or Flux to synchronize changes to your cluster.

Claude Code assists by reviewing configuration changes before you commit. It can verify that new alerting rules have valid PromQL syntax, check that ServiceMonitor selectors match your service labels, and ensure Alertmanager routing logic is syntactically correct.

A pre-commit hook that uses Claude to validate configurations:

```bash
#!/bin/bash
Validate Prometheus rules
for rulefile in monitoring/*.yaml; do
 if ! promtool check rules "$rulefile"; then
 echo "Invalid rules in $rulefile"
 exit 1
 fi
done
```

You can extend this to also validate Alertmanager config syntax:

```bash
#!/bin/bash
Validate Alertmanager config
if ! amtool check-config alertmanager.yaml; then
 echo "Invalid Alertmanager configuration"
 exit 1
fi

Validate all PrometheusRule manifests
for rulefile in monitoring/rules/*.yaml; do
 promtool check rules <(kubectl apply --dry-run=client -f "$rulefile" -o json \
 | jq -r '.spec') || exit 1
done
```

For ArgoCD-based GitOps, Claude Code can generate the Application manifest that points to your monitoring configuration directory:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
 name: cluster-monitoring
 namespace: argocd
spec:
 project: default
 source:
 repoURL: https://github.com/your-org/k8s-config
 targetRevision: HEAD
 path: monitoring
 destination:
 server: https://kubernetes.default.svc
 namespace: monitoring
 syncPolicy:
 automated:
 prune: true
 selfHeal: true
```

## Metrics Persistence and Long-Term Analysis

By default, Prometheus stores metrics locally on disk with a retention period (commonly 15 to 90 days). For long-term storage across multiple clusters, Thanos or Cortex extends Prometheus with horizontal scalability.

Here's a comparison of long-term storage options:

| Solution | Architecture | Cost Model | Query Latency |
|----------|-------------|-----------|--------------|
| Thanos | Sidecar + object store | Storage only | Medium (object store reads) |
| Cortex | Microservices + object store | Compute + storage | Low (caching) |
| Mimir | Cortex successor | Compute + storage | Low (optimized) |
| VictoriaMetrics | Single binary | Storage + compute | Very low |

Claude helps you configure appropriate retention policies and compaction settings based on your storage budget and query performance requirements.

A basic Thanos sidecar configuration added to your Prometheus deployment:

```yaml
containers:
- name: thanos-sidecar
 image: thanosio/thanos:v0.34.0
 args:
 - sidecar
 - --tsdb.path=/prometheus
 - --prometheus.url=http://localhost:9090
 - --objstore.config-file=/etc/thanos/objstore.yaml
 volumeMounts:
 - name: prometheus-data
 mountPath: /prometheus
 - name: thanos-config
 mountPath: /etc/thanos
```

When analyzing historical trends, the combination of Thanos Querier for efficient metric retrieval and Claude for query construction accelerates root cause analysis significantly. You can paste a Thanos query and a description of a past incident and ask Claude to help you identify the contributing metrics.

## Practical Workflow: Responding to a Production Alert

To see how all of this comes together, here's a realistic workflow where Claude Code assists during an incident:

1. PagerDuty fires: `PodCrashLooping` for `payments-api` in the `production` namespace.

2. You open Claude Code and paste the alert details. Claude immediately suggests checking recent deployments and OOM events.

3. You run:
 ```bash
 kubectl describe pod -n production -l app=payments-api | tail -40
 ```
 and paste the output into Claude. It spots `OOMKilled` in the last termination state.

4. Claude generates the PromQL query to confirm memory trend:
 ```promql
 container_memory_working_set_bytes{namespace="production", container="payments-api"}
 ```

5. You see memory climbing steadily over 6 hours. Claude suggests the likely cause (memory leak or increased load) and drafts a temporary patch to increase the memory limit while the team investigates.

6. Claude also drafts a PrometheusRule for a `PodMemoryLeakSuspected` alert based on a rising memory trend rather than a fixed threshold, so you can catch this earlier next time.

This kind of interactive back-and-forth with Claude Code during an incident is where the productivity gains are most tangible.

## Building Your Monitoring Foundation

Effective Kubernetes monitoring with Prometheus requires thoughtful configuration of collectors, alerts, and notification pathways. Claude Code acts as a knowledgeable teammate that understands your infrastructure context and helps you build reliable monitoring systems faster.

Start with solid scrape configurations, write targeted alerts that reduce noise, and ensure notifications reach the right people. Build incrementally: get the basics working first, then add custom application metrics, refine alert thresholds based on real data, and eventually layer in long-term storage with Thanos or Mimir.

Claude skills like pdf for reporting, xlsx for data analysis, and tdd for testing alert logic create a comprehensive monitoring toolkit that scales with your cluster. The biggest gains come from treating Claude as a peer reviewer for your PromQL and alerting logic, it catches subtle issues that are easy to miss when you're deep in the details of a complex configuration.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-kubernetes-monitoring-prometheus)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code Kubernetes Logging Stack Guide](/claude-code-kubernetes-logging-stack-guide/)
- [Claude Code Platform Engineer Observability Stack Workflow](/claude-code-platform-engineer-observability-stack-workflow/)
- [Claude Code Kubernetes Cost Optimization Guide](/claude-code-kubernetes-cost-optimization-guide/)
- [Claude Code for Kubernetes Profiling Workflow](/claude-code-for-kubernetes-profiling-workflow/)
- [How to Use Kubernetes Resource Limits (2026)](/claude-code-kubernetes-resource-limits-guide/)
- [Claude Code Kubernetes Persistent Volumes Guide](/claude-code-kubernetes-persistent-volumes-guide/)
- [Claude Code Kubernetes YAML Generation Workflow Guide](/claude-code-kubernetes-yaml-generation-workflow-guide/)
- [Claude Code for OpenFaaS Kubernetes Workflow](/claude-code-for-openfaas-kubernetes-workflow/)
- [Claude Code Kubernetes RBAC Security Guide](/claude-code-kubernetes-rbac-security-guide/)
- [Claude Code for Traefik Ingress Kubernetes Workflow Guide](/claude-code-for-traefik-ingress-kubernetes-workflow-guide/)
- [Claude Code GitHub Actions with Bedrock](/claude-code-github-actions-bedrock/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


