---
layout: default
title: "Enterprise Extension Management API"
description: "Learn how to programmatically manage Chrome extensions in enterprise environments using the Chrome Enterprise Extension Management API with code examples."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-enterprise-extension-management-api/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
The Chrome Enterprise Extension Management API provides administrators with powerful programmatic controls for managing browser extensions across their organization. This API, part of Google's Chrome Browser Cloud Management suite, enables IT teams to install, configure, and remove extensions across managed devices without requiring manual intervention on each workstation.

## Understanding the Extension Management API

The Chrome Enterprise Extension Management API operates through the Google Admin SDK and allows administrators to manage extensions at the organizational unit (OU) level. This means you can apply consistent policies across departments or teams while maintaining flexibility for different groups within your enterprise.

Before using the API, ensure you have the necessary prerequisites in place. You'll need:

- A Google Workspace domain with Chrome Browser Cloud Management enabled
- Service account credentials with appropriate admin scopes
- The Chrome Browser Management API enabled in your Google Cloud project

The API uses RESTful endpoints and supports standard HTTP methods for performing CRUD operations on extensions. Authentication relies on OAuth 2.0, typically through a service account that has been granted delegated admin privileges.

It helps to understand where the Extension Management API fits within the broader Chrome Enterprise toolset. Google offers several overlapping mechanisms for controlling extensions in managed environments:

| Mechanism | Scope | Best For |
|---|---|---|
| Chrome Browser Cloud Management API | Organization-wide, programmatic | Automation, reporting, incident response |
| Google Admin Console (GUI) | Organization-wide, manual | One-off changes, policy configuration |
| Chrome Policy via Group Policy (GPO) | Windows domain-joined devices | On-prem environments without Workspace |
| Managed Device Configuration | Individual device settings | Device-level overrides |

The API is the right choice when you need automation at scale, when manually clicking through the Admin Console for dozens of extensions across hundreds of OUs becomes impractical.

## Getting Started with the API

First, you'll need to configure your environment to make API calls. Here's how to set up authentication using Python:

```python
from google.oauth2 import service_account
from googleapiclient.discovery import build

Define required scopes
SCOPES = [
 'https://www.googleapis.com/auth/chrome-management.appdetails.readonly',
 'https://www.googleapis.com/auth/chrome.management'
]

Load service account credentials
credentials = service_account.Credentials.from_service_account_file(
 'path-to-your-service-account.json',
 scopes=SCOPES
)

Build the Chrome Management API service
service = build('chromeManagement', 'v1', credentials=credentials)
```

The service account must have appropriate permissions delegated through the Google Admin console. Without proper delegation, your API calls will return authentication errors.

Beyond basic authentication, a production-grade setup should handle token refresh and error recovery gracefully. Here is a more solid initialization pattern:

```python
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import logging

logger = logging.getLogger(__name__)

def build_chrome_service(service_account_path: str, delegated_admin: str):
 """
 Build an authenticated Chrome Management API service with domain delegation.

 Args:
 service_account_path: Path to the service account JSON key file.
 delegated_admin: Email of an admin user to impersonate.
 """
 SCOPES = [
 'https://www.googleapis.com/auth/chrome-management.appdetails.readonly',
 'https://www.googleapis.com/auth/chrome.management'
 ]

 credentials = service_account.Credentials.from_service_account_file(
 service_account_path,
 scopes=SCOPES
 )

 # Delegate credentials to an admin user
 delegated_credentials = credentials.with_subject(delegated_admin)

 service = build('chromeManagement', 'v1', credentials=delegated_credentials)
 return service
```

Domain delegation is required when your service account needs to act on behalf of a user who has Chrome management privileges. Without this, calls to org unit-scoped endpoints will return 403 errors even if the service account is correctly configured in your GCP project.

## Listing Installed Extensions

One of the most common use cases for this API is auditing which extensions are installed across your organization. You can retrieve extensions installed by specific users or across entire organizational units.

