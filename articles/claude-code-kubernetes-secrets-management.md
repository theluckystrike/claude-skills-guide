---
layout: default
title: "Claude Code Kubernetes Secrets"
description: "Learn how to manage Kubernetes secrets effectively using Claude Code. This guide covers native methods, external secrets operators, and automation."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-kubernetes-secrets-management/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---
{% raw %}
Managing secrets in Kubernetes is a critical skill for any developer deploying applications to production. Whether you're handling API keys, database credentials, or TLS certificates, understanding how to manage these sensitive values securely directly impacts your application's security posture. Claude Code provides several approaches to streamline Kubernetes secrets management, from direct kubectl operations to sophisticated external secrets integrations.

## Understanding Kubernetes Native Secrets

Kubernetes has built-in support for secrets through the Secret resource type. You can create secrets manually using kubectl, but this approach has limitations. Base64 encoding isn't encryption, and storing secrets in plain text within YAML files poses security risks, especially when committing to version control.

Here's a basic example of creating a secret manually:

```bash
kubectl create secret generic db-credentials \
 --from-literal=username=admin \
 --from-literal=password=securepassword123
```

This creates a generic secret that can be mounted as environment variables or files within your pods. However, managing secrets this way becomes cumbersome at scale. Each secret must be created individually, and there's no built-in mechanism for synchronization with external secret management systems.

## Secret Types and When to Use Them

Kubernetes defines several built-in secret types, each suited to a specific purpose:

| Type | Use Case | Key Fields |
|---|---|---|
| `Opaque` | Generic key-value data, most common | Arbitrary |
| `kubernetes.io/dockerconfigjson` | Private container registry credentials | `.dockerconfigjson` |
| `kubernetes.io/tls` | TLS certificates and private keys | `tls.crt`, `tls.key` |
| `kubernetes.io/service-account-token` | Service account API tokens | `token`, `ca.crt` |
| `kubernetes.io/basic-auth` | Username/password pairs | `username`, `password` |
| `kubernetes.io/ssh-auth` | SSH private keys | `ssh-privatekey` |

Using the correct type matters because Kubernetes validates the required fields and some controllers. like cert-manager and Ingress controllers. specifically look for the `kubernetes.io/tls` type when mounting certificates.

## The Base64 Misconception

A persistent source of confusion is thinking that base64-encoded values in a Secret manifest are protected. They are not. Base64 is an encoding scheme, not encryption. Anyone who can read the Secret object via kubectl or the Kubernetes API can trivially decode the values:

```bash
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 -d
```

This is why secrets at rest in etcd are a concern. The protection you actually want comes from three places: RBAC restricting who can read Secret objects, encryption at rest for etcd, and avoiding storing secret manifests with actual values in version control.

## External Secrets Operator Approach

The External Secrets Operator (ESO) has become the standard solution for Kubernetes secrets management. It synchronizes secrets from external secret stores like AWS Secrets Manager, HashiCorp Vault, or Azure Key Vault into Kubernetes secrets. This approach provides centralized secret management with audit logs and automatic rotation.

To get started with ESO, you install the operator and configure a ClusterSecretStore that points to your external secrets provider. Then you define ExternalSecret resources that specify which secrets to sync:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
 name: api-keys-secret
spec:
 refreshInterval: 1h
 secretStoreRef:
 name: vault-backend
 kind: ClusterSecretStore
 target:
 name: api-keys
 creationPolicy: Owner
 data:
 - secretKey: STRIPE_API_KEY
 remoteRef:
 key: production/stripe
 property: api_key
```

This configuration syncs the Stripe API key from HashiCorp Vault into a Kubernetes secret named `api-keys`. The refresh interval determines how often the operator checks for secret updates. You can adjust this based on your rotation requirements. more frequent rotations warrant shorter intervals.

## Configuring a ClusterSecretStore for AWS Secrets Manager

For teams running on AWS, Secrets Manager is often the most natural external store. Here is a full ClusterSecretStore definition using IAM roles for service accounts (IRSA):

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
 name: aws-secrets-manager
spec:
 provider:
 aws:
 service: SecretsManager
 region: us-east-1
 auth:
 jwt:
 serviceAccountRef:
 name: external-secrets-sa
 namespace: external-secrets
```

The `serviceAccountRef` points to a Kubernetes service account that has been annotated with the ARN of an IAM role. That IAM role carries a policy granting `secretsmanager:GetSecretValue` on the relevant secrets. This keeps AWS credentials out of the cluster entirely. the pod's projected service account token is exchanged for temporary AWS credentials through the IRSA mechanism.

## Configuring for HashiCorp Vault

For HashiCorp Vault, the setup looks similar but uses Vault's token or Kubernetes auth method:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
 name: vault-backend
