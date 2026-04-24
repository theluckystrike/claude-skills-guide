---

layout: default
title: "Configure K8s Resource Limits"
description: "Configure Kubernetes CPU and memory resource limits with Claude Code. Right-sizing strategies, OOMKill prevention, and QoS class optimization."
date: 2026-03-14
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /claude-code-kubernetes-resource-limits-guide/
categories: [guides]
tags: [claude-code, kubernetes, resource-management]
reviewed: true
score: 8
last_tested: "2026-04-21"
geo_optimized: true
---

# Claude Code Kubernetes Resource Limits Guide

Kubernetes resource limits control how much CPU and memory your containers can use. Getting these settings right is critical for application performance and cluster efficiency. This guide shows you how to configure resource limits effectively using Claude Code and related skills.

## Why Resource Limits Matter

Without proper resource limits, your pods can consume excessive cluster resources, causing instability for other workloads. Setting limits too low causes application crashes; setting them too high wastes valuable cluster resources and inflates your infrastructure costs.

The key concepts are requests and limits. Requests define the minimum resources Kubernetes guarantees to your container. Limits cap the maximum resources a container can use. Striking the right balance requires understanding your application's actual needs.

When you omit resource limits entirely, your containers run in a "best effort" QoS class. Kubernetes will evict these pods first under memory pressure. If you set requests but no limits, your pods run in the "burstable" class. Setting both requests and limits equal gives you the "guaranteed" QoS class. the highest priority for scheduling and eviction.

```
QoS Class | Requests Set | Limits Set | Eviction Priority
-------------|--------------|------------|-------------------
Guaranteed | Yes | Yes (equal)| Last to evict
Burstable | Yes | Optional | Middle priority
BestEffort | No | No | First to evict
```

For production workloads, always aim for at least Burstable class. Critical services should target Guaranteed where feasible.

## Setting Resource Limits in Your Pod Specification

Here's a basic pod manifest with resource limits:

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: my-app
spec:
 containers:
 - name: app-container
 image: my-app:latest
 resources:
 requests:
 memory: "128Mi"
 cpu: "100m"
 limits:
 memory: "256Mi"
 cpu: "500m"
```

In this example, the container requests 128MB memory and 100 millicpus (0.1 CPU cores). The limits cap memory at 256MB and CPU at 500m (0.5 cores). Kubernetes uses these values to schedule pods on appropriate nodes.

CPU is a compressible resource. when a container exceeds its CPU limit, it gets throttled but keeps running. Memory is incompressible. when a container exceeds its memory limit, the kernel kills it with an OOMKilled exit code. This distinction is crucial when deciding how conservatively to set each limit type.

## Understanding CPU Units

CPU values in Kubernetes can be confusing. Here is a quick reference:

```
Value | Meaning
----------|------------------------------------
1 | 1 full CPU core
500m | 500 millicpus = 0.5 cores
250m | 250 millicpus = 0.25 cores
100m | 100 millicpus = 0.1 cores
2000m | 2000 millicpus = 2 cores (same as "2")
```

The millicpu unit is useful because most microservices need fractions of a core at idle. A Node.js API might idle at 5-10m and spike to 200m under load. Setting the request to 50m and the limit to 500m is perfectly reasonable and reflects real-world usage.

## Using Claude Code to Generate Resource Configurations

Claude Code can help you generate appropriate resource configurations based on your application characteristics. By describing your workload type. whether it's a REST API, background worker, or data processing job. you can get tailored recommendations.

For example, a web API typically needs more CPU for request handling, while a batch processing job might need higher memory for data manipulation. When working with Claude Code, provide context about your workload to receive more accurate configurations.

A practical prompt pattern that works well with Claude Code:

```
"Generate a Kubernetes Deployment manifest for a Node.js REST API that:
- Serves ~500 requests/minute at peak
- Connects to a PostgreSQL database
- Includes health check endpoints at /healthz
- Should use 3 replicas
- Needs appropriate resource limits for a mid-size production cluster"
```

The more context you provide. runtime, traffic patterns, observed memory usage. the more accurate the generated configuration will be. Claude Code can also help you reason through the tradeoffs between different limit settings by asking follow-up questions about your cluster node sizes and other workloads sharing the namespace.

## Practical Examples for Common Workloads

## REST API Service

```yaml
resources:
 requests:
 memory: "256Mi"
 cpu: "250m"
 limits:
 memory: "512Mi"
 cpu: "1000m"
