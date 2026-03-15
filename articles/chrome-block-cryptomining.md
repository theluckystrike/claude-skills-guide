---

layout: default
title: "Chrome Block Cryptomining: A Developer's Guide to Protection"
description: "Learn how to block cryptomining scripts in Chrome. Practical methods for developers and power users to protect browsers and servers from unauthorized mining."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-block-cryptomining/
---

# Chrome Block Cryptomining: A Developer's Guide to Protection

Cryptojacking has become one of the most insidious threats in web security. Attackers embed cryptocurrency mining scripts into websites, and once you visit, your browser silently consumes CPU resources to generate revenue for the attacker. For developers and power users, understanding how to block cryptomining in Chrome is essential for maintaining system performance and security.

## What Is Cryptomining in the Browser

Browser-based cryptomining exploits your device's processing power to solve cryptographic puzzles. The most common implementation uses JavaScript to run the CoinHive miner or similar services. When you land on an infected page, the script immediately begins mining, often at 100% CPU utilization.

The signs are unmistakable: your fans spin up, your battery drains rapidly, and your system becomes sluggish. Users frequently mistake this for a malware infection, but the culprit is often a website running hidden mining scripts.

Legitimate sites sometimes use cryptomining as an alternative to advertising revenue. However, most cryptomining occurs without user consent, making it a significant privacy and security concern.

## Method 1: Chrome's Native Protection

Chrome includes built-in protections against malicious scripts, though it's not specifically marketed as a cryptomining blocker. The browser's Safe Browsing feature identifies known cryptomining domains and blocks them before they execute.

To ensure Safe Browsing is enabled:

1. Open Chrome settings
2. Navigate to Privacy and Security
3. Click on Security
4. Verify "Protect you and your device from dangerous sites" is selected

This provides baseline protection against known cryptomining scripts, but it relies on a database of known threats rather than proactive blocking.

## Method 2: uBlock Origin for Script Blocking

The most effective method for power users involves uBlock Origin, an ad and script blocker available in the Chrome Web Store. uBlock Origin maintains specific filter lists targeting cryptomining domains.

After installing uBlock Origin, you should enable the following filter lists:

- **uBlock filters** (default)
- **AdGuard Base Filter**
- **NoCoin Filter List** (specifically targets cryptominers)

To configure these filters:
1. Click the uBlock Origin icon in Chrome
2. Open the dashboard (gear icon)
3. Navigate to Filter Lists
4. Enable "AdGuard Base Filter" and ensure other privacy filters are active

The NoCoin filter list specifically blocks domains known to host cryptomining scripts, including coinhive.com, coin-hive.com, cryptoloot.pro, and similar services.

## Method 3: Script Blocking with uMatrix

For developers who want granular control, uMatrix provides fine-grained script blocking capabilities. Unlike uBlock Origin's automatic filters, uMatrix requires you to explicitly define which domains can load resources.

With uMatrix, you can block all JavaScript by default and selectively enable only trusted domains:

```
# uMatrix default rules
* script allow
google-analytics.com script allow
trusted-site.com script allow
```

This approach is more labor-intensive but provides comprehensive protection against cryptomining and other script-based attacks.

## Method 4: DNS-Level Blocking

For network-level protection, you can block known cryptomining domains at the DNS level. This approach protects all devices on your network without requiring browser extensions.

Create a custom hosts file entry to block mining domains:

```
# Block cryptomining domains
0.0.0.0 coin-hive.com
0.0.0.0 coinhive.com
0.0.0.0 jsecoin.com
0.0.0.0 cryptoloot.pro
0.0.0.0 minero.cc
0.0.0.0 webmine.pro
0.0.0.0 authedmine.com
```

On macOS, edit `/etc/hosts` with sudo privileges. On Windows, modify `C:\Windows\System32\drivers\etc\hosts`. After saving, flush your DNS cache:

```bash
# macOS
sudo dscacheutil -flushcache

# Windows
ipconfig /flushdns
```

For whole-network protection, consider running Pi-hole, a DNS-level ad blocker that also maintains blocklists for cryptomining domains.

## Method 5: Detecting Cryptominers with Developer Tools

As a developer, you may need to identify cryptomining scripts on your own websites or investigate suspicious behavior. Chrome's Developer Tools provide the necessary capabilities.

### Using the Performance Tab

1. Open Developer Tools (F12 or Cmd+Option+I)
2. Navigate to the Performance tab
3. Click Record and let it run for 30-60 seconds
4. Look for JavaScript functions consuming excessive CPU

Cryptomining scripts typically show as:
- Continuous CPU usage during page load
- Web Worker threads with unknown origins
- Frequent calls to crypto-related functions

### Using Network Tab

1. Open the Network tab in Developer Tools
2. Filter by Fetch/XHR
3. Look for requests to known mining domains or unusual endpoints

Suspicious patterns include:
- Repeated POST requests to unknown domains
- Large payload transfers without visible content
- Requests to domains with "mine" or "coin" in the URL

### Identifying Web Workers

Cryptominers often use Web Workers to mine in the background. To detect them:

1. Open the Application tab in Developer Tools
2. Expand "Service Workers" and "Web Workers"
3. Check for workers with unusual names or origins

## Method 6: Browser Extensions for Enhanced Protection

Several Chrome extensions specifically target cryptomining:

- **NoMiner** - Blocks known cryptomining domains
- **MinerBlock** - Maintains an updated blocklist
- **ScriptSafe** - Advanced script control with whitelist capabilities

When choosing extensions, verify their source code if possible, as malicious extensions have been known to embed their own mining scripts.

## Automating Protection with Chrome Policies

For enterprise environments, Chrome provides administrative policies to control extensions and script execution. You can deploy policies via group policy or MDM:

```json
{
  "ExtensionSettings": {
    "*": {
      "installation_mode": "force_installed",
      "update_url": "https://clients2.google.com/service/update2/crx"
    }
  }
}
```

This ensures consistent protection across all managed devices.

## Building Detection into Your Applications

For web developers, consider implementing detection mechanisms to alert users:

```javascript
// Detect potential cryptomining
function detectMining() {
  const miningIndicators = [
    'coinhive',
    'cryptoloot',
    'coin-hive',
    'jsecoin'
  ];
  
  const scripts = document.querySelectorAll('script[src]');
  for (const script of scripts) {
    const src = script.src.toLowerCase();
    if (miningIndicators.some(indicator => src.includes(indicator))) {
      console.warn('Potential cryptomining script detected:', src);
      return true;
    }
  }
  return false;
}
```

## Conclusion

Protecting against browser-based cryptomining requires a layered approach. The most effective strategy combines multiple methods: enable Safe Browsing for baseline protection, install uBlock Origin for script filtering, and implement DNS-level blocking for network-wide coverage.

For developers, understanding how to detect cryptominers using Chrome's Developer Tools provides valuable debugging capabilities. Whether you're protecting personal systems or enterprise infrastructure, these methods offer practical solutions to block unauthorized cryptomining.

The threat landscape continues to evolve, with new mining techniques and obfuscation methods appearing regularly. Stay vigilant, keep your blocklists updated, and monitor system performance for signs of unauthorized mining activity.

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