spec:
 provider:
 vault:
 server: "https://vault.internal.example.com"
 path: "secret"
 version: "v2"
 auth:
 kubernetes:
 mountPath: "kubernetes"
 role: "external-secrets"
 serviceAccountRef:
 name: external-secrets-sa
 namespace: external-secrets
```

Vault's Kubernetes auth method validates the pod's service account token against the Kubernetes API to issue a Vault token. This avoids hard-coding Vault tokens in cluster configuration and supports automatic token renewal.

## Automating Secrets Management with Claude Code

Claude Code excels at automating repetitive Kubernetes operations. When you describe your secrets architecture in a CLAUDE.md file or system prompt, Claude Code builds up context about which secrets exist in which namespaces, their expected refresh intervals, and the external store paths they map to. This persistent context proves invaluable when debugging issues across multiple environments.

For day-to-day operations, Claude Code can help you:

1. Generate secure secret manifests without exposing values
2. Validate secret configurations before deployment
3. Audit existing secrets across multiple namespaces
4. Implement secret rotation procedures
5. Write tests that verify secrets are properly mounted and accessible

When working with secrets, always follow the principle of least privilege. Use dedicated service accounts for each application and limit secret access to specific namespaces. Claude Code can generate the appropriate Role and RoleBinding YAML for your applications, ensuring proper isolation between workloads.

## Generating RBAC for Secrets

Here is the kind of RBAC scaffolding Claude Code can produce for a typical application that needs to read a specific secret:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
 name: payments-app
 namespace: production
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
 name: payments-secret-reader
 namespace: production
rules:
 - apiGroups: [""]
 resources: ["secrets"]
 resourceNames: ["stripe-keys", "db-credentials"]
 verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
 name: payments-secret-reader-binding
 namespace: production
subjects:
 - kind: ServiceAccount
 name: payments-app
 namespace: production
roleRef:
 kind: Role
 name: payments-secret-reader
 apiGroup: rbac.authorization.k8s.io
```

Scoping the Role to specific `resourceNames` ensures the payments application can only read the two secrets it legitimately needs, not every secret in the namespace. Claude Code can generate this scaffolding quickly if you provide the application name, namespace, and list of required secrets.

## Best Practices for Production Environments

Production environments require stricter secrets management. Never commit actual secret values to version control. Instead, commit only the ExternalSecret definitions that describe which secrets to pull from your external store and how to map them into the cluster.

Consider these security measures:

- Enable encryption at rest for etcd to protect secrets at storage level
- Use pod security policies (or their replacement, Pod Security Admission) to restrict secret access based on workload requirements
- Implement network policies that limit which pods can access secrets
- Enable audit logging for all secret operations for compliance and forensic analysis
- Scan your CI pipeline for secret values accidentally committed to manifests

## Encryption at Rest

Kubernetes supports envelope encryption for secrets at rest in etcd. You configure this through the `EncryptionConfiguration` API on the API server:

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
 - resources:
 - secrets
 providers:
 - aescbc:
 keys:
 - name: key1
 secret: <base64-encoded-32-byte-key>
 - identity: {}
```

Managed Kubernetes services like EKS, GKE, and AKS offer envelope encryption through their respective KMS integrations, which is generally easier to manage than a self-hosted key. Enable this on new clusters before you start storing secrets. retroactively encrypting existing secrets requires rewriting them.

## Detecting Secrets in Version Control

Before any manifest is committed, run a scanner. Tools like `detect-secrets` or `trufflehog` can be configured as pre-commit hooks:

```bash
.pre-commit-config.yaml
repos:
 - repo: https://github.com/Yelp/detect-secrets
 rev: v1.4.0
 hooks:
 - id: detect-secrets
 args: ['--baseline', '.secrets.baseline']
