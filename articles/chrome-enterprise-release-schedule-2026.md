---
layout: default
title: "Chrome Enterprise Release Schedule 2026"
description: "Chrome Enterprise release dates for 2026. Stable, Extended Stable, and Beta channel schedules with upgrade planning tips. Tested on Chrome."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-enterprise-release-schedule-2026/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
---

# Chrome Enterprise Release Schedule 2026: A Practical Guide

Understanding the Chrome Enterprise release schedule is essential for IT administrators and developers managing browser deployments across organizations. Google maintains a predictable release cadence that balances new features with stability requirements for enterprise environments.

This guide covers the Chrome Enterprise release schedule for 2026, explaining release channels, version numbering, and practical strategies for managing browser updates in production environments.

## Understanding Chrome Release Channels

Chrome offers three primary release channels, each serving different organizational needs:

## Stable Channel

The Stable channel receives updates approximately every four weeks. These releases contain fully tested features and bug fixes that have passed through the Beta and Dev channels. For most enterprise deployments, the Stable channel provides the right balance between security and predictability.

## Extended Stable Channel

Google introduced the Extended Stable channel specifically for enterprise environments requiring more testing time before deploying updates. This channel receives updates every eight weeks, giving IT teams additional window to validate browser changes before they reach end users.

The Extended Stable channel follows a staggered release pattern. When a new Stable version launches, the Extended Stable channel receives the previous Stable release. This creates a predictable lag that enterprises can plan around.

## Beta and Dev Channels

The Beta channel receives updates roughly every week and represents features planned for future Stable releases. The Dev channel, updated even more frequently, contains experimental features still under development.

## Chrome Enterprise Release Schedule 2026

Here is the projected Stable and Extended Stable release schedule for 2026:

| Month | Stable Version | Extended Stable Version |
|-------|---------------|------------------------|
| January 2026 | Chrome 131 | Chrome 129 |
| February 2026 | Chrome 132 | Chrome 129 |
| March 2026 | Chrome 133 | Chrome 131 |
| April 2026 | Chrome 134 | Chrome 131 |
| May 2026 | Chrome 135 | Chrome 133 |
| June 2026 | Chrome 136 | Chrome 133 |
| July 2026 | Chrome 137 | Chrome 135 |
| August 2026 | Chrome 138 | Chrome 135 |
| September 2026 | Chrome 139 | Chrome 137 |
| October 2026 | Chrome 140 | Chrome 137 |
| November 2026 | Chrome 141 | Chrome 139 |
| December 2026 | Chrome 142 | Chrome 139 |

This schedule follows Google's four-week release cycle with the eight-week Extended Stable cadence layered on top.

## Managing Chrome Updates via Group Policy

For Windows environments managed through Active Directory, Group Policy provides granular control over Chrome updates. Here are the key policy settings IT administrators should configure:

## Disable Automatic Updates

If your organization requires manual update control, you can disable automatic updates:

```xml
<!-- Group Policy XML snippet -->
<policy name="AutoUpdateCheckPeriodMinutes" 
 category="Google Chrome - Updates" 
 value="0" />
<policy name="UpdatePolicyOverrideDefault" 
 category="Google Chrome - Updates" 
 value="update_policy_override_default=disabled" />
```

## Configure Update Check Frequency

For organizations wanting controlled automatic updates, adjust the check interval:

```xml
<policy name="AutoUpdateCheckPeriodMinutes" 
 category="Google Chrome - Updates" 
 value="60" /> <!-- Check every 60 minutes -->
```

## Set Target Channel

You can force specific channels across your organization:

```xml
<policy name="UpdateChannel" 
 category="Google Chrome - Updates" 
 value="extended" /> <!-- Use Extended Stable -->
```

## Chrome Enterprise for macOS and Linux

Managing Chrome Enterprise on macOS and Linux requires different approaches compared to Windows.

macOS MDM Deployment

For macOS environments, use Mobile Device Management (MDM) to deploy Chrome with specific configurations:

```bash
Create Chrome Enterprise configuration profile
defaults write com.google.Chrome UpdateChannel -string "extended"
defaults write com.google.Chrome AutoUpdateCheckPeriodMinutes -int 0
```

## Linux Package Management

On Linux, you can pin specific Chrome versions using your package manager. For example, with apt:

```bash
Pin Chrome to a specific version
echo "google-chrome-stable hold" | sudo dpkg --set-selections

Or specify version pinning in apt preferences
cat /etc/apt/preferences.d/chrome-pin
Package: google-chrome-*
Pin: version 131.*
Pin-Priority: 1000
```

## Version Detection and Scripting

Developers and IT teams often need to programmatically detect Chrome versions across their infrastructure. Here are practical approaches:

## PowerShell Script for Windows

```powershell
function Get-ChromeVersion {
 $chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
 
 if (Test-Path $chromePath) {
 $version = (Get-Item $chromePath).VersionInfo.FileVersion
 $channel = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Google\Chrome\BLBeacon" -ErrorAction SilentlyContinue).version
 
 return @{
 Version = $version
 Channel = if ($channel -match "extended") { "Extended Stable" } else { "Stable" }
 }
 }
 return $null
}

Get-ChromeVersion
```

## Bash Script for macOS/Linux

```bash
#!/bin/bash

get_chrome_version() {
 if [[ "$OSTYPE" == "darwin"* ]]; then
 chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
 else
 chrome_path="/usr/bin/google-chrome-stable"
 fi
 
 if [[ -f "$chrome_path" ]]; then
 version=$("$chrome_path" --version 2>/dev/null)
 echo "Chrome Version: $version"
 else
 echo "Chrome not found"
 fi
}

get_chrome_version
```

## Planning Your Deployment Strategy

When planning Chrome Enterprise deployments, consider these factors:

## Testing Environment Setup

Create a representative test group that receives updates first. This group should include users from different departments and use cases. Monitor for issues before broader rollout.

## Staged Rollout Approach

For larger organizations, implement phased deployment:

1. Pilot Group (5-10%): Initial deployment to IT-friendly users
2. Extended Pilot (25%): Broader testing with representative users
3. General Deployment (100%): Organization-wide rollout

## Monitoring and Rollback

Always maintain the ability to rollback if issues arise. Chrome stores previous versions that can be reinstalled if needed:

```powershell
Windows: List available Chrome versions
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome" | Select-Object DisplayVersion
```

## Security Considerations

Chrome Enterprise releases include critical security patches. The security release schedule typically aligns with the regular release cadence, but out-of-band patches may occur for critical vulnerabilities.

Ensure your update infrastructure can handle emergency patches. Configure notification systems to alert IT staff when critical updates are available:

```json
{
 "chrome_update_config": {
 "check_frequency": "hourly",
 "critical_alerts": true,
 "auto_download": false,
 "auto_install": false
 }
}
```

## Conclusion

The Chrome Enterprise release schedule for 2026 maintains Google's commitment to predictable four-week Stable releases with an eight-week Extended Stable option. Organizations should choose their channel based on testing capacity and risk tolerance.

For most enterprises, the Extended Stable channel provides the best balance between security updates and deployment stability. However, organizations with solid testing infrastructure may prefer the Stable channel for access to the latest features.

Understanding these release patterns and implementing appropriate management policies ensures smooth browser deployments while maintaining security compliance across your organization.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-enterprise-release-schedule-2026)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Stable Channel Management: A Practical Guide](/chrome-enterprise-stable-channel-management/)
- [Chrome Extension Enterprise Approval Workflow: A Practical Guide](/chrome-extension-enterprise-approval-workflow/)
- [Chrome Enterprise Bookmark Bar Settings: A Complete Guide](/chrome-enterprise-bookmark-bar-settings/)
- [Schedule Tweets Threads Chrome Extension Guide (2026)](/chrome-extension-schedule-tweets-threads/)
- [Sneaker Release Alert Chrome Extension Guide (2026)](/chrome-extension-sneaker-release-alert-chrome/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


