---
layout: default
title: "Chrome Enterprise Single App Kiosk (2026)"
description: "Learn how to configure Chrome Enterprise single app kiosk mode for dedicated devices. Step-by-step setup, XML configuration, and PowerShell deployment."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-enterprise-single-app-kiosk/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
## Chrome Enterprise Single App Kiosk: Complete Implementation Guide

Single app kiosk mode in Chrome Enterprise transforms any ChromeOS device into a dedicated terminal running only one application. This configuration eliminates user distraction, locks down the system to a single purpose, and provides a controlled environment perfect for retail point-of-sale systems, digital signage, library terminals, or enterprise check-in kiosks.

This guide walks through the technical implementation using Chrome Enterprise policies, covering both managed device configurations and the XML-based assignment files required for enterprise deployment.

## Understanding Kiosk Mode Types

ChromeOS supports two distinct kiosk implementations through Google Admin Console and Chrome Enterprise policies:

Chrome Kiosk Apps run as web applications or Chrome extensions within the kiosk session. These are ideal for web-based dashboards, single-page applications, or PWAs that function entirely in the browser. The advantage here is portability, you can update the application centrally without touching the device configuration.

Android Kiosk Apps allow enterprises to run approved Android applications in kiosk mode on ChromeOS devices that support Android apps. This option provides access to native Android functionality when your use case requires hardware access or capabilities not available in web technologies.

For this guide, we focus on Chrome Kiosk apps since they work across all ChromeOS devices without additional licensing requirements.

## Prerequisites

Before configuring kiosk mode, ensure you have:

- A Chrome Enterprise Plus or Chrome Education Standard license
- Administrative access to Google Admin Console
- A Chrome extension or web app to serve as your kiosk application
- The extension ID or web app URL for configuration

## Configuration Through Google Admin Console

The simplest path to single app kiosk involves Google Admin Console, but this guide focuses on the programmatic approach using management XML files, essential for organizations managing hundreds of devices or integrating with existing MDM solutions.

## Programmatic Configuration Using XML Assignment Files

For enterprise-scale deployments, Chrome Enterprise supports XML-based configuration files that define kiosk behavior. These files deploy through Google Workspace MDM or Chrome Policy API.

## Creating the Kiosk Configuration

Here's an example XML configuration for single app kiosk mode:

```xml
< kioskmode>
 <enabled>true</enabled>
 <kiosk_app>
 <extension_id>aldgkghkdjnfhfcpidhhkllgbcnjggln</extension_id>
 <extension_type>CHROME_APP</extension_type>
 </kiosk_app>
 <auto_launch_enabled>true</auto_launch_enabled>
 <show_login_override>false</show_login_override>
 <oem_apps>
 <app>
 <extension_id>hkagkepgcopmbbmdjpbokgfhfmnlajln</extension_id>
 <install_type>FORCE_INSTALLED</install_type>
 </app>
 </oem_apps>
</kioskmode>
```

This configuration enables kiosk mode, specifies a Chrome app by its extension ID, enables automatic launch on device startup, hides the login screen, and force-installs one additional OEM app.

To find your extension ID, navigate to `chrome://extensions` in Chrome and enable Developer Mode. The extension ID appears as a 32-character string using lowercase letters.

## PowerShell Deployment for Windows-Based Management

If your organization uses Microsoft Intune or other Windows-centric management, you can push Chrome Enterprise policies to managed Windows devices running Chrome Browser. While these devices won't run ChromeOS kiosk mode directly, the same policy framework controls Chrome behavior on managed Windows workstations.

Here's a PowerShell script that configures kiosk policies via registry for Chrome Browser:

```powershell
Chrome Enterprise Kiosk Policy Configuration
Run as Administrator

$ChromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$AppPath = "$ChromePath\KioskEnable"

Create registry keys if they don't exist
if (!(Test-Path $ChromePath)) {
 New-Item -Path $ChromePath -Force | Out-Null
}

if (!(Test-Path $AppPath)) {
 New-Item -Path $AppPath -Force | Out-Null
}

Enable Kiosk Mode
Set-ItemProperty -Path $AppPath -Name "KioskModeEnabled" -Value 1 -Type DWord
Set-ItemProperty -Path $AppPath -Name "KioskModeCustomURL" -Value "https://your-kiosk-app.example.com" -Type String
Set-ItemProperty -Path $AppPath -Name "KioskModeAutoLaunch" -Value 1 -Type DWord
Set-ItemProperty -Path $AppPath -Name "KioskDisableLoginOverride" -Value 1 -Type DWord

Write-Host "Chrome Kiosk policies configured successfully"
```

