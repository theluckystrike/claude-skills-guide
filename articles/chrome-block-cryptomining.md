---

layout: default
title: "How to Block Cryptomining in Chrome: A Developer's Guide"
description: "Learn multiple methods to block cryptomining scripts in Chrome. Includes built-in settings, extensions, network-level filtering, and developer tools for protecting your browser."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-block-cryptomining/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
---


# How to Block Cryptomining in Chrome: A Developer's Guide

Cryptomining scripts silently consume your CPU resources when you visit certain websites. These scripts run JavaScript-based miners that can significantly slow down your machine, increase power consumption, and degrade your browsing experience. As a developer or power user, you have several effective methods to block cryptomining in Chrome without sacrificing functionality.

## Understanding Cryptomining in the Browser

Web-based cryptomining became popular around 2017 when the Coinhive service introduced JavaScript miners. While some websites disclose their mining activity transparently, many embed miners without user consent. These scripts typically use WebAssembly to run mining algorithms directly in your browser, often consuming 30-100% of a single CPU core.

The most common mining scripts target Monero (XMR) because its proof-of-work algorithm is designed to be CPU-friendly rather than requiring expensive GPU hardware. This makes it practical to mine using regular web browsers on user machines.

## Chrome's Built-in Protection

Chrome introduced protection against cryptomining starting with Chrome 73. The browser maintains a blocklist of known cryptomining domains. When enabled, this feature prevents connections to these domains entirely.

To verify this protection is active, navigate to **Settings** → **Privacy and security** → **Security** and ensure "Standard protection" or "Enhanced protection" is selected. The enhanced protection mode provides real-time checks against Google's safe browsing database, which includes cryptomining domains.

However, this built-in protection has limitations. It only blocks domains explicitly listed in Google's database, so new or lesser-known mining operations may slip through. For developers testing mining scripts locally or working with blockchain applications, the blocklist might interfere with legitimate work.

## Using Hosts File Blocking

For network-level control, editing your system's hosts file provides a reliable method to block known mining domains. This approach works at the DNS resolution level, preventing any application on your machine from connecting to mining servers.

Create a comprehensive hosts file entry pattern:

```bash
# Block common cryptomining domains
0.0.0.0 coinhive.com
0.0.0.0 coin-hive.com
0.0.0.0 coinhive.min.js
0.0.0.0 jsecoin.com
0.0.0.0 minero.cc
0.0.0.0 cryptoloot.pro
0.0.0.0 webmine.pro
0.0.0.0 webminepool.com
0.0.0.0 coinblind.com
0.0.0.0 miner.pr0gramer.com
```

On macOS, edit `/etc/hosts` with sudo privileges. On Windows, modify `C:\Windows\System32\drivers\etc\hosts`. After saving, flush your DNS cache:

```bash
# macOS
sudo dscacheutil -flushcache

# Windows
ipconfig /flushdns
```

This method blocks known mining domains at the network level, but requires manual updates to catch new mining domains.

## Browser Extensions for Mining Protection

Several Chrome extensions provide automated protection with regularly updated blocklists. These extensions typically use EasyList's mining filter list, which the community maintains.

Popular options include:

**NoCoin** is a lightweight extension with minimal resource overhead. It blocks known mining scripts and displays a small icon when it detects blocked attempts. The extension is open-source and available on GitHub.

**MinerBlock** offers similar functionality with additional configuration options. You can create custom block rules, whitelist specific domains, and view statistics about blocked attempts.

When choosing an extension, verify its source code is publicly available. Extensions with full network request interception capabilities need trustworthy implementations.

## Network-Level Filtering with Pi-hole

For developers managing multiple machines or teams, deploying a Pi-hole DNS server provides network-wide protection. Pi-hole functions as a DNS-level ad and tracker blocker that can also filter mining domains.

Install Pi-hole on a Raspberry Pi or virtual machine, then configure your network's DHCP server to use the Pi-hole as your primary DNS resolver. The Pi-hole community maintains blocklists that include known mining domains.

Query the Pi-hole logs to identify any mining attempts on your network:

```bash
# Query Pi-hole API for mining domain queries
curl -s "http://pi.hole/admin/api.php?getQuerySources" | jq '.'
```

This approach protects all devices on your network without requiring individual configuration on each machine.

## Developer Tools for Detection

When auditing websites or testing your own applications, you need to detect mining scripts programmatically. Several methods help identify cryptomining behavior.

### Network Request Monitoring

Open Chrome DevTools (F12), go to the **Network** tab, and look for suspicious scripts loading WebAssembly modules or making requests to known mining domains. Common indicators include:

- Scripts with names like `miner.js`, `coinhive.js`, or `cryptominer.js`
- WebAssembly module loading
- Repeated POST requests to mining pool domains
- High CPU usage correlating with page load

### Runtime Detection

Create a simple detection script to identify mining activity:

```javascript
// Detect if WebAssembly is being used for mining
const originalInstantiate = WebAssembly.instantiate;

WebAssembly.instantiate = function(...args) {
  console.warn('WebAssembly instantiation detected');
  return originalInstantiate.apply(this, args);
};

// Monitor for known mining library signatures
const miningSignatures = [
  'CoinHive',
  'CryptoLoot',
  'JSEcoin',
  'Minero'
];

function detectMiningScripts() {
  const scripts = document.querySelectorAll('script[src]');
  scripts.forEach(script => {
    miningSignatures.forEach(sig => {
      if (script.src.toLowerCase().includes(sig.toLowerCase())) {
        console.error(`Potential mining script detected: ${script.src}`);
      }
    });
  });
}

detectMiningScripts();
```

## Blocking via Chrome Policies (Enterprise)

For enterprise environments or shared workstations, Chrome's group policy settings provide administrative control over mining protection. These policies can enforce specific blocklists or disable mining entirely.

Configure the following policies in your Chrome policy file:

```json
{
  "URLBlocklist": [
    "*://*.coinhive.com/*",
    "*://*.coin-hive.com/*",
    "*://*.jsecoin.com/*",
    "*://*.cryptoloot.pro/*"
  ]
}
```

This approach works on Chrome Enterprise editions and provides consistent enforcement across managed devices.

## Best Practices for Protection

Combining multiple protection layers provides the most robust defense against cryptomining. Use Chrome's built-in protection as a baseline, add a reliable extension for automatic blocklist updates, and consider network-level filtering for comprehensive coverage.

Regularly review your browser's resource usage. If you notice unexplained high CPU consumption, check the Task Manager (Shift+Esc) to identify which tabs are consuming resources. Unload suspicious tabs immediately and run a malware scan if necessary.

For developers working with blockchain technologies, maintain a whitelist of trusted domains where mining is expected. This prevents interference with legitimate development work while maintaining protection elsewhere.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
