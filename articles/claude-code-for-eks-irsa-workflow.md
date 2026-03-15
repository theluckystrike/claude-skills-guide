---
layout: default
title: "Claude Code for EKS IRSA Workflow"
description: "Learn how to automate EKS IAM Roles for Service Accounts (IRSA) configuration using Claude Code. Practical examples and actionable guidance for developers."
date: 2026-03-15
author: Claude Skills Guide
permalink: /claude-code-for-eks-irsa-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code for EKS IRSA Workflow

Managing IAM roles for Kubernetes service accounts in Amazon EKS can be complex. Manual configuration of OIDC providers, IAM policies, and Kubernetes service accounts often leads to errors and security misconfigurations. This guide shows how to use Claude Code to automate and simplify your EKS IRSA workflow, making it reproducible, secure, and maintainable.

## Understanding EKS IRSA Architecture

Before diving into the Claude Code workflow, let's briefly review how EKS IRSA works. When you configure IRSA, you create an IAM role with a trust policy that allows the Kubernetes service account to assume it. The EKS cluster's OIDC provider mediates this trust relationship, enabling pods to use AWS credentials without storing long-lived secrets.

The key components are:

1. **OIDC Provider** - Must be configured for your EKS cluster
2. **IAM Role** - With a trust policy referencing the service account
3. **IAM Policy** - Defining the actual permissions
4. **Kubernetes Service Account** - Annotated with the IAM role ARN

## Setting Up Claude Code for IRSA Automation

To automate IRSA workflows with Claude Code, you'll want to create a specialized skill. This skill will help generate the necessary configurations and validate your setup. Here's a skill definition that handles IRSA operations:

```yaml
---
name: eks-irsa
description: "Manage EKS IAM Roles for Service Accounts"
---
```

This skill uses three essential tools: bash for executing AWS CLI commands, read_file for inspecting existing configurations, and write_file for generating manifests.

## Automating OIDC Provider Configuration

The first step in any IRSA setup is ensuring your EKS cluster has an OIDC provider. Claude Code can check this and guide you through the configuration. Here's a practical workflow:

```bash
# Check if OIDC provider exists for your cluster
aws eks describe-cluster --name your-cluster-name --query 'cluster.identity.oidc.issuer' --output text
```

If the OIDC provider doesn't exist, Claude can help you create it using `eksctl` or the AWS Console. The key is extracting the issuer URL and registering it with IAM.

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

Notice how the condition restricts the trust to a specific namespace and service account—this follows the principle of least privilege.

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

## End-to-End Workflow with Claude Code

Here's a practical end-to-end workflow you can execute with Claude:

1. **Initialize the IRSA setup** - Provide your cluster name, namespace, and desired permissions
2. **Generate configurations** - Claude creates the IAM policy, trust policy, and service account manifest
3. **Apply resources** - Execute the generated configurations with proper sequencing
4. **Verify the setup** - Check that pods can successfully assume the role

```bash
# Example verification command
kubectl run test-irsa --image=amazon/aws-cli --restart=Never -- \
  aws sts get-caller-identity
```

If the pod can retrieve caller identity using IRSA, your setup is working correctly.

## Best Practices for IRSA with Claude Code

When automating IRSA workflows, follow these actionable best practices:

**Use separate roles per application** - Don't share IAM roles across multiple applications. Each service account should have its own role with minimal permissions specific to that application.

**Always validate OIDC configuration** - Before creating IAM roles, verify that your cluster's OIDC provider is properly configured. Misconfiguration here is the most common IRSA failure point.

**Use namespace restrictions** - In the trust policy, always specify the namespace in the condition. This prevents cross-namespace privilege escalation.

**Implement rotation awareness** - If you need to rotate IAM roles, Claude Code can help you update the service account annotations without downtime by using rolling deployments.

**Audit your IRSA usage** - Regularly review which service accounts have IAM role annotations and whether those roles still match the principle of least privilege.

## Troubleshooting Common IRSA Issues

Even with automation, issues can arise. Here are common problems and how Claude Code can help diagnose them:

**Pod cannot assume role** - Check the trust policy. Ensure the OIDC provider ID matches exactly and the service account name includes the namespace.

**Permission denied errors** - Verify the IAM policy attached to the role contains the required permissions. Use AWS IAM policy simulator to validate.

**OIDC provider not found** - Ensure the OIDC provider is associated with your AWS account and the issuer URL matches your cluster's OIDC endpoint.

## Conclusion

Claude Code transforms EKS IRSA from a manual, error-prone process into a repeatable, secure workflow. By generating correct IAM policies, validating trust relationships, and creating proper Kubernetes manifests, Claude helps you implement IRSA correctly on the first try.

Start by creating a dedicated skill for IRSA operations in your Claude Code setup. Then, for each new application requiring AWS access, use Claude to generate the complete IRSA configuration. This approach ensures consistency, security, and auditability across your EKS workloads.

Remember: IRSA is about security. Always prefer more restrictive trust policies, use dedicated roles per application, and regularly audit your configurations. Claude Code makes this disciplined approach practical and scalable.
{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

