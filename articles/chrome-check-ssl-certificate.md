---

layout: default
title: "How to Check SSL Certificates in Chrome: Developer Guide"
description: "Learn multiple methods to inspect, verify, and troubleshoot SSL certificates directly in Chrome browser for developers and power users."
date: 2026-03-15
categories: [guides]
tags: [chrome, ssl, security, https, developer-tools, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /chrome-check-ssl-certificate/
---


# How to Check SSL Certificates in Chrome: Developer Guide

Checking SSL certificates in Chrome is an essential skill for developers, security engineers, and anyone managing web applications. Whether you're debugging mixed content issues, verifying certificate chains, or investigating HTTPS errors, Chrome provides several built-in tools to inspect SSL certificates without external tools.

This guide covers all practical methods for checking SSL certificates in Chrome, from the basic lock icon to advanced developer tools.

## Method 1: Using the Lock Icon (Quick Verification)

The fastest way to check a certificate is through the address bar:

1. Visit any HTTPS website in Chrome
2. Look for the lock icon on the left side of the address bar
3. Click the lock icon to open the connection summary
4. Click "Certificate is valid" to view certificate details

This shows:
- Certificate issuer (Certificate Authority)
- Valid from/to dates
- Subject (domain name)

For quick verification, this method works well. However, it only shows basic information and doesn't reveal the full certificate chain or technical details.

## Method 2: Developer Tools Security Panel (Detailed Inspection)

Chrome's Developer Tools provide comprehensive certificate information:

1. Press `F12` or `Cmd+Option+I` (Mac) to open DevTools
2. Click the three-dot menu in DevTools
3. Select "More tools" → "Security"
4. Refresh the page to see security details

The Security panel shows:
- Main origin certificate details
- Certificate chain (root, intermediate, leaf certificates)
- Connection protocol and cipher suite
- Subresource security (HTTP vs HTTPS)

This is the preferred method for developers who need to verify certificate chains and connection security.

## Method 3: Certificate Viewer (Full Details)

For the most detailed certificate information:

1. Click the lock icon in the address bar
2. Click the arrow next to "Connection is secure"
3. Click "Certificate is valid"
4. Navigate through the certificate tabs

The Certificate Viewer displays:
- **Details tab**: Serial number, signature algorithm, public key info
- **Certificate chain tab**: Full chain from root CA to leaf certificate
- **Subject** and **Issuer** information
- **Extensions**: Key usage, SAN (Subject Alternative Names)

This method reveals SAN entries, which is critical for verifying certificates covering multiple domains.

## Method 4: chrome://inspector Page (Advanced)

For power users, Chrome exposes certificate information through internal pages:

1. Open `chrome://net-internals/#certificate` in a new tab
2. This page shows all certificates Chrome has cached
3. For live certificate inspection, use `chrome://inspect` → "Security" tab

You can also view certificate information through `chrome://settings` by clicking "Manage HTTPS certificates" at the bottom of the Privacy and Security section.

## Method 5: Command-Line Verification (For Automation)

While not a Chrome-specific method, developers often need automated certificate checks. Use OpenSSL for command-line verification:

```bash
# Check certificate details
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -text

# Check certificate expiration
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -dates

# Check certificate chain
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -issuer -subject
```

For Python developers, use the `ssl` module:

```python
import ssl
import socket

def check_certificate(domain, port=443):
    context = ssl.create_default_context()
    with socket.create_connection((domain, port)) as sock:
        with context.wrap_socket(sock, server_hostname=domain) as ssock:
            cert = ssock.getpeercert()
            print(f"Subject: {cert['subject']}")
            print(f"Issuer: {cert['issuer']}")
            print(f"Valid from: {cert['notBefore']}")
            print(f"Valid until: {cert['notAfter']}")
            print(f"Subject Alternative Names: {cert.get('subjectAltName', [])}")

check_certificate('example.com')
```

## Common SSL Issues and How to Identify Them

### Expired Certificates

In Chrome, an expired certificate displays a warning page with "Your connection is not private." The error message specifically states "ERR_CERT_DATE_INVALID." Check the Certificate Viewer's "Valid from/to" dates to confirm.

### Name Mismatch

When the certificate's Common Name (CN) or Subject Alternative Names (SAN) don't match the requested domain, Chrome shows "ERR_CERT_COMMON_NAME_INVALID." Always verify the SAN entries in the Certificate Viewer.

### Self-Signed Certificates

Self-signed certificates show an issuer that matches the subject, indicating it's not signed by a trusted CA. For development, you can bypass this warning by clicking "Advanced" → "Proceed to [domain] (unsafe)."

### Incomplete Certificate Chain

If intermediate certificates are missing, Chrome may show a partial lock icon or chain errors. The Security panel in Developer Tools indicates which certificates in the chain are valid or missing.

### Mixed Content Issues

Even with a valid SSL certificate, loading HTTP resources on an HTTPS page triggers warnings. Use the Chrome DevTools Console—look for "Mixed Content" warnings—to identify non-secure resources.

## Best Practices for Developers

1. **Always verify SAN entries** — Modern certificates use SAN instead of CN. Check all listed domains.

2. **Inspect certificate chains** — Don't just verify the leaf certificate; ensure the full chain is valid.

3. **Check revocation status** — Chrome checks CRL (Certificate Revocation List) and OCSP (Online Certificate Status Protocol). Ensure your certificates haven't been revoked.

4. **Use HSTS** — Implement HTTP Strict Transport Security to enforce HTTPS.

5. **Monitor expiration** — Set up automated monitoring for certificate renewal. Tools like `certbot` can automate Let's Encrypt certificate renewal.

## Conclusion

Chrome provides multiple built-in methods for inspecting SSL certificates, from quick lock icon checks to detailed Developer Tools panels. For developers, the Security panel in DevTools offers the best balance of detail and convenience. For automation, command-line tools like OpenSSL and Python's ssl module provide programmatic access to certificate information.

Regular certificate verification should be part of your development workflow, especially when deploying new domains or renewing existing certificates.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
