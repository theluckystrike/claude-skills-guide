---

layout: default
title: "Chrome OS Kiosk Mode: Managed Guest Setup Guide (2026)"
description: "Configure Chrome OS kiosk mode and managed guest sessions for enterprise deployments. Step-by-step setup for restricted user environments."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-os-kiosk-mode-managed-guest/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

Chrome OS provides two powerful mechanisms for deploying locked-down, single-purpose device configurations: Kiosk Mode and Managed Guest Sessions. These features serve different use cases but share a common goal, providing controlled access to Chrome OS devices while maintaining security and manageability.

This guide covers the technical implementation details for both approaches, with practical configuration examples for enterprise administrators and developers building kiosk-style applications. Whether you are deploying a fleet of self-service terminals in a hospital lobby or setting up shared Chromebooks for a school computer lab, understanding how these two modes differ will help you choose the right approach and avoid common pitfalls.

## Understanding the Two Approaches

Kiosk Mode runs a single specified web app or Android app as the only accessible application on the device. The user cannot exit Kiosk Mode without administrative credentials. This is ideal for digital signage, point-of-sale terminals, and dedicated information kiosks.

Managed Guest Sessions create a temporary, guest-oriented session that persists during use but wipes completely upon logout. This approach suits shared device scenarios in education, healthcare, and retail where users need browser access without persistent data storage.

Both modes integrate with Google Admin Console for centralized management, but they differ significantly in deployment complexity and user experience.

## Quick Comparison

| Feature | Kiosk Mode | Managed Guest Session |
|---|---|---|
| App access | Single app only | Full Chrome browser |
| User logout | Admin credentials required | User can log out freely |
| Data persistence | Configurable per-session | Wiped on logout |
| Extensions | Kiosk app extensions only | Policy-defined extensions |
| Best for | Digital signage, POS, ATMs | Shared browsers, labs, lobbies |
| License required | Chrome Enterprise / Education | Chrome Enterprise / Education |
| Auto-launch | Yes, on device boot | No, user selects session |

Understanding these distinctions upfront will save you from a common mistake: deploying Managed Guest Sessions when you actually need the strict lockdown of Kiosk Mode, or vice versa.

## Kiosk Mode Implementation

## Prerequisites

Before configuring Kiosk Mode, ensure you have:

- A Chrome device enrolled in Chrome Enterprise or Chrome Education
- Admin Console access with sufficient privileges
- A Kiosk app (PWA or Android app) published to your organization or the public Chrome Web Store
- Chrome OS version 87 or later for PWA kiosk support (Android app kiosks require version 64+)

## Configuration via Google Admin Console

1. Navigate to Devices > Chrome > Apps & Extensions > Kiosks in Google Admin Console
2. Click Add and select your kiosk application
3. Configure auto-launch settings and session persistence options
4. Assign the kiosk to specific organizational units

When adding the app, you will be prompted to choose whether it auto-launches on device boot. For production kiosk deployments, always enable auto-launch. This ensures the device recovers automatically after power outages or reboots without requiring manual intervention.

You can also configure multiple kiosk apps per organizational unit. The device will display a selection screen unless exactly one app has auto-launch enabled. This is useful for testing, where you might want engineers to choose between a production and staging version of your kiosk app.

## Command-Line Configuration for Testing

For development and testing, you can enable Kiosk Mode directly on a Chrome OS device:

```bash
Enter developer mode (requires powerwash or recovery)
Open terminal (Ctrl+Alt+T) and run:

set_kiosk <app-id> --acknowledge-warning

Example with a PWA
set_kiosk ohadmglpchpmjddabeookgjjmgohgfhh --acknowledge-warning
```

To find your app ID, install the Kiosk app from the Chrome Web Store and note the ID from the URL (e.g., `https://chrome.google.com/webstore/detail/app-name/APP_ID_HERE`).

For hosted web apps and PWAs, the app ID is generated when you publish to the Chrome Web Store or when you load the app via a policy-specified URL. To find an installed app's ID from the Crosh terminal, run:

```bash
List installed kiosk apps and their IDs
kiosk_launcher list

Get detailed information about a specific kiosk session
kiosk_launcher info <app-id>
```

## JSON Configuration for Auto-Setup

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

For organizations managing hundreds of devices, consider using the Chrome Management API to push policy updates programmatically rather than navigating the Admin Console manually for each organizational unit:

```bash
Using the Chrome Management API via gcloud
gcloud alpha chromeos-devices update DEVICE_ID \
 --orgunit-path="/Kiosk Devices/Production" \
 --project=YOUR_PROJECT_ID
```

## Advanced Kiosk Configuration Options

Beyond basic app selection, Chrome OS exposes several advanced kiosk configuration options that enterprise deployments commonly need:

```json
{
 "KioskAppSettings": {
 "enable_cros_auto_update": true,
 "update_required_on_login": false,
 "allow_bailout": false,
 "required_platform_version": "15359",
 "power_management_policy": {
 "ac_screen_dim_delay_ms": 0,
 "ac_screen_off_delay_ms": 0,
 "ac_idle_action": "DoNothing"
 }
 }
}
```

The `power_management_policy` block is critical for digital signage deployments. Without it, Chrome OS may dim or turn off the display based on default power settings, even while displaying content. Setting `ac_idle_action` to `DoNothing` prevents the display from sleeping when the device is plugged in.

The `required_platform_version` field lets you pin your fleet to a specific Chrome OS version, preventing automatic OS updates that might break your kiosk app. Use this carefully, security updates will also be deferred, so establish a tested update cadence rather than pinning indefinitely.

## Managed Guest Session Configuration

Managed Guest Sessions provide a middle ground between full Kiosk Mode and regular user accounts. Users get a Chrome browser experience with enterprise-defined policies, but no personal data persists.

## Enabling Managed Guest Sessions

In Google Admin Console:

1. Go to Devices > Chrome > Device Settings
2. Scroll to Managed Guest Session
3. Enable the following options:
 - Allow Managed Guest Session
 - Enable session extension (optional, keeps session alive during brief disconnections)
 - Allow folder sharing (optional)

After enabling, the Managed Guest Session option appears on the device's login screen. Users click "Browse as Guest" to start a session. At logout, Chrome OS wipes all browsing data, cookies, local storage, and downloaded files, giving each user a clean slate.

## Session Policies for Managed Guests

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

The `SessionExpirationTimeout` value is in minutes. Setting it to 480 means sessions automatically terminate after 8 hours of activity, useful for library computers or public terminals where you want to reclaim the device overnight. Note that this timer measures session duration, not idle time. For idle-based timeouts, use the `DeviceIdleTimeout` policy separately.

## Customizing the Managed Guest Experience

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

## Pre-Installing Extensions in Managed Guest Sessions

One powerful feature of Managed Guest Sessions is the ability to force-install specific Chrome extensions that appear automatically in every guest session. This is useful for accessibility tools, translation aids, or productivity extensions that should be available to all shared-device users:

```json
{
 "ExtensionInstallForcelist": [
 "mhjfbmdgcfjbbpaeojofohoefgiehjai;https://clients2.google.com/service/update2/crx",
 "ghbmnnjooekpmoecnnnilnnbdlolhkhi;https://clients2.google.com/service/update2/crx"
 ],
 "ExtensionInstallBlacklist": ["*"],
 "ExtensionInstallWhitelist": [
 "mhjfbmdgcfjbbpaeojofohoefgiehjai",
 "ghbmnnjooekpmoecnnnilnnbdlolhkhi"
 ]
}
```

The `ExtensionInstallBlacklist: ["*"]` setting blocks users from installing any extensions not explicitly whitelisted. Combined with `ExtensionInstallForcelist`, you get a controlled extension environment where pre-approved tools are always available but users cannot add unauthorized extensions.

## Managed Guest Session vs. Kiosk Mode: When to Use Each

The decision between Kiosk Mode and Managed Guest Sessions often comes down to how much flexibility you want users to have:

| Scenario | Recommended Mode | Reason |
|---|---|---|
| Airport check-in terminal | Kiosk Mode | One app, no exit needed |
| Hospital patient portal | Kiosk Mode | Single app, high security |
| School computer lab | Managed Guest Session | Students need browser for research |
| Library public computer | Managed Guest Session | General browsing, clean sessions |
| Retail self-checkout | Kiosk Mode | POS app, no browser access |
| Conference room display | Kiosk Mode | Signage or room booking app |
| Hotel lobby workstation | Managed Guest Session | Guests need email, printing |
| Workforce training center | Managed Guest Session | Multiple learning platforms |

## Use Case: Developer Kiosk for Testing

Developers often need dedicated test devices that simulate end-user environments. Chrome OS Kiosk Mode excels here:

1. Create a test PWA: Package your web app as a Progressive Web App with a valid manifest and service worker
2. Enroll a Chromebox: Use cloud-based enrollment or USB drive enrollment
3. Configure Kiosk Mode: Point to your test PWA's app ID
4. Add debugging policies: Enable remote debugging for development:

```json
{
 "DevToolsAvailability": "allowed",
 "ScreensaverLock": false,
 "LoginScreenPowerManagement": {
 "ACIdleDelaySeconds": 300,
 "BatteryIdleDelaySeconds": 180
 }
}
```

This setup provides a clean, reproducible test environment that mirrors production kiosk deployments.

