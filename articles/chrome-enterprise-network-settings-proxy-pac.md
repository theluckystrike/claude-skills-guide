---
layout: default
title: "Chrome Enterprise Network Settings Proxy — Developer Guide"
description: "Learn how to configure Proxy PAC files in Chrome Enterprise for developers and power users. Includes practical examples, JavaScript patterns, and."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-enterprise-network-settings-proxy-pac/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
# Chrome Enterprise Network Settings: Configuring Proxy PAC Files

Proxy Auto-Configuration (PAC) files provide a powerful way to control how Chrome handles network traffic based on URLs, hostnames, or network conditions. For developers and power users managing Chrome Enterprise deployments, understanding PAC file configuration is essential for building flexible, maintainable proxy infrastructures.

What Is a Proxy PAC File?

A PAC file is a JavaScript function that returns proxy connection strings. Chrome evaluates this function for each URL request, determining whether to route traffic directly, through a specific proxy, or through a proxy chain. The standard format uses the `FindProxyForURL(url, host)` function:

```javascript
function FindProxyForURL(url, host) {
 // Direct connection for local addresses
 if (isPlainHostName(host) ||
 isInNet(dnsResolve(host), "10.0.0.0", "255.0.0.0") ||
 isInNet(dnsResolve(host), "172.16.0.0", "255.240.0.0") ||
 isInNet(dnsResolve(host), "192.168.0.0", "255.255.0.0")) {
 return "DIRECT";
 }

 // Route corporate traffic through proxy
 if (shExpMatch(host, "*.corporate.internal") ||
 shExpMatch(host, "*.company.com")) {
 return "PROXY corporate-proxy.company.com:8080";
 }

 // Default to direct for everything else
 return "DIRECT";
}
```

The function receives two parameters: the full URL string and the hostname extracted from it. It must return one of three types of strings: `"DIRECT"` for a direct connection, `"PROXY host:port"` to route through a specific proxy, or `"SOCKS host:port"` for SOCKS proxies. You can chain multiple options separated by semicolons to enable fallback behavior.

## Proxy Deployment Method Comparison

Before diving into configuration, it helps to understand which deployment method fits your environment:

| Method | Platform | Best For | Managed Via |
|---|---|---|---|
| Group Policy (GPO) | Windows + AD | Large enterprise, AD-joined machines | GPMC / ADMX templates |
| Chrome Policy List (JSON) | Cross-platform | Mixed OS fleets, MDM-managed devices | MDM (Intune, Jamf, etc.) |
| Inline PAC in policy | Cross-platform | Small teams, simple rules | Same as above |
| External PAC URL | Cross-platform | Complex rules, centralized updates | Web server + policy |
| WPAD (auto-discovery) | Network-level | Zero-config environments | DNS or DHCP |

WPAD is convenient but introduces security risks: an attacker on the same network segment can serve a malicious PAC file if WPAD is not properly locked down. For enterprise deployments, explicitly setting the PAC URL via policy is safer than relying on WPAD auto-discovery.

## Configuring PAC in Chrome Enterprise

Chrome provides several methods for deploying PAC configuration across an organization. The most common approaches use group policies or the Chrome Policy List.

Using Group Policy (Windows)

For Windows environments managed through Active Directory, configure the proxy settings through Group Policy:

1. Open Group Policy Management
2. Navigate to Computer Configuration → Administrative Templates → Google Chrome → Proxy Server
3. Enable "Proxy settings" and select "Use a PAC file"
4. Enter the PAC URL: `https://proxy.company.com/proxy.pac`

Make sure you have the Chrome ADMX templates installed on your domain controllers. Download the latest templates from the Chrome Enterprise release notes page to ensure the policy keys match your deployed Chrome version. Mismatched template versions can cause policies to be silently ignored.

Using the Chrome Policy List (Cross-Platform)

For cross-platform deployments, use the Chrome Policy List with the `ProxySettings` policy:

```json
{
 "ProxySettings": {
 "Mode": "pac_script",
 "PacScript": {
 "Source": "function FindProxyForURL(url, host) {\n if (localHostOrDomainIs(host, \"localhost\")) {\n return \"DIRECT\";\n }\n return \"PROXY proxy.company.com:8080\";\n}"
 }
 }
}
```

Alternatively, reference an external PAC file:

```json
{
 "ProxySettings": {
 "Mode": "pac_script",
 "PacScript": {
 "Url": "https://proxy.company.com/proxy.pac"
 }
 }
}
```