```

REST APIs usually have steady memory usage with CPU spikes during request processing. The request should cover baseline memory needs, while the limit accommodates traffic spikes.

## Background Worker

```yaml
resources:
 requests:
 memory: "512Mi"
 cpu: "500m"
 limits:
 memory: "2Gi"
 cpu: "2000m"
```

Background workers often process batches of data, requiring more memory. The higher memory limit allows them to handle larger datasets efficiently.

## Database-Like Workload

```yaml
resources:
 requests:
 memory: "1Gi"
 cpu: "1000m"
 limits:
 memory: "4Gi"
 cpu: "4000m"
```

Database containers need generous memory allocations for caching and query processing. CPU limits can be higher since database operations are often CPU-intensive.

Sidecar Container (Log Shipper or Agent)

```yaml
resources:
 requests:
 memory: "32Mi"
 cpu: "10m"
 limits:
 memory: "128Mi"
 cpu: "100m"
```

Sidecar containers like Fluentd or Datadog agents should be given tight limits so they do not compete with your main application container. These processes are generally predictable and tolerate throttling well.

## Configuring Limits for Deployments

While pod specifications work for individual pods, most production workloads use Deployments. Here's how to set resource limits in a Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: api-deployment
spec:
 replicas: 3
 selector:
 matchLabels:
 app: api
 template:
 metadata:
 labels:
 app: api
 spec:
 containers:
 - name: api
 image: my-api:latest
 ports:
 - containerPort: 8080
 resources:
 requests:
 memory: "256Mi"
 cpu: "200m"
 limits:
 memory: "512Mi"
 cpu: "1000m"
```

Deployments apply the same resource limits to all replica pods automatically. This ensures consistent resource allocation across your application instances.

With 3 replicas using the configuration above, your Deployment will reserve 3 x 256Mi = 768Mi of memory and 3 x 200m = 600m CPU across the cluster. Always account for total replica count when estimating cluster capacity requirements.

## Using LimitRange to Enforce Namespace Defaults

For teams where developers might forget to set resource limits, LimitRange objects enforce namespace-wide defaults:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
 name: default-limits
 namespace: production
spec:
 limits:
 - default:
 cpu: "500m"
 memory: "256Mi"
 defaultRequest:
 cpu: "100m"
 memory: "128Mi"
 type: Container
```

Any container deployed to the `production` namespace without explicit resource settings will automatically receive these defaults. This prevents BestEffort pods from appearing in production and protects neighboring workloads from runaway containers.

## Monitoring and Tuning Your Limits

After deployment, monitor actual resource usage to refine your limits. Tools like kubectl top show current consumption:

```bash
kubectl top pod api-deployment-abc123
```

For namespace-wide visibility:

```bash
kubectl top pods -n production --sort-by=memory
kubectl top pods -n production --sort-by=cpu
```

Compare actual usage against your limits. If containers consistently hit their limits, consider increasing them. If they rarely approach their limits, you is overallocating and should consider reducing them.

A useful pattern is to check usage ratios. If a container requests 256Mi but only ever uses 80Mi at peak, your request is 3x larger than needed. that reserved memory cannot be used by other workloads:

```bash
Get actual vs requested memory for all pods in a namespace
kubectl top pods -n production --no-headers | while read name cpu mem; do
 echo "$name: actual=${mem}"
