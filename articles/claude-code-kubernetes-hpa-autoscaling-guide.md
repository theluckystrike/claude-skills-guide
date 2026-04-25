---

layout: default
title: "Claude Code Kubernetes HPA Autoscaling"
description: "Configure Kubernetes HPA autoscaling with Claude Code for CPU, memory, and custom metric-based pod scaling. Working YAML configs and test commands."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: theluckystrike
permalink: /claude-code-kubernetes-hpa-autoscaling-guide/
categories: [guides]
tags: [claude-code, kubernetes, autoscaling, hpa]
reviewed: true
score: 8
geo_optimized: true
---

# Claude Code Kubernetes HPA Autoscaling Guide

Horizontal Pod Autoscaling (HPA) automatically adjusts the number of pod replicas based on observed metrics. This capability is essential for handling traffic spikes while optimizing costs during low-traffic periods. This guide demonstrates how to configure HPA using Claude Code, covering basic CPU and memory scaling, custom metrics, behavior tuning, and the observability you need to trust your autoscaler in production.

## Understanding Horizontal Pod Autoscaling

HPA monitors resource usage and scales pods accordingly. The Kubernetes HPA controller checks metrics at regular intervals (default 15 seconds) and adjusts replica counts within defined boundaries. You specify minimum and maximum replica counts, and HPA maintains optimal pod counts based on your chosen metrics.

The autoscaler works with CPU usage, memory usage, or custom metrics. For most applications, CPU-based autoscaling provides a solid starting point. Memory-based scaling helps applications with variable memory footprints. for example, JVM services that load data into heap on first request. Custom metrics enable sophisticated scaling decisions based on business-specific indicators like request queue depth or active user sessions.

Before configuring HPA, ensure your cluster runs Kubernetes 1.18 or later for the `autoscaling/v2` API. You also need `metrics-server` deployed for resource metrics collection. Verify it is running before any HPA configuration:

```bash
kubectl get deployment metrics-server -n kube-system
kubectl top nodes # Should return CPU/memory data, not an error
```

If `kubectl top` returns an error, HPA will not function regardless of how well you write your manifests. This is one of the most common sources of confusion when first setting up autoscaling. Claude Code can help you diagnose this by asking it to review your cluster configuration.

## How the HPA Algorithm Works

Understanding the scaling algorithm prevents surprises in production. The HPA controller calculates the desired replica count using:

```
desiredReplicas = ceil(currentReplicas * (currentMetricValue / desiredMetricValue))
```

So if you have 4 pods running at 80% CPU and your target is 50%, the controller calculates `ceil(4 * (80 / 50)) = ceil(6.4) = 7` pods. If those 7 pods settle at 55% CPU, the next cycle calculates `ceil(7 * (55 / 50)) = ceil(7.7) = 8` pods. This incremental approach prevents overshooting.

For scale-down, the controller uses a default stabilization window of 300 seconds. It will not scale down until the metrics have indicated fewer replicas are needed for the entire window. This prevents thrashing during brief traffic dips. For scale-up, the default stabilization window is 0 seconds. HPA reacts immediately to load increases.

## Basic HPA Configuration

Create a deployment first, then attach the autoscaler. Here's a complete example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: api-server
 labels:
 app: api-server
spec:
 replicas: 3
 selector:
 matchLabels:
 app: api-server
 template:
 metadata:
 labels:
 app: api-server
 spec:
 containers:
 - name: api-container
 image: myapi:latest
 ports:
 - containerPort: 8080
 resources:
 requests:
 memory: "256Mi"
 cpu: "200m"
 limits:
 memory: "512Mi"
 cpu: "500m"
```

Now create the HPA resource:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: api-server-hpa
spec:
 scaleTargetRef:
 apiVersion: apps/v1
 kind: Deployment
 name: api-server
 minReplicas: 2
 maxReplicas: 10
 metrics:
 - type: Resource
 resource:
 name: cpu
 target:
 type: Utilization
 averageUtilization: 70
 - type: Resource
 resource:
 name: memory
 target:
 type: Utilization
 averageUtilization: 80
 behavior:
 scaleDown:
 stabilizationWindowSeconds: 300
 policies:
 - type: Percent
 value: 10
 periodSeconds: 60
 scaleUp:
 stabilizationWindowSeconds: 0
 policies:
 - type: Percent
 value: 100
 periodSeconds: 15
```

This configuration scales between 2 and 10 replicas. The autoscaler triggers scaling when CPU exceeds 70% or memory exceeds 80% usage. The `behavior` section controls scaling stability, preventing rapid fluctuations.

The scale-down policy removes at most 10% of current replicas per 60-second window. For a 10-pod deployment, that means removing 1 pod per minute during scale-down. The scale-up policy allows doubling the replica count every 15 seconds, enabling rapid response to sudden load spikes.

