---
layout: default
title: "Claude Code For Kube State — Complete Developer Guide"
description: "Learn how to use Claude Code to streamline your Kube State Metrics workflow, from deployment configuration to custom metric creation and alerting."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-kube-state-metrics-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---
{% raw %}
Claude Code for Kube State Metrics Workflow: A Complete Guide

Kubernetes has become the backbone of modern cloud-native infrastructure, and understanding what's happening inside your clusters is crucial for maintaining reliable applications. Kube State Metrics (KSM) plays a vital role in exposing cluster-level objects as Prometheus-compatible metrics, but configuring and extending it can be complex. This is where Claude Code becomes your powerful ally in building efficient Kube State Metrics workflows.

What is Kube State Metrics?

Kube State Metrics is a service that listens to the Kubernetes API server and generates metrics about the state of Kubernetes objects, pods, deployments, services, and more. Unlike node-level metrics (which focus on CPU and memory), KSM focuses on the status and health of your Kubernetes resources.

For example, KSM can tell you:
- How many pods are running versus pending in a deployment
- Whether a ReplicaSet is meeting its desired replicas
- If a PVC (PersistentVolumeClaim) is bound or pending
- The current state of your cronjobs and jobs

These metrics are invaluable for understanding cluster health and setting up meaningful alerts.

## Setting Up Claude Code for KSM Workflows

Before diving into examples, ensure Claude Code is configured with access to your Kubernetes context. The most effective approach is creating a dedicated skill for Kubernetes operations.

## Creating a K8s Operations Skill

```yaml
~/.claude/skills/kubernetes-skill/skill.md
name: Kubernetes Operations
description: Assists with Kubernetes resource management and monitoring

Context includes kubeconfig and kubectl access
Focus on Kube State Metrics and Prometheus integration
```

When working with KSM, provide Claude Code with your cluster context, including which metrics you're currently tracking and what alerting rules exist. This context helps generate more accurate and relevant configurations.

## Practical Examples: Building Your KSM Workflow

## Example 1: Deploying and Configuring Kube State Metrics

Claude Code can help you deploy KSM and configure it appropriately for your cluster size:

```yaml
KSM Deployment generated with Claude Code guidance
apiVersion: apps/v1
kind: Deployment
metadata:
 name: kube-state-metrics
 namespace: monitoring
spec:
 replicas: 2
 selector:
 matchLabels:
 app: kube-state-metrics
 template:
 metadata:
 labels:
 app: kube-state-metrics
 spec:
 serviceAccountName: kube-state-metrics
 containers:
 - name: kube-state-metrics
 image: registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.10.0
 ports:
 - containerPort: 8080
 resources:
 requests:
 cpu: 100m
 memory: 190Mi
 limits:
 cpu: 200m
 memory: 250Mi
```

When asking Claude Code to generate this, specify your cluster's scale. For large clusters with hundreds of namespaces, you might need to adjust resource limits and use sharding strategies.

## Example 2: Creating Custom Metrics with PromQL

Kube State Metrics provides a solid foundation, but you'll often need custom metrics tailored to your application. Here's how Claude Code can help:

```promql
Custom PromQL for deployment health
kube_pod_container_status_ready{namespace="production"} 
== 1

Alert for pods stuck in pending state for more than 5 minutes
kube_pod_status_pending{namespace="production"} == 1
 and
time() - kube_pod_start_time{namespace="production"} > 300

Deployment replica mismatch alert
kube_deployment_spec_replicas{namespace="production"}
 !=
kube_deployment_status_replicas_available{namespace="production"}
```

Claude Code excels at writing PromQL queries when you describe what you want to monitor. Provide concrete examples of failure scenarios you're concerned about, and it can generate appropriate queries.

## Example 3: Alerting Rules Configuration

```yaml
prometheus-alerts.yaml - Generated with Claude Code
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
 name: ksm-alerts
 namespace: monitoring
spec:
 groups:
 - name: kube-state-metrics
 rules:
 - alert: PodNotReady
 expr: |
 kube_pod_status_ready{namespace=~".*", condition="true"} == 0
 for: 5m
 labels:
 severity: critical
 annotations:
 summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is not ready"
 description: "Pod has been not ready for more than 5 minutes"
 
 - alert: DeploymentReplicasMismatch
 expr: |
 kube_deployment_spec_replicas != kube_deployment_status_replicas_available
 for: 10m
 labels:
 severity: warning
 annotations:
 summary: "Deployment replicas mismatch"
 description: "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has mismatched replicas"
```

