---

layout: default
title: "How to Use GitHub Actions OIDC Workflow (2026)"
description: "Learn how to securely authenticate with cloud providers using OpenID Connect (OIDC) in your GitHub Actions workflows, eliminating the need for."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-github-actions-oidc-workflow-guide/
categories: 
  - Claude Code
  - DevOps
  - Security
tags: [claude-code, claude-skills]
reviewed: true
score: 7
categories: [guides]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code for GitHub Actions OIDC Workflow Guide

If you're deploying to AWS, Azure, or GCP from GitHub Actions, you've probably faced the challenge of managing secrets, API keys, access tokens, and credentials that need to be rotated and stored securely. OpenID Connect (OIDC) offers a better approach: temporary, scoped tokens that expire automatically, eliminating the risk of leaked long-lived credentials. This guide shows you how to set up OIDC authentication in your GitHub Actions workflows using Claude Code.

What is OIDC and Why Does It Matter?

OIDC (OpenID Connect) is an authentication protocol built on top of OAuth 2.0 that provides identity verification. In the context of GitHub Actions, OIDC allows your workflow to request short-lived tokens directly from your cloud provider, without storing permanent secrets in GitHub.

Benefits of OIDC:
- No secrets storage, Credentials never leave your cloud provider
- Automatic expiration, Tokens are valid for minutes to hours, not months
- Reduced attack surface, No long-lived secrets to rotate or revoke
- Fine-grained permissions, Scope tokens to specific roles and resources

## Setting Up OIDC for AWS

AWS uses IAM Roles with Web Identity Federation to enable OIDC authentication from GitHub Actions.

## Step 1: Create an IAM OIDC Provider in AWS

First, register GitHub as an OIDC identity provider in IAM:

```bash
Create OIDC provider for GitHub
aws iam create-open-id-connect-provider \
 --url https://token.actions.githubusercontent.com \
 --client-id-list "sts.amazonaws.com" \
 --thumbprint-list "6938FD4D9B1C1B20EED1D8B0CEE4F3A1B8C9D0E1F"
```

## Step 2: Create an IAM Role with Trust Policy

Create a role that GitHub can assume, with conditions matching your repository:

```json
{
 "Version": "2012-10-17",
 "Statement": [
 {
 "Effect": "Allow",
 "Principal": {
 "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
 },
 "Action": "sts:AssumeRoleWithWebIdentity",
 "Condition": {
 "StringEquals": {
 "token.actions.githubusercontent.com:sub": "repo:your-org/your-repo:ref:refs/heads/main",
 "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
 }
 }
 }
 ]
}
```

## Step 3: Configure GitHub Secrets

In your GitHub repository, add these settings:

1. Go to Settings → Secrets and variables → Actions
2. Add an AWS region variable: `AWS_REGION = us-east-1`
3. No AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY needed!

## Step 4: Create the GitHub Actions Workflow

Here's a complete workflow using OIDC:

```yaml
name: Deploy to AWS with OIDC

on:
 push:
 branches: [main]

 id-token: write # Required to request OIDC token
 contents: read # Required to checkout code

jobs:
 deploy:
 runs-on: ubuntu-latest
 steps:
 - name: Checkout code
 uses: actions/checkout@v4

 - name: Configure AWS credentials
 uses: aws-actions/configure-aws-credentials@v4
 with:
 role-to-assume: arn:aws:iam::123456789012:role/github-deploy-role
 aws-region: ${{ vars.AWS_REGION }}

 - name: Deploy application
 run: |
 aws s3 sync ./dist s3://your-bucket-name
 aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

The key permission is `id-token: write`, this tells GitHub to mint an OIDC token for the workflow.

## Setting Up OIDC for Azure

Azure uses Azure Active Directory (Entra ID) to manage OIDC federation with GitHub.

## Step 1: Register a Federated Identity

Create a workload identity in Azure:

```bash
Create a service principal
az ad sp create-for-rbac \
 --name "github-deploy-sp" \
 --role contributor \
 --scope /subscriptions/YOUR_SUB_ID/resourceGroups/YOUR_RG

Create federated credential
az ad sp show --id YOUR_SP_OBJECT_ID --query appId

Add federated credential
az rest --method POST \
 --uri "https://graph.microsoft.com/v1.0/applications/YOUR_APP_ID/federatedIdentityCredentials" \
 --body '{
 "name": "github-deploy-credential",
 "issuer": "https://token.actions.githubusercontent.com",
 "subject": "repo:your-org/your-repo:ref:refs/heads/main",
 "audiences": ["api://AzureADTokenValidation"]
 }'
```

## Step 2: Create the GitHub Actions Workflow

```yaml
name: Deploy to Azure with OIDC

on:
 push:
 branches: [main]

 id-token: write
 contents: read

