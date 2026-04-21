---

layout: default
title: "Chrome Enterprise Self-Hosted Extension Store Guide (2026)"
description: "Set up a self-hosted Chrome extension store for enterprise. Complete implementation guide with code examples and deployment instructions. Tested on Chrome."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-enterprise-self-hosted-extension-store/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

Chrome extensions power productivity across organizations, but distributing them securely within an enterprise requires more than the public Chrome Web Store. A self-hosted extension store gives IT administrators complete control over which extensions are available, when they're updated, and who can access them.

This guide walks through setting up a private Chrome extension repository for enterprise environments. You'll learn the technical requirements, configuration steps, and practical considerations for managing internal extensions at scale.

## Why Self-Hosted Extension Stores Matter

Enterprise environments often operate under strict security policies. Many organizations restrict internet access, require air-gapped networks, or need compliance with specific data handling regulations. The public Chrome Web Store becomes inaccessible in these scenarios.

A self-hosted extension store solves this by hosting extension CRX files on infrastructure you control. Your IT team approves extensions, hosts the packages internally, and configures Chrome to pull from your private repository instead of Google's servers.

Beyond network restrictions, self-hosted stores provide:

- Version control: Deploy specific extension versions across your organization
- Security vetting: Review extensions before making them available company-wide
- Audit trails: Track which users have installed which extensions
- Offline support: Serve extensions without internet connectivity
- Forced installations: Push required extensions to all managed devices automatically
- Update control: Choose when updates deploy rather than accepting Google's schedule

## Self-Hosted vs. Chrome Web Store: Comparison

| Feature | Chrome Web Store | Self-Hosted Store |
|---|---|---|
| Works on air-gapped networks | No | Yes |
| IT controls update timing | No | Yes |
| Security review before install | Limited | Full control |
| Supports private extensions | No | Yes |
| Requires infrastructure | No | Yes |
| Cost | Free | Server + maintenance |
| Audit trail | Minimal | Full |

For small teams or consumer use cases the Web Store is sufficient. For organizations with security requirements, compliance obligations, or internal-only tools, self-hosting is the correct approach.

## Planning Your Extension Infrastructure

Before writing any configuration, decide on your hosting topology. There are three common architectures:

Single central server: One Nginx or Apache server hosts all CRX files. Simple to manage, single point of failure. Good for up to a few hundred devices.

CDN-backed hosting: Place your CRX files behind a CDN (internal or external). Handles geographic distribution and load, but adds CDN configuration complexity.

Object storage: Host CRX files in an S3-compatible bucket or Azure Blob Storage with a public read policy scoped to corporate IP ranges. Minimal operational overhead once configured.

For most enterprise deployments, a single server behind an internal load balancer hits the right balance of simplicity and reliability. The rest of this guide uses that model.

## Setting Up Your Extension Repository

A self-hosted Chrome extension store is fundamentally a web server serving CRX files with proper headers. You don't need specialized software, a basic web server handles the job.

## Directory Structure

Organize your extension repository with a clear structure:

```
/var/www/extensions/
 manifest.json
 update.xml
 icons/
 internal-tool-128.png
 password-manager-128.png
 internal-tool-1.2.0.crx
 internal-tool-1.2.1.crx
 company-password-manager.crx
 custom-integration-0.5.0.crx
```

Keep old CRX versions around for at least one revision cycle. Devices that missed an update cycle need to pull the previous version before upgrading to the latest. Deleting old files breaks staged rollouts.

manifest.json Structure

Create a manifest that describes your extension catalog:

```json
{
 "name": "Company Extension Repository",
 "version": "1.0",
 "extensions": [
 {
 "name": "Internal Tool",
 "version": "1.2.1",
 "description": "Company internal utilities",
 "id": "gjflkafdjjglhfjpgbognhfcnakkgbhe",
 "package": "internal-tool-1.2.1.crx",
 "icons": {
 "128": "icons/internal-tool-128.png"
 }
 },
 {
 "name": "Custom Integration",
 "version": "0.5.0",
 "description": "CRM integration module",
 "id": "abcdefghijklmnopqrstuvwxyz123456",
 "package": "custom-integration-0.5.0.crx"
 }
 ]
}
```

The extension ID is critical. Chrome uses the ID to track installations and updates. Generate IDs using the official extension packaging process in Chrome.

