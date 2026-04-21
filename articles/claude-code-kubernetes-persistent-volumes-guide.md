---
layout: default
title: "Claude Code Kubernetes Persistent Volumes Guide (2026)"
description: "Learn how to manage Kubernetes persistent volumes effectively with Claude Code. Practical examples for PVCs, storage classes, and dynamic provisioning."
last_tested: "2026-04-22"
date: 2026-03-14
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /claude-code-kubernetes-persistent-volumes-guide/
categories: [guides]
tags: [claude-code, kubernetes, persistent-volumes, storage]
reviewed: true
score: 8
geo_optimized: true
---

# Claude Code Kubernetes Persistent Volumes Guide

Persistent volumes in Kubernetes solve a fundamental challenge: containers are ephemeral by design, but many applications need durable storage that survives pod restarts and rescheduling. This guide demonstrates how to work with PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs) using Claude Code and complementary skills.

## Understanding Persistent Volumes in Kubernetes

A PersistentVolume represents a piece of storage in the cluster that exists independently of any individual pod. When a pod needs persistent storage, it requests storage through a PersistentVolumeClaim. This separation allows storage to be managed separately from pod lifecycle.

There are two main approaches to provisioning persistent storage: static and dynamic. Static provisioning involves creating PVs manually, while dynamic provisioning uses StorageClasses to create storage on-demand. Most modern deployments rely on dynamic provisioning through the cloud-provider's native storage solutions.

## Creating a PersistentVolumeClaim

A PersistentVolumeClaim requests a specific amount of storage with optional access modes. Here's a basic PVC definition:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: app-data-pvc
spec:
 accessModes:
 - ReadWriteOnce
 resources:
 requests:
 storage: 10Gi
 storageClassName: standard
```

The `accessModes` field defines how the volume can be mounted. `ReadWriteOnce` allows mounting by a single node. For multi-node access, use `ReadWriteMany` with compatible storage backends like NFS or CephFS.

When you apply this PVC, Kubernetes binds it to an available PersistentVolume that satisfies the requirements. You can then reference this PVC in your pod specification:

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: app-with-storage
spec:
 containers:
 - name: app
 image: my-app:latest
 volumeMounts:
 - name: data-volume
 mountPath: /app/data
 volumes:
 - name: data-volume
 persistentVolumeClaim:
 claimName: app-data-pvc
```

## Using StorageClasses for Dynamic Provisioning

StorageClasses enable dynamic volume provisioning, eliminating the need to pre-create PersistentVolumes. Each StorageClass defines a provisioner and parameters for the underlying storage system.

Common provisioners include:
- `kubernetes.io/gce-pd` for Google Cloud Engine
- `kubernetes.io/aws-ebs` for Amazon Elastic Block Store
- `kubernetes.io/azure-disk` for Azure Disk Storage
- `nginx-ingress` for NFS-backed storage

Here's a PVC that uses a specific StorageClass:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: fast-storage-pvc
spec:
 accessModes:
 - ReadWriteOnce
 resources:
 requests:
 storage: 50Gi
 storageClassName: fast-ssd
```

To create a StorageClass for fast SSD-backed storage:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
 name: fast-ssd
provisioner: kubernetes.io/gce-pd
parameters:
 type: pd-ssd
 replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
```

The `WaitForFirstConsumer` binding mode delays volume binding until a pod using the PVC is scheduled, allowing the scheduler to choose an optimal node based on the pod's requirements.

## Managing Persistent Volumes with Claude Code

Claude Code can generate Kubernetes manifests efficiently. When working on storage-heavy applications, combine Claude Code with the `pdf` skill to document your storage architecture, or use the `tdd` skill to write tests that verify data persistence across pod restarts.

For example, ask Claude Code: "Create a StatefulSet with persistent storage for a PostgreSQL database, including appropriate resource limits and storage class configuration." Claude will generate the manifest with proper volume templates:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
 name: postgres-statefulset
