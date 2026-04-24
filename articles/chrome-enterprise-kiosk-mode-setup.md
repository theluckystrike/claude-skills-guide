---
layout: default
title: "Chrome Enterprise Kiosk Mode Setup"
description: "A comprehensive guide to setting up Chrome Enterprise Kiosk Mode for enterprise deployments. Covers Google Admin Console configuration, PowerShell."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-enterprise-kiosk-mode-setup/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
## Chrome Enterprise Kiosk Mode Setup: Complete Implementation Guide

Chrome Enterprise Kiosk Mode transforms Chrome browsers and ChromeOS devices into dedicated single-application terminals. This configuration is essential for enterprises deploying point-of-sale systems, digital signage, library terminals, corporate check-in kiosks, and restricted employee workstations.

This guide covers the complete setup process using Google Admin Console, Windows Group Policy, and programmatic deployment options for enterprise-scale rollouts.

## Understanding Chrome Enterprise Kiosk Mode

Chrome Enterprise supports kiosk functionality across two distinct platforms:

ChromeOS Kiosk Mode runs on ChromeOS devices (Chromebooks, Chromebases, ChromeOS Flex), locking the device to a single web application or Android app. The user cannot exit kiosk mode without administrator credentials.

Chrome Browser Kiosk Mode runs on Windows, macOS, or Linux workstations, launching Chrome in a dedicated kiosk session that restricts user actions and limits access to a single application.

Both approaches integrate with Chrome Enterprise policies, but the configuration methods differ significantly. This guide covers both deployment scenarios.

## Prerequisites

Before setting up Chrome Enterprise Kiosk Mode, ensure you have:

- Chrome Enterprise Plus, Chrome Education Standard, or Chrome Enterprise Essentials license
- Administrative access to Google Admin Console
- For ChromeOS: a managed Chrome device enrolled in your organization
- For Chrome Browser: Chrome Browser 72 or later on managed workstations
- A kiosk application (web app, PWA, or Chrome extension) with its ID or URL ready

## Setting Up ChromeOS Kiosk Mode

## Step 1: Access Google Admin Console

Navigate to Devices > Chrome > Apps & Extensions > Kiosks in Google Admin Console. This is the central hub for managing all kiosk configurations across your ChromeOS device fleet.

## Step 2: Create a Kiosk Configuration

Click Add and select your kiosk application. You can choose from:

- Chrome Web Store apps - Search and select publicly available kiosk applications
- Custom web apps - Enter the URL of your internal web application
- Chrome extensions - Select extensions configured as kiosk-ready

## Step 3: Configure Kiosk Settings

Configure the following settings based on your deployment requirements:

- Auto-launch - Enable automatic kiosk launch when the device starts
- Session persistence - Choose whether the kiosk session persists across reboots
- User authentication - Configure whether users must authenticate before accessing the kiosk app
- Oversight mode - Enable additional restrictions for supervised usage

## Step 4: Assign to Organizational Units

Assign your kiosk configuration to specific organizational units. Kiosk assignments follow Chrome's hierarchical policy inheritance, so you can create OU-specific configurations for different device locations.

## Setting Up Chrome Browser Kiosk Mode on Windows

For organizations running Chrome Browser on Windows workstations, kiosk mode provides a locked-down browsing experience without full ChromeOS deployment.

## Using Windows Registry for Single-User Kiosk

You can configure Chrome Browser kiosk mode via Windows Registry for non-domain-joined devices:

```powershell
Chrome Browser Kiosk Mode Registry Configuration
$chromeKioskPath = "HKCU:\Software\Policies\Google\Chrome"

Create the registry key if it doesn't exist
if (!(Test-Path $chromeKioskPath)) {
 New-Item -Path $chromeKioskPath -Force | Out-Null
}

Configure kiosk mode settings
Set-ItemProperty -Path $chromeKioskPath -Name "KioskModeEnabled" -Value 1 -Type DWord
Set-ItemProperty -Path $chromeKioskPath -Name "KioskModeRetail" -Value 0 -Type DWord
Set-ItemProperty -Path $chromeKioskPath -Name "KioskModeAppLaunchUrl" -Value "https://your-kiosk-app.example.com" -Type String
```

This configuration enables kiosk mode and specifies the URL that launches automatically. The `KioskModeRetail` setting enables additional retail-specific restrictions when set to 1.

## Using Group Policy for Enterprise Deployment

For domain-joined Windows workstations, deploy kiosk configuration via Group Policy:

1. Download the latest Chrome Browser Chrome Policy Template from Google's support site
2. Import the ADMX templates into your Group Policy Central Store
3. Navigate to Computer Configuration > Administrative Templates > Google Chrome > Kiosk Settings
4. Enable and configure the following policies:
 - Enable Kiosk Mode - Turns on kiosk functionality
 - Kiosk Mode Retail Mode - Enables retail-specific restrictions
 - Kiosk App Launch URL - Specifies the application URL
 - Kiosk Mode Settings - Configures additional kiosk behavior

## PowerShell Deployment Script

Here's a comprehensive deployment script for pushing kiosk configuration via Intune or other MDM solutions:

```powershell
Chrome Enterprise Kiosk Mode Deployment Script
param(
 [Parameter(Mandatory=$true)]
 [string]$KioskAppUrl,
 
 [Parameter(Mandatory=$false)]
 [switch]$RetailMode,
 
 [Parameter(Mandatory=$false)]
 [string]$ChromePolicyPath = "HKLM:\Software\Policies\Google\Chrome"
)

Create Chrome policy registry path
New-Item -Path $ChromePolicyPath -Force | Out-Null

Configure kiosk mode
Set-ItemProperty -Path $ChromePolicyPath -Name "KioskModeEnabled" -Value 1 -Type DWord
Set-ItemProperty -Path $ChromePolicyPath -Name "KioskModeAppLaunchUrl" -Value $KioskAppUrl -Type String

if ($RetailMode) {
 Set-ItemProperty -Path $ChromePolicyPath -Name "KioskModeRetail" -Value 1 -Type DWord
}

Disable exit via ESC key in kiosk mode
Set-ItemProperty -Path $ChromePolicyPath -Name "KioskDisableEscapeQuit" -Value 1 -Type DWord

Disable downloads in kiosk mode
Set-ItemProperty -Path $ChromePolicyPath -Name "KioskDisableDownloads" -Value 1 -Type DWord

Write-Host "Chrome Kiosk Mode configured successfully for: $KioskAppUrl"
```

## Programmatic Configuration with Chrome Policy API

For organizations with custom MDM solutions or automated provisioning systems, Chrome Enterprise supports programmatic policy configuration through the Chrome Policy API.

## Using the Chrome Policy API

```python
#!/usr/bin/env python3
"""
Chrome Enterprise Kiosk Mode Configuration via Policy API
"""

import requests
from google.oauth2 import service_account
from googleapiclient.discovery import build

def configure_kiosk_mode(org_unit_id, kiosk_app_url, credentials):
 """Configure kiosk mode for a specific organizational unit."""
 
 service = build('admin', 'directory_v1', credentials=credentials)
 
 # Build the kiosk policy JSON
 kiosk_policy = {
 'kioskModeEnabled': True,
 'kioskModeAppLaunchUrl': kiosk_app_url,
 'kioskModeRetail': False,
 'kioskDisableEscapeQuit': True,
 'kioskDisableDownloads': True
 }
 
 # Apply the policy to the organizational unit
 body = {
 'policySchemas': [{
 'schemaName': 'kiosk_mode_settings',
 'policyValue': kiosk_policy
 }]
 }
 
 try:
 # This would use the actual Chrome Policy API endpoints
 response = service.chromeosdevices().patch(
 orgUnitPath=org_unit_id,
 body=body
 ).execute()
 return True, response
 except Exception as e:
 return False, str(e)

if __name__ == '__main__':
 print("Chrome Enterprise Kiosk Mode Configuration")
 print("Configure kiosk settings via Google Admin Console or Policy API")
```

## Troubleshooting Common Issues

## Kiosk App Not Launching

If your kiosk application fails to launch, verify:

- The application URL is accessible from the kiosk device
- The application doesn't require authentication mechanisms incompatible with kiosk mode
- ChromeOS devices have network connectivity to the application host
- For Chrome Browser kiosks, confirm the registry or Group Policy applied correctly

## Device Not Entering Kiosk Mode

For ChromeOS devices:

- Confirm the device is enrolled in Chrome Enterprise
- Verify the organizational unit assignment is correct
- Check that the kiosk app is published to your organization or publicly available
- Review device logs in Google Admin Console for policy application errors

## Network Connectivity Issues

Kiosk devices require network access for:

- Initial kiosk app download and caching
- Ongoing application functionality
- Policy updates from Google Admin Console

Configure static IP addresses and trusted network settings for production kiosk deployments to prevent connectivity-related failures.

## Best Practices for Production Deployments

1. Use dedicated kiosk hardware - ChromeOS devices designed for kiosk use offer better longevity than repurposed consumer hardware

2. Configure automatic updates - Set up Chrome Update policies to keep kiosk browsers current without manual intervention

3. Implement monitoring - Use Google Admin Console device reports to track kiosk health and connectivity

4. Plan for offline scenarios - Configure cached content and offline capabilities for your kiosk application

5. Document recovery procedures - Create clear instructions for exiting kiosk mode and performing device recovery when needed

Chrome Enterprise Kiosk Mode provides a secure, manageable foundation for deploying purpose-built browser experiences across your organization. With proper configuration and monitoring, kiosk deployments can operate reliably for years with minimal maintenance.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-enterprise-kiosk-mode-setup)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Munki Deployment: Complete Setup Guide](/chrome-enterprise-munki-deployment/)
- [Chrome Enterprise Single App Kiosk: Complete.](/chrome-enterprise-single-app-kiosk/)
- [Chrome Incognito Mode Disable Enterprise: A Complete Guide](/chrome-incognito-mode-disable-enterprise/)
- [How to Use Zotero Chrome Extension Setup Guide](/zotero-chrome-extension-setup-guide/)
- [Chrome Signage Kiosk Digital Display — Developer Guide](/chrome-signage-kiosk-digital-display/)
- [Guest Mode vs Incognito in Chrome — Differences (2026)](/chrome-guest-mode-vs-incognito/)
- [Chrome OS Kiosk Mode: Managed Guest Setup Guide (2026)](/chrome-os-kiosk-mode-managed-guest/)
- [Chrome Energy Saver Mode — Developer Guide (2026)](/chrome-energy-saver-mode/)
- [JavaScript Blocker Chrome Extension Guide (2026)](/chrome-javascript-blocker-extension/)
- [Chrome Browser Msi Deployment Sccm — Developer Guide](/chrome-browser-msi-deployment-sccm/)
- [Break Reminder Remote Work Chrome Extension Guide (2026)](/chrome-extension-break-reminder-remote-work/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