## Advanced Workflow: Extending Kube State Metrics

## Building Custom Metrics Exporters

When KSM doesn't expose the specific metrics you need, consider building a custom exporter. Claude Code can help scaffold this:

```go
// Custom metrics exporter structure
package main

import (
 "github.com/prometheus/client_golang/prometheus"
 "github.com/prometheus/client_golang/prometheus/promhttp"
 "k8s.io/client-go/kubernetes"
 "k8s.io/client-go/rest"
 "net/http"
)

var (
 customMetric = prometheus.NewGaugeVec(
 prometheus.GaugeOpts{
 Name: "myapp_custom_metric",
 Help: "A custom metric for my application",
 },
 []string{"namespace", "pod"},
 )
)

func init() {
 prometheus.MustRegister(customMetric)
}

func collectCustomMetrics(clientset *kubernetes.Clientset) {
 pods, err := clientset.CoreV1().Pods("").List(context.Background(), metav1.ListOptions{})
 if err != nil {
 return
 }
 
 for _, pod := range pods.Items {
 customMetric.WithLabelValues(pod.Namespace, pod.Name).Set(float64(pod.Status.ContainerStatuses[0].RestartCount))
 }
}
```

Integrating with Service-Level Objectives (SLOs)

For teams practicing SRE, Claude Code can help translate KSM metrics into meaningful SLOs:

```yaml
SLO Configuration Example
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
 name: app-slo-monitor
 namespace: monitoring
spec:
 selector:
 matchLabels:
 app: my-application
 endpoints:
 - port: web
 path: /metrics
 namespaceSelector:
 matchNames:
 - production
```

## Actionable Advice for KSM Workflows

## Start Simple and Iterate

Begin with the default KSM metrics. They're battle-tested and cover most common use cases. Only extend with custom metrics when you have specific operational needs that the defaults don't address.

## Resource Planning for KSM

As your cluster grows, KSM resource requirements increase. Here's a practical guideline:

| Cluster Size | Recommended Replicas | CPU Request | Memory Request |
|-------------|---------------------|-------------|----------------|
| < 50 pods | 1 | 100m | 190Mi |
| 50-200 pods | 1-2 | 200m | 250Mi |
| 200+ pods | 2-3 | 500m | 500Mi |

Claude Code can help you calculate these based on your actual cluster metrics.

## Implementing Cost-Based Alerting

One powerful pattern is correlating KSM metrics with cloud provider costs. Use pod restart counts and resource requests to identify inefficient workloads:

```promql
Finding over-provisioned pods
kube_pod_container_resource_requests{resource="cpu"} 
 / on(pod, namespace) kube_pod_status_ready{condition="true"}
 > 0.5
```

This helps identify pods requesting more CPU than they actually use.

## Monitoring Claude Code Itself

Don't forget to monitor your AI-assisted workflows. Track metrics like:
- Time spent configuring KSM rules
- Number of custom metrics created
- Alert fatigue reduction through better queries

This meta-monitoring helps you optimize your own processes.

## Conclusion

Claude Code transforms Kube State Metrics from a complex configuration task into a streamlined workflow. By using AI assistance for generating manifests, writing PromQL queries, and designing alerting strategies, you can build solid Kubernetes monitoring faster while reducing errors.

The key is providing Claude Code with clear context about your cluster environment and specific monitoring requirements. Start with basic deployments, then incrementally add custom metrics as your observability needs evolve.

Remember: effective Kubernetes monitoring isn't about collecting every possible metric, it's about collecting the right metrics that help you understand system health and respond quickly to issues. Claude Code can help you identify and implement exactly what you need.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-kube-state-metrics-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Community Health Metrics Documentation Workflow](/claude-code-community-health-metrics-documentation-workflow/)
- [Claude Code Flutter State Management Workflow Best Practices](/claude-code-flutter-state-management-workflow-bestpractices/)
- [Claude Code for Code Review Metrics Workflow Guide](/claude-code-for-code-review-metrics-workflow-guide/)
- [Claude Code for OpenTelemetry Metrics Workflow Guide](/claude-code-for-opentelemetry-metrics-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