Apply both resources and verify:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f hpa.yaml
kubectl get hpa api-server-hpa --watch
```

The `--watch` flag shows the HPA status updating in real time. The `TARGETS` column displays `current/desired` usage. If it shows `<unknown>/70%`, the metrics-server is not yet collecting data for those pods. wait 30-60 seconds.

## Using Claude Code for HPA Configuration

Claude Code accelerates HPA setup through natural language queries. Describe your requirements and receive ready-to-apply configurations. A productive workflow looks like this:

1. Paste your existing Deployment manifest into Claude Code and ask it to generate a matching HPA with appropriate thresholds for your traffic pattern.
2. Describe edge cases. "this service spikes 10x during business hours but drops to near-zero at night". and ask Claude Code to suggest min/max replica values and behavior tuning.
3. Ask Claude Code to review your resource requests against your observed p95 CPU usage to check whether your usage targets are realistic.

For example, if you tell Claude Code "my pods typically use 150m CPU under normal load and spike to 400m under peak load, and I have a 200m request set", it will recognize that your normal load is already at 75% usage and suggest either raising your CPU request or lowering your target usage threshold to avoid premature scale-out.

When working with complex multi-metric HPA configurations, combine Claude Code with documentation generation to produce runbooks that explain your autoscaling strategy. These runbooks help on-call engineers understand why replica counts are changing during incidents rather than treating autoscaling as a black box.

## Custom Metrics for Advanced Autoscaling

Production applications often require scaling beyond simple CPU or memory metrics. Custom metrics enable HPA to respond to application-specific indicators like request queue length, database connection pool usage, or business metrics such as active user sessions.

To use custom metrics, deploy Prometheus and configure the Prometheus adapter. Install the adapter with Helm:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus-adapter prometheus-community/prometheus-adapter \
 --set prometheus.url=http://prometheus-server.monitoring.svc.cluster.local \
 --set prometheus.port=80
```

Configure a custom metric mapping in the adapter's ConfigMap:

```yaml
rules:
- seriesQuery: 'http_requests_total{namespace!="",pod!=""}'
 resources:
 overrides:
 namespace:
 resource: namespace
 pod:
 resource: pod
 name:
 matches: "^http_requests_total"
 as: "http_requests_per_second"
 metricsQuery: 'rate(http_requests_total{<<.LabelMatchers>>}[2m])'
```

Now create an HPA that uses the custom metric:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: api-server-custom-hpa
spec:
 scaleTargetRef:
 apiVersion: apps/v1
 kind: Deployment
 name: api-server
 minReplicas: 2
 maxReplicas: 20
 metrics:
 - type: Pods
 pods:
 metric:
 name: http_requests_per_second
 target:
 type: AverageValue
 averageValue: "1000"
 behavior:
 scaleUp:
 stabilizationWindowSeconds: 60
```

This configuration scales based on requests per second per pod. When average RPS per pod exceeds 1000, HPA adds more pods to bring the per-pod average back down. The `type: Pods` metric type means HPA calculates the average across all pods in the deployment. it will scale up if the cluster-wide average exceeds the threshold, even if individual pods vary.

Metric type comparison:

| Metric Type | Calculated As | Best For |
|---|---|---|
| Resource (CPU/Memory) | Average usage % across pods | General workloads |
| Pods | Average value per pod | Request rates, queue depths |
| Object | Single value from a Kubernetes object | Ingress request counts, queue lengths |
| External | Value from outside the cluster | Cloud queue depths, external APIs |

Claude Code is particularly helpful for writing the Prometheus adapter configuration, which has an unintuitive label matcher syntax. Describe your Prometheus metric name and the dimensions you want to expose, and Claude Code generates the correct `seriesQuery` and `metricsQuery` expressions.

## Resource Requests: The Most Important Configuration Detail

HPA calculates usage based on resource requests, not limits. This single fact is responsible for more misconfigured autoscalers than any other issue.

If a pod has `requests.cpu: 100m` but typically uses `300m` under normal load, HPA calculates 300% usage. With a 70% target, HPA will try to scale out immediately even at normal traffic levels, leading to constant unnecessary scaling. Conversely, if requests are set too high. `requests.cpu: 1000m` but actual usage is 100m. HPA will never trigger even under heavy load.

The right approach is to set requests at roughly your p50 usage and limits at your p99 usage. Claude Code can help you derive these values if you provide your Prometheus query output:

```bash
Check actual average CPU usage for your pods over the last hour
kubectl top pods -l app=api-server

