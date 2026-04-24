---

layout: default
title: "Chrome Enterprise Munki Deployment"
description: "Learn how to deploy and manage Google Chrome Enterprise using Munki with practical examples, scripts, and configuration strategies for Mac administrators."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-enterprise-munki-deployment/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

Deploying Google Chrome Enterprise across a Mac fleet requires a reliable package management solution. Munki provides an open-source framework for software distribution that gives administrators fine-grained control over installations, updates, and removals. This guide covers the complete workflow for getting Chrome Enterprise running in your organization using Munki.

## Understanding Munki for Enterprise Software Deployment

Munki consists of three main components: the Munki server (a simple web server hosting software packages and manifests), the Munki client installed on managed Macs, and the `makepkginfo` tool for creating package definitions. Unlike commercial solutions, Munki puts you in complete control of your software distribution infrastructure.

The Chrome Enterprise deployment workflow follows a straightforward pattern: download the installer, create a Munki catalog entry, define a manifest for target machines, and let Munki handle the rest. This approach works whether you manage ten Macs or ten thousand.

## Downloading Chrome Enterprise

Google provides Chrome Enterprise as a PKG installer suitable for Munki deployment. You can download the macOS version directly from Google's enterprise portal or use the command-line download for automation:

```bash
curl -L -o /tmp/GoogleChrome.pkg "https://dl.google.com/chrome/mac/stable/GGRO/GoogleChrome.pkg"
```

If you need the latest version programmatically, check Google's download page for the current URL. For organizations requiring specific versions, consider hosting a cached copy on your internal Munki server to ensure consistency across deployments.

## Creating the Munki Package Definition

Once you have the installer, use Munki's `makepkginfo` tool to generate the package catalog entry. This creates an XML plist describing the package, its version, and installation behavior:

```bash
makepkginfo /path/to/GoogleChrome.pkg --name GoogleChrome --version 120.0.6099.129 \
 --displayname "Google Chrome" --description "Google Chrome Enterprise Browser" \
 --category "Browsers" --developer "Google"
```

The command outputs XML that you add to your Munki catalog. Save this output and import it using the `makecatalogs` command:

```bash
makepkginfo /tmp/GoogleChrome.pkg >> /Library/WebServer/Documents/munki/catalogs/your-catalogname
makecatalogs your-catalogname
```

For Munki servers running in a different location, adjust the catalog path accordingly. The key fields, name, version, and displayname, appear in Self Service and the Munki status interface, so choose clear values.

## Configuring Chrome Enterprise Policies

Chrome Enterprise supports extensive group policy configuration through preferences files. Munki can deploy these as separate configuration items, ensuring browsers in your organization follow your security and usability standards.

Create a `com.google.Chrome.plist` file with your desired policies:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>DefaultBrowserSettingEnabled</key>
 <false/>
 <key>Disable3rdpartyCookies</key>
 <false/>
 <key>ForceSafeSearch</key>
 <true/>
 <key>PasswordManagerEnabled</key>
 <false/>
 <key>UpdatePolicy</key>
 <string>automatic</string>
</dict>
</plist>
```

This configuration disables setting Chrome as the default browser, enables forced safe search, disables the built-in password manager (integrate with your enterprise solution instead), and sets automatic updates. Adjust these values based on your organization's security requirements.

Deploy the preferences file using Munki by converting it to a package or using the `installs` key with a file-based rule. For Munki, create a separate pkginfo entry for the preferences:

```bash
makepkginfo --name ChromeEnterprisePrefs --version 1.0 \
 --installs "/Library/Preferences/com.google.Chrome.plist" \
 --displayname "Chrome Enterprise Policies"
```

## Building the Manifest

Munki uses manifests to define which software each machine or group receives. Create a manifest for Chrome deployment:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>catalogs</key>
 <array>
 <string>production</string>
 </array>
 <key>managed_installs</key>
 <array>
 <string>GoogleChrome</string>
 <string>ChromeEnterprisePrefs</string>
 </array>
 <key>managed_uninstalls</key>
 <array/>
 <key>optional_installs</key>
 <array/>
</dict>
</plist>
```

