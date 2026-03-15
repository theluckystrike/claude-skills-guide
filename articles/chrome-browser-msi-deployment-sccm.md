---
layout: default
title: "Chrome Browser MSI Deployment via SCCM: A Practical Guide"
description: "Learn how to deploy Google Chrome using MSI packages through Microsoft SCCM/Configuration Manager. Includes command-line parameters, distribution."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-browser-msi-deployment-sccm/
categories: [guides]
tags: [sccm, chrome, msi, deployment, enterprise, windows]
reviewed: true
score: 7
---

# Chrome Browser MSI Deployment via SCCM: A Practical Guide

Enterprise environments often require centralized software distribution, and Microsoft SCCM (System Center Configuration Manager) remains a popular choice for Windows deployments. Deploying Google Chrome via MSI through SCCM provides administrators with Group Policy-like control over browser settings, silent installation capabilities, and consistent rollout across the organization.

## Obtaining the Chrome MSI Package

Google provides enterprise MSI installers directly through their Chrome Enterprise bundle. The enterprise MSI differs from the standard EXE installer in that it supports silent installation and includes administrative template files for Group Policy configuration.

Navigate to the [Chrome Enterprise](https://chromeenterprise.google/) downloads page and select the MSI installer for your architecture. You will typically find two versions:

- `GoogleChromeStandaloneEnterprise.msi` — per-machine installation
- `GoogleChromeEnterprise.msi` — the same package that works for both per-user and per-machine scenarios

Download the 64-bit or 32-bit version depending on your organizational requirements. Place the MSI file in your SCCM package source directory.

## Understanding MSI Installation Parameters

The Chrome MSI supports several command-line parameters that control installation behavior. These parameters become critical when configuring your SCCM application deployment type.

### Common Installation Properties

```powershell
# Basic silent installation
msiexec /i GoogleChromeStandaloneEnterprise.msi /qn

# Installation with logging
msiexec /i GoogleChromeStandaloneEnterprise.msi /qn /l*v C:\Logs\chrome_install.log

# Specify installation directory
msiexec /i GoogleChromeStandaloneEnterprise.msi INSTALLDIR="C:\Program Files\Google\Chrome" /qn

# Disable automatic updates via MSI
msiexec /i GoogleChromeStandaloneEnterprise.msi UPDATE_DISABLED=1 /qn
```

The `UPDATE_DISABLED=1` parameter proves particularly useful in enterprise environments where you manage Chrome updates separately through SCCM or Group Policy. Without this parameter, Chrome will attempt to check for and install updates independently, potentially conflicting with your deployment schedule.

### Silent Switch Considerations

Note that `/qn` provides silent installation with no UI, while `/qb` displays a basic progress bar. For SCCM deployments, `/qn` is typically preferred to avoid any interactive prompts that might cause deployment failures.

## Creating the SCCM Application

Begin by creating a new application in the SCCM console rather than a legacy package. Applications provide better detection logic and user experience management.

### Application Properties

1. Open the SCCM console and navigate to **Software Library** → **Applications**
2. Right-click and select **Create Application**
3. Choose **Manually specify the application information**
4. Fill in the general details:
   - **Name**: Google Chrome Enterprise
   - **Publisher**: Google LLC
   - **Version**: (current version number)

### Deployment Type Configuration

Create a Windows Installer (.msi file) deployment type:

1. Add a deployment type
2. Select **Windows Installer (.msi file)**
3. Browse to your MSI file in the content location
4. Set the installation program to:
   ```
   msiexec /i GoogleChromeStandaloneEnterprise.msi /qn
   ```
5. Configure detection rules to verify Chrome is installed:
   - Rule: **File System**
   - Path: `C:\Program Files\Google\Chrome\Application\chrome.exe`
   - File or folder: `chrome.exe`
   - This file exists with version property

### Requirements and Dependencies

Configure requirements to ensure Chrome only deploys to supported systems:

- **OS**: Windows 10 or later
- **Architecture**: x64 or x86 depending on your MSI version

You may also create dependencies on runtime dependencies like Visual C++ redistributables if your environment requires them.

## Distributing Content to Distribution Points

After creating the application, you must distribute the content to your SCCM distribution points.

1. Right-click the application and select **Distribute Content**
2. Choose your distribution point groups
3. Complete the distribution wizard

Verify the content status shows as **Success** on your distribution points before proceeding with deployment.

## Creating the Deployment

### Collection Selection

Create or select a device collection for your Chrome deployment. Common approaches include:

- **Pilot collection**: IT test devices first
- **Department collections**: Specific user groups
- **All Systems**: organization-wide rollout

### Deployment Settings

When creating the deployment:

- **Action**: Install
- **Purpose**: Required (or Available for user-initiated)
- **Deployment available time**: Set based on your maintenance window
- **Installation deadline**: Allow immediate or schedule for after-hours

For a required deployment, users cannot easily bypass the installation. This ensures consistent browser deployment across your organization.

### User Experience Settings

Configure the deployment to minimize user disruption:

- **User notifications**: Display in Software Center and show all notifications
- **Installation restart behavior**: No action required
- **Allow users to run the application independently**: Disabled for required deployments

## Post-Installation Configuration

Chrome's enterprise MSI includes support for administrative template settings that control browser behavior. These settings integrate with Group Policy after installation.

### Administrative Templates

The Chrome Enterprise bundle includes ADMX template files. Copy these to your Group Policy Central Store:

- `chrome.admx` — template definitions
- `chrome.adml` — language-specific definitions

Common enterprise settings include:

- **Default search provider**: Configure your organization's preferred search
- **Homepage URL**: Set corporate intranet or dashboard as homepage
- **Auto-update settings**: Control update behavior and timing
- **Proxy settings**: Configure organizational proxy configurations

### Registry-Based Configuration

For simpler configurations without Group Policy, you can set registry values post-installation through SCCM scripts:

```powershell
# Set default homepage via registry
$regPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
New-Item -Path $regPath -Force | Out-Null
New-ItemProperty -Path $regPath -Name "HomepageURL" -Value "https://intranet.company.com" -PropertyType String -Force | Out-Null
```

## Managing Updates

Enterprise Chrome deployments require a strategy for browser updates. Without explicit configuration, Chrome will attempt self-updates.

### Update Management Options

1. **Group Policy updates**: Use the Update policy settings to control timing
2. **SCCM software updates**: Deploy Chrome updates as you would any other update
3. **Third-party tools**: Enterprise tools like PatchMyPC can manage Chrome updates

For organizations preferring full control, disable Chrome's internal update mechanism and use SCCM to deploy new MSI versions as they become available. This approach requires monitoring Google's release cadence and testing new versions before production deployment.

## Troubleshooting Common Issues

When deployments fail, check several common sources:

**Installation logs**: The `/l*v` parameter creates detailed logs. Check `%TEMP%\Chrome_Install.log` on client machines.

**Exit codes**: MSI installations return specific exit codes. A return value of 0 indicates success, while 3010 typically means a restart is required.

**Detection rule failures**: Verify the detection rule correctly identifies Chrome installation. The path must match exactly where the MSI installs Chrome.

**Distribution point issues**: Ensure content has replicated to all distribution points serving the collection.

## Advanced: Task Sequence Deployment

For complex scenarios requiring pre-installation steps or multiple applications, consider using task sequences:

1. Create a task sequence that installs prerequisites
2. Add the Chrome MSI application step
3. Configure post-installation scripts for organizational settings
4. Deploy the task sequence to collections

This approach provides flexibility for organizations with varied machine configurations.

## Conclusion

Deploying Chrome via SCCM using MSI packages gives enterprise administrators control over browser deployment and configuration. The combination of silent installation, detection rules, and Group Policy integration creates a robust deployment framework. Remember to disable automatic updates if managing updates through SCCM, and establish a process for testing and deploying Chrome browser updates regularly.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
