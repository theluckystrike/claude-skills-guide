---

layout: default
title: "Claude Code Network Proxy Configuration for Enterprise"
description: "Learn how to configure Claude Code network proxy settings for enterprise environments. This guide covers HTTP/HTTPS proxies, authentication, SSL certificates, and practical deployment scenarios."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-network-proxy-configuration-for-enterprise/
categories: [guides]
reviewed: false
score: 0
tags: [claude-code, network, proxy, enterprise, configuration]
---

{% raw %}

# Claude Code Network Proxy Configuration for Enterprise

Enterprise environments often require all network traffic to route through corporate proxies for security monitoring, compliance, and access control. Configuring Claude Code to work within these environments is essential for teams that need AI assistance while maintaining strict network policies. This guide covers everything you need to know about setting up Claude Code with network proxies, including authentication, SSL certificate handling, and troubleshooting common issues.

## Understanding Enterprise Proxy Requirements

Corporate networks typically deploy proxies for several reasons: security inspection, access logging, content filtering, and malware prevention. When your organization requires all HTTP/HTTPS traffic to pass through a proxy, Claude Code must be explicitly configured to use these settings. Without proper configuration, network requests will fail, and you'll encounter connection errors when trying to use online features or tool integrations.

Claude Code supports standard environment variable configuration for proxy settings, which aligns with how most enterprise applications handle network routing. The primary variables you'll work with are `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` (also recognized in lowercase variants).

## Basic Proxy Configuration

The simplest way to configure Claude Code for proxy environments is through environment variables. Set these before launching Claude Code, and all network operations will automatically use the specified proxy.

```bash
# Set HTTP and HTTPS proxy
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# Configure exceptions for internal resources
export NO_PROXY="localhost,127.0.0.1,.internal.company.com,10.0.0.0/8"

# Start Claude Code
claude
```

This configuration works for most enterprise scenarios. The proxy server at `proxy.company.com` on port 8080 will handle all outbound HTTP and HTTPS requests from Claude Code and its tool integrations.

## Proxy Authentication

Many enterprise proxies require authentication. You can include credentials directly in the proxy URL or use environment variables for usernames and passwords. Claude Code supports authenticated proxy configurations through standard URL formatting.

```bash
# Authentication in proxy URL
export HTTP_PROXY=http://username:password@proxy.company.com:8080
export HTTPS_PROXY=http://username:password@proxy.company.com:8080
```

For enhanced security, avoid storing passwords in plain text. Instead, use environment variable files or secret management tools that your organization provides. Some enterprises integrate with identity providers that handle proxy authentication through single sign-on, reducing the need to store credentials directly.

```bash
# Using environment variables for credentials (more secure)
export HTTP_PROXY=http://proxy.company.com:8080
export PROXY_USER=your_username
export PROXY_PASS=$(security find-generic-password -w -s "Corporate Proxy")
```

## SSL Certificate Handling

Enterprise proxies typically perform SSL/TLS inspection, which means they terminate and re-encrypt HTTPS connections. This creates a new certificate signed by the corporate certificate authority. Claude Code must trust these certificates for HTTPS connections to work properly.

### Installing Corporate Certificates

Most operating systems provide mechanisms for adding corporate certificates to the trusted store. On macOS, you can add certificates through Keychain Access:

```bash
# Import certificate to macOS Keychain
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain corporate-ca.crt
```

For Linux systems, the process varies by distribution. On Ubuntu and Debian:

```bash
# Copy certificate to system directory
sudo cp corporate-ca.crt /usr/local/share/ca-certificates/

# Update CA certificates
sudo update-ca-certificates
```

After installing certificates, restart Claude Code to ensure it picks up the new trusted certificates.

### Using Custom CA Certificates with Claude Code

If you need to specify a custom certificate bundle, you can set environment variables that some tool integrations respect:

```bash
# Point to custom CA bundle
export REQUESTS_CA_BUNDLE=/path/to/corporate-ca-bundle.crt
export CURL_CA_BUNDLE=/path/to/corporate-ca-bundle.crt
```

## Configuring Claude Code for Specific Network Scenarios

### Split Tunneling Configuration

Some enterprises use split tunneling, where only specific traffic goes through the proxy while direct connections are allowed for internal resources. The `NO_PROXY` variable controls this behavior.

```bash
# Configure split tunneling
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
export NO_PROXY="localhost,127.0.0.1,.local,10.0.0.0/8,192.168.0.0/16,.company.com,*.internal.company.com"
```

### SOCKS Proxy Support

For environments using SOCKS proxies instead of HTTP proxies, Claude Code can work with SOCKS5 proxies through tool-specific configuration:

```bash
# SOCKS5 proxy configuration
export SOCKS_PROXY=socks5://proxy.company.com:1080
export SOCKS5_PROXY=socks5://proxy.company.com:1080
```

### Transparent Proxy Configuration

Transparent proxies intercept traffic without requiring client-side configuration. If your network uses transparent proxying, you may not need to configure anything in Claude Code. However, you should verify that SSL inspection is properly configured and corporate certificates are trusted.

## Troubleshooting Common Proxy Issues

### Connection Timeout Errors

If you see connection timeout errors, first verify the proxy is reachable:

```bash
# Test proxy connectivity
curl -x http://proxy.company.com:8080 https://api.anthropic.com -v
```

Check that the proxy hostname resolves correctly and the port is accessible. Firewall rules may block proxy access from your current network location.

### Certificate Validation Failures

Certificate errors typically indicate that corporate CA certificates aren't trusted. The error message will show which certificate failed validation. Install the corporate certificate as described earlier, or temporarily bypass verification for testing (not recommended for production):

```bash
# Warning: Only for testing
export CURL_CA_BUNDLE=""
```

### Authentication Failures

Invalid credentials result in 407 proxy authentication errors. Verify your username and password are correct. Some proxies use Kerberos or NTLM authentication, which may require additional configuration or integration with your system's authentication provider.

### Tool Integration Issues

Some Claude Code tool integrations have their own network configuration. For example, Git operations might ignore proxy environment variables. Configure Git explicitly:

```bash
# Configure Git to use proxy
git config --global http.proxy http://proxy.company.com:8080
git config --global https.proxy http://proxy.company.com:8080
```

## Enterprise Deployment Best Practices

When deploying Claude Code across an enterprise, consider these best practices:

**Use configuration management tools** to distribute proxy settings consistently across all machines. Group Policy, MDM solutions, or configuration management systems like Ansible can ensure every installation has the correct settings.

**Document proxy exceptions** for internal resources your teams need to access. Different teams may require different NO_PROXY settings based on their internal tools and services.

**Test thoroughly** before rolling out to users. Create test scripts that verify Claude Code can connect to external APIs through the proxy and can reach internal resources directly.

**Provide support channels** for users encountering proxy issues. Enterprise networks vary significantly, and users may need assistance troubleshooting specific configurations.

## Conclusion

Configuring Claude Code for enterprise proxy environments is straightforward once you understand the standard mechanisms. By setting appropriate environment variables, installing corporate certificates, and following the troubleshooting guidelines in this article, your team can successfully use Claude Code within restrictive network environments. Remember to test configurations thoroughly and document any specific requirements for different teams or use cases within your organization.

{% endraw %}
