---
layout: default
title: "Claude Code for EKS Karpenter (2026)"
description: "Automate EKS Karpenter node provisioning with Claude Code. NodePool config, consolidation policies, and cost-optimized scaling workflow patterns."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-eks-karpenter-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
last_tested: "2026-04-21"
geo_optimized: true
---
Managing Amazon EKS clusters with Karpenter doesn't have to be complex. With Claude Code, you can automate Karpenter provisioning, optimize node lifecycle management, and build reproducible infrastructure workflows. This guide walks you through practical examples to integrate Claude Code into your EKS Karpenter operations.

## Understanding the EKS Karpenter Workflow

Karpenter is an open-source Kubernetes autoscaler that dynamically provisions nodes based on workload requirements. It replaces the traditional Kubernetes Cluster Autoscaler (CAS) with faster, more cost-effective node provisioning. Understanding the differences helps you see where Claude Code adds the most value:

| Feature | Cluster Autoscaler | Karpenter |
|---|---|---|
| Node provisioning speed | 2–5 minutes | 30–60 seconds |
| Instance selection | Fixed node groups | Any instance type matching constraints |
| Spot diversification | Manual node group per type | Automatic across hundreds of types |
| Bin packing | Limited | Native consolidation |
| AWS integration | ASG-based | Direct EC2 Fleet API |
| Config complexity | Node group YAML | NodePool + EC2NodeClass YAML |

When combined with Claude Code, you can create intelligent automation scripts that handle everything from initial cluster setup to ongoing node lifecycle management. Claude Code excels at generating the YAML configurations, validating policies, identifying misconfigured resources, and writing reusable shell scripts for routine operations.

The typical Karpenter workflow involves four phases:

1. Bootstrap. Install Karpenter, create IAM roles, and configure EC2NodeClass
2. Provision. Define NodePools that match your workload profiles
3. Operate. Monitor node health, costs, and scaling events
4. Optimize. Tune consolidation policies and right-size instance selection

Claude Code can assist at every phase. Let's walk through each one.

## Setting Up Claude Code for EKS Karpenter

Before diving into workflows, ensure Claude Code is configured with appropriate AWS credentials and kubectl access. You'll need:

- AWS CLI configured with appropriate IAM permissions (EKS, EC2, IAM, SNS, Cost Explorer)
- kubectl configured for your EKS cluster
- Karpenter installed on your cluster (v0.37+ for the stable v1 API)
- helm and eksctl are helpful but not required

Once Claude Code has access to your terminal and file system, you can begin creating automation scripts. Start by verifying your cluster connectivity and Karpenter health:

```bash
Authenticate to the cluster
aws eks update-kubeconfig --name your-cluster-name --region us-west-2

Verify node and pod status
kubectl get nodes -o wide
kubectl get pods -n karpenter

Check Karpenter version and controller logs
kubectl get deployment karpenter -n karpenter -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=50
```

If Karpenter is not yet installed, ask Claude Code to generate the full bootstrap commands for your account and region. Claude Code can produce the complete `eksctl` or `helm` installation sequence, including the required IAM role for service accounts (IRSA) setup:

```bash
Ask Claude Code to generate this for your specific account
export KARPENTER_VERSION="1.1.1"
export CLUSTER_NAME="production-eks"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION="us-west-2"

Install Karpenter via Helm
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
 --version "${KARPENTER_VERSION}" \
 --namespace karpenter \
 --create-namespace \
 --set "settings.clusterName=${CLUSTER_NAME}" \
 --set "settings.interruptionQueue=${CLUSTER_NAME}" \
 --set controller.resources.requests.cpu=1 \
 --set controller.resources.requests.memory=1Gi \
 --set controller.resources.limits.cpu=1 \
 --set controller.resources.limits.memory=1Gi \
 --wait
```

## Creating Karpenter NodeClasses and Provisioners with Claude Code

One of the most powerful applications of Claude Code is generating Karpenter configurations from a plain-language description. Instead of memorizing the exact YAML schema, you describe your requirements conversationally.

## EC2NodeClass

The `EC2NodeClass` defines AWS-specific settings that all NodePools in a cluster share or reference:

```yaml
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
 name: default
spec:
 amiFamily: AL2023 # Amazon Linux 2023
 role: KarpenterNodeRole # IAM role attached to provisioned nodes
 subnetSelectorTerms:
 - tags:
 karpenter.sh/discovery: production
 securityGroupSelectorTerms:
 - tags:
 karpenter.sh/discovery: production
 amiSelectorTerms:
 - alias: al2023@latest # Always use the latest AL2023 AMI
 blockDeviceMappings:
 - deviceName: /dev/xvda
 ebs:
 volumeSize: 50Gi
 volumeType: gp3
 iops: 3000
 throughput: 125
 encrypted: true
 userData: |
 #!/bin/bash
 /etc/eks/bootstrap.sh production-eks
 echo "vm.max_map_count=262144" >> /etc/sysctl.conf
 sysctl -p
 tags:
 Environment: production
 ManagedBy: karpenter
```

Claude Code can generate this file after you describe your VPC tagging scheme, the IAM role name, and any custom `userData` requirements. It will also validate that your subnet and security group selector tags exist in your account.

## Provisioner for Compute-Intensive Workloads

For a Provisioner targeting compute-intensive workloads, you might ask Claude Code to generate a configuration that:

- Uses On-Demand instances for reliability
- Targets specific instance types
- Sets appropriate consolidation policies
- Defines TTL for idle nodes

Claude Code produces the complete YAML:

```yaml
apiVersion: karpenter.sh/v1
kind: Provisioner
metadata:
 name: compute-workload
spec:
 requirements:
 - key: kubernetes.io/arch
 operator: In
 values: ["amd64"]
 - key: karpenter.sh/capacity-type
 operator: In
 values: ["on-demand"]
 - key: node.kubernetes.io/instance-type
 operator: In
 values: ["c5.2xlarge", "c5.4xlarge", "c6i.2xlarge", "c6i.4xlarge", "m5.2xlarge"]
 limits:
 cpu: 1000
 memory: 1000Gi
 consolidation:
 enabled: true
 ttlSecondsAfterEmpty: 300
 ttlSecondsUntilExpired: 86400 # Recycle nodes after 24h for security patching
 providerRef:
 name: default
```

Note the use of `ttlSecondsUntilExpired: 86400`. This ensures nodes are regularly recycled, which keeps them on the latest AMI and reduces the risk of long-lived configuration drift. Claude Code can help you choose an appropriate TTL based on your patching policy.

## Building Automated Node Pool Management

NodePools allow you to define different node characteristics for various workload types. A well-structured production environment typically uses three or more NodePools with different cost and performance profiles:

## General Purpose NodePool

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
 name: general-purpose
spec:
 template:
 metadata:
 labels:
 workload-type: general
 spec:
 requirements:
 - key: karpenter.sh/capacity-type
 operator: In
 values: ["on-demand"]
 - key: karpenter.k8s.aws/instance-category
 operator: In
 values: ["m", "c"]
 - key: karpenter.k8s.aws/instance-generation
 operator: Gt
 values: ["4"] # Prefer newer generations
 - key: kubernetes.io/arch
 operator: In
 values: ["amd64"]
 nodeClassRef:
 apiVersion: karpenter.k8s.aws/v1
 kind: EC2NodeClass
 name: default
 taints: [] # No taints. accepts all workloads
 limits:
 cpu: 500
 memory: 2000Gi
 disruption:
 consolidationPolicy: WhenUnderutilized
 consolidateAfter: 30s
 expireAfter: 720h # 30 days
```

## Memory-Optimized NodePool

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
 name: memory-optimized
spec:
 template:
 metadata:
 labels:
 workload-type: memory
 spec:
 requirements:
 - key: karpenter.sh/capacity-type
 operator: In
 values: ["on-demand"]
 - key: karpenter.k8s.aws/instance-category
 operator: In
 values: ["r"] # r6i, r7i, r8g families
 - key: karpenter.k8s.aws/instance-generation
 operator: Gt
 values: ["5"]
 nodeClassRef:
 apiVersion: karpenter.k8s.aws/v1
 kind: EC2NodeClass
 name: default
 taints:
 - key: workload-type
 value: memory
 effect: NoSchedule # Only accept pods that tolerate this taint
 limits:
 cpu: 200
 memory: 4000Gi
 disruption:
 consolidationPolicy: WhenUnderutilized
 consolidateAfter: 60s
```

## Spot NodePool for Batch Workloads

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
 name: spot-batch
spec:
 template:
 metadata:
 labels:
 workload-type: spot-batch
 spec:
 requirements:
 - key: karpenter.sh/capacity-type
 operator: In
 values: ["spot"]
 - key: karpenter.k8s.aws/instance-category
 operator: In
 values: ["c", "m", "r"]
 - key: karpenter.k8s.aws/instance-size
 operator: NotIn
 values: ["nano", "micro", "small"] # Avoid tiny instances
 - key: kubernetes.io/arch
 operator: In
 values: ["amd64", "arm64"] # Both arches for flexibility
 nodeClassRef:
 apiVersion: karpenter.k8s.aws/v1
 kind: EC2NodeClass
 name: default
 taints:
 - key: workload-type
 value: spot-batch
 effect: NoSchedule
 limits:
 cpu: 1000
 disruption:
 consolidationPolicy: WhenEmpty
 consolidateAfter: 10s
 budgets:
 - nodes: "10%" # Never disrupt more than 10% of nodes at once
