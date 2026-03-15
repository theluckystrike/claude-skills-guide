---
layout: default
title: "Chrome Enterprise Jamf Deployment on Mac: A Practical Guide"
description: "Learn how to deploy and manage Google Chrome Enterprise on Mac using Jamf Pro with practical examples, scripts, and configuration strategies."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-enterprise-jamf-deployment-mac/
---

Deploying Google Chrome Enterprise across a Mac fleet using Jamf Pro gives administrators precise control over browser settings, updates, and security policies. This guide walks through the complete deployment pipeline, from package acquisition to ongoing management, with actionable scripts you can adapt for your environment.

## Acquiring the Chrome Enterprise Package

Google distributes Chrome Enterprise as a DMG file containing a PKG installer. Download the macOS version from the [Chrome Enterprise browser page](https://chromeenterprise.google/browser/). You need a Google Admin console to access the full policy templates, but the base installer works without one.

For automated downloads, use the direct download URL:

```bash
curl -L -o /tmp/GoogleChrome.dmg "https://dl.google.com/chrome/mac/stable/GGRO/GoogleChrome.dmg"
```

Extract the PKG from the DMG using the `hdiutil` command:

```bash
hdiutil attach /tmp/GoogleChrome.dmg -nobrowse
cp -R /Volumes/Google\ Chrome/Google\ Chrome.pkg /tmp/
hdiutil detach /Volumes/Google\ Chrome
```

## Creating a Jamf Pro Policy

In your Jamf Pro console, navigate to **Computers > Policies** and create a new policy. Set the trigger to match your deployment strategy—common options include:

- **Enrollment complete**: Deploys when a Mac finishes Jamf enrollment
- **Recurring check**: Runs on a schedule for ongoing deployment
- **Manual**: Allows users to request Chrome from Self Service

Add the Chrome PKG as a package:

```bash
# Upload the .pkg to Jamf Pro via API
jamf policy -event installChrome
```

For scripting the installation directly on Macs, use this bash script:

```bash
#!/bin/bash
CHROME_DMG="/tmp/GoogleChrome.dmg"
CHROME_VOLUME="/Volumes/Google Chrome"
INSTALL_PATH="/Applications/Google Chrome.app"

# Download Chrome Enterprise
curl -L -o "$CHROME_DMG" "https://dl.google.com/chrome/mac/stable/GGRO/GoogleChrome.dmg"

# Mount and install
hdiutil attach "$CHROME_DMG" -nobrowse
cp -R "${CHROME_VOLUME}/Google Chrome.app" /Applications/
hdiutil detach "$CHROME_VOLUME"

# Clean up
rm -f "$CHROME_DMG"

# Verify installation
if [ -d "$INSTALL_PATH" ]; then
    echo "Chrome installed successfully"
else
    echo "Chrome installation failed" >&2
    exit 1
fi
```

## Managing Chrome Preferences with Configuration Profiles

Jamf Pro integrates with macOS configuration profiles to push Chrome settings. Create a new **Computer Configuration Profile** in Jamf and add Chrome-specific preferences under the **Google Chrome** payload.

### Essential Enterprise Settings

Configure these settings in your configuration profile:

```xml
<key>ChromePreferences</key>
<dict>
    <key>DefaultBrowserProviderID</key>
    <string>com.google.chrome</string>
    <key>Disable3rdPartyAppBlocking</key>
    <false/>
    <key>ForceSafeSearch</key>
    <true/>
    <key>IncognitoModeAvailability</key>
    <integer>1</integer>
    <key>ManagedBookmarks</key>
    <array>
        <dict>
            <key>children</key>
            <array>
                <dict>
                    <key>url</key>
                    <string>https://internal.yourcompany.com</string>
                </dict>
            </array>
            <key>name</key>
            <string>Internal Tools</string>
        </dict>
    </array>
    <key>ShowBookmarkBar</key>
    <true/>
</dict>
```

### Extension Management

Control which extensions load by default:

```xml
<key>ExtensionInstallForcelist</key>
<array>
    <string>gbkeegbaiigmenfmjfclcdgdpimamgkj;https://clients2.google.com/service/update2/crx</string>
</array>
<key>ExtensionInstallBlocklist</key>
<array>
    <string>extension_id_to_block</string>
</array>
```

Replace the extension ID with your organization's required extensions. Find extension IDs by visiting the Chrome Web Store and copying the ID from the URL.

## Automating Updates with Jamf

Chrome's auto-update mechanism works independently of Jamf, but enterprises often require controlled update rollouts. Disable Chrome's built-in updates and manage them through Jamf policies instead.

Create a separate policy for updates:

```bash
#!/bin/bash
# update-chrome.sh - Run via Jamf policy

CURRENT_VERSION=$(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version | awk '{print $3}')
LATEST_VERSION=$(curl -s "https://omahaproxy.appspot.com/all?channel=stable" | grep "mac,arm64" | cut -d',' -f3)

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Updating Chrome from $CURRENT_VERSION to $LATEST_VERSION"
    
    # Download and install new version
    curl -L -o /tmp/GoogleChrome.dmg "https://dl.google.com/chrome/mac/stable/GGRO/GoogleChrome.dmg"
    hdiutil attach /tmp/GoogleChrome.dmg -nobrowse
    rm -rf /Applications/Google\ Chrome.app
    cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/
    hdiutil detach "/Volumes/Google Chrome"
    rm -f /tmp/GoogleChrome.dmg
    
    echo "Chrome updated successfully"
else
    echo "Chrome is current ($CURRENT_VERSION)"
fi
```

Schedule this policy to run weekly or monthly depending on your change management requirements.

## Deploying Chrome Policies via ADMD Files

For more complex policy management, use Chrome's administrative template (ADMX/ADML) files. Download them from the [Chrome Enterprise release archive](https://chromeenterprise.google/browser/download). Import the templates into your Jamf Pro instance:

1. Download the Chrome policy template ZIP
2. Extract `chrome.adml` and `chrome.admx`
3. In Jamf Pro, go to **Computer Configuration Profiles > New > Add**
4. Under **Templates**, select the Chrome policies you need

This approach supports hundreds of settings including proxy configuration, certificate management, and content filtering.

## Verification and Troubleshooting

After deployment, verify Chrome is installed and configured correctly:

```bash
# Check Chrome installation
ls -la /Applications/Google\ Chrome.app

# Verify Chrome opens without errors
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Check applied policies
defaults read com.google.Chrome 2>/dev/null | head -20
```

Common issues and solutions:

- **Extension blocked**: Ensure the extension ID in your blocklist matches exactly
- **Policies not applying**: Check the configuration profile is assigned to the correct computer group
- **Update failures**: Verify network access to dl.google.com and ensure the Mac has sufficient permissions

## Scripted Uninstall for Testing

When testing different configurations, you may need to remove Chrome:

```bash
#!/bin/bash
# uninstall-chrome.sh

# Quit Chrome if running
osascript -e 'quit app "Google Chrome"' 2>/dev/null

# Remove application
rm -rf /Applications/Google\ Chrome.app

# Remove supporting files
rm -rf ~/Library/Application\ Support/Google/Chrome
rm -rf ~/Library/Caches/Google/Chrome
rm -rf ~/Library/Preferences/com.google.Chrome.plist

echo "Chrome removed"
```

## Wrapping Up

Deploying Chrome Enterprise via Jamf gives you the best of both worlds: the browser your users expect combined with enterprise-grade control. Start with basic deployment, then layer on policies for extensions, bookmarks, and security settings as your rollout matures.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
