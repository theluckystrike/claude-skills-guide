---
layout: default
title: "Chrome Check SSL Certificate — Developer Guide"
description: "Learn how to check SSL certificates in Chrome for developers and power users. Covers DevTools, command-line tools, and practical verification techniques."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-check-ssl-certificate/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
Chrome Check SSL Certificate: A Developer Guide

Verifying SSL certificates is a fundamental skill for developers and power users who need to diagnose HTTPS issues, validate certificate chains, or troubleshoot connection problems. Chrome provides multiple built-in ways to inspect SSL certificates, each serving different use cases.

This guide covers the most effective methods for checking SSL certificates in Chrome, from quick visual checks to detailed technical analysis. plus command-line tools for automation, common errors you'll encounter, and how to set up proactive expiration monitoring.

## Quick Certificate Inspection

The fastest way to check a site's SSL certificate in Chrome is through the address bar. When you visit a site with HTTPS, look for the lock icon on the left side of the URL bar.

Click the lock icon to reveal a summary panel showing:
- Connection is secure
- Certificate validity status
- Cookies status for the domain

For detailed certificate information, click "Certificate is valid" or the certificate icon. This opens the Certificate Viewer dialog with three tabs:

1. Details: Certificate chain, serial number, signature algorithm, validity dates
2. Subject: Domain name, organization, issuer information
3. Path: The certificate chain from leaf to root

This quick method works for most day-to-day certificate checks. If the lock icon is missing or replaced by a warning triangle, Chrome has already detected a problem. use DevTools to dig deeper.

## Detailed look with Chrome DevTools

For more comprehensive analysis, Chrome DevTools provides detailed security information. Open DevTools with F12 or right-click and select "Inspect," then navigate to the Security tab.

The Security tab shows:
- Main origin certificate details
- Certificate chain visualization
- Security summary with protocol and cipher suite
- Mixed content warnings

Click "View certificate" to open the detailed Certificate Viewer. This interface shows:
- Issued to: The domain name
- Issued by: The certificate authority (CA)
- Valid from/to: Validity period
- Serial number: Unique identifier
- Signature algorithm: Hash and encryption method
- Public key: Algorithm and size

For developers debugging certificate issues, the Security tab also displays:
- Certificate chain errors
- Mixed content warnings (HTTP resources on HTTPS pages)
- HSTS (HTTP Strict Transport Security) status
- Certificate transparency information

## Reading the Security Tab's Protocol Information

Beyond the certificate itself, the Security tab tells you which TLS version and cipher suite the connection negotiated. This matters more than most developers realize. A site might have a perfectly valid certificate but still be negotiating TLS 1.0 or a weak cipher. both of which Chrome flags as security problems.

Look for lines like:

```
TLS 1.3, X25519, AES_128_GCM
TLS 1.2, ECDHE_RSA, AES_256_GCM
```

TLS 1.3 is preferred. If you see TLS 1.0 or TLS 1.1, Chrome will show a "Your connection is not fully secure" message and the server should be updated to disable those older protocol versions.

For cipher suite analysis, avoid anything containing RC4, DES, or NULL in the name. Modern deployments should negotiate ECDHE or DHE key exchange (providing forward secrecy) combined with AES-GCM or ChaCha20-Poly1305 encryption.

## Checking Certificate Transparency

Chrome logs all certificates to Certificate Transparency (CT) logs, which provides an additional verification mechanism. When a certificate passes through Chrome's requirements, it appears in these public logs.

To check if a certificate is logged:
1. Visit the site in Chrome
2. Open DevTools → Security tab
3. Look for "Certificate Transparency" information

You can also use Google's Certificate Transparency search at crt.sh or Google's CT monitor to look up certificates by domain name. This helps verify that certificates were properly issued and logged.

## Why CT Matters for Developers

Certificate Transparency was introduced to prevent CAs from secretly issuing certificates. Before CT, a rogue CA could issue a certificate for google.com without Google knowing. With CT, every certificate must be logged in a public append-only log before browsers will trust it.

For developers, CT has a practical implication: if you're issuing certificates for internal services or staging environments, those certificates will appear in public CT logs. Anyone can search crt.sh for your domain and see every certificate ever issued. including staging subdomains you might not want advertised. Consider using private PKI for internal services rather than publicly-trusted certificates.

## Command-Line Tools for SSL Verification

For automation and scripting, command-line tools provide more flexibility than browser-based inspection. These are especially useful for CI/CD pipelines, monitoring scripts, and bulk certificate audits.

## OpenSSL

The most versatile tool for SSL certificate checking:

```bash
Check certificate details
openssl s_client -connect example.com:443 -servername example.com </dev/null

Get certificate expiration
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates

Extract certificate to file
openssl s_client -connect example.com:443 -servername example.com </dev/null | openssl x509 -out cert.pem

Check certificate SANs (Subject Alternative Names)
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"

Verify full certificate chain
openssl s_client -connect example.com:443 -servername example.com -showcerts </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer
```

The `-servername` flag is critical when checking certificates on hosts with multiple domains (SNI). Without it, you may receive the wrong certificate for shared hosting environments.