```

Claude Code can generate these configurations and also create corresponding Helm values files for GitOps deployments. Ask it to produce a Helmfile or Kustomize overlay that manages all three NodePools as a single unit.

## Matching Workloads to NodePools

Pods select a NodePool through `nodeSelector` or `nodeAffinity`. Here is a deployment using the memory-optimized pool:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: redis-cache
spec:
 replicas: 3
 selector:
 matchLabels:
 app: redis-cache
 template:
 metadata:
 labels:
 app: redis-cache
 spec:
 nodeSelector:
 workload-type: memory # Matches the NodePool label
 tolerations:
 - key: workload-type
 value: memory
 effect: NoSchedule # Required to schedule on the tainted pool
 containers:
 - name: redis
 image: redis:7-alpine
 resources:
 requests:
 memory: "4Gi"
 cpu: "500m"
 limits:
 memory: "4Gi"
```

## Implementing Cost Optimization Workflows

Karpenter's consolidation capability is one of its strongest cost levers. Claude Code can help you implement comprehensive strategies at multiple levels.

## Right-Sizing Recommendations

Ask Claude Code to analyze your current workload patterns and recommend NodePool configurations:

```bash
Collect current node usage data
kubectl top nodes --sort-by=cpu > node-utilization.txt
kubectl get nodes -o json | jq '
 .items[] | {
 name: .metadata.name,
 instance_type: .metadata.labels["node.kubernetes.io/instance-type"],
 capacity_type: .metadata.labels["karpenter.sh/capacity-type"],
 cpu_capacity: .status.capacity.cpu,
 memory_capacity: .status.capacity.memory
 }
' > node-inventory.json

Collect pod resource requests per node
kubectl get pods -A -o json | jq '
 [.items[] | select(.spec.nodeName != null) | {
 node: .spec.nodeName,
 pod: .metadata.name,
 namespace: .metadata.namespace,
 cpu_request: (.spec.containers[0].resources.requests.cpu // "0"),
 memory_request: (.spec.containers[0].resources.requests.memory // "0")
 }]
' > pod-requests.json
```

Feed these files to Claude Code:

```
Review node-utilization.txt, node-inventory.json, and pod-requests.json.
Identify:
1. Nodes where CPU usage is below 20%. these are consolidation candidates
2. Any instance types being provisioned that are consistently oversized
3. Workloads that have no resource requests set (they block effective bin-packing)
Recommend specific NodePool changes to reduce our monthly compute cost.
```

## Budget Alerts and Automation

Create a Claude Code script that monitors Karpenter-driven costs and triggers alerts:

```bash
#!/bin/bash
karpenter-cost-monitor.sh. run daily via cron or GitHub Actions
set -euo pipefail

CLUSTER_NAME="production-eks"
BUDGET_THRESHOLD="${COST_THRESHOLD:-1000}"
SNS_TOPIC_ARN="${COST_ALERT_SNS_ARN:?}"

Get current month's EC2 costs for nodes tagged with our cluster
COST=$(aws ce get-cost-and-usage \
 --time-period "Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d)" \
 --granularity MONTHLY \
 --metrics UnblendedCost \
 --filter '{
 "And": [
 {"Dimensions": {"Key": "SERVICE", "Values": ["Amazon EC2"]}},
 {"Tags": {"Key": "karpenter.sh/nodepool", "Values": ["general-purpose", "memory-optimized", "spot-batch"]}}
 ]
 }' \
 --query "ResultsByTime[0].Total.UnblendedCost.Amount" \
 --output text)

echo "Current month Karpenter EC2 cost: \$$COST"

if python3 -c "import sys; sys.exit(0 if float('$COST') > $BUDGET_THRESHOLD else 1)"; then
 MESSAGE="Karpenter EC2 cost for ${CLUSTER_NAME} has reached \$${COST} this month, exceeding threshold of \$${BUDGET_THRESHOLD}."
 echo "ALERT: $MESSAGE"
 aws sns publish \
 --topic-arn "$SNS_TOPIC_ARN" \
 --subject "Karpenter Cost Alert: ${CLUSTER_NAME}" \
 --message "$MESSAGE"
fi
```