## Remote Debugging a Kiosk App

With `DevToolsAvailability` set to `allowed`, you can attach Chrome DevTools remotely to inspect your kiosk app without physically accessing the device:

```bash
On your development machine, connect to the kiosk device over SSH
Chrome remote debugging port defaults to 9222 in kiosk sessions
ssh -L 9222:localhost:9222 user@kiosk-device-ip

Then open Chrome and navigate to:
chrome://inspect/#devices
Your kiosk app will appear under Remote Target
```

Remote debugging is invaluable when troubleshooting production kiosk issues, you can inspect the DOM, monitor network requests, and execute console commands without interrupting the kiosk session or touching the physical hardware.

## Simulating Kiosk Mode in a Browser Window

During initial development, use Chrome's `--kiosk` flag to simulate the kiosk environment before enrolling a device:

```bash
macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
 --kiosk \
 --app=https://your-kiosk-app.example.com \
 --disable-infobars \
 --noerrdialogs \
 --no-first-run

Linux
google-chrome \
 --kiosk \
 --app=https://your-kiosk-app.example.com \
 --disable-infobars \
 --noerrdialogs
```

This launches Chrome in a full-screen, borderless window that closely approximates the Chrome OS Kiosk Mode experience. The main differences are that you can still use keyboard shortcuts like Alt+F4 to exit, and Chrome OS-specific APIs are not available in this mode.

## Security Considerations

Both Kiosk Mode and Managed Guest Sessions operate within Chrome OS's sandboxed architecture, but you should still implement additional safeguards:

- Network restrictions: Configure allowlists for accessible domains using URL Filtering policies
- Session timeouts: Set automatic logout after periods of inactivity
- USB restrictions: Disable USB storage access in device policies
- External peripheral control: Limit or block access to cameras, microphones, and external displays

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

## URL Filtering in Depth

The URL filtering policy in Chrome OS supports several pattern types beyond simple domain matching:

```json
{
 "URLBlocklist": ["*"],
 "URLAllowlist": [
 "https://app.yourcompany.com",
 "https://*.googleapis.com",
 "chrome-extension://*",
 "https://accounts.google.com/ServiceLogin",
 "data:*"
 ]
}
```

Using `URLBlocklist: ["*"]` combined with an explicit allowlist is the most secure approach for kiosk deployments. It denies all URLs by default and only permits explicitly listed resources. This prevents users from navigating to arbitrary sites even if they find a way to open a browser window.

Include `chrome-extension://*` in the allowlist if you have force-installed extensions, some extensions load local resources from the `chrome-extension://` scheme and will break if this scheme is blocked.

## Hardening the Physical Device

Policies alone do not protect against physical tampering. For unattended kiosk deployments, consider these hardware-level safeguards:

- Enable Verified Boot (enabled by default on Chrome OS, but verify in Admin Console)
- Disable the developer mode escape sequence so users cannot bypass enrollment
- Configure USB port restrictions to prevent data exfiltration via USB drives while still allowing HID devices like mice and keyboards if needed
- Use tamper-evident enclosures for Chromebox devices in public locations
- Enable remote wipe capabilities through Google Admin Console in case of device theft

```json
{
 "DeviceBlockDevmode": true,
 "UsbDetachableAllowlist": [],
 "ExternalStorageReadOnly": true,
 "DeviceRebootOnShutdown": true
}
```

`DeviceRebootOnShutdown` ensures that if a kiosk device is shut down rather than restarted, it reboots automatically. This prevents the device from sitting in a powered-off state in a public location where it is accessed during the boot sequence.

## Troubleshooting Common Issues

Kiosk app fails to launch: Verify the app ID is correct and the app is published to your organization or publicly. Check Chrome OS version compatibility. Review the device log at `chrome://device-log` for specific error messages. Common causes include app ID mismatches, network failures preventing the app from loading, and policy conflicts between organizational units.

Managed Guest Session unavailable: Ensure the device is enrolled and your license includes Managed Guest Sessions (typically Chrome Education or Enterprise). The feature is not available on Chrome OS Flex or unmanaged consumer devices.

Session terminates unexpectedly: Review power management settings and session timeout configurations. Check for policy conflicts in Google Admin Console. Sessions may also terminate if the device detects low storage, Chrome OS requires a minimum amount of free disk space to operate normally.

Network connectivity issues: Pre-configure WiFi credentials using device onboarding policies. Consider offline functionality for critical kiosk deployments.