On macOS with Jamf, deploy this JSON as a Chrome managed preference profile. On Linux with Puppet or Ansible, write the JSON to `/etc/opt/chrome/policies/managed/proxy.json`. Chrome reads the managed policies directory at startup and on a refresh cycle roughly every 30 minutes.

## Applying Policy on macOS with Jamf

```bash
Create the managed policies directory if it doesn't exist
sudo mkdir -p /Library/Managed\ Preferences/com.google.Chrome

Write the policy plist (Jamf can also push this as a Configuration Profile)
sudo defaults write /Library/Managed\ Preferences/com.google.Chrome ProxySettings \
 -dict Mode pac_script PacScript -dict Url https://proxy.company.com/proxy.pac
```

Verify the policy was applied by navigating to `chrome://policy` in Chrome. Active policies are listed there with their source (platform, machine, or user level).

## Advanced PAC Patterns for Developers

## Bypassing SSL Inspection for Development

When using SSL inspection proxies, development URLs often fail due to certificate issues. Use PAC to bypass inspection for local development:

```javascript
function FindProxyForURL(url, host) {
 // Bypass for localhost and local development servers
 if (isPlainHostName(host) ||
 host === "localhost" ||
 host.match(/^127\.\d+\.\d+\.\d$/) ||
 host.endsWith(".local") ||
 host.endsWith(".test") ||
 host.endsWith(".localhost")) {
 return "DIRECT";
 }

 // Bypass specific development domains
 if (shExpMatch(host, "*.dev.company.com") ||
 shExpMatch(host, "*.localhost") ||
 shExpMatch(host, "*.test")) {
 return "DIRECT";
 }

 return "PROXY proxy.company.com:8080";
}
```

This pattern matters especially for developers running local TLS with tools like `mkcert`. If the SSL inspection proxy intercepts requests to `localhost:3000`, the self-signed certificate will not match the proxy's re-signed certificate, breaking the browser's trust chain entirely.

## Failover and Load Balancing

PAC files support multiple proxy servers with failover capability:

```javascript
function FindProxyForURL(url, host) {
 // Try primary proxy, fall back to secondary, then direct
 return "PROXY primary.proxy.company.com:8080; " +
 "PROXY secondary.proxy.company.com:8080; " +
 "DIRECT";
}
```

The semicolon-separated list tells Chrome to try each proxy in order until one succeeds. Chrome considers a proxy failed after a connection timeout, then automatically advances to the next entry. This is not true load balancing. Chrome will always try the first proxy first. but it provides resilience against proxy outages without requiring DNS failover configuration.

For true load balancing, use a load balancer in front of your proxy fleet and point the PAC file at the load balancer's VIP rather than individual proxy hostnames.

## Conditional Routing Based on Network

For organizations with multiple office locations, route traffic based on the detected network:

```javascript
function FindProxyForURL(url, host) {
 var proxy = "PROXY corporate-proxy.company.com:8080";
 var direct = "DIRECT";

 // Detect office network by checking local subnet
 var local_ip = myIpAddress();

 if (isInNet(local_ip, "10.1.0.0", "255.255.0.0")) {
 // HQ office - use local proxy
 return proxy;
 } else if (isInNet(local_ip, "10.2.0.0", "255.255.0.0")) {
 // Branch office - use branch proxy
 return "PROXY branch-proxy.company.com:8080";
 }

 // Remote or unknown location
 return proxy;
}
```

Note that `myIpAddress()` returns the machine's primary network interface IP, which is a VPN tunnel address when the user is connected to VPN. Test this behavior explicitly if your PAC logic relies on subnet detection. VPN clients vary in how they affect the IP returned by `myIpAddress()`.

## Protocol-Specific Routing

PAC functions receive the full URL, not just the host. This means you can route based on protocol:

```javascript
function FindProxyForURL(url, host) {
 // Route all HTTPS through a TLS-aware proxy
 if (url.substring(0, 6) === "https:") {
 return "PROXY tls-proxy.company.com:8443";
 }

 // Route HTTP through standard proxy
 if (url.substring(0, 5) === "http:") {
 return "PROXY http-proxy.company.com:8080";
 }

 // FTP and other protocols direct
 return "DIRECT";
}
```

## Deploying PAC Files via Enterprise Certificate

For secure PAC file distribution, serve the file over HTTPS with a certificate trusted by Chrome. This prevents man-in-the-middle attacks on the PAC file itself.