This manifest tells Munki to install both Google Chrome and the enterprise preferences on any Mac assigned to it. Assign machines to manifests based on your organizational structure, department, location, or machine type work well as grouping criteria.

## Handling Updates

Munki tracks installed versions and offers updates through its standard update mechanism. For Chrome specifically, consider these strategies:

Automatic minor updates: Chrome's built-in updater handles point releases automatically when you set `UpdatePolicy` to `automatic` in your preferences. This requires minimal Munki intervention beyond initial deployment.

Controlled major updates: If you need to test new Chrome versions before rolling them out, don't include the new version in your production catalog immediately. Test in a staging environment using a separate manifest, verify compatibility with your web applications, then promote to production when ready.

Blocked updates: For situations requiring version stability, you can block Chrome updates by removing Chrome's update components or setting `UpdatePolicy` to `disabled`. This works for specific use cases but creates security debt, plan for eventual updates.

## Automating the Deployment Pipeline

For larger deployments, script the entire process. Here's a complete example that downloads Chrome, creates the Munki package info, and imports to your catalog:

```bash
#!/bin/bash
Chrome Enterprise Munki Import Script

CHROME_VERSION="120.0.6099.129"
DOWNLOAD_URL="https://dl.google.com/chrome/mac/stable/GGRO/GoogleChrome.pkg"
PKG_PATH="/tmp/GoogleChrome.pkg"
CATALOG_DIR="/Library/WebServer/Documents/munki/catalogs"
CATALOG_NAME="production"

Download Chrome
echo "Downloading Chrome $CHROME_VERSION..."
curl -L -o "$PKG_PATH" "$DOWNLOAD_URL"

Create package info and append to catalog
echo "Creating Munki package definition..."
makepkginfo "$PKG_PATH" \
 --name "GoogleChrome" \
 --version "$CHROME_VERSION" \
 --displayname "Google Chrome Enterprise" \
 --description "Google Chrome Enterprise browser" \
 --category "Browsers" \
 --developer "Google" >> "$CATALOG_DIR/$CATALOG_NAME"

Rebuild catalog
echo "Rebuilding Munki catalog..."
makecatalogs "$CATALOG_NAME"

echo "Chrome $CHROME_VERSION added to Munki catalog"
```

Run this script on your Munki server to keep Chrome current. Schedule it with cron or launchd for regular updates.

## Troubleshooting Common Issues

When Chrome doesn't appear in Self Service or fails to install, check these common problems:

Catalog synchronization: Run `sudo managedsoftwareupdate --catalog` on the client to force a catalog refresh. Verify the package appears in `sudo managedsoftwareupdate --list` output.

Permission issues: Munki runs as root during automatic installs but as the logged-in user for Self Service. Ensure your preferences file has appropriate ownership and permissions.

Catalina and beyond: macOS 10.15 and later require user approval for certain installations. For fully automated deployments, consider MDM-based enrollment that provides the necessary privileges.

Version conflicts: If users have the consumer Chrome installed alongside your enterprise version, you may need to uninstall the consumer version first. Add `GoogleChrome` to `managed_uninstalls` after confirming the enterprise version works correctly.

Deploying Chrome Enterprise with Munki gives your organization a flexible, scriptable solution for browser management. The initial setup requires some infrastructure work, but the payoff comes in consistent deployments, automatic updates, and centralized policy control across your entire Mac fleet.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=chrome-enterprise-munki-deployment)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Bandwidth Management: A Practical Guide](/chrome-enterprise-bandwidth-management/)
- [Chrome Enterprise Context-Aware Access: Implementation Guide](/chrome-enterprise-context-aware-access/)
- [Chrome Enterprise Default Printer Policy: A Developer's.](/chrome-enterprise-default-printer-policy/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