This script creates the necessary registry keys that Chrome reads on startup. The `KioskModeCustomURL` specifies your web-based kiosk application, while the additional flags control startup behavior.

## JSON Policy Format for Chrome Policy API

Modern Chrome Enterprise deployments often use the Chrome Policy API with JSON-formatted policies. Here's how to structure kiosk configuration:

```json
{
 "chrome.KioskModeSettings": {
 "Value": {
 "kiosk_enabled": true,
 "auto_launch_kiosk_app": {
 "id": "aldgkghkdjnfhfcpidhhkllgbcnjggln",
 "type": "CHROME_APP"
 },
 "disable_login_override": true,
 "force_ephemeral_mode": false,
 "update_settings": {
 "update_check_url": "https://your-update-server.example.com/updates.xml",
 "update_check_period_minutes": 60
 }
 }
 },
 "chrome.KioskEnable": {
 "Value": {
 "EnableKioskMode": true,
 "KioskCustomLaunchUrl": "https://your-kiosk-app.example.com"
 }
 }
}
```

This JSON structure works with Google's admin SDK tools and can be pushed through Chrome Enterprise or Google Workspace MDM.

## Controlling Kiosk Session Behavior

Beyond initial launch configuration, Chrome Enterprise policies control what users can do within the kiosk session. Add these policies to your configuration:

```xml
<kiosk_session_controls>
 <user_session_allowed>false</user_session_allowed>
 <exit_disabled>true</exit_disabled>
 <reset_on_exit>false</reset_on_exit>
 <url_allowlist>
 <url>https://primary-kiosk-app.example.com</url>
 </url_allowlist>
 <url_blocklist>
 <url>*</url>
 </url_blocklist>
</kiosk_session_controls>
```

The `url_allowlist` and `url_blocklist` work together, only URLs matching the allowlist can be navigated to, while the blocklist provides an additional filtering layer. In this example, the wildcard blocklist ensures no navigation occurs outside the explicitly allowed domain.

## Testing Your Configuration

Before rolling out kiosk mode organization-wide, test your setup on a small device group:

1. Create a dedicated organizational unit in Google Admin Console
2. Apply kiosk policies to that OU only
3. Enroll a test device into the OU
4. Verify the application launches automatically
5. Confirm exit attempts are blocked or behave as expected

Use the Chrome Management Settings Report in Admin Console to audit which devices have received and applied your kiosk policies.

## Troubleshooting Common Issues

Kiosk app fails to launch: Verify the extension ID is correct and the app is published or whitelisted. Check Chrome Device Management reports for policy push failures.

Device stuck in login screen: The `show_login_override` setting is true, or the kiosk app ID is invalid. Review device logs through the admin console.

Application updates not applying: Ensure your update check URL is reachable and the device can access it. Kiosk apps may need explicit update policy configuration.

Exit button visible when it shouldn't be: The `exit_disabled` policy only works with managed sessions. Ensure devices are properly enrolled and receiving policies.

## Conclusion

Chrome Enterprise single app kiosk mode provides a solid foundation for deploying dedicated-purpose ChromeOS devices. By combining XML assignment files, PowerShell deployment scripts, and Chrome Policy API configurations, IT administrators can manage kiosk deployments at scale while maintaining security and control.

The key to successful kiosk deployments lies in thoroughly testing your configuration before broad rollout and maintaining clear policies around application updates and session management. With proper implementation, Chrome Enterprise kiosk mode delivers reliable, distraction-free computing experiences for any single-app use case.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-enterprise-single-app-kiosk)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Kiosk Mode Setup: Complete.](/chrome-enterprise-kiosk-mode-setup/)
- [AI Coding Tools Security Concerns Enterprise Guide](/ai-coding-tools-security-concerns-enterprise-guide/)
- [Augment Code AI Review for Enterprise Teams 2026](/augment-code-ai-review-for-enterprise-teams-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