## Chrome's Update XML Format

For automatic update detection, Chrome also supports an XML update manifest format. This is the format used by the `update_url` field inside an extension's own manifest. Create an `update.xml` file alongside your JSON manifest:

```xml
<?xml version='1.0' encoding='UTF-8'?>
<gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
 <app appid='gjflkafdjjglhfjpgbognhfcnakkgbhe'>
 <updatecheck
 codebase='https://extensions.company.internal/internal-tool-1.2.1.crx'
 version='1.2.1' />
 </app>
 <app appid='abcdefghijklmnopqrstuvwxyz123456'>
 <updatecheck
 codebase='https://extensions.company.internal/custom-integration-0.5.0.crx'
 version='0.5.0' />
 </app>
</gupdate>
```

Chrome fetches this XML when the extension's `update_url` is called. The `appid` must exactly match the extension ID, and the `version` triggers updates only when it is higher than what is installed.

## Required Server Configuration

Your web server must serve CRX files with specific CORS headers. Without these headers, Chrome blocks the installation.

For Nginx, add these headers to your server block:

```nginx
server {
 listen 443 ssl;
 server_name extensions.company.internal;

 ssl_certificate /etc/ssl/company/cert.pem;
 ssl_certificate_key /etc/ssl/company/key.pem;

 root /var/www/extensions;

 location ~* \.crx$ {
 add_header Access-Control-Allow-Origin *;
 add_header X-Content-Type-Options nosniff;
 add_header Content-Type application/x-chrome-extension;
 expires -1;
 add_header Cache-Control "no-store, no-cache, must-revalidate";
 }

 location ~* \.(json|xml)$ {
 add_header Content-Type application/json;
 expires -1;
 add_header Cache-Control "no-store, no-cache, must-revalidate";
 }
}
```

For Apache, use mod_headers in your .htaccess or server configuration:

```apache
<VirtualHost *:443>
 ServerName extensions.company.internal
 DocumentRoot /var/www/extensions

 SSLEngine on
 SSLCertificateFile /etc/ssl/company/cert.pem
 SSLCertificateKeyFile /etc/ssl/company/key.pem

 <FilesMatch "\.crx$">
 Header set Access-Control-Allow-Origin "*"
 Header set X-Content-Type-Options "nosniff"
 Header set Content-Type "application/x-chrome-extension"
 Header set Cache-Control "no-store, no-cache, must-revalidate"
 </FilesMatch>

 <FilesMatch "\.(json|xml)$">
 Header set Cache-Control "no-store, no-cache, must-revalidate"
 </FilesMatch>
</VirtualHost>
```

Cache headers on the manifest and XML files are just as important as on the CRX files. If your update manifest is cached, Chrome will not pick up new versions until the cache expires.

## Configuring Chrome to Use Your Store

Chrome Enterprise policies control which extension sources Chrome uses. Configure these through Group Policy on Windows, configuration profile on macOS, or JSON policies on Linux.

## Windows Group Policy

Deploy this policy through Group Policy Management:

- Policy path: Computer Configuration → Administrative Templates → Google Chrome → Extensions
- Setting: "Extension install sources"
- Value: Add your internal repository URL

The policy accepts patterns like `https://extensions.company.internal/*` or `https://cdn.company.com/*`.

For forced installations, also configure the "Configure the list of force-installed apps and extensions" policy. Each entry uses the format `EXTENSION_ID;UPDATE_URL`.

macOS Configuration Profile

On macOS, deploy Chrome policies through an MDM solution (Jamf, Mosyle, or Kandji) using a `.mobileconfig` profile:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>PayloadContent</key>
 <array>
 <dict>
 <key>PayloadType</key>
 <string>com.google.Chrome</string>
 <key>ExtensionInstallSources</key>
 <array>
 <string>https://extensions.company.internal/*</string>
 </array>
 <key>ExtensionInstallForcelist</key>
 <array>
 <string>gjflkafdjjglhfjpgbognhfcnakkgbhe;https://extensions.company.internal/update.xml</string>
 </array>
 </dict>
 </array>