jobs:
 deploy:
 runs-on: ubuntu-latest
 steps:
 - name: Checkout
 uses: actions/checkout@v4

 - name: Azure login
 uses: azure/login@v2
 with:
 client-id: ${{ secrets.AZURE_CLIENT_ID }}
 tenant-id: ${{ secrets.AZURE_TENANT_ID }}
 subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

 - name: Deploy to Azure
 run: |
 az webapp up --name your-app --resource-group your-rg --runtime "NODE:18-lts"
```

## Step 3: Configure Azure Secrets

Add these repository secrets:
- `AZURE_CLIENT_ID`, Application (client) ID
- `AZURE_TENANT_ID`, Directory (tenant) ID 
- `AZURE_SUBSCRIPTION_ID`, Subscription ID

Note that you still need these identifiers, but the secret itself (password/certificate) is replaced by OIDC federation.

## Setting Up OIDC for GCP

Google Cloud uses Workload Identity Federation to connect GitHub Actions.

## Step 1: Create a Workload Identity Pool

```bash
Create workload identity pool
gcloud iam workload-identity-pools create github-pool \
 --location="global" \
 --description="GitHub Actions OIDC" \
 --project=YOUR_PROJECT_ID

Get the pool attribute mapping
gcloud iam workload-identity-pools describe github-pool \
 --location="global" \
 --project=YOUR_PROJECT_ID \
 --format="value(name)"
```

## Step 2: Create a Service Account and Link It

```bash
Create service account
gcloud iam service-accounts create github-deploy-sa \
 --project=YOUR_PROJECT_ID

Add the workload identity pool to the service account
gcloud iam service-accounts add-iam-policy-binding \
 github-deploy-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
 --member="principalSet://iam.googleapis.com/projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/your-org/your-repo" \
 --role="roles/storage.objectAdmin"
```

## Step 3: Configure GitHub Actions

```yaml
name: Deploy to GCP with OIDC

on:
 push:
 branches: [main]

 id-token: write
 contents: read

jobs:
 deploy:
 runs-on: ubuntu-latest
 steps:
 - name: Checkout
 uses: actions/checkout@v4

 - name: Authenticate to Google Cloud
 uses: google-github-actions/auth@v2
 with:
 workload_identity_provider: projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider
 service_account: github-deploy-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com

 - name: Deploy to Cloud Run
 run: |
 gcloud run deploy your-service \
 --source ./ \
 --region us-central1 \
 --allow-unauthenticated
```

## Using Claude Code to Generate OIDC Workflows

Claude Code can help you set up OIDC authentication quickly. Here's a prompt you can use:

> "Create a GitHub Actions workflow that deploys to [AWS/Azure/GCP] using OIDC authentication. The workflow should:
> - Run on push to main branch
> - Use OIDC (not secrets) for authentication
> - Deploy to [specific service/bucket]
> - Include proper permission scopes"

Claude Code will generate the complete workflow with the correct OIDC configuration for your chosen provider.

## Best Practices for OIDC in GitHub Actions

1. Scope permissions tightly, Use `sub` conditions to restrict which repository branches or paths can authenticate:
 ```json
 "Condition": {
 "StringLike": {
 "token.actions.githubusercontent.com:sub": "repo:your-org/*:ref:refs/heads/*"
 }
 }
 }
 ```

2. Use separate roles per environment, Create distinct IAM roles/Azure AD apps for dev, staging, and production with different permission levels.

3. Audit regularly, Review CloudTrail/AWS CloudTrail logs to verify which roles are being assumed and from where.

4. Enable GitHub's OIDC token verification, Ensure your cloud provider validates the OIDC token signature.

5. Use environment protection rules, Combine OIDC with GitHub Environments requiring approvals for production deployments.

## Troubleshooting Common Issues

"Request not valid" errors
- Ensure your OIDC provider thumbprint is correct
- Verify the `sub` claim in your trust policy matches your repository exactly

Permission denied after push
- Check that the role/principal has the required permissions
- Verify the condition in your trust policy isn't too restrictive

Token expired errors
- This usually indicates network issues fetching the token
- Ensure GitHub Actions runners can reach your cloud provider's STS endpoint

## Conclusion

OIDC authentication for GitHub Actions is a significant security improvement over storing long-lived secrets. By using temporary, scoped tokens, you reduce the risk of credential compromise while simplifying your security posture. Claude Code can help you generate the appropriate workflow files for your cloud provider, making the setup process straightforward.

Start by migrating one workflow to OIDC, you'll immediately see the benefits of eliminating secret rotation and gaining fine-grained access control.


---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-for-github-actions-oidc-workflow-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for GitHub CLI — Workflow Guide](/claude-code-for-github-cli-workflow-guide/)
