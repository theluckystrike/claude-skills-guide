---
layout: default
title: "Chrome Block Cryptomining (2026)"
last_tested: "2026-04-22"
description: "Learn multiple methods to block cryptomining scripts in Chrome. Includes built-in settings, extensions, network-level filtering, and developer tools."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-block-cryptomining/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
geo_optimized: true
robots: "noindex, nofollow"
sitemap: false
---
Cryptomining scripts silently consume your CPU resources when you visit certain websites. These scripts run JavaScript-based miners that can significantly slow down your machine, increase power consumption, and degrade your browsing experience. As a developer or power user, you have several effective methods to block cryptomining in Chrome without sacrificing functionality.

## Understanding Cryptomining in the Browser

Web-based cryptomining became popular around 2017 when the Coinhive service introduced JavaScript miners. While some websites disclose their mining activity transparently, many embed miners without user consent. These scripts typically use WebAssembly to run mining algorithms directly in your browser, often consuming 30-100% of a single CPU core.

The most common mining scripts target Monero (XMR) because its proof-of-work algorithm is designed to be CPU-friendly rather than requiring expensive GPU hardware. This makes it practical to mine using regular web browsers on user machines.

## How Browser Mining Scripts Work

Understanding the technical mechanics helps you identify and block them more effectively. A typical cryptomining script follows this lifecycle:

1. The page loads a JavaScript file from a third-party domain (or inlines it)
2. The script initializes a WebAssembly module containing the mining algorithm
3. It establishes a WebSocket connection to a mining pool server
4. The pool assigns work (a block hash puzzle to solve)
5. The browser's CPU begins computing hashes in a tight loop
6. Valid solutions are submitted back to the pool, earning XMR for the script operator

The WebAssembly component is key. Raw JavaScript can compute approximately 10-15 hashes per second (H/s) on a modern CPU, but WebAssembly-based miners typically achieve 30-80 H/s by compiling the CryptoNight algorithm to near-native machine code. That efficiency gap is why mining scripts almost always include a `.wasm` module.

## Symptoms of Active Mining

Before blocking, you should be able to recognize when mining is already happening:

- CPU usage spikes to 50-100% on a single core immediately after loading a page
- Fan speed increases noticeably within seconds of arriving on a site
- Chrome Task Manager shows one tab consuming disproportionate CPU compared to others
- Battery drain accelerates on laptops, sometimes cutting runtime by 30-50%
- System feels sluggish during what should be a passive browsing session

To open Chrome's built-in Task Manager: press Shift+Esc (Windows/Linux) or navigate to the Chrome menu > More Tools > Task Manager. Sort by CPU column descending to identify offending tabs.

## Chrome's Built-in Protection

Chrome introduced protection against cryptomining starting with Chrome 73. The browser maintains a blocklist of known cryptomining domains. When enabled, this feature prevents connections to these domains entirely.

To verify this protection is active, navigate to Settings → Privacy and security → Security and ensure "Standard protection" or "Enhanced protection" is selected. The enhanced protection mode provides real-time checks against Google's safe browsing database, which includes cryptomining domains.

However, this built-in protection has limitations. It only blocks domains explicitly listed in Google's database, so new or lesser-known mining operations may slip through. For developers testing mining scripts locally or working with blockchain applications, the blocklist might interfere with legitimate work.

## What Chrome's Protection Actually Covers

Chrome's Safe Browsing integration works by comparing requested URLs against a locally cached hash database that updates every 30 minutes. Enhanced Protection mode also sends partial URL hashes to Google's servers for real-time lookup. The practical coverage:

| Protection Level | Database Updates | Mining Coverage | Privacy Impact |
|---|---|---|---|
| No protection | None | None | None |
| Standard protection | Every 30 min (local) | Known domains only | Minimal |
| Enhanced protection | Real-time (cloud) | Broader, faster updates | Shares browsing data with Google |

For most developers, Standard protection is a reasonable baseline, but it cannot catch novel mining scripts that have not yet been added to the blocklist.

## Using Hosts File Blocking

For network-level control, editing your system's hosts file provides a reliable method to block known mining domains. This approach works at the DNS resolution level, preventing any application on your machine from connecting to mining servers.

Create a comprehensive hosts file entry pattern:

```bash
Block common cryptomining domains
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
macOS
sudo dscacheutil -flushcache

Windows
ipconfig /flushdns
```

This method blocks known mining domains at the network level, but requires manual updates to catch new mining domains.

## Automating Hosts File Updates

