---
layout: default
title: "Claude Code LemonSqueezy License Key Validation Workflow"
description: "Learn how to build a robust license key validation workflow using Claude Code and LemonSqueezy's API. This guide covers practical patterns for software licensing."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-lemonsqueezy-license-key-validation-workflow/
---

{% raw %}
# Claude Code LemonSqueezy License Key Validation Workflow

Software licensing is a critical component of any commercial application. Whether you're selling a desktop app, a SaaS product, or a plugin, you need a reliable way to validate that users have purchased valid licenses. LemonSqueezy provides an excellent merchant-of-record solution for digital product sales, complete with license key management. Combined with Claude Code's agentic capabilities, you can build a powerful, automated validation workflow that integrates seamlessly into your development process.

This guide walks you through creating a practical license key validation system using Claude Code skills and LemonSqueezy's API.

## Understanding the LemonSqueezy License API

LemonSqueezy generates unique license keys for each purchase. These keys can be validated against their API to check:

- Whether the license is active and not expired
- How many activation limits have been used
- The license type and associated product

The API endpoint for license validation is `GET /v1/licenses/{license_key}` which returns detailed information about the license status.

## Building the Validation Skill

Create a new Claude Code skill for license validation. This skill will handle the communication with LemonSqueezy's API and provide clear responses about license status.

```yaml
---
name: license-validator
description: "Validate LemonSqueezy license keys and check activation status"
tools:
  - bash
  - read_file
  - write_file
---

# License Key Validator

This skill validates LemonSqueezy license keys and provides detailed license status information.

## Usage

When asked to validate a license key or check license status, use the following process:

1. Extract the license key from the user's request
2. Call the LemonSqueezy API to validate the key
3. Parse the response and provide clear feedback

## API Call Format

Use this curl command to validate a license:

```bash
curl -s -X GET "https://api.lemonsqueezy.com/v1/licenses/{license_key}" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer {api_key}"
```

Replace `{license_key}` with the user's license key and `{api_key}` with your LemonSqueezy API key.
```

## Implementing the Validation Function

Beyond the skill, you can create a reusable validation function that your applications can call. Here's a practical example in JavaScript that you can integrate into any project:

```javascript
const LEMONSQUEEZY_API_URL = 'https://api.lemonsqueezy.com/v1/licenses';

async function validateLicense(licenseKey, apiKey) {
  try {
    const response = await fetch(`${LEMONSQUEEZY_API_URL}/${licenseKey}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/vnd.api+json',
        'Content-Type': 'application/vnd.api+json',
        'Authorization': `Bearer ${apiKey}`
      }
    });

    if (!response.ok) {
      return { valid: false, error: 'License check failed' };
    }

    const data = await response.json();
    const license = data.data.attributes;

    return {
      valid: license.status === 'active',
      expiresAt: license.expires_at,
      usageCount: license.usage_count,
      limit: license.usage_limit,
      productName: license.product_name,
      variantName: license.variant_name
    };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}
```

This function returns a clear object with all the information your application needs to make licensing decisions.

## Automated License Checking in CI/CD

One powerful use case is integrating license validation into your continuous integration pipeline. You can create a Claude Code workflow that checks licenses during deployment:

```yaml
name: License Check
on:
  workflow_dispatch:
    inputs:
      license_key:
        description: 'License key to validate'
        required: true

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Validate License
        run: |
          response=$(curl -s -X GET "https://api.lemonsqueezy.com/v1/licenses/${{ github.event.inputs.license_key }}" \
            -H "Accept: application/vnd.api+json" \
            -H "Content-Type: application/vnd.api+json" \
            -H "Authorization: Bearer ${{ secrets.LEMON_API_KEY }}")
          
          status=$(echo $response | jq -r '.data.attributes.status')
          
          if [ "$status" != "active" ]; then
            echo "License is not active: $status"
            exit 1
          fi
          
          echo "License validated successfully"
```

This workflow can be triggered manually or as part of your release process to ensure only valid licenses are activated.

## Creating an Activation/Deactivation System

For desktop applications that need to track activations (like limiting usage to a specific number of machines), you can implement an activation system:

```javascript
async function activateLicense(licenseKey, machineId, apiKey) {
  const response = await fetch(`${LEMONSQUEEZY_API_URL}/${licenseKey}/activations`, {
    method: 'POST',
    headers: {
      'Accept': 'application/vnd.api+json',
      'Content-Type': 'application/vnd.api+json',
      'Authorization': `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      data: {
        type: 'license-activations',
        attributes: {
          machine_id: machineId
        }
      }
    })
  });

  return response.json();
}

async function deactivateLicense(licenseKey, activationId, apiKey) {
  const response = await fetch(
    `${LEMONSQUEEZY_API_URL}/${licenseKey}/activations/${activationId}`,
    {
      method: 'DELETE',
      headers: {
        'Accept': 'application/vnd.api+json',
        'Authorization': `Bearer ${apiKey}`
      }
    }
  );

  return response.ok;
}
```

This allows users to transfer their license between machines by deactivating on the old machine and activating on the new one.

## Best Practices for Production Systems

When implementing license validation in production, consider these important practices:

**Never expose your API key in client-side code.** Always validate licenses server-side where possible. If you must validate client-side, use a proxy server to hide your API credentials.

**Cache validation results intelligently.** License status doesn't change frequently, so implement caching with a reasonable TTL (time-to-live) to reduce API calls while still maintaining security.

**Handle network failures gracefully.** If LemonSqueezy's API is unavailable, decide whether to grant temporary access or block the user. Most applications choose to allow access with a warning.

**Log validation attempts.** Keep track of when and where licenses are validated to detect potential abuse or piracy.

## Conclusion

Building a license validation workflow with Claude Code and LemonSqueezy combines the best of both worlds: Claude Code's agentic capabilities for automation and LemonSqueezy's robust licensing infrastructure. Whether you're validating licenses in a CLI tool, a web application, or a desktop app, the patterns outlined in this guide provide a solid foundation.

Start by creating the Claude Code skill to handle validation conversations, then implement the API calls in your application code. With proper error handling and caching, you'll have a production-ready system that protects your software while providing a smooth experience for legitimate customers.
{% endraw %}
