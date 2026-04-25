---

layout: default
title: "Claude Code LemonSqueezy License Key"
description: "Learn how to build a solid license key validation workflow using Claude Code and LemonSqueezy's API. This guide covers practical patterns for software."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-lemonsqueezy-license-key-validation-workflow/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code LemonSqueezy License Key Validation Workflow

Software licensing is a critical component of any commercial application. Whether you're selling a desktop app, a SaaS product, or a plugin, you need a reliable way to validate that users have purchased valid licenses. LemonSqueezy provides an excellent merchant-of-record solution for digital product sales, complete with license key management. Combined with Claude Code's agentic capabilities, you can build a powerful, automated validation workflow that integrates smoothly into your development process.

This guide walks you through creating a practical license key validation system using Claude Code skills and LemonSqueezy's API. from basic key checking to full activation management, caching strategies, and server-side proxy patterns.

## Understanding the LemonSqueezy License API

LemonSqueezy generates unique license keys for each purchase. These keys can be validated against their API to check:

- Whether the license is active and not expired
- How many activation limits have been used
- The license type and associated product
- Which variant (plan tier) the customer purchased

The primary endpoint for license validation is `POST /v1/licenses/validate`, which checks a key against a specific instance identifier. There's also `GET /v1/licenses/{license_key}` for reading raw license data.

## LemonSqueezy License States

Understanding the possible states a license can be in helps you write correct validation logic:

| Status | Meaning | Recommended action |
|---|---|---|
| `active` | License is valid and within activation limits | Allow access |
| `inactive` | License exists but no active activations | Prompt user to activate |
| `expired` | License period has ended | Prompt renewal |
| `disabled` | Manually disabled by seller | Block access, contact support |
| `invalid` | Key does not exist | Show error, prompt purchase |

Always handle all five states rather than assuming anything that isn't `active` is a generic failure.

## Building the Validation Skill

Create a new Claude Code skill for license validation. This skill will handle the communication with LemonSqueezy's API and provide clear responses about license status.

```yaml
---
name: license-validator
description: "Validate LemonSqueezy license keys and check activation status"
---

License Key Validator

This skill validates LemonSqueezy license keys and provides detailed license status information.

Usage

When asked to validate a license key or check license status, use the following process:

1. Extract the license key from the user's request
2. Call the LemonSqueezy API to validate the key
3. Parse the response and provide clear feedback

API Call Format

Use this curl command to validate a license:

```bash
curl -s -X GET "https://api.lemonsqueezy.com/v1/licenses/{license_key}" \
 -H "Accept: application/vnd.api+json" \
 -H "Content-Type: application/vnd.api+json" \
 -H "Authorization: Bearer {api_key}"
```

Replace `{license_key}` with the user's license key and `{api_key}` with your LemonSqueezy API key.
```

Once this skill file is committed to your `.claude/skills/` directory, Claude Code can answer questions like "Is license key XXXX-YYYY valid?" directly within your terminal workflow. This is especially useful during support conversations or internal tooling where you want to check a customer's license without opening the LemonSqueezy dashboard.

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
 status: license.status,
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

This function returns a clear object with all the information your application needs to make licensing decisions. Note that the `status` field is included so callers can distinguish between `expired`, `disabled`, and `inactive` states rather than treating all non-active responses identically.

## Python Version

For Python-based desktop apps, CLI tools, or backend services:

```python
import requests

LEMONSQUEEZY_API_URL = "https://api.lemonsqueezy.com/v1/licenses"

def validate_license(license_key: str, api_key: str) -> dict:
 """
 Validate a LemonSqueezy license key.
 Returns a dict with 'valid' bool and license details.
 """
 headers = {
 "Accept": "application/vnd.api+json",
 "Content-Type": "application/vnd.api+json",
 "Authorization": f"Bearer {api_key}",
 }

 try:
 response = requests.get(
 f"{LEMONSQUEEZY_API_URL}/{license_key}",
 headers=headers,
 timeout=10,
 )
 response.raise_for_status()
 data = response.json()
 attrs = data["data"]["attributes"]

 return {
 "valid": attrs["status"] == "active",
 "status": attrs["status"],
 "expires_at": attrs.get("expires_at"),
 "usage_count": attrs.get("usage_count"),
 "usage_limit": attrs.get("usage_limit"),
 "product_name": attrs.get("product_name"),
 "variant_name": attrs.get("variant_name"),
 }
 except requests.exceptions.Timeout:
 return {"valid": False, "error": "Request timed out"}
 except requests.exceptions.RequestException as e:
 return {"valid": False, "error": str(e)}
```

