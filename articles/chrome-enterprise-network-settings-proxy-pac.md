---

layout: default
title: "Chrome Enterprise Network Settings: Configuring Proxy PAC Files"
description: "Learn how to configure Proxy PAC files in Chrome Enterprise for developers and power users. Includes practical examples, JavaScript patterns, and troubleshooting tips."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-enterprise-network-settings-proxy-pac/
---

# Chrome Enterprise Network Settings: Configuring Proxy PAC Files

Proxy Auto-Configuration (PAC) files provide a powerful way to control how Chrome handles network traffic based on URLs, hostnames, or network conditions. For developers and power users managing Chrome Enterprise deployments, understanding PAC file configuration is essential for building flexible, maintainable proxy infrastructures.

## What Is a Proxy PAC File?

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

## Configuring PAC in Chrome Enterprise

Chrome provides several methods for deploying PAC configuration across an organization. The most common approaches use group policies or the Chrome Policy List.

### Using Group Policy (Windows)

For Windows environments managed through Active Directory, configure the proxy settings through Group Policy:

1. Open Group Policy Management
2. Navigate to Computer Configuration → Administrative Templates → Google Chrome → Proxy Server
3. Enable "Proxy settings" and select "Use a PAC file"
4. Enter the PAC URL: `https://proxy.company.com/proxy.pac`

### Using the Chrome Policy List (Cross-Platform)

For cross-platform deployments, use the Chrome Policy List with the `ProxySettings` policy:

```json
{
  "ProxySettings": {
    "Mode": "pac_script",
    "PacScript": {
      "Source": "function FindProxyForURL(url, host) {\n  if (localHostOrDomainIs(host, \"localhost\")) {\n    return \"DIRECT\";\n  }\n  return \"PROXY proxy.company.com:8080\";\n}"
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

## Advanced PAC Patterns for Developers

### Bypassing SSL Inspection for Development

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

### Failover and Load Balancing

PAC files support multiple proxy servers with failover capability:

```javascript
function FindProxyForURL(url, host) {
  // Try primary proxy, fall back to secondary, then direct
  return "PROXY primary.proxy.company.com:8080; " +
         "PROXY secondary.proxy.company.com:8080; " +
         "DIRECT";
}
```

The semicolon-separated list tells Chrome to try each proxy in order until one succeeds.

### Conditional Routing Based on Network

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

## Deploying PAC Files via Enterprise Certificate

For secure PAC file distribution, serve the file over HTTPS with a certificate trusted by Chrome. This prevents man-in-the-middle attacks on the PAC file itself.

Serve the PAC file with these headers:

```
Content-Type: application/x-ns-proxy-autoconfig
Cache-Control: no-cache, no-store, must-revalidate
```

## Troubleshooting PAC Configuration

### Common Issues

1. **PAC file not loading**: Verify the URL is accessible and returns the correct MIME type (`application/x-ns-proxy-autoconfig`)

2. **Syntax errors**: Use a JavaScript linter to validate the PAC file before deployment

3. **Chrome ignoring PAC**: Check `chrome://net-internals/#proxy` to see current proxy configuration

### Testing PAC Files

Use the Chrome net-internals tool to reload PAC settings:

1. Open `chrome://net-internals/#proxy`
2. Click "Reapply settings" to force Chrome to reload the PAC file
3. Check the log for any errors

You can also test PAC logic using the JavaScript console in developer tools or a simple Node.js script:

```javascript
// Test PAC function
function FindProxyForURL(url, host) {
  if (host.includes("google.com")) return "DIRECT";
  return "PROXY localhost:8080";
}

console.log(FindProxyForURL("https://google.com", "google.com")); // DIRECT
console.log(FindProxyForURL("https://example.com", "example.com")); // PROXY localhost:8080
```

## Best Practices

- **Keep PAC files small and fast**: Avoid complex DNS lookups in the main path
- **Use caching wisely**: Balance freshness against network overhead
- **Test thoroughly**: Validate rules against all expected URL patterns
- **Monitor PAC URL health**: A failed PAC file blocks all web traffic
- **Version control PAC files**: Track changes and rollback easily

For Chrome Enterprise deployments, PAC files remain a robust solution for organizations needing fine-grained proxy control without managing complex infrastructure manually.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