Or query Prometheus directly
rate(container_cpu_usage_seconds_total{pod=~"api-server.*"}[5m])
```

Share the output with Claude Code and ask it to recommend appropriate request and limit values along with a corresponding HPA target usage.

## Best Practices and Common Pitfalls

Never set minimum replicas to zero for latency-sensitive services. Zero replicas means cold starts that delay response times when traffic returns. Set minimums based on your application's startup time and acceptable latency. For most stateless services, 2 replicas minimum provides both availability and a baseline for HPA to calculate usage from.

Cap maximum replicas to prevent runaway scaling that exhausts cluster resources. Set your maximum based on your cluster's available capacity minus headroom for other workloads and for rolling updates.

Test your HPA configuration under load. Simulate traffic spikes using tools like `hey` or `k6`:

```bash
Install hey
go install github.com/rakyll/hey@latest

Send 10,000 requests with 200 concurrent workers
hey -n 10000 -c 200 https://your-service.example.com/api/health
```

Watch the HPA status while the load test runs:

```bash
kubectl get hpa api-server-hpa --watch
```

Verify that scaling triggers at expected thresholds and that new pods become ready within an acceptable time. If pods take 3 minutes to become ready, your scale-up behavior window may need adjustment.

Account for pod startup time in your behavior configuration. If your application takes 60 seconds to become ready, setting `scaleUp.stabilizationWindowSeconds: 0` with a `Percent: 100` policy can create a scaling loop. HPA adds pods, they are not ready yet so load stays high, HPA adds more pods, and so on. Consider using a `periodSeconds` equal to your pod startup time plus a 30-second buffer.

Watch for metric lag. Prometheus metrics typically have a 30-60 second scrape delay. HPA decisions based on stale metrics can cause overcorrection. The `averageValue` target should account for this lag. set it slightly below your true maximum capacity so HPA has time to scale before you hit saturation.

## Monitoring and Observability

Effective autoscaling requires visibility into scaling decisions. Kubernetes emits HPA events you can review directly:

```bash
kubectl describe hpa api-server-hpa
```

The Events section at the bottom shows every scaling decision with timestamps and reasons. This is your first stop when diagnosing unexpected behavior.

Configure Prometheus to scrape the `kube-state-metrics` service for HPA state:

```promql
Current replica count
kube_horizontalpodautoscaler_status_current_replicas{horizontalpodautoscaler="api-server-hpa"}

Desired replica count
kube_horizontalpodautoscaler_status_desired_replicas{horizontalpodautoscaler="api-server-hpa"}

Min/max boundaries
kube_horizontalpodautoscaler_spec_min_replicas{horizontalpodautoscaler="api-server-hpa"}
kube_horizontalpodautoscaler_spec_max_replicas{horizontalpodautoscaler="api-server-hpa"}
```

Create a Grafana dashboard with four panels: current vs desired replicas over time, the metric values that drive scaling decisions, pod readiness lag (time from scale event to pods-ready), and HTTP error rate during scaling events. Correlating error spikes with scaling events tells you whether your readiness probes are correctly preventing traffic from reaching pods that are not ready.

Set up alerting for the case where desired replicas equal max replicas for an extended period. This indicates your service is saturated and the autoscaler cannot help. you either need to raise the maximum or investigate a performance regression.

Use centralized logging to capture HPA controller events alongside application logs. This lets you correlate scaling events with application-level metrics like p99 latency and error rates, which provides the data you need to tune thresholds over time.

Regularly review HPA performance. Traffic patterns evolve as applications grow. Reassess threshold values quarterly to ensure they align with current workloads. Document scaling decisions and configuration changes to maintain institutional knowledge about why specific thresholds were chosen.

## Conclusion

Horizontal Pod Autoscaling transforms Kubernetes deployments into responsive, cost-efficient systems. Start with basic CPU and memory metrics, set resource requests accurately, and configure behavior windows that match your pod startup time. Then evolve toward custom metrics as your observability maturity increases and you have real traffic data to calibrate thresholds against.

Claude Code streamlines configuration generation and helps maintain best practices across your cluster. Use it to audit existing HPA configurations, generate Prometheus adapter rules, and review whether your resource requests match your observed usage. Combine HPA with other infrastructure patterns. rolling update deployments for zero-downtime releases, pod disruption budgets to protect against simultaneous scaling and node maintenance, and cluster autoscaling to handle the case where HPA wants more pods but the cluster lacks available nodes. Together these tools create solid, self-adjusting workloads that serve users effectively while controlling infrastructure costs.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-kubernetes-hpa-autoscaling-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code Kubernetes Cost Optimization Guide](/claude-code-kubernetes-cost-optimization-guide/)
- [Claude Code Kubernetes Helm Charts Guide](/claude-code-kubernetes-helm-charts-guide/)
- [Claude Code Kubernetes Ingress Configuration](/claude-code-kubernetes-ingress-configuration/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