## Spot Interruption Handling

Karpenter automatically handles Spot interruption notices via the SQS interruption queue, but you should also configure Pod Disruption Budgets to prevent too many pods from being evicted at once:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
 name: api-server-pdb
spec:
 minAvailable: 2 # Always keep at least 2 replicas running during disruptions
 selector:
 matchLabels:
 app: api-server
```

Ask Claude Code to audit all your Deployments and generate PDB manifests for any that are missing one:

```
Review all Deployments in the default and production namespaces.
For any Deployment with 2 or more replicas that does not have a PodDisruptionBudget,
generate a PDB that keeps at least 50% of replicas available at all times.
Output each PDB as a separate YAML file named {deployment-name}-pdb.yaml.
```

## Disaster Recovery and Migration

Claude Code can also assist with disaster recovery scenarios involving Karpenter. A solid backup and validation workflow ensures you can recover quickly from misconfigurations or cluster failures.

## Backup All Karpenter Resources

```bash
#!/usr/bin/env bash
karpenter-backup.sh
set -euo pipefail

BACKUP_DIR="karpenter-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

Export all Karpenter custom resources
echo "Exporting NodePools..."
kubectl get nodepools -o yaml > "$BACKUP_DIR/nodepools.yaml"

echo "Exporting EC2NodeClasses..."
kubectl get ec2nodeclasses -o yaml > "$BACKUP_DIR/ec2nodeclasses.yaml"

echo "Exporting NodeClaims (currently provisioned nodes)..."
kubectl get nodeclaims -o yaml > "$BACKUP_DIR/nodeclaims.yaml"

Also export Karpenter controller config
echo "Exporting Karpenter configmaps..."
kubectl get configmap -n karpenter -o yaml > "$BACKUP_DIR/karpenter-configmaps.yaml"

echo "Backup saved to $BACKUP_DIR/"
tar czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR/"
echo "Archive: ${BACKUP_DIR}.tar.gz"
```

## Validate Cluster State Before Maintenance

Before applying Karpenter updates or making significant changes, validate the cluster is in a healthy state:

```bash
#!/usr/bin/env bash
pre-maintenance-check.sh
set -euo pipefail

echo "=== Karpenter Controller Health ==="
kubectl get deployment karpenter -n karpenter
kubectl get pods -n karpenter -o wide

echo ""
echo "=== NodePool Status ==="
kubectl get nodepools

echo ""
echo "=== NodeClaim Status ==="
kubectl get nodeclaims

echo ""
echo "=== Recent Karpenter Events ==="
kubectl get events -n karpenter --sort-by='.lastTimestamp' | tail -20

echo ""
echo "=== Nodes Not Ready ==="
kubectl get nodes | grep -v " Ready " || echo "All nodes are Ready"

echo ""
echo "=== Pending Pods ==="
kubectl get pods -A --field-selector=status.phase=Pending | head -20 || echo "No pending pods"
```

Pipe the output to Claude Code and ask:

```
Review the pre-maintenance check output and tell me:
1. Is the cluster in a healthy state to apply a Karpenter upgrade?
2. Are there any NodeClaims in an unexpected state?
3. Are the pending pods caused by resource constraints or node taints?
```

## Rolling Back a Bad NodePool Configuration

If a NodePool configuration causes nodes to fail to provision, you can restore from backup:

```bash
Identify the broken NodePool
kubectl describe nodepool general-purpose | tail -30
kubectl get events --field-selector reason=FailedProvisioning -n karpenter

Roll back to the last known-good configuration
kubectl apply -f karpenter-backup-20260314-120000/nodepools.yaml

Verify recovery
kubectl get nodepools
kubectl get nodeclaims
```

## Monitoring Karpenter with Prometheus and Grafana

Karpenter exposes a Prometheus metrics endpoint. Claude Code can generate the ServiceMonitor and alerting rules needed to ingest these metrics:

```yaml
karpenter-service-monitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
 name: karpenter
 namespace: karpenter
 labels:
 release: prometheus # Must match your Prometheus operator selector label
spec:
 selector:
 matchLabels:
 app.kubernetes.io/name: karpenter
 endpoints:
 - port: http-metrics
 interval: 30s
 path: /metrics
