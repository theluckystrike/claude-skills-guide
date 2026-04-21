---
layout: default
title: "Chrome Enterprise Startup Pages Policy — Developer Guide"
description: "Learn how to configure Chrome enterprise startup pages policy for your organization. Practical examples for developers managing browser configurations."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-enterprise-startup-pages-policy/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
{% raw %}
Chrome Enterprise provides powerful group policies that let administrators control what happens when users launch the browser or open new tabs. The startup pages policy is particularly useful for organizations that need to direct users to internal dashboards, documentation portals, or compliance landing pages immediately after Chrome launches.

This guide covers the technical details developers and IT administrators need to deploy and manage Chrome startup pages across their organization. Whether you are deploying to twenty developer workstations or twenty thousand managed endpoints, the same policies apply. and the configuration mistakes are largely the same too. This guide covers both, with practical examples at each step.

## Understanding Chrome Startup Pages Policy

Chrome supports several policies related to startup behavior:

- StartupPages: Defines URLs that open when Chrome starts
- NewTabPageLocation: Sets the URL for new tabs
- RestoreOnStartup: Controls whether Chrome restores previous sessions or opens specified URLs
- RestoreOnStartupURLs: A list of URLs to open on startup (used with RestoreOnStartup)

The primary policy you will work with is `StartupPages`, which accepts a list of URLs that Chrome loads when the browser launches. This policy works alongside `RestoreOnStartup` to determine startup behavior.

## The RestoreOnStartup Values Explained

The `RestoreOnStartup` policy is an integer that controls the overall startup mode. Knowing which value to set is a common point of confusion:

| Value | Behavior | When to use |
|---|---|---|
| 1 | Restore the last session | Productivity workflows where users resume previous work |
| 4 | Open a specific list of URLs | Organization-mandated dashboards or portals |
| 5 | Open the New Tab page | Minimal intervention, let users customize |
| 6 | Open the New Tab page and restore the last session | Hybrid. new tab plus session restore |

For startup page enforcement, you want `RestoreOnStartup: 4` paired with a populated `RestoreOnStartupURLs` list. Setting `RestoreOnStartup` to 4 without also setting `RestoreOnStartupURLs` results in Chrome opening a blank new tab. a silent failure that is easy to miss during rollout.

## Policy Scope: Machine-Level vs. User-Level

Chrome policies can be applied at two scopes, and the distinction matters for how reliably they are enforced:

Machine-level (recommended for enforcement): Applies to all users who log in on that machine. Set through Group Policy Object (GPO) in the `Computer Configuration` branch, or via managed plist at `/Library/Managed Preferences/com.google.Chrome.plist` on macOS. Users cannot override machine-level policies.

User-level (recommended for defaults): Applies to a specific user profile. Set through GPO in the `User Configuration` branch, or via plist at `~/Library/Preferences/com.google.Chrome.plist` on macOS. Users can override these with local settings unless the policy is set as mandatory.

For compliance-critical startup pages. such as a security acknowledgment portal or a required SSO login. always use machine-level policies. For convenient defaults like linking to the team dashboard, user-level recommended policies are less intrusive and allow power users to adjust their setup.

## Configuring Startup Pages via Group Policy

Windows (Group Policy Editor)

On Windows machines managed through Active Directory or Intune, you configure these policies through the Group Policy Editor:

1. Open `gpedit.msc`
2. Navigate to: `Computer Configuration > Administrative Templates > Google Chrome > Startup`
3. Configure the following policies:

Configure Startup URLs:
```
Policy: Configure startup URLs
Path: Computer Configuration > Administrative Templates > Google Chrome > Startup

Value: https://internal.dashboard.company.com,https://docs.internal.company.com
```

Set startup behavior:
```
Policy: Action to take on startup
Options:
- Open a list of URLs (use RestoreOnStartupURLs)
- Restore the last session
- Open the New Tab page
```

