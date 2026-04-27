---
sitemap: false
layout: default
title: "Chrome Browser Msi Deployment Sccm (2026)"
description: "Claude Code extension tip: learn how to deploy Google Chrome via MSI installer using Microsoft SCCM. Practical examples, command-line parameters, and..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-browser-msi-deployment-sccm/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
---
Chrome Browser MSI Deployment with SCCM: A Complete Guide

Deploying Google Chrome Enterprise across an organization requires a strategic approach. System Center Configuration Manager (SCCM) provides a solid framework for enterprise software distribution, and combining it with Chrome's MSI installer creates a reliable deployment pipeline. This guide covers the technical details you need to implement Chrome Browser MSI deployment through SCCM.

## Why Use MSI for Chrome Deployment

The MSI (Windows Installer) format offers significant advantages over EXE installers in enterprise environments. MSI packages support silent installation, group policy integration, and detailed transaction logging. When deploying Chrome across hundreds or thousands of machines, these capabilities become essential for compliance and troubleshooting.

Google provides official MSI installers for Chrome Enterprise through their Chrome Enterprise bundle. These MSI packages differ from the consumer installer in several key ways:

- Managed preferences can be embedded during installation
- Update behavior is configurable through installer properties
- Enterprise-specific policies are pre-configured in the installer

## Obtaining the Chrome Enterprise MSI

The Chrome Enterprise MSI is available through the Chrome Enterprise storefront. You'll need a Google Chrome Enterprise license to access the official MSI files. Once licensed, download the ChromeEnterpriseBundle.msi which extracts to include the Chrome MSI installer along with administrative templates and documentation.

The extracted package contains `GoogleChromeStandaloneEnterprise.msi`, this is the file you'll distribute through SCCM.

## SCCM Application Creation Steps

## Creating the Application

Launch the SCCM console and navigate to the Software Library workspace. Right-click on Applications and select Create Application. Choose Manually specify the application information since you're working with an MSI that SCCM doesn't automatically detect.