Rather than manually maintaining hosts entries, you can automate updates from community-maintained blocklists. The following shell script fetches the StevenBlack hosts list (which includes mining domains) and appends it to your existing hosts file:

```bash
#!/bin/bash
update-mining-blocklist.sh
Run: chmod +x update-mining-blocklist.sh && sudo ./update-mining-blocklist.sh

HOSTS_FILE="/etc/hosts"
BLOCKLIST_URL="https://raw.githubusercontent.com/nicehash/nicehash-mining-block/master/hosts"
MARKER_START="# === CRYPTOMINING BLOCKLIST START ==="
MARKER_END="# === CRYPTOMINING BLOCKLIST END ==="

Remove existing blocklist section
sed -i '' "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"

Fetch updated blocklist
BLOCKLIST=$(curl -s "$BLOCKLIST_URL")

Append new blocklist with markers
echo "$MARKER_START" >> "$HOSTS_FILE"
echo "$BLOCKLIST" >> "$HOSTS_FILE"
echo "$MARKER_END" >> "$HOSTS_FILE"

Flush DNS cache
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

echo "Mining blocklist updated: $(echo "$BLOCKLIST" | wc -l) entries"
```

Schedule this script as a weekly cron job: `0 9 * * 1 /usr/local/bin/update-mining-blocklist.sh`

## Browser Extensions for Mining Protection

Several Chrome extensions provide automated protection with regularly updated blocklists. These extensions typically use EasyList's mining filter list, which the community maintains.

Popular options include:

NoCoin is a lightweight extension with minimal resource overhead. It blocks known mining scripts and displays a small icon when it detects blocked attempts. The extension is open-source and available on GitHub.

MinerBlock offers similar functionality with additional configuration options. You can create custom block rules, whitelist specific domains, and view statistics about blocked attempts.

When choosing an extension, verify its source code is publicly available. Extensions with full network request interception capabilities need trustworthy implementations.

## Extension Comparison

| Extension | Size | Update Frequency | Custom Rules | Open Source | CPU Overhead |
|---|---|---|---|---|---|
| NoCoin | ~50KB | Manual releases | No | Yes (MIT) | Negligible |
| MinerBlock | ~80KB | Regular | Yes | Yes (MIT) | Negligible |
| uBlock Origin (with mining list) | ~2MB | Automatic | Yes | Yes (GPLv3) | Very low |
| AdGuard | ~5MB | Automatic | Yes | Partial | Low |
| NoScript | ~500KB | Regular | Advanced | Yes | Low |

For most developers, uBlock Origin with the "Cryptocurrency (Cryptomining) Protection" filter list enabled is the most maintainable approach. It consolidates ad blocking, tracker blocking, and mining protection in one extension with a well-funded, actively maintained filter list.

## Configuring uBlock Origin for Mining Protection

If you already use uBlock Origin, activating mining protection takes under a minute:

1. Click the uBlock Origin toolbar icon
2. Open the Dashboard (the grid icon)
3. Navigate to Filter lists tab
4. Expand Cryptocurrency (Cryptomining) Protection
5. Check NoCoin Filter List and Anti-Adblock Killer (optional)
6. Click Apply changes and Update now

uBlock Origin will now intercept network requests matching mining domains before the browser even initiates a connection. This is more efficient than extension approaches that let the request happen and then cancel it.

## Network-Level Filtering with Pi-hole

For developers managing multiple machines or teams, deploying a Pi-hole DNS server provides network-wide protection. Pi-hole functions as a DNS-level ad and tracker blocker that can also filter mining domains.

Install Pi-hole on a Raspberry Pi or virtual machine, then configure your network's DHCP server to use the Pi-hole as your primary DNS resolver. The Pi-hole community maintains blocklists that include known mining domains.

Query the Pi-hole logs to identify any mining attempts on your network:

```bash
Query Pi-hole API for mining domain queries
curl -s "http://pi.hole/admin/api.php?getQuerySources" | jq '.'
```

This approach protects all devices on your network without requiring individual configuration on each machine.

## Setting Up Pi-hole with Mining Blocklists

After the base Pi-hole installation, add targeted mining blocklists through the web interface or via the CLI:

```bash
SSH into your Pi-hole host and add blocklists via sqlite
sqlite3 /etc/pihole/gravity.db \
 "INSERT OR IGNORE INTO adlist (address, enabled, comment) VALUES \
 ('https://raw.githubusercontent.com/nicehash/nicehash-mining-block/master/hosts', 1, 'Cryptomining domains'), \
 ('https://blocklistproject.github.io/Lists/crypto.txt', 1, 'Crypto mining blocklist');"

Run gravity update to apply new lists
pihole -g
```