spec:
 serviceName: postgres
 replicas: 3
 selector:
 matchLabels:
 app: postgres
 template:
 metadata:
 labels:
 app: postgres
 spec:
 containers:
 - name: postgres
 image: postgres:15
 volumeMounts:
 - name: postgres-data
 mountPath: /var/lib/postgresql/data
 volumeClaimTemplates:
 - metadata:
 name: postgres-data
 spec:
 accessModes: ["ReadWriteOnce"]
 storageClassName: fast-ssd
 resources:
 requests:
 storage: 20Gi
```

## Resizing Persistent Volumes

Kubernetes supports volume expansion for most cloud-provider storage types. To enable resizing, the StorageClass must have `allowVolumeExpansion` set to true:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
 name: standard
provisioner: kubernetes.io/gce-pd
allowVolumeExpansion: true
```

Once enabled, you can resize a PVC by modifying the storage request:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: app-data-pvc
spec:
 resources:
 requests:
 storage: 20Gi # Increased from 10Gi
```

The expansion happens automatically for CSI-based provisioners. For older provisioners, you may need to delete and recreate the pod after the resize.

## Data Backup Strategies

Persistent volumes contain your application state, making backup critical. Common approaches include:

Volume snapshots capture the volume state at a specific point in time:

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
 name: data-backup
spec:
 volumeSnapshotClassName: standard
 source:
 persistentVolumeClaimName: app-data-pvc
```

For application-level backups, consider scheduling jobs that export data to object storage. Tools like Velero provide cluster-level disaster recovery, including persistent volume snapshots.

## Access Modes in Practice

Choosing the wrong access mode is one of the most common sources of confusion with persistent volumes. Kubernetes defines three modes, but not all storage backends support all three.

`ReadWriteOnce` (RWO) mounts the volume as read-write on a single node. This covers the majority of production use cases: databases, message queues, application logs. AWS EBS, GCE PD, and Azure Disk all support RWO exclusively, if your application needs a volume on more than one node simultaneously, you cannot use these backends.

`ReadOnlyMany` (ROX) allows the volume to be mounted read-only on many nodes at once. This is useful for distributing configuration files, static assets, or reference data across a fleet of pods without the complexity of a shared writable volume.

`ReadWriteMany` (RWX) allows read-write access from multiple nodes. This requires a network-attached storage solution. On AWS you would use EFS via the `efs.csi.aws.com` provisioner. On GKE, Filestore provides NFS-backed volumes. On-premises deployments commonly use CephFS or an NFS server. RWX volumes carry additional latency compared to block storage, measure throughput before committing shared-write volumes to performance-sensitive paths.

Here is an RWX claim against EFS on AWS:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: shared-assets-pvc
spec:
 accessModes:
 - ReadWriteMany
 resources:
 requests:
 storage: 100Gi
 storageClassName: efs-sc
```

And the corresponding StorageClass:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
 name: efs-sc
provisioner: efs.csi.aws.com
parameters:
 provisioningMode: efs-ap
 fileSystemId: fs-0123456789abcdef0
 directoryPerms: "700"
```

## StatefulSet Volume Lifecycle

StatefulSets handle volumes differently from Deployments. Each replica in a StatefulSet gets its own PVC created from the `volumeClaimTemplates` section. Critically, these PVCs are not deleted when the StatefulSet is scaled down or deleted, this is intentional. The data survives the workload.

This behavior matters operationally. When you scale a StatefulSet from three replicas down to one, the PVCs for replicas 1 and 2 remain bound. When you scale back up, those exact volumes are reattached to the revived pods. For a Kafka cluster this means partitions reconnect to their original brokers. For a Redis Cluster it means slots are not reshuffled.

The flip side: you must manage PVC cleanup explicitly. After decommissioning a StatefulSet, clean up orphaned claims:

```bash
kubectl get pvc -l app=postgres
kubectl delete pvc postgres-data-postgres-statefulset-1
kubectl delete pvc postgres-data-postgres-statefulset-2
```

For production teardowns, verify there is no data you need before deleting these claims. The `kubectl get pv` output will show volumes in Released state after their PVC is deleted; the Reclaim Policy on the PV determines whether the underlying disk is deleted or retained.

## Reclaim Policies

The Reclaim Policy controls what happens to the underlying storage resource when a PVC is deleted:

- `Retain`: The PV moves to Released state. The disk is preserved and must be manually reclaimed. Useful when you need to extract data from a decommissioned PVC.
- `Delete`: The PV and the underlying cloud disk are deleted automatically. This is the default for most dynamic provisioners.
- `Recycle`: Deprecated. Do not use in new deployments.

Set Reclaim Policy on the StorageClass:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
 name: retain-storage
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Retain
allowVolumeExpansion: true
parameters:
 type: pd-standard
```

For critical production databases, prefer `Retain`. A bug in a deployment pipeline that accidentally deletes a StatefulSet should not cascade into data loss. With `Retain`, the disk sits in Released state waiting for manual intervention. You can create a new PV referencing the same disk and bind it to a new PVC to recover.

## Using Claude Code to Audit Volume Configuration

Claude Code is well-suited for analyzing existing Kubernetes manifests and identifying configuration gaps. Feed it your current YAML files with a prompt like: "Review these StatefulSet and StorageClass definitions. Identify any missing reclaim policies, volumes without resource limits, or PVCs that use the default StorageClass where a named class would be more appropriate."

Claude will cross-reference the manifests and flag issues like:

- PVCs with no explicit `storageClassName` that will fall back to cluster defaults, which may have `Delete` reclaim policy
- StatefulSets missing resource requests on their `volumeClaimTemplates`, making capacity planning impossible
- StorageClasses without `allowVolumeExpansion: true`, which will block resizing later

Combine Claude Code with the `tdd` skill to write integration tests that verify storage behavior. A practical test suite for a stateful application should include: a test that writes data to the mounted volume, deletes the pod, waits for it to reschedule, and confirms the data persists.

## Common Pitfalls and Solutions

One frequent issue is PVCs stuck in Pending state. This typically occurs when no available PV matches the claim requirements or the StorageClass provisioner is misconfigured. Check events on the PVC to identify the root cause:

```bash
kubectl describe pvc <pvc-name>
```

Look for messages like "no persistent volumes available for this claim" (static provisioning exhausted), "storageclass not found" (incorrect StorageClass name), or provisioner-specific errors indicating the cloud API call failed due to permissions.

Another common problem is pod startup failures due to volume mount issues. Verify the PVC is bound first:

```bash
kubectl get pvc
```

A PVC in `Bound` state with a pod still failing to start usually points to a mount path conflict, incorrect file permissions on the mounted volume, or a previous pod holding the volume on a different node (common with RWO volumes after node failures). Force-deleting a stuck pod with `kubectl delete pod --grace-period=0 --force` often releases the volume lock.

For production workloads, always set appropriate resource requests and limits on your storage. Use the `supermemory` skill to maintain documentation of your storage architecture decisions and the reasoning behind storage class selections.

## Summary

Persistent volumes provide essential durability for stateful applications in Kubernetes. Master the PVC workflow: request storage through claims, select appropriate StorageClasses for your performance needs, and implement backup strategies before deploying to production. Claude Code accelerates this process by generating correct manifests and identifying potential issues in your configuration.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-kubernetes-persistent-volumes-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code for OpenEBS Storage Workflow Tutorial](/claude-code-for-openebs-storage-workflow-tutorial/)
- [Claude Code Kubernetes Cost Optimization Guide](/claude-code-kubernetes-cost-optimization-guide/)
- [Claude Code Kubernetes Helm Charts Guide](/claude-code-kubernetes-helm-charts-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


