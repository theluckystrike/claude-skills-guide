---

layout: default
title: "Claude Code for EKS IRSA Workflow (2026)"
description: "Learn how to automate EKS IAM Roles for Service Accounts (IRSA) configuration using Claude Code. Practical examples and actionable guidance for developers."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-eks-irsa-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
last_tested: "2026-04-22"
---


Claude Code for EKS IRSA Workflow

Managing IAM roles for Kubernetes service accounts in Amazon EKS can be complex. Manual configuration of OIDC providers, IAM policies, and Kubernetes service accounts often leads to errors and security misconfigurations. This guide shows how to use Claude Code to automate and simplify your EKS IRSA workflow, making it reproducible, secure, and maintainable.

## Understanding EKS IRSA Architecture

Before diving into the Claude Code workflow, let's briefly review how EKS IRSA works. When you configure IRSA, you create an IAM role with a trust policy that allows the Kubernetes service account to assume it. The EKS cluster's OIDC provider mediates this trust relationship, enabling pods to use AWS credentials without storing long-lived secrets.

The key components are:

1. OIDC Provider - Must be configured for your EKS cluster
2. IAM Role - With a trust policy referencing the service account
3. IAM Policy - Defining the actual permissions
4. Kubernetes Service Account - Annotated with the IAM role ARN

Understanding the request flow helps when debugging: a pod starts, the Kubernetes mutating webhook injects a projected service account token volume into the pod spec, the AWS SDK reads that token, calls `sts:AssumeRoleWithWebIdentity`, and receives temporary credentials. This entire chain depends on each component being configured correctly. which is exactly where manual setups break down and Claude Code's automation pays off.

## IRSA vs. Other AWS Credential Patterns

Before committing to IRSA, it helps to understand why it is preferred over the alternatives:

| Pattern | How it Works | Key Drawbacks |
|---------|-------------|---------------|
| Instance Profile | Node IAM role shared by all pods | No pod-level isolation; overly broad permissions |
| Secret-mounted credentials | Long-lived AWS keys in Kubernetes Secrets | Secret rotation risk; credentials can leak |
| Kube2IAM / Kiam | Node-level metadata proxy | Additional operational overhead; deprecated in practice |
| IRSA | Pod-scoped short-lived token via OIDC | Preferred: per-service isolation, automatic rotation |

IRSA is the recommended pattern for EKS workloads because credentials are short-lived (1 hour by default), scoped to a single service account, and never stored in Kubernetes Secrets.

## Setting Up Claude Code for IRSA Automation

To automate IRSA workflows with Claude Code, you'll want to create a specialized skill. This skill will help generate the necessary configurations and validate your setup. Here's a skill definition that handles IRSA operations:

```yaml
---
name: eks-irsa
description: "Manage EKS IAM Roles for Service Accounts"
---
```

This skill uses three essential tools: bash for executing AWS CLI commands, read_file for inspecting existing configurations, and write_file for generating manifests.

When you invoke the skill, give Claude the context it needs to generate accurate configurations. A good prompt provides the cluster name, AWS account ID, region, target namespace, service account name, and the AWS services the pod needs to access. With these inputs, Claude can produce the complete IRSA configuration without requiring you to remember the exact syntax for trust policy conditions or the correct annotation key name.

Example invocation prompt for Claude Code:

```
/eks-irsa

Cluster: prod-cluster-1
Region: us-east-1
Account ID: 123456789012
Namespace: payments
Service Account: payment-processor
Required permissions: read/write to S3 bucket "payments-receipts-prod",
 publish to SNS topic "payment-events", read from SQS queue "payment-jobs"
```

Claude will respond with the complete OIDC verification steps, IAM policy JSON, trust policy JSON, Kubernetes manifest, and apply commands in the correct order.

## Automating OIDC Provider Configuration

The first step in any IRSA setup is ensuring your EKS cluster has an OIDC provider. Claude Code can check this and guide you through the configuration. Here's a practical workflow:

```bash
Check if OIDC provider exists for your cluster
aws eks describe-cluster --name your-cluster-name \
 --query 'cluster.identity.oidc.issuer' \
 --output text
```

This returns the issuer URL, for example:
`https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE`

The OIDC ID is the hex string after `/id/`. You then need to verify this OIDC provider is registered in IAM:

```bash
List OIDC providers in your account
aws iam list-open-id-connect-providers

Check if your cluster's OIDC provider is registered
aws iam list-open-id-connect-providers | \
 grep EXAMPLED539D4633E53DE1B71EXAMPLE
```

If the OIDC provider doesn't exist, Claude can help you create it using `eksctl` or the AWS CLI. The `eksctl` approach is simpler:

```bash
Create OIDC provider using eksctl (recommended)
eksctl utils associate-iam-oidc-provider \
 --cluster your-cluster-name \
 --region us-east-1 \
 --approve
```

Alternatively, using the AWS CLI directly:

```bash
Get the OIDC issuer URL
OIDC_URL=$(aws eks describe-cluster \
 --name your-cluster-name \
 --query 'cluster.identity.oidc.issuer' \
 --output text)

Get the OIDC thumbprint
THUMBPRINT=$(echo | openssl s_client -servername \
 "$(echo $OIDC_URL | sed 's|https://||')" \
 -connect "$(echo $OIDC_URL | sed 's|https://||'):443" 2>&1 | \
 openssl x509 -fingerprint -noout | \
 sed 's/SHA1 Fingerprint=//' | tr -d ':' | tr '[:upper:]' '[:lower:]')

Create the OIDC provider
aws iam create-open-id-connect-provider \
 --url "$OIDC_URL" \
 --client-id-list sts.amazonaws.com \
 --thumbprint-list "$THUMBPRINT"
```

Claude Code can generate this entire sequence for you and adapt it to your specific cluster configuration.

## Generating IAM Role Trust Policies

The trust policy is critical for security. It determines which service account can assume the role. Claude Code can generate this policy dynamically based on your inputs:

```json
{
 "Version": "2012-10-17",
 "Statement": [
 {
 "Effect": "Allow",
 "Principal": {
 "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.REGION.amazonaws.com/id/CLUSTER_OIDC_ID"
 },
 "Action": "sts:AssumeRoleWithWebIdentity",
 "Condition": {
 "StringEquals": {
 "oidc.eks.REGION.amazonaws.com/id/CLUSTER_OIDC_ID:sub": "system:serviceaccount:NAMESPACE:SERVICE_ACCOUNT_NAME"
 }
 }
 }
 ]
}
```

Notice how the condition restricts the trust to a specific namespace and service account. this follows the principle of least privilege.

For the payments example above, Claude would generate a concrete policy:

```bash
Create the trust policy file
cat > trust-policy.json << 'EOF'
{
 "Version": "2012-10-17",
 "Statement": [
 {
 "Effect": "Allow",
 "Principal": {
 "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
 },
 "Action": "sts:AssumeRoleWithWebIdentity",
 "Condition": {
 "StringEquals": {
 "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:sub": "system:serviceaccount:payments:payment-processor",
 "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:aud": "sts.amazonaws.com"
 }
 }
 }
 ]
}
EOF

Create the IAM role
aws iam create-role \
 --role-name payment-processor-irsa \
 --assume-role-policy-document file://trust-policy.json \
 --description "IRSA role for payment-processor service account"
```

Note the addition of the `aud` condition (`sts.amazonaws.com`). This is a security hardening measure that restricts the token's audience and is recommended by AWS as of 2024.

## Creating IAM Permission Policies

The trust policy controls who can assume the role; the permission policy controls what they can do once they have assumed it. For the payments service example:

```json
{
 "Version": "2012-10-17",
 "Statement": [
 {
 "Sid": "S3PaymentsReceiptsAccess",
 "Effect": "Allow",
 "Action": [
 "s3:GetObject",
 "s3:PutObject",
 "s3:DeleteObject"
 ],
 "Resource": "arn:aws:s3:::payments-receipts-prod/*"
 },
 {
 "Sid": "S3PaymentsReceiptsList",
 "Effect": "Allow",
 "Action": "s3:ListBucket",
 "Resource": "arn:aws:s3:::payments-receipts-prod"
 },
 {
 "Sid": "SNSPaymentEvents",
 "Effect": "Allow",
 "Action": "sns:Publish",
 "Resource": "arn:aws:sns:us-east-1:123456789012:payment-events"
 },
 {
 "Sid": "SQSPaymentJobs",
 "Effect": "Allow",
 "Action": [
 "sqs:ReceiveMessage",
 "sqs:DeleteMessage",
 "sqs:GetQueueAttributes"
 ],
 "Resource": "arn:aws:sqs:us-east-1:123456789012:payment-jobs"
 }
 ]
}
```

Claude Code generates this permission policy by reasoning about your stated requirements. It also surfaces common mistakes. for example, if you ask for S3 access but forget `s3:ListBucket` on the bucket ARN (not the object ARN), Claude will include it because list permission requires a separate statement targeting the bucket itself rather than `bucket/*`.

```bash
Attach the permission policy to the role
aws iam put-role-policy \
 --role-name payment-processor-irsa \
 --policy-name payment-processor-permissions \
 --policy-document file://permission-policy.json
```

## Creating Kubernetes Service Account Manifests

Once the IAM role exists, you need to create the Kubernetes service account with the correct annotation. Claude Code can generate this manifest:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
 name: my-app-sa
 namespace: production
 annotations:
 eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-app-role
```

The annotation must match exactly with the IAM role ARN. Claude can validate this match and alert you if there's a discrepancy.

For the payments service, the complete manifest includes additional recommended annotations:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
 name: payment-processor
 namespace: payments
 annotations:
 eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/payment-processor-irsa
 eks.amazonaws.com/token-expiration: "86400"
 labels:
 app: payment-processor
 managed-by: claude-code
```

The `eks.amazonaws.com/token-expiration` annotation lets you extend the token lifetime beyond the default 86,400 seconds (24 hours) if your workload requires it, though the default is appropriate for most applications.

After applying the service account manifest, verify the annotation was set correctly:

```bash
kubectl apply -f service-account.yaml

kubectl get serviceaccount payment-processor \
 -n payments \
 -o jsonpath='{.metadata.annotations}'
```

## End-to-End Workflow with Claude Code

Here's a practical end-to-end workflow you can execute with Claude:

1. Initialize the IRSA setup - Provide your cluster name, namespace, and desired permissions
2. Verify OIDC provider - Claude checks if the provider exists and generates the creation commands if not
3. Generate configurations - Claude creates the IAM policy, trust policy, and service account manifest as separate files
4. Apply resources in order - Create the IAM role, attach the policy, then apply the Kubernetes manifest
5. Verify the setup - Check that pods can successfully assume the role

The ordering matters. The IAM role must exist before the Kubernetes service account references it, otherwise pods that start before the role is created will fail to authenticate. Claude Code understands this dependency and generates the apply commands in the correct sequence.

```bash
Step 1: Create the IAM role with trust policy
aws iam create-role \
 --role-name payment-processor-irsa \
 --assume-role-policy-document file://trust-policy.json

Step 2: Attach the permission policy
aws iam put-role-policy \
 --role-name payment-processor-irsa \
 --policy-name payment-processor-permissions \
 --policy-document file://permission-policy.json

Step 3: Apply the Kubernetes service account
kubectl apply -f service-account.yaml

Step 4: Verify the role ARN annotation
kubectl get sa payment-processor -n payments -o yaml

Step 5: Run a verification pod
kubectl run test-irsa \
 --image=amazon/aws-cli \
 --restart=Never \
 --serviceaccount=payment-processor \
 -n payments \
 -- aws sts get-caller-identity
```