done
```

For sustained analysis, deploy Prometheus and Grafana alongside your workloads, or use the Kubernetes Metrics Server. The goal is to set limits as close to actual usage as possible while maintaining headroom for traffic spikes and error conditions. This maximizes cluster efficiency without risking application stability.

## Handling Memory Limits Gracefully

When containers exceed their memory limits, Kubernetes terminates them with an OOMKilled status. Your application should handle SIGTERM signals for graceful shutdown. Implement proper shutdown hooks to complete in-flight requests before termination.

For Node.js applications:

```javascript
process.on('SIGTERM', () => {
 console.log('SIGTERM received, shutting down gracefully');
 server.close(() => {
 console.log('HTTP server closed');
 process.exit(0);
 });
 // Force exit after 10 seconds
 setTimeout(() => process.exit(1), 10000);
});
```

For Java applications, set JVM heap sizes within your container memory limits. A common pattern:

```yaml
env:
- name: JAVA_OPTS
 value: "-XX:MaxHeapSize=384m -XX:ActiveProcessorCount=1"
```

This prevents the JVM from exceeding your container's memory allocation. The JVM defaults to using a fraction of total system memory, which in a container context means it looks at node memory rather than container limits. leading to OOMKills. Always set explicit heap bounds for JVM workloads.

For Go applications, you can limit the garbage collector's memory target:

```yaml
env:
- name: GOMEMLIMIT
 value: "400MiB"
```

This Go runtime environment variable (introduced in Go 1.19) tells the GC to run more aggressively before you approach the container limit, reducing the chance of an OOMKill under burst conditions.

## Horizontal Pod Autoscaling with Resource Limits

Resource requests are the basis for HPA (Horizontal Pod Autoscaler) calculations. The HPA measures CPU or memory usage as a percentage of the container's request value:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: api-hpa
spec:
 scaleTargetRef:
 apiVersion: apps/v1
 kind: Deployment
 name: api-deployment
 minReplicas: 2
 maxReplicas: 10
 metrics:
 - type: Resource
 resource:
 name: cpu
 target:
 type: Utilization
 averageUtilization: 70
```

This HPA scales the deployment when average CPU usage across pods exceeds 70% of their CPU request. If your request is set too low, the HPA will scale aggressively even when actual load is modest. If set too high, the HPA will be slow to respond to genuine traffic spikes.

Accurate CPU requests are therefore not just about cost efficiency. they directly control your autoscaling behavior.

## Claude Code Skills That Enhance Kubernetes Workflows

Several Claude skills can improve your Kubernetes resource management:

The pdf skill helps you generate documentation for your resource configurations. You can create deployment guides or architecture documents in PDF format for team sharing.

When implementing test-driven development with the tdd skill, you can write tests that verify your application behavior under different resource constraints. This ensures your code handles OOM (out of memory) situations gracefully.

The frontend-design skill indirectly supports Kubernetes work by helping you build monitoring dashboards that visualize resource usage. These dashboards help teams understand consumption patterns.

For maintaining historical data about your configurations, the supermemory skill stores and retrieves context about past resource limit decisions. This helps teams learn from previous tuning efforts.

## Best Practices Summary

Start with requests based on baseline measurements. Set limits conservatively at first, then adjust based on observed usage. Use horizontal pod autoscaling (HPA) for workloads with variable demand. Implement liveness and readiness probes to help Kubernetes manage pod lifecycle effectively.

Document your resource limit decisions. When you change limits, record the reasoning. This helps future maintainers understand why specific values were chosen.

Regularly review and adjust limits as your application evolves. What works today might not suit your needs next quarter.

Key rules to internalize:

- Never run production workloads without resource requests. this protects the cluster from noisy neighbors
- Set memory limits conservatively. OOMKills are always preferable to cascading node pressure
- Use LimitRange for namespace-level safety nets. it catches configurations that slip through code review
- Align CPU requests with HPA thresholds. your autoscaling behavior depends on accurate request values
- Test OOM behavior in staging. deliberately trigger OOMKills to verify your application restarts cleanly

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-kubernetes-resource-limits-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code Kubernetes Cost Optimization Guide](/claude-code-kubernetes-cost-optimization-guide/)
- [Claude Code Kubernetes Helm Charts Guide](/claude-code-kubernetes-helm-charts-guide/)
- [Claude Code Kubernetes HPA Autoscaling Guide](/claude-code-kubernetes-hpa-autoscaling-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


