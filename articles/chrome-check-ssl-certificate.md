---


layout: default
title: "Chrome Check SSL Certificate: A Developer Guide"
description: "Learn how to check SSL certificates in Chrome for developers and power users. Covers DevTools, command-line tools, and practical verification techniques."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-check-ssl-certificate/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


{% raw %}
# Chrome Check SSL Certificate: A Developer Guide

Verifying SSL certificates is a fundamental skill for developers and power users who need to diagnose HTTPS issues, validate certificate chains, or troubleshoot connection problems. Chrome provides multiple built-in ways to inspect SSL certificates, each serving different use cases.

This guide covers the most effective methods for checking SSL certificates in Chrome, from quick visual checks to detailed technical analysis.

## Quick Certificate Inspection

The fastest way to check a site's SSL certificate in Chrome is through the address bar. When you visit a site with HTTPS, look for the lock icon on the left side of the URL bar.

Click the lock icon to reveal a summary panel showing:
- Connection is secure
- Certificate validity status
- Cookies status for the domain

For detailed certificate information, click "Certificate is valid" or the certificate icon. This opens the Certificate Viewer dialog with three tabs:

1. **Details**: Certificate chain, serial number, signature algorithm, validity dates
2. **Subject**: Domain name, organization, issuer information
3. **Path**: The certificate chain from leaf to root

This quick method works for most day-to-day certificate checks.

## Deep Dive with Chrome DevTools

For more comprehensive analysis, Chrome DevTools provides detailed security information. Open DevTools with F12 or right-click and select "Inspect," then navigate to the **Security** tab.

The Security tab shows:
- Main origin certificate details
- Certificate chain visualization
- Security summary with protocol and cipher suite
- Mixed content warnings

Click "View certificate" to open the detailed Certificate Viewer. This interface shows:
- **Issued to**: The domain name
- **Issued by**: The certificate authority (CA)
- **Valid from/to**: Validity period
- **Serial number**: Unique identifier
- **Signature algorithm**: Hash and encryption method
- **Public key**: Algorithm and size

For developers debugging certificate issues, the Security tab also displays:
- Certificate chain errors
- Mixed content warnings (HTTP resources on HTTPS pages)
- HSTS (HTTP Strict Transport Security) status
- Certificate transparency information

## Checking Certificate Transparency

Chrome logs all certificates to Certificate Transparency (CT) logs, which provides an additional verification mechanism. When a certificate passes through Chrome's requirements, it appears in these public logs.

To check if a certificate is logged:
1. Visit the site in Chrome
2. Open DevTools → Security tab
3. Look for "Certificate Transparency" information

You can also use Google's Certificate Transparency search at crt.sh or Google's CT monitor to look up certificates by domain name. This helps verify that certificates were properly issued and logged.

## Command-Line Tools for SSL Verification

For automation and scripting, command-line tools provide more flexibility than browser-based inspection.

### OpenSSL

The most versatile tool for SSL certificate checking:

```bash
# Check certificate details
openssl s_client -connect example.com:443 -servername example.com </dev/null

# Get certificate expiration
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates

# Extract certificate to file
openssl s_client -connect example.com:443 -servername example.com </dev/null | openssl x509 -out cert.pem
```

### Certifi and Python

For programmatic certificate checking:

```python
import ssl
import socket
from datetime import datetime

def check_ssl_certificate(hostname, port=443):
    context = ssl.create_default_context()
    with context.wrap_socket(socket.socket(), server_hostname=hostname) as sock:
        sock.connect((hostname, port))
        cert = sock.getpeercert()
        
        print(f"Domain: {hostname}")
        print(f"Issuer: {cert['issuer']}")
        print(f"Subject: {cert['subject']}")
        print(f"Valid from: {cert['notBefore']}")
        print(f"Valid until: {cert['notAfter']}")
        
        # Check expiration
        not_after = datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y %Z')
        days_remaining = (not_after - datetime.now()).days
        print(f"Days until expiration: {days_remaining}")

check_ssl_certificate('example.com')
```

### curl for Quick Checks

```bash
# Get certificate info with curl
curl -vI https://example.com 2>&1 | grep -E "(SSL|TLS|certificate)"

# Save certificate to file
curl -s https://example.com | openssl x509 -out cert.crt
```

## Common Certificate Problems and How to Identify Them

Understanding common SSL issues helps you diagnose problems faster.

### Expired Certificates

The most frequent issue. In Chrome, an expired certificate shows a security warning with a red lock icon. The Certificate Viewer displays the expiration date prominently. Use the expiration check commands above to proactively monitor certificates.

### Self-Signed Certificates

Self-signed certificates show a "not secure" warning. The issuer and subject fields match the same domain. These work for development but cause browser warnings in production.

### Certificate Name Mismatch

This occurs when the certificate's Common Name (CN) or Subject Alternative Name (SAN) doesn't match the requested domain. Chrome shows "ERR_CERT_COMMON_NAME_INVALID" or "ERR_CERT_NAME_CONSTRAINT_FAILED". Check the certificate's Subject and SAN fields against the domain you're visiting.

### Chain Issues

Certificate chain problems arise when intermediate certificates are missing or misconfigured. Chrome shows "ERR_CERT_AUTHORITY_INVALID" or "ERR_CERT_CHAINING_ERROR". The Security tab in DevTools clearly displays broken chain visualization.

### Revoked Certificates

Chrome checks certificate revocation status via CRL (Certificate Revocation List) or OCSP (Online Certificate Status Protocol). A revoked certificate shows "ERR_CERT_REVOKED". Chrome maintains its own revocation checks but also respects OCSP responses.

## Certificate Pinning Considerations

Some sites implement certificate pinning to prevent man-in-the-middle attacks. When a site pins its certificate, Chrome only accepts the pinned certificate or certificates in the chain.

If you're developing against a pinned site:
1. You may see pinning errors when using proxy tools
2. Local development requires matching the pinned certificate
3. Some development environments provide pinning bypass options

## Best Practices for Developers

- **Monitor certificate expiration**: Use automated monitoring tools or scripts to check certificate validity before expiration
- **Test across browsers**: Different browsers handle certificate edge cases differently
- **Understand chain validation**: Chrome validates the full certificate chain, not just the leaf certificate
- **Keep browsers updated**: Chrome's certificate handling evolves with security standards

---

## Related Reading

- [Chrome DevTools Security Panel Documentation](https://developer.chrome.com/docs/devtools/security)
- [SSL Labs Server Test](https://www.ssllabs.com/ssltest/)
- [Certificate Transparency Explained](https://certificate.transparency.dev/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}