If the pod can retrieve caller identity using IRSA, your setup is working correctly. The response will show the assumed role ARN rather than the node's instance profile, confirming that pod-level identity is functioning.

```bash
Check the test pod output
kubectl logs test-irsa -n payments

Expected output:
{
 "UserId": "AROAIOSFODNN7EXAMPLE:botocore-session-1234567890",
 "Account": "123456789012",
 "Arn": "arn:aws:sts::123456789012:assumed-role/payment-processor-irsa/botocore-session-1234567890"
}

Clean up the test pod
kubectl delete pod test-irsa -n payments
```

## Using Claude Code to Audit Existing IRSA Configurations

One of the most valuable uses of Claude Code is auditing existing IRSA setups across a cluster. Over time, applications accumulate roles with stale permissions or misconfigured trust policies. Claude can help you systematically review them:

```bash
List all service accounts with IRSA annotations across all namespaces
kubectl get serviceaccounts --all-namespaces \
 -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.metadata.annotations.eks\.amazonaws\.com/role-arn}{"\n"}{end}' | \
 grep -v "^.*\t.*\t$"
```

Feed this output to Claude and ask it to cross-reference each role ARN against your IAM roles, check that the trust policies are correctly scoped, and flag any roles that grant permissions beyond what the service account likely needs. This kind of audit is tedious to do manually but straightforward for Claude to reason through systematically.

## Best Practices for IRSA with Claude Code

When automating IRSA workflows, follow these actionable best practices:

Use separate roles per application - Don't share IAM roles across multiple applications. Each service account should have its own role with minimal permissions specific to that application. Sharing roles means a compromised pod in one namespace can use permissions intended for a different application.

Always validate OIDC configuration - Before creating IAM roles, verify that your cluster's OIDC provider is properly configured. Misconfiguration here is the most common IRSA failure point. If the OIDC provider's thumbprint drifts, all IRSA in your cluster stops working simultaneously.

Use namespace restrictions - In the trust policy, always specify the namespace in the condition. This prevents cross-namespace privilege escalation. A service account in the `default` namespace should not be able to assume a role intended for a `payments` namespace service account.

Add the audience condition - Include `aud: sts.amazonaws.com` in the trust policy condition. This prevents tokens issued for other purposes from being used to assume your role.

Implement rotation awareness - If you need to rotate IAM roles, Claude Code can help you update the service account annotations without downtime by using rolling deployments. The key insight is that pods only acquire credentials at startup, so rotating an annotation requires a pod restart to take effect.

Tag IAM roles for auditability - Include tags on your IAM roles that identify the cluster, namespace, and service account:

```bash
aws iam tag-role \
 --role-name payment-processor-irsa \
 --tags \
 Key=eks-cluster,Value=prod-cluster-1 \
 Key=k8s-namespace,Value=payments \
 Key=k8s-service-account,Value=payment-processor \
 Key=managed-by,Value=claude-code
```

Audit your IRSA usage - Regularly review which service accounts have IAM role annotations and whether those roles still match the principle of least privilege. Use AWS CloudTrail to see which roles are actively being assumed and remove roles for decommissioned services.

## Troubleshooting Common IRSA Issues

Even with automation, issues can arise. Here are common problems and how Claude Code can help diagnose them:

Pod cannot assume role - Check the trust policy. Ensure the OIDC provider ID matches exactly and the service account name includes the namespace. The most common mistake is a mismatch between the trust policy's `sub` condition value and the actual service account name. Use Claude to diff your trust policy against the expected format.

Permission denied errors - Verify the IAM policy attached to the role contains the required permissions. Use the AWS IAM policy simulator to validate before applying:

```bash
Simulate S3 access for the IRSA role
aws iam simulate-principal-policy \
 --policy-source-arn arn:aws:iam::123456789012:role/payment-processor-irsa \
 --action-names s3:GetObject \
 --resource-arns arn:aws:s3:::payments-receipts-prod/test-key
```

OIDC provider not found - Ensure the OIDC provider is associated with your AWS account and the issuer URL matches your cluster's OIDC endpoint. This error often appears after cluster upgrades or when working across multiple AWS accounts.

Token expiration errors - If pods run long-running jobs exceeding 24 hours, they may see credential expiration. Increase the token expiration annotation on the service account or ensure the application refreshes credentials using the SDK's built-in credential chain.

Webhook mutation not applied - If the projected token volume is not injected into the pod, check that the `eks-pod-identity-webhook` is running in `kube-system` and that the pod's service account has the IRSA annotation. Pods in namespaces with the `eks.amazonaws.com/skip-pod-identity: true` label will not receive the injection.

```bash
Check if the webhook is running
kubectl get pods -n kube-system | grep pod-identity-webhook

Verify token projection on a running pod
kubectl exec -n payments my-pod -- \
 ls /var/run/secrets/eks.amazonaws.com/serviceaccount/
```

## Comparing IRSA Setup Approaches

| Approach | Setup Time | Error Risk | Repeatability | Claude Code Benefit |
|----------|-----------|------------|---------------|---------------------|
| Manual (AWS Console + kubectl) | High | High | Low | Full generation and validation |
| Terraform/CDK | Medium | Medium | High | Review and fix existing code |
| eksctl commands | Low | Low | Medium | Wrap in repeatable skill |
| Claude Code skill | Low | Low | High | Best for ad-hoc and new services |

Claude Code is particularly valuable for the initial setup of new services where you need to create all components from scratch. For infrastructure managed at scale with Terraform or CDK, Claude Code is better used as a reviewer and debugger of existing IaC rather than as the primary generator.

## Conclusion

Claude Code transforms EKS IRSA from a manual, error-prone process into a repeatable, secure workflow. By generating correct IAM policies, validating trust relationships, and creating proper Kubernetes manifests, Claude helps you implement IRSA correctly on the first try.

Start by creating a dedicated skill for IRSA operations in your Claude Code setup. Then, for each new application requiring AWS access, use Claude to generate the complete IRSA configuration. This approach ensures consistency, security, and auditability across your EKS workloads.

Use Claude Code's audit capabilities periodically to review your existing IRSA configurations and remove stale permissions. Security drift in IAM roles is a real risk in active clusters, and having an automated review step keeps your least-privilege posture intact over time.

Remember: IRSA is about security. Always prefer more restrictive trust policies, use dedicated roles per application, tag your roles for discoverability, and regularly audit your configurations. Claude Code makes this disciplined approach practical and scalable.


---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-eks-irsa-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for EKS Karpenter Workflow: A Complete Guide](/claude-code-for-eks-karpenter-workflow/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
- [Claude Code for Split.io Experimentation Workflow](/claude-code-for-split-io-experimentation-workflow/)
- [Claude Code For Go Benchmark — Complete Developer Guide](/claude-code-for-go-benchmark-workflow-tutorial-guide/)
- [Claude Code for New Relic APM Workflow Guide](/claude-code-for-new-relic-apm-workflow-guide/)
- [Claude Code For Chargebee — Complete Developer Guide](/claude-code-for-chargebee-subscription-workflow/)
- [Claude Code for Clojure re-frame Workflow Guide](/claude-code-for-clojure-re-frame-workflow-guide/)
- [Claude Code for DDoS Mitigation Workflow Guide](/claude-code-for-ddos-mitigation-workflow-guide/)
- [Claude Code for Semantic Versioning Workflow Tutorial](/claude-code-for-semantic-versioning-workflow-tutorial/)
- [Claude Code for Charm Bracelet Workflow Guide](/claude-code-for-charm-bracelet-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Get started →** Generate your project setup with our [Project Starter](/starter/).

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).