</dict>
</plist>
```

Upload this profile to your MDM and scope it to the appropriate device groups.

JSON Configuration (Linux/Chromium OS)

Create a JSON policy file at `/etc/opt/chrome/policies/managed/extensions.json`:

```json
{
 "ExtensionInstallSources": [
 "https://extensions.company.internal/*",
 "https://cdn.company.com/*"
 ],
 "ExtensionInstallForcelist": [
 "gjflkafdjjglhfjpgbognhfcnakkgbhe;https://extensions.company.internal/update.xml",
 "abcdefghijklmnopqrstuvwxyz123456;https://extensions.company.internal/update.xml"
 ],
 "ExtensionInstallBlocklist": [
 "*"
 ],
 "ExtensionInstallAllowlist": [
 "gjflkafdjjglhfjpgbognhfcnakkgbhe",
 "abcdefghijklmnopqrstuvwxyz123456"
 ]
}
```

The `ExtensionInstallForcelist` policy forces specific extensions onto managed devices without user interaction, useful for security tools that must be present on all machines.

Adding `ExtensionInstallBlocklist` with a wildcard `*` combined with an allowlist creates a whitelist-only environment. Users cannot install any extension not explicitly permitted by IT.

## Policy Deployment Verification

After deploying policies, verify they applied correctly on a test device:

1. Open `chrome://policy` in the browser
2. Look for your extension policies under the "Chrome policies" section
3. Entries should show the source as "Platform" (machine-level policy) or "Cloud" (if using Chrome Browser Cloud Management)

If policies do not appear, check file permissions on the policy JSON file. Chrome requires the file to be owned by root and not world-writable.

## Managing Updates

Self-hosted extensions require manual update management. Chrome checks for updates based on the `update_url` in the extension manifest. For internally hosted extensions, point this to your update.xml.

In your extension's manifest.json (the extension's own manifest, not the repository manifest):

```json
{
 "manifest_version": 3,
 "name": "Internal Tool",
 "version": "1.2.1",
 "update_url": "https://extensions.company.internal/update.xml",
 "permissions": ["storage", "activeTab"]
}
```

When you upload a new version to your repository, update the version number in your update.xml. Chrome detects the new version on its next check cycle (every few hours by default) and installs the update automatically.

Automate this process with a deployment script that packages the extension, uploads it, and regenerates your manifests:

```bash
#!/bin/bash
set -euo pipefail

EXTENSION_DIR="/var/www/extensions"
SOURCE_DIR="/opt/extensions/internal-tool"
NEW_VERSION="1.2.2"
EXTENSION_ID="gjflkafdjjglhfjpgbognhfcnakkgbhe"
UPDATE_URL="https://extensions.company.internal/update.xml"
KEY_FILE="/opt/extensions/keys/internal-tool.pem"

Package the extension
google-chrome --pack-extension="$SOURCE_DIR" \
 --pack-extension-key="$KEY_FILE" \
 --no-message-box

Move the packaged CRX to the repository
mv "${SOURCE_DIR}.crx" "${EXTENSION_DIR}/internal-tool-${NEW_VERSION}.crx"

Update the XML update manifest
python3 - <<PYEOF
import xml.etree.ElementTree as ET

tree = ET.parse('${EXTENSION_DIR}/update.xml')
root = tree.getroot()
ns = {'g': 'http://www.google.com/update2/response'}

for app in root.findall('g:app', ns):
 if app.get('appid') == '${EXTENSION_ID}':
 uc = app.find('g:updatecheck', ns)
 uc.set('version', '${NEW_VERSION}')
 uc.set('codebase', '${UPDATE_URL}'.replace(
 'update.xml',
 'internal-tool-${NEW_VERSION}.crx'
 ))

tree.write('${EXTENSION_DIR}/update.xml',
 xml_declaration=True, encoding='UTF-8')
PYEOF

echo "Deployed internal-tool version ${NEW_VERSION}"
```

Store the private key (`internal-tool.pem`) in a secrets manager or hardware security module. Losing this key means you cannot issue signed updates, you would need to redistribute the extension as a new ID.

## Security Considerations

## HTTPS Is Mandatory

Host your extension repository over HTTPS. Chrome blocks extensions loaded over insecure HTTP connections in modern versions. Use a certificate from your internal PKI if your devices trust it, or a public CA if you prefer not to manage certificate distribution.

Self-signed certificates work only if you distribute the CA certificate to all managed devices and configure Chrome to trust it via policy:

```json
{
 "CACertificates": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t..."
}
```

The value is the base64-encoded DER certificate. Managed via the `CACertificates` Chrome policy or through your MDM's certificate profile.