The general information phase requires these details:
- Name: Google Chrome Enterprise
- Manufacturer: Google LLC
- Software version: (check the downloaded MSI version)
- Category: Web Browsers (or your organization's preference)

## Distribution Point Configuration

Before proceeding, ensure you have a distribution point configured in your SCCM hierarchy. The application content will need to be distributed to this point for client deployment.

## Deployment Type Setup

The deployment type defines how SCCM installs the software. For Chrome MSI, create a new deployment type with these specifications:

Installation Program:
```
msiexec /i "GoogleChromeStandaloneEnterprise.msi" /q /norestart
```

Uninstall Program:
```
msiexec /x "GoogleChromeStandaloneEnterprise.msi" /q
```

Installation behavior: Install for system
Installation program visibility: Normal (or Hidden if you prefer completely silent deployment)
Maximum allowed run time: 60 minutes
Estimated installation time: 10 minutes

## Essential MSI Properties for Enterprise Deployment

The msiexec command supports numerous properties that control Chrome's installation behavior. Understanding these parameters enables customized deployments matching your organization's requirements.

## Silent Installation Properties

| Property | Description | Example Value |
|----------|-------------|---------------|
| /q | Quiet mode - minimal UI | Required |
| /qn | No UI at all | Optional |
| /norestart | Prevents automatic restart | Recommended |
| /l*v | Verbose logging | /l*v chrome_install.log |

## Chrome-Specific Properties

Chrome's MSI supports additional properties for enterprise control:

```
msiexec /i "GoogleChromeStandaloneEnterprise.msi" /q 
INSTALLDIR="C:\Program Files\Google\Chrome" 
DELETE_CACHE=1 
ENABLE_CHROMIUM_UPDATE=0
```

The `INSTALLDIR` property specifies a custom installation path. By default, Chrome installs to `%ProgramFiles%\Google\Chrome\Application`.

Setting `DELETE_CACHE=1` removes the Google Update cache after installation, preventing potential conflicts with your update infrastructure.

The `ENABLE_CHROMROMIUM_UPDATE=0` property disables Chrome's built-in update mechanism, critical when you manage updates through SCCM or Group Policy.

## Configuring Installation Behavior

## Detection Method

SCCM requires a detection method to determine if Chrome is already installed. Create a rule checking for the Chrome installation directory:

- Path: `%ProgramFiles%\Google\Chrome\Application`
- File: `chrome.exe`
- This registry key also works: `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome`

## Requirements and Dependencies

Create requirements to target appropriate machines:
- Operating System: Windows 10 version 1809 or later
- Available disk space: Minimum 500 MB
- Existing browser: Not required (Chrome can be the primary or secondary browser)

Dependencies typically aren't required for Chrome, but you might create an application dependency for Visual C++ redistributables if your organization uses older infrastructure.

## Deployment Collection Strategy

Organize your deployment using SCCM collections for staged rollouts:

1. Pilot Collection: IT department and early adopters
2. Broad Collection: General workforce
3. Exclude Collection: Machines requiring legacy browser compatibility

Apply deployment settings appropriate to each collection:
- Pilot: Available deployment, 2-day enforcement deadline
- Broad: Required deployment, 7-day enforcement deadline

## Troubleshooting Common Issues

## Installation Failures

When deployments fail, check these common causes:

Insufficient Permissions: Ensure the computer account has read access to the distribution point. The SYSTEM account performs the installation, not the user.

Disk Space: Chrome requires approximately 300 MB. Verify available space before deployment.

Conflicting Processes: If Chrome is already running during installation, the MSI fails. Use task sequencing or mandatory restart before deployment.

## Log File Analysis

Chrome installation generates logs in multiple locations:

- MSI Log: `%TEMP%\ChromeInstall.log` (or path specified with /l*v)
- Google Update Log: `%ProgramFiles%\Google\Update\Log\update.log`
- SCCM Logs: Check `%Windir%\ccm\logs` for AppDiscovery.log and AppEnforce.log

The MSI log provides the most detailed failure information. Look for return code 1603 (fatal error during installation) which typically indicates permission or path issues.

## Return Codes

Understanding MSI return codes helps diagnose issues:

- 0: Success
- 1602: User cancelled installation
- 1603: Fatal error during installation
- 1618: Another installation in progress
- 1641: Success, restart initiated

Code 1618 requires waiting for other installations to complete or investigating what process holds the Windows Installer mutex.

## Automating Updates Post-Deployment

After initial deployment, you'll need a strategy for Chrome updates. Three primary approaches work for enterprise environments:

Option 1: Disable Chrome Updates: Set `ENABLE_CHROMIUM_UPDATE=0` during installation and manage entirely through SCCM application updates.

Option 2: Use Google Update: Deploy the Google Update administrative template and configure policy settings for automatic updates.

Option 3: Hybrid Approach: Allow Chrome to check for updates but delay installation, giving SCCM time to test new versions before they're applied.

For most organizations, disabling Chrome's built-in updates and managing through SCCM provides the best control over version stability.

## Final Checklist Before Production Deployment

Before rolling out to production, verify:

- [ ] MSI file tested on clean Windows 10 and Windows 11 images
- [ ] Detection method correctly identifies existing Chrome installations
- [ ] Uninstall capability tested and verified
- [ ] Distribution point content status shows "Successfully distributed"
- [ ] Test deployment to pilot collection completed without errors
- [ ] Logging paths configured for post-deployment troubleshooting

Deploying Chrome through SCCM provides centralized control, consistent configuration, and enterprise-grade update management. The initial setup effort pays dividends through simplified ongoing maintenance and improved security posture across your organization.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=chrome-browser-msi-deployment-sccm)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading


- [Getting Started Guide](/getting-started/). From zero to productive with Claude Code
- [Chrome Memory Saver Mode: A Developer's Guide to Reducing Browser Memory Usage](/chrome-memory-saver-mode/)
- [Lightest Browser for Chromebook: A Developer Guide](/lightest-browser-chromebook/)
- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