```json
{
 "OpenNetworkConfiguration": {
 "Type": "UnencryptedConfiguration",
 "NetworkConfigurations": [
 {
 "GUID": "kiosk-wifi-primary",
 "Name": "KioskNetwork",
 "Type": "WiFi",
 "WiFi": {
 "SSID": "KioskNetwork",
 "Security": "WPA-PSK",
 "Passphrase": "your-passphrase",
 "AutoConnect": true
 }
 }
 ]
 }
}
```

App updates breaking the kiosk: If a kiosk app auto-updates and introduces a regression, you can roll back by pointing the kiosk configuration to a specific version of your app. For Chrome Web Store apps, use the `update_url` parameter to serve app updates from your own update server, giving you full control over when updates are pushed to production devices.

Kiosk device not appearing in Admin Console: Enrollment failures commonly occur when the device cannot reach Google's enrollment servers during the setup process. Ensure the device has internet access and the domain's enrollment token has not expired. Check that the organizational unit associated with the enrollment token has Chrome enrollment enabled.

## Monitoring and Reporting

Google Admin Console provides a device overview report that shows the online/offline status of all enrolled Chrome devices, the version of Chrome OS running on each, and the last sync time for policy updates. For kiosk deployments at scale, set up alerts for devices that have been offline for an extended period, this usually indicates a network failure, power outage, or hardware issue that needs physical investigation.

For more granular monitoring, the Chrome Management API exposes device status endpoints:

```bash
Fetch device status using the Chrome Management API
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 "https://chromemanagement.googleapis.com/v1/customers/my_customer/devices?pageSize=100&filter=deviceType:CHROME"
```

Use this to build dashboards tracking fleet health, identifying devices with outdated Chrome OS versions, and auditing policy compliance across organizational units.

## Summary

Chrome OS Kiosk Mode delivers fully locked-down single-app experiences ideal for digital signage and point-of-sale. Managed Guest Sessions provide flexible, ephemeral browsing environments perfect for shared devices in enterprise and educational settings. Both integrate with Google Admin Console for centralized management and support extensive policy customization.

Choose Kiosk Mode when you need absolute control over the user experience, when the device should do one thing and only one thing. Choose Managed Guest Sessions when you need browser functionality with temporary, secure guest access and the flexibility to support multiple web-based workflows per session.

For large-scale deployments, invest time in your policy JSON structure and organizational unit hierarchy before enrolling devices. Restructuring your Admin Console OU tree after enrolling hundreds of devices is painful. Plan for monitoring and alerting from the start so you can detect device failures before users do.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-os-kiosk-mode-managed-guest)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Enterprise Kiosk Mode Setup: Complete.](/chrome-enterprise-kiosk-mode-setup/)
- [How to Disable Chrome Guest Mode via Group Policy](/chrome-guest-mode-disable-group-policy/)
- [Chrome Energy Saver Mode: A Complete Guide for.](/chrome-energy-saver-mode/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



---

## Frequently Asked Questions

### What is Understanding the Two Approaches?

Chrome OS offers two locked-down device configurations: Kiosk Mode runs a single specified web app or Android app as the only accessible application, requiring admin credentials to exit, ideal for digital signage, POS terminals, and self-service kiosks. Managed Guest Sessions create temporary browser sessions that wipe completely on logout, suited for shared devices in education, healthcare, and retail. Both require Chrome Enterprise or Education licenses and integrate with Google Admin Console for centralized fleet management.

### What is Quick Comparison?

Kiosk Mode restricts the device to a single app, requires admin credentials to exit, supports auto-launch on boot, and is best for digital signage, POS systems, and ATMs. Managed Guest Sessions provide full Chrome browser access, allow users to log out freely, wipe all data on logout, support policy-defined extension installation, and are best for shared browsers, computer labs, and hotel lobbies. Both require Chrome Enterprise or Education licensing and cannot run on Chrome OS Flex or unmanaged consumer devices.

### What is Kiosk Mode Implementation?

Kiosk Mode implementation requires a Chrome device enrolled in Chrome Enterprise or Education, Admin Console access, a Kiosk app (PWA or Android app) published to your organization, and Chrome OS version 87+ for PWA kiosks (64+ for Android apps). Configuration is done through Google Admin Console at Devices > Chrome > Apps & Extensions > Kiosks, where you add your app, enable auto-launch for production deployments, and assign it to organizational units. For bulk deployment, use JSON provisioning configurations with the Chrome Management API.

### What is Configuration via Google Admin Console?

In Google Admin Console, navigate to Devices > Chrome > Apps & Extensions > Kiosks, click Add to select your kiosk application, configure auto-launch settings (always enable for production deployments to recover from power outages automatically), and assign to specific organizational units. Multiple kiosk apps per OU display a selection screen unless exactly one has auto-launch enabled. For fleet management at scale, use the Chrome Management API via `gcloud alpha chromeos-devices update` to push policy updates programmatically.