## Network Access Controls

Restrict access to your extension server using network ACLs or firewall rules. Only devices on your corporate network or connected via VPN should reach the extension endpoints. A simple approach on Linux with iptables:

```bash
Allow only corporate IP range to access the extension server
iptables -A INPUT -p tcp --dport 443 -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j DROP
```

Combine this with HTTP basic authentication as a second layer:

```nginx
location /extensions/ {
 auth_basic "Corporate Extensions";
 auth_basic_user_file /etc/nginx/.htpasswd;
}
```

## CRX Signing and Verification

Chrome validates the CRX file signature during installation. When you package an extension using Chrome's built-in packager or the `crx` command-line tool, it signs the file with your private key. If someone replaces a CRX file on your server with a malicious file, the signature check fails and Chrome refuses to install it.

For extra assurance, generate a checksum file alongside each CRX:

```bash
sha256sum internal-tool-1.2.2.crx > internal-tool-1.2.2.crx.sha256
```

Your deployment automation can verify checksums before updating the manifest, preventing a corrupted upload from reaching end users.

## Common Pitfalls

Extension IDs change when repackaged without the original key. If you generate a new CRX file without preserving the original private key, Chrome treats it as a different extension. Users lose their settings and the old extension remains installed alongside the new one. Keep your private keys in source-controlled secret storage (HashiCorp Vault, AWS Secrets Manager, etc.) and back them up.

Caching breaks update detection. Ensure your web server doesn't cache `manifest.json`, `update.xml`, or CRX files with long TTLs. The cache header configuration shown earlier in the Nginx and Apache sections handles this. Verify with `curl -I https://extensions.company.internal/update.xml` that `Cache-Control: no-store` appears in the response.

Policy files with incorrect permissions are silently ignored. Chrome requires policy JSON files to be owned by root and have permissions of `644` or stricter. A file owned by your deploy user with `777` permissions will be ignored, and extensions will not be forced-installed. Check with `ls -la /etc/opt/chrome/policies/managed/`.

Testing in incognito mode reveals permission issues. Extensions that work in regular mode sometimes fail in incognito due to additional restrictions. Test both modes before deploying organization-wide. Enable your extension in incognito explicitly during development via `chrome://extensions` and check the "Allow in incognito" toggle.

Manifest version mismatches cause silent failures. If your extension targets Manifest V3 but your update XML references a Manifest V2 package, Chrome may refuse to install the update. Always package and test extensions against the manifest version you intend to ship.

## Rolling Out to a Subset of Devices

Rather than pushing updates to your entire fleet at once, use organizational units (OUs) in your directory service or MDM device groups to stage rollouts:

1. Create a "Canary" OU containing a small set of test machines.
2. Point the Canary OU's extension policy at a separate `update-canary.xml` that references the new version.
3. After 24-48 hours of successful operation, update the main `update.xml` for the rest of the fleet.

This pattern catches permission regressions or compatibility issues before they affect all users.

## Monitoring and Audit

Chrome Browser Cloud Management (free for basic use) provides a dashboard showing which extensions are installed across your managed fleet. For organizations not using Chrome Browser Cloud Management, build your own audit by scraping Chrome's reporting endpoint or parsing extension installation logs:

```bash
On Linux, Chrome logs extension events to syslog
journalctl -u chrome --since "1 hour ago" | grep -i extension
```

Combine this with a nightly cron job that checks each managed device's installed extension list against your approved list and alerts on deviations.

## Wrap-Up

A self-hosted Chrome extension store provides the control enterprises need for secure extension distribution. The setup requires basic web hosting, proper CORS and cache configuration, signed CRX files, and Chrome Enterprise policies for deployment.

Start small, host a single internal tool, verify the update cycle works end-to-end, then expand. Pay particular attention to key management and cache headers; those two areas cause the majority of real-world deployment failures. The investment pays off in security, compliance, and operational control over every extension running on your managed fleet.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-enterprise-self-hosted-extension-store)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [AI Coding Tools Security Concerns Enterprise Guide](/ai-coding-tools-security-concerns-enterprise-guide/)
- [Augment Code AI Review for Enterprise Teams 2026](/augment-code-ai-review-for-enterprise-teams-2026/)
- [Chrome ADMX Templates for Windows Server: Enterprise.](/chrome-admx-templates-windows-server/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