After updating gravity, verify that known mining domains resolve to the Pi-hole's sinkhole IP:

```bash
Test from a client machine on the network
dig coinhive.com @<your-pihole-ip>
Expected result: NXDOMAIN or resolution to 0.0.0.0
```

## Pi-hole vs Extension vs Hosts File: When to Use Each

| Method | Scope | Maintenance | Bypass Risk | Best For |
|---|---|---|---|---|
| Chrome built-in | Single browser | Automatic | Medium | Casual users |
| Browser extension | Single browser | Automatic | Low | Most developers |
| Hosts file | Single machine, all apps | Manual/scripted | Low | Power users, air-gapped machines |
| Pi-hole | Entire network | Low, centralized | Low | Teams, home labs, shared offices |
| Enterprise policy | Managed fleet | Centralized | Very low | IT-managed environments |

## Developer Tools for Detection

When auditing websites or testing your own applications, you need to detect mining scripts programmatically. Several methods help identify cryptomining behavior.

## Network Request Monitoring

Open Chrome DevTools (F12), go to the Network tab, and look for suspicious scripts loading WebAssembly modules or making requests to known mining domains. Common indicators include:

- Scripts with names like `miner.js`, `coinhive.js`, or `cryptominer.js`
- WebAssembly module loading
- Repeated POST requests to mining pool domains
- High CPU usage correlating with page load

## Runtime Detection

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

## Advanced Detection with Performance Monitoring

The script above catches known signatures, but sophisticated miners obfuscate their filenames. A more solid approach monitors CPU behavior directly using the Performance API:

```javascript
// cpu-mining-detector.js
// Detects anomalous CPU usage patterns indicative of mining

class MiningDetector {
 constructor(options = {}) {
 this.threshold = options.threshold || 80; // CPU% that triggers alert
 this.windowMs = options.windowMs || 3000; // sampling window in ms
 this.sampleInterval = options.sampleInterval || 500; // ms between samples
 this.samples = [];
 this.timer = null;
 }

 start() {
 this.timer = setInterval(() => this._sample(), this.sampleInterval);
 }

 stop() {
 clearInterval(this.timer);
 this.timer = null;
 }

 _sample() {
 const start = performance.now();
 // Run a fixed computation to estimate available CPU time
 let count = 0;
 const deadline = start + 50;
 while (performance.now() < deadline) {
 count++;
 }

 // Normalize: if CPU is fully occupied by mining, our count will be low
 const usage = Math.max(0, 100 - (count / 50000) * 100);
 this.samples.push({ time: Date.now(), cpu: usage });

 // Keep only samples within the window
 const cutoff = Date.now() - this.windowMs;
 this.samples = this.samples.filter(s => s.time > cutoff);

 const avgCpu = this.samples.reduce((s, x) => s + x.cpu, 0) / this.samples.length;
 if (avgCpu > this.threshold && this.samples.length >= 3) {
 this._onMiningDetected(avgCpu);
 }
 }

 _onMiningDetected(cpuPercent) {
 console.warn(`[MiningDetector] High CPU usage detected: ${cpuPercent.toFixed(1)}%`);
 this.stop();
 // Custom callback here: e.g., alert user, log to analytics, reload page
 }
}

// Usage
const detector = new MiningDetector({ threshold: 70, windowMs: 5000 });
detector.start();
```

This approach does not rely on domain signatures, making it effective against novel mining scripts that self-host assets on legitimate-looking domains.

## Using Chrome's Performance Profiler for Forensic Analysis

If you suspect a page is mining but your script hasn't fired, use Chrome's Performance panel for a definitive check:

1. Open DevTools (F12) and navigate to the Performance tab
2. Click the record button and interact with the suspicious page for 10-15 seconds
3. Stop recording
4. Look for long tasks (red bars above the main thread) that repeat every frame
5. Expand the flame chart. mining tasks typically appear as tight loops in WebAssembly calls

A mining script's flame chart typically shows a CryptoNight or RandomX computation function dominating 95%+ of CPU time in a repeating pattern. Legitimate WebAssembly usage (video codecs, image processing) shows burst activity, not a steady loop.

Blocking via Chrome Policies (Enterprise)

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

Deploying Chrome Policy via MDM (macOS)