```python
def list_extensions_by_customer(customer_id):
 """List all extensions installed in the organization."""
 results = service.customers().extensions().list(
 customer=customer_id
 ).execute()

 extensions = results.get('extensions', [])

 for ext in extensions:
 print(f"Name: {ext.get('name')}")
 print(f"ID: {ext.get('extensionId')}")
 print(f"Publisher: {ext.get('publisherName')}")
 print(f"Version: {ext.get('version')}")
 print("---")

 return extensions

Example usage
customer_id = 'my_customer'
extensions = list_extensions_by_customer(customer_id)
```

For large organizations with thousands of managed devices, the response will be paginated. Always handle pagination to ensure you retrieve the full dataset:

```python
def list_all_extensions(service, customer_id):
 """List all extensions with pagination handling."""
 all_extensions = []
 page_token = None

 while True:
 request = service.customers().extensions().list(
 customer=customer_id,
 pageToken=page_token
 )
 response = request.execute()

 extensions = response.get('extensions', [])
 all_extensions.extend(extensions)

 page_token = response.get('nextPageToken')
 if not page_token:
 break

 return all_extensions
```

This approach helps security teams identify unwanted extensions or ensure compliance with organizational policies. You can filter results by extension ID, name, or installation source to focus on specific subsets of your managed extensions.

A practical application is generating a CSV compliance report that can be fed into your SIEM or ticketing system:

```python
import csv
from datetime import datetime

def export_extensions_report(service, customer_id, output_path):
 """Export extension inventory to CSV for compliance reporting."""
 extensions = list_all_extensions(service, customer_id)

 timestamp = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

 with open(output_path, 'w', newline='') as csvfile:
 fieldnames = ['extensionId', 'name', 'publisherName', 'version',
 'installationType', 'homepageUri', 'reportTime']
 writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
 writer.writeheader()

 for ext in extensions:
 writer.writerow({
 'extensionId': ext.get('extensionId', ''),
 'name': ext.get('name', ''),
 'publisherName': ext.get('publisherName', ''),
 'version': ext.get('version', ''),
 'installationType': ext.get('installationType', ''),
 'homepageUri': ext.get('homepageUri', ''),
 'reportTime': timestamp
 })

 return len(extensions)
```

Running this report weekly and diffing against a known-good baseline is a lightweight but effective way to detect unauthorized extension installations.

## Installing Extensions Programmatically

The API allows you to push extensions to users or organizational units. This is particularly valuable for deploying corporate-required extensions such as password managers, VPN clients, or internal tools.

```python
def install_extension_for_org_unit(customer_id, org_unit_id, extension_id):
 """Install an extension for all users in an organizational unit."""
 extension_install_details = {
 'extensionId': extension_id,
 'installationType': 'FORCE_INSTALLED',
 'updateUrl': f'https://clients2.google.com/service/update2/crx?response=redirect&prodversion=99.9&acceptformat=crx2,crx3&x=id%3D{extension_id}%26uc'
 }

 result = service.customers().orgunits().chrome().extensions().install(
 customer=customer_id,
 orgUnitId=org_unit_id,
 body=extension_install_details
 ).execute()

 return result
```

When forcing extension installation, users cannot disable or remove the extension through the browser UI. This ensures critical security tools remain active, but use this capability judiciously, forced installations can frustrate users if overused.

The `installationType` field supports several values with meaningfully different behaviors:

| Value | User Can Remove? | User Can Disable? | Best For |
|---|---|---|---|
| `FORCE_INSTALLED` | No | No | Security tools, DLP agents |
| `NORMAL_INSTALLED` | Yes | Yes | Optional corporate tools |
| `RECOMMENDED` | Yes (never installed automatically) | Yes | Suggested productivity tools |
| `BLOCKED` | N/A (prevents installation) | N/A | Blocking specific extensions |

Choosing the right installation type matters. If every extension is `FORCE_INSTALLED`, users lose agency and may work around restrictions by using non-managed browsers. Reserve forced installs for extensions that truly need to be present for compliance or security reasons.

## Configuring Extension Settings

Beyond simple installation, you can configure extension-specific settings through the API. Different extensions expose different configuration options, but the pattern remains consistent:

```python
def configure_extension(customer_id, extension_id, settings):
 """Configure extension-specific settings."""
 config = {
 'extensionId': extension_id,
 'settings': settings
 }

 result = service.customers().extensions().update(
 customer=customer_id,
 updateMask='settings',
 body=config
 ).execute()

 return result

Configure a hypothetical security extension
settings = {
 'blockList': ['malicious-extension-id-1', 'malicious-extension-id-2'],
 'reportEnabled': True,
 'reportEndpoint': 'https://company.com/reports/extension-usage'
}

result = configure_extension('my_customer', 'your-secure-extension-id', settings)
```

These configuration options let you customize extension behavior without requiring users to manually adjust settings. For example, you might configure a data loss prevention extension with your company's specific rules and exception policies.

For extensions that support managed configuration through the Chrome policy schema, you can also push configurations that the extension reads via `chrome.storage.managed`. This keeps sensitive configuration values out of user-accessible storage:

```python
def set_managed_storage_policy(service, customer_id, org_unit_id, extension_id, policy_schema):
 """
 Push a managed storage policy for an extension.
 policy_schema should match the extension's declared managed_schema.json.
 """
 body = {
 'extensionId': extension_id,
 'installationType': 'FORCE_INSTALLED',
 'policySchema': policy_schema
 }

 result = service.customers().orgunits().chrome().extensions().patch(
 customer=customer_id,
 orgUnitId=org_unit_id,
 extensionId=extension_id,
 updateMask='policySchema',
 body=body
 ).execute()

 return result
```

This is particularly useful for internal extensions that need environment-specific settings (API endpoints, tenant IDs, feature flags) that should differ between production and development OUs.

## Removing Extensions from Managed Devices

When an extension is no longer needed or poses a security risk, you can remove it programmatically:

```python
def uninstall_extension(customer_id, org_unit_id, extension_id):
 """Uninstall an extension from an organizational unit."""
 result = service.customers().orgunits().chrome().extensions().uninstall(
 customer=customer_id,
 orgUnitId=org_unit_id,
 extensionId=extension_id
 ).execute()

 return result
```

This functionality proves essential during security incidents when a compromised extension needs immediate removal across all managed devices. Rather than waiting for users to manually uninstall, you can respond within seconds.

A real-world incident response scenario might look like this: a security researcher discloses a critical vulnerability in a widely-used browser extension. Your security team has a 4-hour window before exploits are expected in the wild. Instead of sending an all-hands email and hoping users act, you run a script that uninstalls the extension from every OU in your organization, then sends a summary to the incident channel with the count of affected devices. This approach is repeatable, auditable, and does not depend on end-user compliance.

To uninstall across all OUs rather than a single one, you first enumerate OUs and then iterate:

```python
def uninstall_from_all_org_units(service, customer_id, extension_id):
 """Remove a specific extension from every organizational unit."""
 # List all OUs
 admin_service = build('admin', 'directory_v1', credentials=delegated_credentials)
 ou_response = admin_service.orgunits().list(
 customerId=customer_id,
 type='all'
 ).execute()

 org_units = ou_response.get('organizationUnits', [])
 removed_from = []

 for ou in org_units:
 ou_id = ou.get('orgUnitId')
 try:
 uninstall_extension(customer_id, ou_id, extension_id)
 removed_from.append(ou.get('orgUnitPath'))
 except HttpError as e:
 # Extension may not be installed in this OU. skip
 if e.resp.status != 404:
 logger.error(f"Failed to uninstall from {ou.get('orgUnitPath')}: {e}")

 return removed_from
```

## Monitoring Extension Usage

Understanding how extensions are being used helps with capacity planning and security monitoring. The API provides usage analytics:

```python
def get_extension_usage(customer_id, extension_id, from_date, to_date):
 """Get usage statistics for a specific extension."""
 result = service.customers().extensions().usage().get(
 customer=customer_id,
 extensionId=extension_id,
 date=f'{from_date},{to_date}'
 ).execute()

 return result
```

Usage data includes metrics like daily active users, total installation count, and permission requests. This information helps administrators make informed decisions about which extensions to allow or block.

Beyond raw usage counts, permissions monitoring is often the more valuable signal. Chrome extensions request permissions at install time, but they can also request additional permissions at runtime through the `chrome.permissions` API. Tracking permission changes over time helps catch extensions that quietly expand their access scope after initial approval:

```python
def audit_extension_permissions(service, customer_id):
 """Identify extensions with high-risk permissions."""
 HIGH_RISK_PERMISSIONS = {
 'tabs',
 'webRequest',
 'webRequestBlocking',
 'cookies',
 'history',
 'browsingData',
 'nativeMessaging'
 }

 all_extensions = list_all_extensions(service, customer_id)
 flagged = []

 for ext in all_extensions:
 permissions = set(ext.get('permissions', []))
 risky = permissions.intersection(HIGH_RISK_PERMISSIONS)

 if risky:
 flagged.append({
 'extensionId': ext.get('extensionId'),
 'name': ext.get('name'),
 'riskyPermissions': list(risky),
 'installationType': ext.get('installationType')
 })

 return flagged
```

Feeding this output into a dashboard or weekly report gives your security team visibility into which extensions have broad access to user browsing data, independent of whether those extensions are currently causing problems.

## Best Practices for Implementation

When implementing extension management at scale, consider establishing a review workflow before pushing new extensions organization-wide. Test extensions in a pilot group first, then gradually expand deployment based on user feedback and usage data.

Maintain a catalog of approved extensions with documented business justifications. This makes audit preparation easier and helps new administrators understand why specific extensions are required. Keep the catalog in version control alongside the scripts that deploy it, this creates a natural audit trail of who approved what and when.

Structure your extension management scripts so that configuration state is declarative rather than imperative. Instead of writing scripts that say "install extension X in OU Y," maintain a YAML or JSON file that describes the desired state, and write a reconciliation script that compares actual state from the API against the desired state and makes only the necessary changes. This idempotent approach is safer to run on a schedule and easier to reason about during audits.

```yaml
desired_extensions.yaml
org_units:
 - path: "/Engineering"
 extensions:
 - id: "cjpalhdlnbpafiamejdnhcphjbkeiagm"
 name: "uBlock Origin"
 installationType: NORMAL_INSTALLED
 - id: "your-internal-devtools-extension"
 name: "Internal DevTools"
 installationType: FORCE_INSTALLED
 - path: "/Finance"
 extensions:
 - id: "your-dlp-extension-id"
 name: "Data Loss Prevention"
 installationType: FORCE_INSTALLED
```

Finally, establish automated policies that trigger extension reviews when new permissions are requested. Extensions frequently update and request additional permissions, so continuous monitoring is essential for maintaining security. Pair this with webhook notifications to your security team whenever the audit script detects a new high-risk permission appearing in an extension that was previously clean.

The Chrome Enterprise Extension Management API transforms browser extension administration from a manual, time-consuming process into a scalable, automated workflow. By integrating these capabilities into your IT operations, you gain precise control over the browser environment while reducing administrative overhead, and you build the kind of institutional knowledge and tooling that makes the next security incident a manageable operational task rather than a scramble.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-enterprise-extension-management-api)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading


- [Getting Started Guide](/getting-started/). From zero to productive with Claude Code
- [Chrome Enterprise Bandwidth Management: A Practical Guide](/chrome-enterprise-bandwidth-management/)
- [AI Code Assistant Chrome Extension: Practical Guide for.](/ai-code-assistant-chrome-extension/)
- [Best AI Chrome Extensions 2026: A Practical Guide for Developers](/best-ai-chrome-extensions-2026/)
- [Project Management Chrome Extension Guide (2026)](/project-management-chrome-extension/)
- [Sso Extension Enterprise Chrome Extension Guide (2026)](/chrome-sso-extension-enterprise/)
- [Chrome Enterprise Jamf Deployment Mac — Developer Guide](/chrome-enterprise-jamf-deployment-mac/)
- [How to Mock API Responses in Chrome Extensions](/chrome-extension-mock-api-responses/)
- [Chrome Os Enterprise Management — Developer Guide](/chrome-os-enterprise-management/)
- [Dual Pane Reader Chrome Extension Guide (2026)](/chrome-extension-dual-pane-reader/)
- [Sneaker Release Alert Chrome Extension Guide (2026)](/chrome-extension-sneaker-release-alert-chrome/)
- [Auto Summarize Articles Chrome Extension Guide (2026)](/chrome-extension-auto-summarize-articles/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