## Certifi and Python

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

 # Check SANs
 san_list = []
 for san_type, san_value in cert.get('subjectAltName', []):
 san_list.append(f"{san_type}: {san_value}")
 print(f"SANs: {', '.join(san_list)}")

 # Warn if expiring soon
 if days_remaining < 30:
 print(f"WARNING: Certificate expires in {days_remaining} days!")

check_ssl_certificate('example.com')
```

You can extend this to check multiple domains and send email alerts:

```python
import smtplib
from email.message import EmailMessage

DOMAINS_TO_MONITOR = [
 'example.com',
 'api.example.com',
 'staging.example.com',
]

def check_all_domains(warning_days=30):
 alerts = []
 for domain in DOMAINS_TO_MONITOR:
 try:
 days = get_days_remaining(domain)
 if days < warning_days:
 alerts.append(f"{domain}: {days} days remaining")
 except Exception as e:
 alerts.append(f"{domain}: CHECK FAILED - {e}")
 return alerts

def get_days_remaining(hostname, port=443):
 context = ssl.create_default_context()
 with context.wrap_socket(socket.socket(), server_hostname=hostname) as sock:
 sock.connect((hostname, port))
 cert = sock.getpeercert()
 not_after = datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y %Z')
 return (not_after - datetime.now()).days
```

curl for Quick Checks

```bash
Get certificate info with curl
curl -vI https://example.com 2>&1 | grep -E "(SSL|TLS|certificate|expire|subject)"

Check if cert is valid (exit code 0 = valid, nonzero = problem)
curl --silent --output /dev/null --write-out "%{ssl_verify_result}" https://example.com

Show certificate chain details
curl -vI --cacert /etc/ssl/certs/ca-certificates.crt https://example.com 2>&1 | grep -A5 "Server certificate"

Check with specific TLS version (useful for compatibility testing)
curl --tlsv1.2 --tls-max 1.2 -vI https://example.com 2>&1 | head -20
```

## Using nmap for SSL Auditing

For comprehensive SSL/TLS auditing, nmap's ssl-enum-ciphers script goes deeper than curl or openssl:

```bash
Enumerate supported cipher suites
nmap --script ssl-enum-ciphers -p 443 example.com

Check for known SSL vulnerabilities
nmap --script ssl-heartbleed,ssl-poodle,ssl-dh-params -p 443 example.com
```

The ssl-enum-ciphers output grades each cipher suite (A, B, C, D, F) and shows the complete list of supported protocols. This is invaluable for security audits and compliance checks.

## Common Certificate Problems and How to Identify Them

Understanding common SSL issues helps you diagnose problems faster. Here is a reference for the errors Chrome surfaces and what causes them.

| Chrome Error | Cause | Fix |
|---|---|---|
| ERR_CERT_DATE_INVALID | Certificate expired | Renew certificate; enable auto-renewal |
| ERR_CERT_AUTHORITY_INVALID | Self-signed or unknown CA | Install intermediate certs; use trusted CA |
| ERR_CERT_COMMON_NAME_INVALID | Domain mismatch | Reissue cert with correct SAN entries |
| ERR_CERT_REVOKED | Certificate revoked by CA | Reissue certificate |
| ERR_CERT_WEAK_SIGNATURE_ALGORITHM | SHA-1 or MD5 signature | Reissue with SHA-256 |
| ERR_CERT_CHAINING_ERROR | Missing intermediate cert | Install complete chain on server |
| ERR_SSL_PROTOCOL_ERROR | Protocol negotiation failed | Check TLS version configuration |
| ERR_SSL_VERSION_OR_CIPHER_MISMATCH | No common protocol/cipher | Enable TLS 1.2/1.3; update cipher list |

## Expired Certificates

The most frequent issue. In Chrome, an expired certificate shows a security warning with a red lock icon. The Certificate Viewer displays the expiration date prominently. Use the expiration check commands above to proactively monitor certificates.

Let's Encrypt certificates expire every 90 days by design, making automated renewal essential. If you're using Certbot, verify your renewal cron job is working:

```bash
Test renewal without actually renewing
certbot renew --dry-run