On macOS with a mobile device management (MDM) solution like Jamf or Mosyle, you can push Chrome policies as a configuration profile:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>PayloadContent</key>
 <array>
 <dict>
 <key>PayloadType</key>
 <string>com.google.chrome</string>
 <key>URLBlocklist</key>
 <array>
 <string>*://*.coinhive.com/*</string>
 <string>*://*.jsecoin.com/*</string>
 <string>*://*.cryptoloot.pro/*</string>
 <string>*://*.webmine.pro/*</string>
 </array>
 <key>SafeBrowsingProtectionLevel</key>
 <integer>2</integer>
 </dict>
 </array>
</dict>
</plist>
```

This locks Chrome's Safe Browsing to Enhanced mode (level 2) and enforces the URL blocklist across every managed Mac in your fleet. Users cannot override these settings from Chrome's preferences UI.

## Windows Group Policy via Registry

On Windows, the equivalent configuration deploys through Group Policy Object (GPO) or directly via registry:

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\URLBlocklist]
"1"="*://*.coinhive.com/*"
"2"="*://*.jsecoin.com/*"
"3"="*://*.cryptoloot.pro/*"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome]
"SafeBrowsingProtectionLevel"=dword:00000002
```

Import this as a `.reg` file or configure through Group Policy Management Console using the Chrome ADMX templates from Google's enterprise download page.

## Best Practices for Protection

Combining multiple protection layers provides the most solid defense against cryptomining. Use Chrome's built-in protection as a baseline, add a reliable extension for automatic blocklist updates, and consider network-level filtering for comprehensive coverage.

Regularly review your browser's resource usage. If you notice unexplained high CPU consumption, check the Task Manager (Shift+Esc) to identify which tabs are consuming resources. Unload suspicious tabs immediately and run a malware scan if necessary.

For developers working with blockchain technologies, maintain a whitelist of trusted domains where mining is expected. This prevents interference with legitimate development work while maintaining protection elsewhere.

## Recommended Defense Stack by Use Case

Individual developer workstation:
- Chrome Enhanced Safe Browsing (enabled)
- uBlock Origin with NoCoin filter list (automatic updates)
- Hosts file entries for belt-and-suspenders coverage

Development team with shared infrastructure:
- Pi-hole on a local VM with mining blocklists
- Chrome extension policy for individual laptops
- Monitoring dashboards to catch anomalous DNS queries

Enterprise managed fleet:
- MDM-deployed Chrome policy (URLBlocklist + SafeBrowsingProtectionLevel: 2)
- Network-level DNS filtering via Cloudflare Gateway or similar
- SIEM alerting on repeated NXDOMAIN responses to known mining domains

## Testing Your Defenses

After configuring your blocking layers, verify they actually work. Several legitimate security testing sites provide harmless mining script simulators:

```javascript
// Quick validation script: paste in DevTools console
// Should be blocked or produce errors if protection is active

const testDomains = [
 'coinhive.com',
 'cryptoloot.pro',
 'webminepool.com'
];

testDomains.forEach(async domain => {
 try {
 const res = await fetch(`https://${domain}/lib/coinhive.min.js`);
 console.warn(`BLOCKED FAILED: ${domain} returned ${res.status}`);
 } catch (e) {
 console.log(`BLOCKED OK: ${domain} - ${e.message}`);
 }
});
```

If your blocking is working correctly, each fetch will throw a network error. If any domain returns a 200 response, that layer of your defense has a gap.

## Monitoring for Regressions

Mining protection can silently degrade: extensions get disabled after updates, Pi-hole reboots can reset its blocklists, and browser policy can be overridden on non-managed machines. Build a lightweight health check into your team's runbook:

```bash
#!/bin/bash
mining-defense-health-check.sh
Returns exit code 1 if any protection layer is missing

echo "Checking hosts file entries..."
if grep -q "coinhive.com" /etc/hosts; then
 echo " hosts: OK"
else
 echo " hosts: MISSING - run update-mining-blocklist.sh"
 exit 1
fi

echo "Checking Pi-hole gravity..."
pihole -q coinhive.com | grep -q "Match found" && echo " pihole: OK" || echo " pihole: NOT BLOCKED"

echo "All checks passed."
```

Run this weekly in your team's CI or as a scheduled task to ensure the protection stack remains intact after system updates.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-block-cryptomining)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Calendar Assistant Chrome Extension: A Developer's Guide](/ai-calendar-assistant-chrome-extension/)
- [AI Form Filler Chrome Extension: A Developer and Power.](/ai-form-filler-chrome-extension/)
- [AI Podcast Summary Chrome Extension: A Developer's Guide.](/ai-podcast-summary-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

