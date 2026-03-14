---

layout: default
title: "Claude Code Kubernetes HPA Autoscaling Guide"
description: "Learn how to implement Horizontal Pod Autoscaling in Kubernetes using Claude Code. Practical examples for setting up CPU, memory, and custom metric-based autoscaling."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-kubernetes-hpa-autoscaling-guide/
categories: [kubernetes, devops]
tags: [claude-code, kubernetes, autoscaling, hpa]
reviewed: true
score: 8
---

# Claude Code Kubernetes HPA Autoscaling Guide

Horizontal Pod Autoscaling (HPA) automatically adjusts the number of pod replicas based on observed metrics. This capability is essential for handling traffic spikes while optimizing costs during low-traffic periods. This guide demonstrates how to configure HPA using Claude Code and associated skills.

## Understanding Horizontal Pod Autoscaling

HPA monitors resource utilization and scales pods accordingly. The Kubernetes HPA controller checks metrics at regular intervals and adjusts replica counts within defined boundaries. You specify minimum and maximum replica counts, and HPA maintains optimal pod counts based on your chosen metrics.

The autoscaler works with CPU utilization, memory usage, or custom metrics. For most applications, CPU-based autoscaling provides a solid starting point. Memory-based scaling helps applications with variable memory footprints. Custom metrics enable sophisticated scaling decisions based on business-specific indicators.

Before configuring HPA, ensure your cluster runs Kubernetes 1.18 or later for the current API version. You also need metrics-server deployed for resource metrics collection.

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

This configuration scales between 2 and 10 replicas. The autoscaler triggers scaling when CPU exceeds 70% or memory exceeds 80% utilization. The behavior section controls scaling stability, preventing rapid fluctuations.

## Using Claude Code for HPA Configuration

Claude Code accelerates HPA setup through natural language queries. Describe your requirements and receive ready-to-apply configurations. The interaction follows patterns similar to other specialized skills like the frontend-design skill for UI components or the tdd skill for test-driven development workflows.

For example, ask Claude Code to generate an HPA for a specific deployment with custom metric thresholds. Provide context about your application's traffic patterns and resource characteristics. Claude Code considers best practices while generating manifests tailored to your scenario.

When working with complex multi-metric HPA configurations, combine Claude Code with the pdf skill to generate documentation explaining your autoscaling strategy. This documentation helps team members understand scaling behavior and facilitates incident response.

## Custom Metrics for Advanced Autoscaling

Production applications often require scaling beyond simple CPU or memory metrics. Custom metrics enable HPA to respond to application-specific indicators like request queue length, database connection pool utilization, or business metrics such as active user sessions.

To use custom metrics, deploy Prometheus and configure the Prometheus adapter. Here's an example custom metric configuration:

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
  scaleBehavior:
    scaleUp:
      stabilizationWindowSeconds: 60
```

This configuration scales based on requests per second, distributing load across more pods as traffic increases. The supermemory skill proves valuable here, storing historical traffic patterns to help predict optimal scaling decisions.

## Best Practices and Common Pitfalls

Avoid setting minimum replicas too low. Zero replicas means cold starts that delay response times. Set minimums based on your application's startup time and acceptable latency. Similarly, cap maximum replicas to prevent runaway scaling that exhausts cluster resources.

Always set resource requests. HPA calculates utilization based on requested resources, not limits. Without requests, the autoscaler cannot determine actual utilization accurately. Use the Kubernetes resource-limits-guide pattern when configuring pod specifications.

Test your HPA configuration under load. Simulate traffic spikes using tools like hey or k6. Verify that scaling triggers at expected thresholds and that new pods become ready quickly. Monitor the metrics-server to confirm accurate data collection.

Implement scale-down stabilization. Rapid scaling creates instability. The behavior section in your HPA manifest controls stabilization windows. Longer windows reduce churn but may delay cost savings during traffic decreases.

## Monitoring and Observability

Effective autoscaling requires visibility into scaling decisions. Configure Prometheus to scrape metric annotations from the HPA controller. Create dashboards showing replica count over time alongside utilization metrics.

Use the logging-stack-guide skill to set up centralized logging for HPA events. Correlate scaling events with application logs to understand how traffic patterns affect performance. This data informs future tuning decisions.

Regularly review HPA performance. Traffic patterns evolve as applications grow. Reassess threshold values quarterly to ensure they align with current workloads. Document scaling decisions using the ai-coding-tools-for-code-documentation-workflow to maintain institutional knowledge.

## Conclusion

Horizontal Pod Autoscaling transforms Kubernetes deployments into responsive, cost-efficient systems. Start with basic CPU and memory metrics, then evolve toward custom metrics as your observability maturity increases. Claude Code streamlines configuration generation and helps maintain best practices across your cluster.

Combine HPA with other Claude skills for comprehensive infrastructure management. The kubernetes-deployment-workflow skill handles rolling updates, while the helm-charts-guide skill manages complex multi-environment configurations. Together, these tools create robust, self-adjusting workloads that serve users effectively while controlling costs.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