Check renewal timer status (systemd)
systemctl status certbot.timer
```

## Self-Signed Certificates

Self-signed certificates show a "not secure" warning. The issuer and subject fields match the same domain. These work for development but cause browser warnings in production.

For local development, you have two better options than accepting browser warnings: use mkcert to create locally-trusted certificates, or use a tool like Caddy that handles certificate issuance automatically.

```bash
Install mkcert and create a locally-trusted cert
mkcert -install
mkcert localhost 127.0.0.1 ::1
```

This installs a local CA into your system trust store and issues certificates signed by it. Chrome trusts them without warnings.

## Certificate Name Mismatch

This occurs when the certificate's Common Name (CN) or Subject Alternative Name (SAN) doesn't match the requested domain. Chrome shows "ERR_CERT_COMMON_NAME_INVALID" or "ERR_CERT_NAME_CONSTRAINT_FAILED". Check the certificate's Subject and SAN fields against the domain you're visiting.

Modern certificates should use SANs rather than the legacy CN field for domain matching. If you're issuing certificates and only specifying a CN, add explicit SAN entries. Chrome deprecated CN matching for DNS names several years ago.

## Chain Issues

Certificate chain problems arise when intermediate certificates are missing or misconfigured. Chrome shows "ERR_CERT_AUTHORITY_INVALID" or "ERR_CERT_CHAINING_ERROR". The Security tab in DevTools clearly displays broken chain visualization.

Verify your server sends the complete chain using ssllabs.com, which checks chain completeness and grades your configuration. Most chain problems stem from servers configured with only the leaf certificate rather than the full chain (leaf + intermediates).

```bash
Count certificates in the chain (should be 2 or 3 for most setups)
openssl s_client -connect example.com:443 -showcerts </dev/null 2>/dev/null | grep -c "BEGIN CERTIFICATE"
```

A result of 1 means only the leaf certificate is being served. you're missing intermediates.

## Revoked Certificates

Chrome checks certificate revocation status via CRL (Certificate Revocation List) or OCSP (Online Certificate Status Protocol). A revoked certificate shows "ERR_CERT_REVOKED". Chrome maintains its own revocation checks but also respects OCSP responses.

If you suspect a certificate was improperly revoked, use the OCSP URL from the certificate's Authority Information Access (AIA) extension to check status directly:

```bash
Get OCSP URL from certificate
openssl x509 -in cert.pem -noout -text | grep "OCSP"

Query OCSP directly
openssl ocsp -issuer issuer.pem -cert cert.pem -url http://ocsp.example.com -resp_text
```

## Certificate Pinning Considerations

Some sites implement certificate pinning to prevent man-in-the-middle attacks. When a site pins its certificate, Chrome only accepts the pinned certificate or certificates in the chain.

If you're developing against a pinned site:
1. You may see pinning errors when using proxy tools like Charles or Burp Suite
2. Local development requires matching the pinned certificate
3. Some development environments provide pinning bypass options

HTTP Public Key Pinning (HPKP) was deprecated and removed from Chrome, so modern pinning happens at the application level (in mobile apps and via Chrome's built-in preload list for major Google domains). If you're using a MITM proxy for debugging and seeing mysterious failures on Google properties, Chrome's built-in pins is the cause.

## Automating Certificate Monitoring

Relying on manual checks means you'll discover expired certificates at the worst possible time. when a customer files a support ticket. Automate expiration monitoring as part of your infrastructure.

## Simple Bash Monitoring Script

```bash
#!/bin/bash
check-certs.sh - Check certificate expiration for a list of domains

DOMAINS=("example.com" "api.example.com" "staging.example.com")
WARNING_DAYS=30
ALERT_EMAIL="ops@example.com"

for domain in "${DOMAINS[@]}"; do
 expiry=$(echo | openssl s_client -connect ${domain}:443 -servername ${domain} 2>/dev/null \
 | openssl x509 -noout -enddate 2>/dev/null \
 | cut -d= -f2)

 if [ -z "$expiry" ]; then
 echo "FAILED to retrieve certificate for ${domain}"
 continue
 fi

 expiry_epoch=$(date -d "${expiry}" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "${expiry}" +%s)
 now_epoch=$(date +%s)
 days=$(( (expiry_epoch - now_epoch) / 86400 ))

 if [ $days -lt $WARNING_DAYS ]; then
 echo "WARNING: ${domain} expires in ${days} days (${expiry})"
 else
 echo "OK: ${domain} - ${days} days remaining"
 fi
done
```

Run this daily via cron and pipe alerts to Slack, PagerDuty, or email. Many teams also use purpose-built tools like `cert-manager` in Kubernetes or UptimeRobot's SSL monitoring feature.

## Best Practices for Developers

- Monitor certificate expiration: Use automated monitoring tools or scripts to check certificate validity before expiration. set alerts at 60, 30, and 14 days
- Enable auto-renewal: Let's Encrypt with Certbot or similar tools automate the renewal cycle; verify the automation works with dry-run tests
- Test across browsers: Different browsers handle certificate edge cases differently. Chrome is stricter than many others
- Understand chain validation: Chrome validates the full certificate chain, not just the leaf certificate. always serve intermediates
- Prefer TLS 1.3: Configure servers to prefer TLS 1.3 while still supporting TLS 1.2; disable TLS 1.0 and 1.1
- Use SANs not CNs: Issue certificates with explicit Subject Alternative Names, not just a Common Name
- Keep browsers updated: Chrome's certificate handling evolves with security standards; what passes today may fail after a Chrome update
- Audit with SSL Labs: Run your public domains through ssllabs.com/ssltest periodically for a comprehensive security grade

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=chrome-check-ssl-certificate)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome DevTools Security Panel Documentation](https://developer.chrome.com/docs/devtools/security)
- [SSL Labs Server Test](https://www.ssllabs.com/ssltest/)
- [Certificate Transparency Explained](https://certificate.transparency.dev/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