```

Key Karpenter metrics to alert on:

| Metric | Alert Condition | Meaning |
|--------|----------------|---------|
| `karpenter_nodes_total` | Rapid increase | Possible runaway scaling |
| `karpenter_provisioner_scheduling_duration_seconds` | p99 > 60s | Provisioning is slow |
| `karpenter_interruption_actions_performed_total` | Spike | High Spot interruption rate |
| `karpenter_deprovisioning_actions_performed_total` | Stops increasing | Consolidation is stalled |
| `karpenter_nodeclaims_terminating` | Stuck > 10 min | Node drain issue |

Ask Claude Code to generate a Prometheus `PrometheusRule` for these alerts, then a Grafana dashboard JSON that visualizes node count, cost per hour, and consolidation efficiency over time.

## Best Practices for Claude Code and Karpenter

To get the most out of your Claude Code and Karpenter integration:

1. Version Control Everything

Store all Karpenter configurations in Git and use Claude Code to generate diff reviews before applying changes. A useful pre-apply workflow:

```bash
Preview what changes will be applied
kubectl diff -f nodepools/ 2>/dev/null | head -100
```

Paste the diff into Claude Code and ask it to flag any changes that could disrupt running workloads.

2. Always Use Dry Run Mode

Never apply Claude Code-generated Kubernetes manifests without previewing them first:

```bash
kubectl apply --dry-run=client -f nodepool-update.yaml
kubectl apply --dry-run=server -f nodepool-update.yaml # Validates against live API
```

3. Implement Budget Limits on Every NodePool

A misconfigured workload can cause Karpenter to provision thousands of nodes. Always set `limits` in your NodePool definitions and configure AWS Service Quotas alerts as a second safety layer.

4. Use Weighted NodePools for Spot Fallback

Rather than a single mixed NodePool, use `weight` to define a preference order. On-Demand as fallback for Spot:

```yaml
In your spot NodePool spec:
spec:
 weight: 100 # Higher weight = preferred by scheduler

In your on-demand fallback NodePool spec:
spec:
 weight: 1 # Lower weight = used only when spot is unavailable
```

5. Monitor Continuously

Use Claude Code to generate monitoring dashboards and alerting rules for Karpenter metrics. Schedule the pre-maintenance health check script to run daily and pipe its output into a Slack channel for passive visibility.

6. Document Your Workflows

Have Claude Code generate documentation for your Karpenter setup as you build your automation. A simple prompt at the end of each work session:

```
Review the YAML files I've created today for Karpenter and write a
RUNBOOK.md section explaining: what each NodePool is for,
how workloads select them, and the steps to add a new NodePool type.
```

## Troubleshooting Common Issues

Claude Code is particularly useful for troubleshooting because it can correlate information from multiple sources, controller logs, events, node status, and pod conditions, at once.

## Pods Stuck in Pending

```bash
Collect diagnostic data
kubectl describe pod <pending-pod-name> -n <namespace> > pod-describe.txt
kubectl get events -n karpenter --sort-by='.lastTimestamp' > karpenter-events.txt
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=100 > karpenter-logs.txt
```

Feed all three files to Claude Code:

```
A pod has been Pending for 10 minutes. Review pod-describe.txt,
karpenter-events.txt, and karpenter-logs.txt and explain why
Karpenter is not provisioning a node for this pod.
Is it a resource request issue, a NodePool selector mismatch,
a taint/toleration problem, or an AWS capacity issue?
```

## Node Consolidation Not Working

```bash
kubectl get nodepools -o yaml > nodepools.yaml
kubectl get nodeclaims -o wide > nodeclaims.txt
kubectl top nodes > node-utilization.txt
```

```
Review nodepools.yaml, nodeclaims.txt, and node-utilization.txt.
I have nodes that appear underutilized but are not being consolidated.
What conditions would prevent Karpenter from consolidating these nodes?
Check for: PodDisruptionBudgets, do-not-disrupt annotations, non-evictable system pods, or consolidation policy settings.
```

## Conclusion

Claude Code transforms Karpenter management from manual configuration to intelligent automation. By using Claude Code's ability to understand infrastructure requirements and generate valid Kubernetes manifests, you can streamline your EKS operations while maintaining best practices.

The workflows in this guide cover the full operational lifecycle: bootstrapping a Karpenter installation, defining NodePools for different workload profiles, implementing cost optimization and alerting, setting up monitoring, and handling disaster recovery. Each workflow is designed to be composable, start with simple Provisioner generation and progressively build more sophisticated automation as your Karpenter deployment grows.

The key is to treat Claude Code as a collaborative partner: describe your requirements clearly, review generated configurations before applying them (always use `--dry-run`), and let automation handle the repetitive tasks while you focus on architecture decisions. With this approach, you get the speed and cost efficiency of Karpenter without the operational toil of managing complex Kubernetes infrastructure manually.


---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-eks-karpenter-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for EKS IRSA Workflow](/claude-code-for-eks-irsa-workflow/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