If you do not have the Chrome ADMX templates installed in your Group Policy central store, the Google Chrome settings will not appear in the Group Policy Editor. Download the latest templates from the [Chrome Enterprise policy download page](https://support.google.com/chrome/a/answer/187202) and copy the `.admx` file to `%SystemRoot%\PolicyDefinitions\` and the corresponding `.adml` language file to `%SystemRoot%\PolicyDefinitions\en-US\`.

Windows Registry (Direct Application or Intune Custom OMA-URI)

For environments using Intune custom OMA-URI configurations, or for scripted registry deployments, set these registry values:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\RestoreOnStartup
Type: DWORD
Value: 4

HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs\1
Type: REG_SZ
Value: https://internal.dashboard.company.com

HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs\2
Type: REG_SZ
Value: https://status.company.com
```

You can deploy this as a PowerShell script through Intune or SCCM:

```powershell
Deploy Chrome startup pages via PowerShell
$basePath = "HKLM:\SOFTWARE\Policies\Google\Chrome"

Ensure the base key exists
New-Item -Path $basePath -Force | Out-Null

Set startup mode to "open specific URLs"
Set-ItemProperty -Path $basePath -Name "RestoreOnStartup" -Value 4 -Type DWord

Create the RestoreOnStartupURLs subkey
$urlPath = "$basePath\RestoreOnStartupURLs"
New-Item -Path $urlPath -Force | Out-Null

Set the startup URLs (1-indexed)
$startupUrls = @(
 "https://internal.dashboard.company.com",
 "https://status.company.com",
 "https://docs.company.com"
)

for ($i = 0; $i -lt $startupUrls.Count; $i++) {
 Set-ItemProperty -Path $urlPath -Name ($i + 1).ToString() `
 -Value $startupUrls[$i] -Type String
}

Write-Host "Chrome startup pages configured successfully."
```

Run this script with administrator privileges. The changes take effect the next time Chrome starts. no machine reboot is required.

macOS (Configuration Profile)

For macOS devices, you deploy Chrome policies via a mobile configuration profile (`.mobileconfig`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>PayloadContent</key>
 <array>
 <dict>
 <key>PayloadDisplayName</key>
 <string>Chrome Startup Policy</string>
 <key>PayloadType</key>
 <string>com.google.Chrome</string>
 <key>PayloadUUID</key>
 <string>YOUR-UUID-HERE</string>
 <key>PayloadVersion</key>
 <integer>1</integer>
 <key>RestoreOnStartup</key>
 <integer>4</integer>
 <key>RestoreOnStartupURLs</key>
 <array>
 <string>https://internal.dashboard.company.com</string>
 <string>https://status.company.com</string>
 </array>
 </dict>
 </array>
</dict>
</plist>
```

Deploy this profile using Jamf Pro, Microsoft Intune, or another MDM solution.

Generate a fresh UUID for your profile using the macOS built-in utility rather than using a placeholder:

```bash
Generate a new UUID for your .mobileconfig profile
uuidgen
Example output: A3F1C2B4-8E7D-4F2A-B319-12C4D5E6F789
```

Replace `YOUR-UUID-HERE` in the profile with this value before deploying. Profiles sharing the same UUID can conflict during updates, so generate a unique UUID for each distinct configuration profile.

Linux (JSON Policy Files)

On Linux, Chrome policies are delivered as JSON files placed in `/etc/opt/chrome/policies/managed/` for mandatory policies or `/etc/opt/chrome/policies/recommended/` for recommended-only policies:

```bash
Create the managed policies directory if it does not exist
sudo mkdir -p /etc/opt/chrome/policies/managed

Create the startup pages policy file
sudo tee /etc/opt/chrome/policies/managed/startup_pages.json > /dev/null <<'EOF'
{
 "RestoreOnStartup": 4,
 "RestoreOnStartupURLs": [
 "https://internal.dashboard.company.com",
 "https://status.company.com"
 ]
}
EOF

Set correct permissions. Chrome reads these as root-owned files
sudo chmod 644 /etc/opt/chrome/policies/managed/startup_pages.json
sudo chown root:root /etc/opt/chrome/policies/managed/startup_pages.json
```

Chrome reads these files at startup. To verify the policy is loaded, navigate to `chrome://policy` after restarting Chrome and look for your `RestoreOnStartupURLs` entry with the source listed as `Platform`.

## Using Chrome Policies for Development Teams

If you manage Chrome configurations programmatically. whether through configuration management tools or as part of a developer machine setup. you can automate policy deployment.

## Puppet Example

```ruby
Deploy Chrome startup pages on macOS
file { '/Library/Managed Preferences/com.google.Chrome.plist':
 ensure => file,
 content => epp('chrome/chrome_startup.plist.epp', {
 startup_urls => ['https://dev-dashboard.local', 'https://jira.company.com']
 }),
 mode => '0644',
 owner => 'root',
 group => 'wheel'
}
```

The corresponding EPP template (`chrome_startup.plist.epp`) would generate a valid plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>RestoreOnStartup</key>
 <integer>4</integer>
 <key>RestoreOnStartupURLs</key>
 <array>
<% $startup_urls.each |$url| { -%>
 <string><%= $url %></string>
<% } -%>
 </array>
</dict>
</plist>
```

## Ansible Example

```yaml
Deploy Chrome startup policy on macOS
- name: Create Chrome plist directory
 file:
 path: /Library/Managed Preferences
 state: directory
 mode: '0755'

- name: Deploy Chrome startup pages
 plist:
 path: /Library/Managed Preferences/com.google.Chrome.plist
 value:
 RestoreOnStartup: 4
 RestoreOnStartupURLs:
 - https://dev-dashboard.local
 - https://jira.company.com
 - https://confluence.company.com
```

For Linux machines managed by Ansible, use a template-based approach:

```yaml
Deploy Chrome policy on Linux managed machines
- name: Ensure Chrome managed policies directory exists
 file:
 path: /etc/opt/chrome/policies/managed
 state: directory
 mode: '0755'
 owner: root
 group: root

- name: Deploy Chrome startup pages policy
 copy:
 content: |
 {
 "RestoreOnStartup": 4,
 "RestoreOnStartupURLs": {{ chrome_startup_urls | to_json }}
 }
 dest: /etc/opt/chrome/policies/managed/startup_pages.json
 mode: '0644'
 owner: root
 group: root
 vars:
 chrome_startup_urls:
 - "https://dev-dashboard.local"
 - "https://jira.company.com"
 - "https://confluence.company.com"
 notify: Inform users to restart Chrome
```

Note that the `to_json` Ansible filter handles proper JSON serialization, including correct quoting of the URL list. Avoid building JSON strings through concatenation. a URL containing special characters can break the policy file silently.

Chrome Admin Console (Google Workspace)

For organizations using Google Workspace, you can configure Chrome browser settings centrally:

1. Sign in to the [Google Admin Console](https://admin.google.com)
2. Go to Devices > Chrome > Settings
3. Select the organizational unit
4. Configure under "Startup" > "Configure startup URLs"

The Google Admin Console also lets you define different startup pages for different organizational units (OUs). This is useful when your engineering team needs different default pages than your sales or support teams. Set the parent OU to a common landing page and override at the child OU level for teams with specific requirements.

Terraform for Google Workspace (via the googleworkspace Provider)

Teams managing Google Workspace configuration as code can set Chrome policies through Terraform:

```hcl
resource "googleworkspace_chrome_policy" "startup_pages" {
 org_unit_id = var.engineering_ou_id

 policies {
 schema_name = "chrome.users.RestoreOnStartup"

 schema_values = {
 restoreOnStartup = jsonencode("openUrls")
 }
 }

 policies {
 schema_name = "chrome.users.RestoreOnStartupURLs"

 schema_values = {
 restoreOnStartupUrls = jsonencode([
 "https://internal.dashboard.company.com",
 "https://status.company.com"
 ])
 }
 }
}
```

This approach ties your Chrome policy configuration to your infrastructure-as-code workflow, making changes auditable through git history and deployable through your existing CI/CD pipeline.

## Policy Precedence and User Experience

Understanding how Chrome resolves conflicting policies helps you avoid unexpected behavior:

1. Machine-level policies take precedence over user-level policies
2. Managed bookmarks work alongside startup pages but do not override them
3. Users cannot modify policies that are set at the machine level

If you need to allow some flexibility while maintaining defaults, consider using recommended policies instead of mandatory ones. This lets power users customize their experience while providing sensible defaults for most users.

## The Mandatory vs. Recommended Distinction

The difference between mandatory and recommended policies is significant for user experience and change management:

| Aspect | Mandatory Policy | Recommended Policy |
|---|---|---|
| User can override | No | Yes |
| Shown in chrome://policy | Yes, with "Platform" source | Yes, with "Platform" source |
| Lock icon in settings | Shown | Not shown |
| Best for | Compliance requirements | Helpful defaults |
| Change management impact | High. users may notice and complain | Low. users adapt at their own pace |

In practice, many organizations deploy startup pages as mandatory during initial onboarding (to ensure users encounter the required documentation or SSO flow) and then relax to recommended policies once the tooling is familiar. The Chrome admin console and most MDM platforms let you toggle this without changing the URL configuration.

## Testing Policy Application Without a Full MDM

During development of your policy configuration, you can test locally on macOS without deploying through MDM by writing directly to the managed preferences location:

```bash
Test a policy locally on macOS (requires sudo)
sudo defaults write /Library/Managed\ Preferences/com.google.Chrome \
 RestoreOnStartup -int 4

sudo defaults write /Library/Managed\ Preferences/com.google.Chrome \
 RestoreOnStartupURLs -array \
 "https://internal.dashboard.company.com" \
 "https://status.company.com"
```

Navigate to `chrome://policy` after restarting Chrome to confirm the policy is recognized. When you are done testing, remove the test values before deploying through your MDM to avoid conflicts:

```bash
sudo defaults delete /Library/Managed\ Preferences/com.google.Chrome
```

## Troubleshooting Common Issues

## Policy Not Applying

If Chrome is not honoring your startup page configuration:

1. Verify the policy is applied: Navigate to `chrome://policy` in Chrome
2. Check for conflicting policies: Look for both user and machine-level configurations
3. Restart Chrome: Some policies only take effect after a full browser restart
4. Clear cache: Run `chrome://restart` to ensure clean policy reload

The `chrome://policy` page is your primary debugging tool. Policies that were set but rejected show up with a red error indicator. Policies that are not present at all do not appear, which distinguishes "not set" from "set but invalid."

Common error states you may encounter:

| chrome://policy error | Root cause | Fix |
|---|---|---|
| "Value is invalid" | Type mismatch (e.g., string instead of integer for RestoreOnStartup) | Check that RestoreOnStartup is set as a DWORD/integer, not a string |
| Policy missing entirely | Profile not installed or registry key in wrong location | Verify file/registry path and run `gpupdate /force` on Windows |
| "Ignored - superseded" | A higher-precedence policy exists | Check machine-level vs. user-level; machine-level always wins |
| Policy present but Chrome ignores it | Chrome requires a full restart, not just window close | Kill all Chrome processes and relaunch |

## URLs Not Loading

Startup pages may fail to load due to:

- Network restrictions: Ensure the URLs are accessible from managed devices
- Certificate issues: Self-signed certificates on internal sites will block loading
- Proxy configuration: Verify proxy settings allow access to internal domains

You can diagnose this by checking Chrome's policy export:

```bash
Export Chrome policy status
"C:\Program Files\Google\Chrome\Application\chrome.exe" --export-app-level-policy
```

On macOS:

```bash
View applied policies
defaults read com.google.Chrome
```

## Handling Self-Signed Certificates on Internal Startup Pages

If your internal dashboard uses a self-signed or internally-signed certificate, Chrome will block it by default. preventing your startup page from loading and replacing it with a certificate warning. You have two clean options:

Option 1: Deploy your internal CA certificate via policy. This is the correct long-term fix. Add your internal CA to Chrome's trust store:

```
Policy: CertificateTransparencyEnforcementDisabledForUrls (only as a workaround)
Better: AuthorityKeyIdentifier via CACertificates policy
```

For macOS, install the certificate into the System keychain and mark it as trusted. Chrome on macOS respects the system keychain:

```bash
sudo security add-trusted-cert -d -r trustRoot \
 -k /Library/Keychains/System.keychain \
 /path/to/internal-ca.crt
```

Option 2: Allow the specific host via `AllowedDomainsForApps` or SSL exception policies. This is appropriate only as a temporary measure while you implement a proper CA chain.

## Diagnosing GPO Propagation on Windows

If you applied a Group Policy change but endpoints are not picking it up:

```powershell
Force Group Policy refresh on local machine
gpupdate /force

Check last GP refresh time
gpresult /r | Select-String "Last time Group Policy was applied"

Verbose GP result including Chrome policies
gpresult /h C:\Temp\gp-report.html
Start-Process C:\Temp\gp-report.html
```

The HTML report from `gpresult /h` is the most complete debugging tool for Group Policy issues. It shows which policies were applied, from which GPO, and which were filtered or blocked.

## Advanced: Dynamic Startup Pages

For more sophisticated deployments, you can use variable substitution in startup URLs. Chrome supports appending query parameters:

```
https://internal.dashboard.company.com?user={USERNAME}&machine={DEVICE_ID}
```

This allows your internal dashboard to personalize content based on the logged-in user or device, without requiring dynamic policy configuration for each user.

## Building a Dashboard That Responds to Startup Page Parameters

On the receiving end, your internal application reads these query parameters and can customize the experience:

```javascript
// dashboard/src/startup.js
const params = new URLSearchParams(window.location.search);
const username = params.get('user');
const deviceId = params.get('machine');

if (username) {
 // Pre-fill the SSO form or redirect to the user's personal workspace
 document.querySelector('#welcome-message').textContent =
 `Welcome back, ${username}`;
 fetchUserDashboard(username);
}

if (deviceId) {
 // Show device-specific alerts (pending software updates, compliance status)
 fetchDeviceStatus(deviceId).then(displayDeviceAlerts);
}
```

Be careful not to trust these parameters for authentication. A user can modify their startup URL or manually navigate to `?user=someone_else`. Use these parameters only for personalization hints, and rely on your SSO or authentication layer for identity verification.

## Using Per-OU Policy for Segment-Specific Startup Pages

In Google Workspace and Active Directory environments, you can assign different startup pages to different organizational units. This is powerful for large organizations where different teams need different defaults:

```
Engineering OU:
 RestoreOnStartupURLs:
 - https://github.company.com
 - https://jira.company.com/projects/ENG
 - https://grafana.company.com

Support OU:
 RestoreOnStartupURLs:
 - https://zendesk.company.com
 - https://kb.company.com

Finance OU:
 RestoreOnStartupURLs:
 - https://erp.company.com
 - https://compliance-portal.company.com
```

In Active Directory, implement this by applying different GPOs to different OUs. In Google Workspace, use the organizational unit hierarchy in the Admin Console to set override policies at child OUs.

## Security Considerations

When configuring startup pages, keep these security practices in mind:

- HTTPS only: Always use HTTPS for startup page URLs to prevent man-in-the-middle attacks
- Internal network access: Ensure managed devices can reach internal URLs. consider split-tunnel VPN configurations
- Minimize the number of startup pages: Each startup page consumes resources; four to six URLs is typically the practical maximum

## Enforcing HTTPS-Only Startup Pages

Beyond manually auditing your URL list, you can enforce the HTTPS requirement through a pre-deployment script that validates your policy files before they are pushed:

```bash
#!/bin/bash
validate-chrome-policy.sh. run before deploying policy changes

POLICY_FILE="${1:-/etc/opt/chrome/policies/managed/startup_pages.json}"

Extract URLs and check each one
urls=$(python3 -c "
import json, sys
with open('$POLICY_FILE') as f:
 policy = json.load(f)
for url in policy.get('RestoreOnStartupURLs', []):
 print(url)
")

exit_code=0
while IFS= read -r url; do
 if [[ ! "$url" =~ ^https:// ]]; then
 echo "ERROR: Non-HTTPS startup URL detected: $url"
 exit_code=1
 fi
done <<< "$urls"

if [ $exit_code -eq 0 ]; then
 echo "All startup URLs use HTTPS. Policy validated."
fi

exit $exit_code
```

Integrate this script into your CI/CD pipeline as a pre-commit or pre-deploy check to catch HTTP URLs before they reach managed machines.

## Policy Tampering Detection

On machines where local admin access cannot be fully restricted, it is worth monitoring for unauthorized changes to Chrome policy files. A simple approach on Linux or macOS is to hash the policy file and alert on changes:

```bash
#!/bin/bash
policy-integrity-check.sh

POLICY_FILE="/etc/opt/chrome/policies/managed/startup_pages.json"
HASH_FILE="/etc/opt/chrome/policies/.startup_pages.sha256"

current_hash=$(sha256sum "$POLICY_FILE" | awk '{print $1}')

if [ -f "$HASH_FILE" ]; then
 stored_hash=$(cat "$HASH_FILE")
 if [ "$current_hash" != "$stored_hash" ]; then
 echo "ALERT: Chrome startup pages policy has been modified."
 logger -t chrome-policy "ALERT: startup_pages.json hash mismatch"
 # Trigger your alerting mechanism here
 fi
else
 echo "$current_hash" > "$HASH_FILE"
 echo "Hash baseline established."
fi
```

Schedule this as a daily cron job or integrate it into your endpoint monitoring pipeline to detect unauthorized policy changes.

## Summary

Chrome Enterprise startup pages policy provides a straightforward mechanism for organizations to direct users to important resources when Chrome launches. Whether you are managing a small development team or a large enterprise deployment, the policy works across Windows, macOS, and Linux.

For developers building internal tooling, understanding these policies helps you anticipate how users will interact with your applications when they open their browser. For IT administrators, automating policy deployment through tools like Ansible, Puppet, or your MDM solution ensures consistent configuration across all managed devices.

The combination of registry-based deployment on Windows, plist files on macOS, and JSON policy files on Linux means the same logical configuration is expressed differently on each platform. but the Chrome policy engine normalizes all of them. Build your deployment pipeline to generate the correct format for each target OS from a single source of truth, and you will avoid the configuration drift that leads to support calls about "Chrome opening the wrong page on my laptop."

Start with a small pilot group, verify the behavior works as expected, then roll out organization-wide. Your users will appreciate landing directly on relevant resources rather than an empty new tab.

## Combining Startup Pages with New Tab Page Policy

Startup pages and the New Tab Page policy work independently. configuring startup pages does not affect what users see when they open a new tab mid-session. For a fully controlled experience, set both policies together.

The `NewTabPageLocation` policy redirects the new tab page to a URL of your choice:

```xml
<!-- macOS plist -->
<key>NewTabPageLocation</key>
<string>https://internal.dashboard.company.com</string>
```

```
Windows Group Policy
Policy: Set New Tab page URL
Value: https://internal.dashboard.company.com
```

For organizations that want users to see the standard Chrome new tab (with Speed Dial and recent pages) while still opening specific URLs at startup, leave `NewTabPageLocation` unset and configure only `RestoreOnStartupURLs`. The startup URLs open in separate tabs at launch but new tabs behave normally.

Conversely, some organizations want new tab control without startup behavior. because users prefer to restore their last session but still want internal tools available from every new tab. Set `NewTabPageLocation` without configuring `RestoreOnStartup`.

A complete policy combination for a development team that wants both behaviors:

```xml
<!-- Open two tabs at startup -->
<key>RestoreOnStartup</key>
<integer>4</integer>
<key>RestoreOnStartupURLs</key>
<array>
 <string>https://dev-dashboard.internal.company.com</string>
 <string>https://status.internal.company.com</string>
</array>

<!-- Every new tab also goes to the dashboard -->
<key>NewTabPageLocation</key>
<string>https://dev-dashboard.internal.company.com</string>

<!-- Pre-populate managed bookmarks -->
<key>ManagedBookmarks</key>
<array>
 <dict>
 <key>toplevel_name</key>
 <string>Company</string>
 </dict>
 <dict><key>name</key><string>Jira</string><key>url</key><string>https://jira.company.com</string></dict>
 <dict><key>name</key><string>Confluence</string><key>url</key><string>https://confluence.company.com</string></dict>
 <dict><key>name</key><string>Grafana</string><key>url</key><string>https://grafana.company.com</string></dict>
</array>
```

Combine these policies with `HomepageLocation` for a completely cohesive experience. every entry point (startup, new tab, home button) routes to company resources.

---

## Testing Startup Page Policy Before Rollout

Before deploying startup page configuration to your entire organization, test it on a single machine to verify the policy applies correctly and the URLs load as expected. A three-step verification process avoids the common issues of policy not applying or URLs failing to load.

First, apply the policy to a test machine (a local VM or your own workstation) and verify it appears in `chrome://policy`. Look for your policy under "Chrome Policies" in the Machine policies section. The "Status" column should show "OK" with a green checkmark for each applied policy.

Second, restart Chrome completely and observe startup behavior. The configured URLs should open automatically without any user interaction. If Chrome opens a previous session instead, verify that `RestoreOnStartup` is set to `4` (open specific URLs) rather than `1` (restore previous session).

Third, check that each URL actually loads. Startup pages that return 404, require VPN authentication, or display certificate errors create a poor first impression for users. For internal URLs, test the policy from outside the corporate network (using a VPN) to simulate the experience for remote workers.

Document the test results. which policies applied, which URLs loaded, and any issues encountered. before requesting approval for organization-wide deployment. This documentation also serves as a rollback reference if you need to revert the configuration quickly.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-enterprise-startup-pages-policy)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Password Manager Policy: A Practical Guide for Developers](/chrome-enterprise-password-manager-policy/)
- [Chrome Enterprise Bandwidth Management: A Practical Guide](/chrome-enterprise-bandwidth-management/)
- [Chrome Enterprise Blocked Extensions: A Practical Guide](/chrome-enterprise-blocked-extensions/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