## Building a Server-Side Proxy

Never call the LemonSqueezy API directly from client-side JavaScript or a desktop app binary. The API key would be exposed in network traffic or decompilation. Instead, route validation through a lightweight server-side proxy.

Here's a minimal Express proxy:

```javascript
import express from 'express';
import fetch from 'node-fetch';

const app = express();
app.use(express.json());

const LEMON_API_KEY = process.env.LEMON_API_KEY;
const LEMON_API_URL = 'https://api.lemonsqueezy.com/v1/licenses';

// Simple in-memory cache: licenseKey -> { result, cachedAt }
const cache = new Map();
const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour

app.post('/api/validate-license', async (req, res) => {
 const { licenseKey } = req.body;

 if (!licenseKey || typeof licenseKey !== 'string') {
 return res.status(400).json({ valid: false, error: 'License key required' });
 }

 // Check cache
 const cached = cache.get(licenseKey);
 if (cached && Date.now() - cached.cachedAt < CACHE_TTL_MS) {
 return res.json({ ...cached.result, cached: true });
 }

 try {
 const response = await fetch(`${LEMON_API_URL}/${licenseKey}`, {
 headers: {
 'Accept': 'application/vnd.api+json',
 'Authorization': `Bearer ${LEMON_API_KEY}`,
 },
 });

 const data = await response.json();

 if (!response.ok) {
 const result = { valid: false, status: 'invalid' };
 cache.set(licenseKey, { result, cachedAt: Date.now() });
 return res.json(result);
 }

 const attrs = data.data.attributes;
 const result = {
 valid: attrs.status === 'active',
 status: attrs.status,
 expiresAt: attrs.expires_at,
 usageCount: attrs.usage_count,
 usageLimit: attrs.usage_limit,
 productName: attrs.product_name,
 variantName: attrs.variant_name,
 };

 cache.set(licenseKey, { result, cachedAt: Date.now() });
 return res.json(result);
 } catch (err) {
 return res.status(500).json({ valid: false, error: 'Validation service unavailable' });
 }
});

app.listen(3000, () => console.log('License proxy running on port 3000'));
```

Clients now call `/api/validate-license` with their key. The server holds the secret API key and handles caching.

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

## Generating a Stable Machine ID

A machine ID needs to be deterministic (same machine always gets the same ID) but not personally identifiable. A common approach is to hash a combination of hardware identifiers:

```javascript
import { machineIdSync } from 'node-machine-id';
import crypto from 'crypto';

function getStableMachineId(appName) {
 const rawId = machineIdSync(true); // `true` = hashed by the library
 // Namespace the ID to your app so it's unique per app, not globally shared
 return crypto
 .createHash('sha256')
 .update(`${appName}:${rawId}`)
 .digest('hex')
 .slice(0, 32);
}
```

Store the returned `activation_id` from LemonSqueezy after a successful activation. you'll need it later for deactivation.

## Handling Offline Grace Periods

A common UX problem is that license validation requires a network call. If your user is on a plane or in a spotty-coverage area, don't lock them out. Implement a grace period using locally cached validation results:

```javascript
import Store from 'electron-store'; // or any persistent local store

const store = new Store();
const GRACE_PERIOD_DAYS = 7;

async function checkLicense(licenseKey) {
 const lastValid = store.get('licenseLastValidated');
 const lastStatus = store.get('licenseStatus');

 // If we validated recently and it was active, allow offline access
 if (lastValid && lastStatus === 'active') {
 const daysSinceCheck = (Date.now() - lastValid) / (1000 * 60 * 60 * 24);
 if (daysSinceCheck < GRACE_PERIOD_DAYS) {
 return { valid: true, source: 'cache', daysUntilRecheck: GRACE_PERIOD_DAYS - daysSinceCheck };
 }
 }

 // Attempt live validation
 try {
 const result = await validateLicense(licenseKey, process.env.LEMON_API_KEY);
 store.set('licenseLastValidated', Date.now());
 store.set('licenseStatus', result.status);
 return { ...result, source: 'live' };
 } catch {
 // Network failure. fall back to cached status if within grace period
 if (lastStatus === 'active') {
 return { valid: true, source: 'offline-fallback', warning: 'Could not reach license server' };
 }
 return { valid: false, source: 'offline', error: 'No cached license and network unavailable' };
 }
}
```

A 7-day grace period is a reasonable default. Adjust it based on your product's connectivity expectations.

## Using Claude Code to Scaffold the Validation Workflow

Claude Code can generate the entire validation stack from a single prompt. A precise prompt produces better results:

```
Build a LemonSqueezy license validation system for an Electron app with:
- Server-side proxy in Express (hides API key)
- In-memory cache with 1-hour TTL
- Activation/deactivation support with machine ID hashing
- 7-day offline grace period using electron-store
- Full TypeScript types for all response shapes
- Error handling for network timeouts and invalid keys
```

Claude Code will scaffold the proxy server, the client-side SDK, the TypeScript interfaces, and wire everything together. You then review the output, drop in your LemonSqueezy API key, and have a working system in minutes rather than days.

## Best Practices for Production Systems

When implementing license validation in production, keep these principles in mind:

| Practice | Implementation |
|---|---|
| Never expose API keys client-side | Use a server proxy for all API calls |
| Cache validation results | 1-hour TTL reduces API load and improves resilience |
| Handle all license states | Don't treat non-active as a single "invalid" case |
| Implement offline grace periods | Avoid locking out users during network outages |
| Store activation IDs persistently | Required for deactivation flows |
| Log all validation events | Build an audit trail for abuse detection |
| Use stable machine IDs | Hash hardware identifiers, namespace per app |
| Set request timeouts | Default 10 seconds; fall back to cache on timeout |

Never expose your API key in client-side code. Always validate licenses server-side where possible. If you must validate client-side, use a proxy server to hide your API credentials.

Cache validation results intelligently. License status doesn't change frequently, so implement caching with a reasonable TTL to reduce API calls while still maintaining security.

Handle network failures gracefully. If LemonSqueezy's API is unavailable, decide whether to grant temporary access or block the user. Most applications choose to allow access with a warning for a defined grace period.

Log validation attempts. Keep track of when and where licenses are validated to detect potential abuse or piracy. Unusual patterns. like the same key being validated from 50 different machines in an hour. are worth alerting on.

## Conclusion

Building a license validation workflow with Claude Code and LemonSqueezy combines the best of both worlds: Claude Code's agentic capabilities for automation and LemonSqueezy's solid licensing infrastructure. Whether you're validating licenses in a CLI tool, a web application, or a desktop app, the patterns outlined in this guide provide a solid foundation.

Start by creating the Claude Code skill to handle validation conversations, then implement the proxy server to keep your API key safe. Add caching and offline grace periods to handle the real-world conditions your users will encounter. With proper error handling, activation management, and audit logging, you'll have a production-ready system that protects your software while providing a smooth experience for legitimate customers.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-lemonsqueezy-license-key-validation-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Using Claude Code for Data Quality Validation Workflow](/claude-code-for-data-quality-validation-workflow/)
- [Claude Code for Dependency License Audit Workflow](/claude-code-for-dependency-license-audit-workflow/)
- [Claude Code for License Compatibility Workflow Guide](/claude-code-for-license-compatibility-workflow-guide/)
- [Claude Code For Lemonsqueezy — Complete Developer Guide](/claude-code-for-lemonsqueezy-billing-workflow/)
- [Claude Code for Pandera Dataframe Validation Workflow](/claude-code-for-pandera-dataframe-validation-workflow-tutori/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}

## See Also

- [Claude Code for Valibot — Workflow Guide](/claude-code-for-valibot-validation-workflow-guide/)