Serve the PAC file with these headers:

```
Content-Type: application/x-ns-proxy-autoconfig
Cache-Control: no-cache, no-store, must-revalidate
```

A minimal nginx configuration for serving a PAC file:

```nginx
server {
 listen 443 ssl;
 server_name proxy.company.com;

 ssl_certificate /etc/ssl/certs/proxy.company.com.crt;
 ssl_certificate_key /etc/ssl/private/proxy.company.com.key;

 location /proxy.pac {
 alias /var/www/pac/proxy.pac;
 add_header Content-Type application/x-ns-proxy-autoconfig;
 add_header Cache-Control "no-cache, no-store, must-revalidate";
 add_header Pragma no-cache;
 add_header Expires 0;
 }
}
```

Avoid caching the PAC file aggressively. A stale PAC file cached on the client can cause all web traffic to break if your proxy infrastructure changes before the cache expires. Setting `no-store` ensures Chrome fetches a fresh copy on each browser startup.

## Troubleshooting PAC Configuration

## Common Issues

1. PAC file not loading: Verify the URL is accessible and returns the correct MIME type (`application/x-ns-proxy-autoconfig`). Some web servers default to `text/plain` for `.pac` files, which Chrome accepts but some proxy clients reject.

2. Syntax errors: Use a JavaScript linter to validate the PAC file before deployment. PAC files run in a sandboxed JavaScript environment without full ES6 support. avoid arrow functions, template literals, and `let`/`const` in PAC files for maximum compatibility.

3. Chrome ignoring PAC: Check `chrome://net-internals/#proxy` to see current proxy configuration. If a policy is set but not appearing, check `chrome://policy` for policy application errors.

4. DNS resolution loops: Calling `dnsResolve()` in the main path of `FindProxyForURL` introduces a DNS lookup for every URL request. On networks with slow DNS, this causes visible page-load lag. Cache resolved values using a JavaScript object when possible, or avoid `dnsResolve()` in favor of `shExpMatch()` or `isInNet()` with known CIDR ranges.

## Testing PAC Files

Use the Chrome net-internals tool to reload PAC settings:

1. Open `chrome://net-internals/#proxy`
2. Click "Reapply settings" to force Chrome to reload the PAC file
3. Check the log for any errors

You can also test PAC logic using the JavaScript console in developer tools or a simple Node.js script:

```javascript
// Test PAC function locally. mock the PAC helper functions
function isPlainHostName(host) { return !host.includes("."); }
function shExpMatch(str, pattern) {
 const regex = new RegExp("^" + pattern.replace(/\./g, "\\.").replace(/\*/g, ".*") + "$");
 return regex.test(str);
}
function isInNet(ip, net, mask) { return false; } // stub for local testing

function FindProxyForURL(url, host) {
 if (host.includes("google.com")) return "DIRECT";
 return "PROXY localhost:8080";
}

console.log(FindProxyForURL("https://google.com", "google.com")); // DIRECT
console.log(FindProxyForURL("https://example.com", "example.com")); // PROXY localhost:8080
```

Dedicated PAC testing tools like `pacparser` (a C library with Python and Node.js bindings) provide a more accurate simulation environment because they implement the full set of PAC helper functions, including `dnsResolve()` and `myIpAddress()`, against your actual network.

## Best Practices

- Keep PAC files small and fast: Avoid complex DNS lookups in the main path
- Use caching wisely: Balance freshness against network overhead
- Test thoroughly: Validate rules against all expected URL patterns
- Monitor PAC URL health: A failed PAC file blocks all web traffic
- Version control PAC files: Track changes and rollback easily
- Avoid ES6 syntax: PAC files run in a sandboxed environment; stick to ES5 for broadest compatibility
- Document each rule: Future administrators will need to understand why a rule exists, not just what it does
- Stage changes: Test PAC updates against a small group of machines before rolling out organization-wide

For Chrome Enterprise deployments, PAC files remain a solid solution for organizations needing fine-grained proxy control without managing complex infrastructure manually.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-enterprise-network-settings-proxy-pac)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise Auto Update Settings: A Developer's Guide](/chrome-enterprise-auto-update-settings/)
- [Chrome Enterprise Bookmark Bar Settings: A Complete Guide](/chrome-enterprise-bookmark-bar-settings/)
- [Chrome Enterprise Printing Settings: A Power User Guide](/chrome-enterprise-printing-settings/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