```

This catches the common case of a developer accidentally pasting a real credential into a manifest during testing.

## Handling Secret Rotation

Rotation is one of the most challenging aspects of secrets management. External Secrets Operator simplifies this by automatically updating Kubernetes secrets when the underlying external secrets change. Set appropriate refresh intervals based on your rotation policies. for highly sensitive credentials, consider hourly refreshes.

For manual rotations, create a clear runbook that Claude Code can help execute:

```bash
Update secret in external store first, then sync
kubectl get secret api-keys -o yaml > backup-secret.yaml
kubectl apply -f external-secret-definition.yaml
Verify new secret is available
kubectl get secret api-keys -o jsonpath='{.data.STRIPE_API_KEY}' | base64 -d
```

Always maintain backups before performing rotations, and test your rollback procedures in a staging environment before touching production.

## Zero-Downtime Rotation

The trickiest part of rotation is that running pods hold the old secret value in their environment variables until they restart. File mounts are updated in place by kubelet (with a small delay), but environment variables are not. For database password rotations, this means:

1. Add the new password to the database (the database now accepts both old and new)
2. Update the secret in your external store
3. Wait for ESO to sync the new value to the Kubernetes Secret
4. Trigger a rolling restart of the affected deployment
5. Once all pods are running on the new password, remove the old password from the database

```bash
After verifying the new secret is synced
kubectl rollout restart deployment/payments-app -n production
kubectl rollout status deployment/payments-app -n production
```

The rolling restart replaces pods gradually, so the application stays available throughout the rotation. New pods get the new password; old pods keep running with the old one until the rollout completes. This is only safe if the database accepts both passwords simultaneously, which is why step 1 comes before updating the secret.

## ESO Refresh vs. Force Sync

ESO syncs on the interval you specify plus any time an ExternalSecret is applied or modified. If you need to force an immediate sync outside the normal schedule, delete and recreate the Kubernetes Secret. ESO will recreate it immediately from the external store:

```bash
kubectl delete secret api-keys -n production
ESO recreates it within seconds
kubectl get secret api-keys -n production
```

This is useful after a manual rotation where you don't want to wait for the next scheduled refresh.

## Advanced Patterns

## Secret Templating

For complex deployments, consider implementing secret templating. This allows you to define a single ExternalSecret that generates multiple Kubernetes secrets with different formats based on the consuming application's requirements:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
 name: database-secret
spec:
 refreshInterval: 1h
 secretStoreRef:
 name: vault-backend
 kind: ClusterSecretStore
 target:
 name: database-credentials
 template:
 engineVersion: v2
 data:
 # Some apps want a connection URL
 DATABASE_URL: "postgresql://{{ .username }}:{{ .password }}@{{ .host }}:5432/{{ .dbname }}"
 # Others want individual components
 DB_HOST: "{{ .host }}"
 DB_USER: "{{ .username }}"
 DB_PASS: "{{ .password }}"
 data:
 - secretKey: username
 remoteRef:
 key: production/database
 property: username
 - secretKey: password
 remoteRef:
 key: production/database
 property: password
 - secretKey: host
 remoteRef:
 key: production/database
 property: host
 - secretKey: dbname
 remoteRef:
 key: production/database
 property: dbname
```

Templating handles both scenarios. applications that expect a single `DATABASE_URL` and legacy applications that need individual components. without storing duplicate data in Vault.

## TLS Certificates with cert-manager and ESO

Another advanced pattern involves using secret references in Ingress resources for TLS certificates. Combine the External Secrets Operator with cert-manager to automatically provision and renew TLS certificates from Let's Encrypt or your internal certificate authority:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
 name: app-tls
 namespace: production
spec:
 secretName: app-tls-cert
 dnsNames:
 - app.example.com
 issuerRef:
 name: letsencrypt-prod
 kind: ClusterIssuer
```

cert-manager creates and rotates the secret `app-tls-cert`. Your Ingress resource then references it:

```yaml
spec:
 tls:
 - hosts:
 - app.example.com
 secretName: app-tls-cert
```

This keeps certificate management fully automated. no manual renewals, no expiry alerts to chase down.

## Multi-Cluster Secret Distribution

For organizations running multiple Kubernetes clusters, distributing secrets consistently is a challenge. One approach uses a central Vault cluster as the single source of truth, with each Kubernetes cluster running ESO configured to pull from the same Vault paths. This means a rotation in Vault propagates to all clusters automatically within the configured refresh interval.

Alternatively, tools like Argo CD can manage ExternalSecret definitions across clusters through GitOps, ensuring the secret configuration (not the values) is consistent everywhere.

## Conclusion

Kubernetes secrets management requires careful planning and the right tooling. Combined with the External Secrets Operator, you have a solid framework for managing sensitive data across your clusters. Start with namespace isolation, implement external secrets storage, and automate rotation workflows to maintain strong security without sacrificing developer productivity.

The path to production-grade secrets management follows a natural progression: replace manually created secrets with ExternalSecrets, enable etcd encryption, implement RBAC scoped to specific secret names, add pre-commit scanning, and finally automate rotation with zero-downtime procedures. Each step is independently valuable, so you can improve incrementally rather than attempting a complete overhaul at once.

By following these practices and using Claude Code to generate YAML scaffolding and rotation runbooks, you can establish a secrets management workflow that scales with your infrastructure while maintaining security best practices appropriate for production workloads.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-kubernetes-secrets-management)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Bandwidth Management: A Practical Guide](/chrome-enterprise-bandwidth-management/)
- [Chrome Enterprise Certificate Management: A Practical Guide](/chrome-enterprise-certificate-management/)
- [Chrome Enterprise Extension Management API: A Practical.](/chrome-enterprise-extension-management-api/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


