---
layout: default
title: "Chrome OS Kiosk Mode and Managed Guest Session Configuration"
description: "A technical guide to configuring Chrome OS kiosk mode and managed guest sessions for enterprise deployments, developer kiosks, and restricted user environments."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-os-kiosk-mode-managed-guest/
---

# Chrome OS Kiosk Mode and Managed Guest Session Configuration

Chrome OS provides two powerful mechanisms for deploying locked-down, single-purpose device configurations: Kiosk Mode and Managed Guest Sessions. These features serve different use cases but share a common goal—providing controlled access to Chrome OS devices while maintaining security and manageability.

This guide covers the technical implementation details for both approaches, with practical configuration examples for enterprise administrators and developers building kiosk-style applications.

## Understanding the Two Approaches

**Kiosk Mode** runs a single specified web app or Android app as the only accessible application on the device. The user cannot exit Kiosk Mode without administrative credentials. This is ideal for digital signage, point-of-sale terminals, and dedicated information kiosks.

**Managed Guest Sessions** create a temporary, guest-oriented session that persists during use but wipes completely upon logout. This approach suits shared device scenarios in education, healthcare, and retail where users need browser access without persistent data storage.

Both modes integrate with Google Admin Console for centralized management, but they differ significantly in deployment complexity and user experience.

## Kiosk Mode Implementation

### Prerequisites

Before configuring Kiosk Mode, ensure you have:

- A Chrome device enrolled in Chrome Enterprise or Chrome Education
- Admin Console access with sufficient privileges
- A Kiosk app (PWA or Android app) published to your organization or the public Chrome Web Store

### Configuration via Google Admin Console

1. Navigate to **Devices > Chrome > Apps & Extensions > Kiosks** in Google Admin Console
2. Click **Add** and select your kiosk application
3. Configure auto-launch settings and session persistence options
4. Assign the kiosk to specific organizational units

### Command-Line Configuration for Testing

For development and testing, you can enable Kiosk Mode directly on a Chrome OS device:

```bash
# Enter developer mode (requires powerwash or recovery)
# Open terminal (Ctrl+Alt+T) and run:

set_kiosk <app-id> --acknowledge-warning

# Example with a PWA
set_kiosk ohadmglpchpmjddabeookgjjmgohgfhh --acknowledge-warning
```

To find your app ID, install the Kiosk app from the Chrome Web Store and note the ID from the URL (e.g., `https://chrome.google.com/webstore/detail/app-name/APP_ID_HERE`).

### JSON Configuration for Auto-Setup

Create a provisioning configuration for bulk deployment:

```json
{
  "kiosk": {
    "enabled": true,
    "app_id": "ojcmgmfcmcnjhneplcgbalfaalamdhlh",
    "auto_launch": true,
    "show_notification": true
  },
  "device_settings": {
    "wifi_enabled": true,
    "configure_wifi": true,
    "network_ssid": "KioskNetwork",
    "network_password": "${WIFI_PASSWORD}"
  }
}
```

Deploy this configuration using Chrome Policy JSON files or through Google Admin Console's JSON import feature.

## Managed Guest Session Configuration

Managed Guest Sessions provide a middle ground between full Kiosk Mode and regular user accounts. Users get a Chrome browser experience with enterprise-defined policies, but no personal data persists.

### Enabling Managed Guest Sessions

In Google Admin Console:

1. Go to **Devices > Chrome > Device Settings**
2. Scroll to **Managed Guest Session**
3. Enable the following options:
   - Allow Managed Guest Session
   - Enable session extension (optional, keeps session alive during brief disconnections)
   - Allow folder sharing (optional)

### Session Policies for Managed Guests

Configure what managed guests can access:

```json
{
  "ManagedGuestSessionSettings": {
    "ManagedGuestSessionEnabled": true,
    "ExtensionsEnabled": true,
    "PrintersEnabled": false,
    "FileTransferEnabled": false,
    "IncognitoModeEnabled": true,
    "SessionExpirationTimeout": 480,
    "AllowLeavingSession": false
  }
}
```

These policies control whether users can install extensions, use printers, transfer files, or browse in incognito mode. Adjust based on your security requirements.

### Customizing the Managed Guest Experience

Add enterprise branding and default configurations:

```json
{
  "ManagedGuestSessionSettings": {
    "DefaultBookmarks": [
      {
        "name": "Help Desk",
        "url": "https://help.yourcompany.com"
      },
      {
        "name": "Company Portal",
        "url": "https://portal.yourcompany.com"
      }
    ],
    "Homepage": "https://welcome.yourcompany.com/kiosk"
  }
}
```

## Use Case: Developer Kiosk for Testing

Developers often need dedicated test devices that simulate end-user environments. Chrome OS Kiosk Mode excels here:

1. **Create a test PWA**: Package your web app as a Progressive Web App
2. **Enroll a Chromebox**: Use cloud-based enrollment or USB drive enrollment
3. **Configure Kiosk Mode**: Point to your test PWA's app ID
4. **Add debugging policies**: Enable remote debugging for development:

```json
{
  "DevToolsAvailability": "allowed",
  "ScreensaverLock": false,
  "LoginScreenPowerManagement": {
    " ACIdleDelaySeconds": 300,
    "BatteryIdleDelaySeconds": 180
  }
}
```

This setup provides a clean, reproducible test environment that mirrors production kiosk deployments.

## Security Considerations

Both Kiosk Mode and Managed Guest Sessions operate within Chrome OS's sandboxed architecture, but you should still implement additional safeguards:

- **Network restrictions**: Configure allowlists for accessible domains using URL Filtering policies
- **Session timeouts**: Set automatic logout after periods of inactivity
- **USB restrictions**: Disable USB storage access in device policies
- **External peripheral control**: Limit or block access to cameras, microphones, and external displays

```json
{
  "URLFilter": {
    "patterns": [
      "*.yourcompany.com",
      "https://trusted-partner.example.com/*"
    ]
  },
  "ExternalStorageDisabled": true,
  "CameraDisabled": false,
  "MicrophoneDisabled": false,
  "ProxySettings": {
    "ProxyMode": "pac_script",
    "ProxyPacUrl": "https://proxy.yourcompany.com/proxy.pac"
  }
}
```

## Troubleshooting Common Issues

**Kiosk app fails to launch**: Verify the app ID is correct and the app is published to your organization or publicly. Check Chrome OS version compatibility.

**Managed Guest Session unavailable**: Ensure the device is enrolled and your license includes Managed Guest Sessions (typically Chrome Education or Enterprise).

**Session terminates unexpectedly**: Review power management settings and session timeout configurations. Check for policy conflicts in Google Admin Console.

**Network connectivity issues**: Pre-configure WiFi credentials using device onboarding policies. Consider offline functionality for critical kiosk deployments.

## Summary

Chrome OS Kiosk Mode delivers fully locked-down single-app experiences ideal for digital signage and point-of-sale. Managed Guest Sessions provide flexible, ephemeral browsing environments perfect for shared devices in enterprise and educational settings. Both integrate with Google Admin Console for centralized management and support extensive policy customization.

Choose Kiosk Mode when you need absolute control over the user experience. Choose Managed Guest Sessions when you need browser functionality with temporary, secure guest access.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
