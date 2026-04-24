---

layout: default
title: "Fix Claude SSL Certificate Error (2026)"
description: "Fix SSL certificate verification failed errors in Claude Code with 3 commands. Covers proxy, corporate firewall, and self-signed cert scenarios."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [troubleshooting]
author: theluckystrike
permalink: /claude-code-ssl-certificate-verification-failed-error/
categories: [troubleshooting]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
last_tested: "2026-04-21"
geo_optimized: true
---

## Fixing SSL Certificate Verification Failed Error in Claude Code

When you're building powerful workflows with Claude Code, you might encounter the dreaded "SSL certificate verification failed" error. This frustrating issue appears when Claude attempts to make HTTPS requests to servers with invalid, expired, self-signed, or otherwise problematic SSL certificates. Understanding this error and knowing how to resolve it will save you hours of debugging and keep your AI-powered workflows running smoothly.

## Understanding the SSL Certificate Verification Failed Error

SSL (Secure Sockets Layer) and its successor TLS (Transport Layer Security) are protocols that encrypt communications between your computer and servers. When you connect to a website or API over HTTPS, your system verifies the server's SSL certificate to ensure you're actually connecting to the intended server and not an imposter.

The "SSL certificate verification failed" error occurs when this verification process fails. In Claude Code, this typically happens when:

- The server's SSL certificate has expired
- The certificate is self-signed (not issued by a trusted Certificate Authority)
- The certificate's domain name doesn't match the URL you're accessing
- Your system has outdated root CA certificates
- A corporate proxy or firewall is performing SSL inspection
- The server is misconfigured with an incomplete certificate chain

When Claude Code encounters this error, it will report it in the terminal output and stop the operation. The exact message varies depending on which underlying tool triggered the failure, Node.js, Python's `requests` library, `curl`, or `git` each produce slightly different wording, but the root cause is always the same: the TLS handshake could not be verified.

## Common Scenarios in Claude Code

## API Integration Failures

When you're building skills that call external APIs, you might encounter this error:

```
SSL certificate verification failed: certificate has expired
```

This commonly happens with older APIs or development and staging environments that use self-signed certificates for testing purposes. It also appears when a service's certificate expires over a weekend and the on-call engineer hasn't renewed it yet, a situation that breaks automated workflows at the worst possible time.

## MCP Server Connection Issues

Model Context Protocol (MCP) servers sometimes trigger SSL errors when they're configured with custom certificates or when running behind corporate proxies:

```
SSL verification error: unable to get local issuer certificate
```

This message means the server sent a certificate, but your system cannot trace it back to a trusted root CA. This is the classic symptom of an incomplete certificate chain, the server sent its own cert but not the intermediate CA cert your system needs to complete the trust path.

## Git Operations Through Claude Code

When Claude Code executes git commands that communicate with remote repositories over HTTPS:

```
SSL certificate problem: unable to get local issuer certificate
fatal: unable to access 'https://github.example.com/': SSL certificate problem
```

Internal GitHub Enterprise instances, self-hosted GitLab servers, and Bitbucket Data Center installations frequently cause this because they use certificates signed by a company's internal CA rather than a public one.

## Python-Based Tools and Scripts

When Claude Code runs Python scripts that use the `requests` or `urllib` library:

```
requests.exceptions.SSLError: HTTPSConnectionPool(host='api.example.com', port=443):
Max retries exceeded with url: /endpoint
(Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_ERROR]
certificate verify failed: unable to get local issuer certificate (_ssl.c:1123)')))
```

On macOS in particular, Python installed via Homebrew or pyenv does not automatically use the system keychain and may need its certificates updated separately.

## Error Messages Quick Reference

| Error Message | Most Likely Cause | First Fix to Try |
|---|---|---|
| `certificate has expired` | Server cert past expiry date | Contact server owner; use custom CA bundle temporarily |
| `unable to get local issuer certificate` | Incomplete cert chain or missing CA | Update system certs or add org CA bundle |
| `self-signed certificate` | Dev/staging server using self-signed cert | Add cert to trust store for that environment |
| `hostname mismatch` | Cert issued for different domain | Verify you're using the correct URL |
| `certificate verify failed` | Generic verification failure | Run OpenSSL diagnostic to narrow down cause |
| `UNABLE_TO_VERIFY_LEAF_SIGNATURE` | Node.js: incomplete chain | Set `NODE_EXTRA_CA_CERTS` to org CA bundle |

## Diagnosing the Problem

Before applying fixes, you need to identify the root cause. Here are diagnostic steps:

## Check the Certificate Details

Use OpenSSL to inspect the server's certificate:

```bash
openssl s_client -connect example.com:443 -showcerts
```

This command displays the certificate chain and any issues with the server's SSL configuration. Look at the output for:

- The expiry date in the `notAfter` field
- Whether the chain includes intermediate certificates
- The `Verify return code` at the bottom, `0 (ok)` means the chain is valid from OpenSSL's perspective

For a cleaner summary of just the expiry and subject:

```bash
openssl s_client -connect example.com:443 </dev/null 2>/dev/null \
 | openssl x509 -noout -subject -dates
```

## Verify Your System's CA Store

Check if your system's root certificates are up to date:

```bash
On macOS: verify a specific cert file
security verify-cert -c /etc/ssl/cert.pem

On any system: use curl with verbose output to see the chain
curl -vI https://example.com 2>&1 | grep -E "(issuer|subject|expire|SSL)"
```

Test Without SSL Verification (Temporary Diagnosis Only)

You can confirm that SSL is the only issue by disabling verification temporarily:

```bash
curl -k https://example.com # -k flag disables SSL verification
```

If this succeeds while the standard request fails, you have confirmed the SSL certificate is the problem. Do not leave this flag in production scripts, it removes all TLS security guarantees.

## Check for Corporate Proxy Interception

Many enterprise networks use SSL inspection proxies that intercept HTTPS traffic, decrypt it, re-encrypt it with a company-issued certificate, and forward it. This is legitimate and intentional, but it means the certificate your tool sees is issued by the company's CA, not the original server's CA.

```bash
Check what certificate is actually being presented
openssl s_client -connect api.github.com:443 -showcerts 2>/dev/null \
 | openssl x509 -noout -issuer
```

If the issuer is something like `Zscaler` or your company name rather than a well-known CA like DigiCert or Let's Encrypt, you are behind an SSL inspection proxy and need to add your company's root CA to your trust store.

## Solutions for Claude Code

Solution 1: Disable SSL Verification (Development Only)

For development and testing environments, you can disable SSL verification. Be extremely cautious with this approach in production.

Using environment variables:

```bash
export NODE_TLS_REJECT_UNAUTHORIZED=0
export CURL_CA_BUNDLE=""
```

Then run Claude Code with these environment variables set. Note that `NODE_TLS_REJECT_UNAUTHORIZED=0` affects all Node.js processes in that shell session, not just Claude Code. Scope it carefully:

```bash
NODE_TLS_REJECT_UNAUTHORIZED=0 claude "fetch the data from https://dev-api.internal.example.com/status"
```

This sets the variable only for that single invocation rather than the entire shell session.

## Solution 2: Specify Custom CA Bundle

If your organization uses a custom CA, point Claude Code to your organization's certificate bundle:

```bash
export REQUESTS_CA_BUNDLE=/path/to/your/ca-bundle.crt
export SSL_CERT_FILE=/path/to/your/ca-bundle.crt
export NODE_EXTRA_CA_CERTS=/path/to/your/ca-bundle.crt
```

The three variables cover different runtimes: `REQUESTS_CA_BUNDLE` and `SSL_CERT_FILE` affect Python, while `NODE_EXTRA_CA_CERTS` adds certs to Node.js without disabling default verification entirely. Adding all three to your shell profile covers most tools Claude Code might invoke.

To find your organization's CA bundle, check with your IT security team or look in:

```bash
macOS: export from system keychain
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain \
 > ~/company-ca-bundle.pem

Linux: check common paths
ls /etc/ssl/certs/
ls /usr/local/share/ca-certificates/
```

## Solution 3: Update System Certificates

Keep your system's root certificates updated:

macOS:
```bash
Install the latest CA certificates via Homebrew
brew install ca-certificates

Or update the system keychain (requires admin)
sudo security update-ca-certificates
```

Ubuntu/Debian:
```bash
sudo apt update && sudo apt install --reinstall ca-certificates
sudo update-ca-certificates
```

RHEL/CentOS/Fedora:
```bash
sudo yum update ca-certificates
or
sudo dnf update ca-certificates
```

Python-specific on macOS (a common gotcha with pyenv or Homebrew Python):
```bash
For Python installed via Homebrew
/Applications/Python\ 3.12/Install\ Certificates.command

Or via pip
pip install --upgrade certifi
```

## Solution 4: Add a Certificate to the System Trust Store

If you have the certificate file for an internal server, you can add it directly to your system's trust store so all applications on the machine trust it:

macOS:
```bash
Add to system keychain (prompts for admin password)
sudo security add-trusted-cert -d -r trustRoot \
 -k /Library/Keychains/System.keychain /path/to/cert.pem
```

Ubuntu/Debian:
```bash
sudo cp /path/to/cert.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

RHEL/CentOS:
```bash
sudo cp /path/to/cert.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

After adding the cert, restart your terminal session and try the operation again. No environment variables needed once the cert is in the system trust store.

## Solution 5: Configure MCP Servers with Custom Certificates

When using MCP servers that require custom certificates, configure them with the appropriate CA bundle. Check your MCP server's documentation for SSL configuration options.

For MCP servers launched by Claude Code, you can pass environment variables in your Claude Code configuration or shell profile so all MCP subprocess inherit the correct certificate settings:

```bash
Add to ~/.zshrc or ~/.bashrc
export NODE_EXTRA_CA_CERTS="$HOME/.config/company-ca-bundle.pem"
export REQUESTS_CA_BUNDLE="$HOME/.config/company-ca-bundle.pem"
```

## Solution 6: Fix Server-Side Issues

If you control the server, fix the certificate issues there:

- Renew expiring certificates before they expire (set calendar alerts 30 days out)
- Get certificates from trusted Certificate Authorities (Let's Encrypt offers free certificates with 90-day validity and automated renewal via certbot)
- Ensure the certificate includes the correct domain names, including any subdomains you access
- Properly configure the certificate chain by including intermediate certificates in your server's TLS configuration

For nginx, a correct certificate chain configuration looks like:

```nginx
ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
```

Note `fullchain.pem` rather than `cert.pem`, the full chain file includes both the server certificate and all intermediate CA certificates, which prevents the "unable to get local issuer certificate" error.

## Best Practices for Production

Avoid disabling SSL verification in production environments. Instead:

1. Use trusted certificates: Obtain certificates from reputable CAs. Let's Encrypt is free and widely trusted. For internal services, establish a proper internal PKI rather than using ad-hoc self-signed certificates.

2. Monitor certificate expiration: Set up alerts for certificate renewal at least 30 days before expiry. Tools like `cert-manager` in Kubernetes or AWS Certificate Manager handle this automatically.

3. Use certificate management tools: Tools like certbot automate renewal and can hook into web server configs to reload certificates without downtime.

4. Implement proper certificate chains: Ensure intermediate certificates are properly configured. Use the `fullchain.pem` output from certbot rather than just `cert.pem`.

5. Test from clean environments: Periodically test your APIs from a machine outside your corporate network or from a fresh cloud VM to catch certificate issues that your internal trust store is silently hiding.

6. Treat `NODE_TLS_REJECT_UNAUTHORIZED=0` as a code smell: If you find this in a codebase or Makefile, flag it for remediation. It is appropriate only in tightly controlled local development scenarios.

## Creating Resilient Skills

When building Claude Code skills that make network requests, handle SSL errors gracefully by structuring the skill to test the connection before performing operations:

```yaml
---
name: api-fetch
description: Fetches data from APIs with SSL error handling
---

This skill handles SSL errors by:
1. First testing the connection with SSL verification enabled
2. If it fails, reporting the specific error type (expired, self-signed, chain issue)
3. Suggesting the correct fix based on the error type rather than disabling verification
4. Only proceeding with custom CA bundles when explicitly configured
```

When writing scripts for Claude Code to execute, structure them to surface certificate errors clearly:

```bash
#!/bin/bash
Test SSL before running the full workflow
if ! curl -sf --max-time 5 "https://api.example.com/health" > /dev/null; then
 echo "ERROR: Cannot reach api.example.com. Checking SSL..."
 openssl s_client -connect api.example.com:443 </dev/null 2>&1 | tail -5
 exit 1
fi
Proceed with actual work
```

This approach makes SSL failures loud and diagnostic rather than silently retrying with verification disabled.

## Conclusion

SSL certificate verification failures are common when working with APIs and external services in Claude Code, especially in enterprise environments with corporate proxies, internal CA authorities, or development servers using self-signed certificates. By understanding the causes and implementing the appropriate solutions, you can keep your AI workflows running smoothly while maintaining security.

The right fix depends on who owns the problem. If the server certificate is expired or misconfigured, fix it at the source. If you are behind a corporate SSL inspection proxy, add the company CA bundle to your environment. If you are working against a local dev server, add the self-signed cert to your trust store for that environment. Reserve `NODE_TLS_REJECT_UNAUTHORIZED=0` and `curl -k` strictly for quick local diagnosis.

Remember: the goal is not just to make the error go away, but to maintain secure, reliable connections that protect your data and your users. Disabling SSL verification trades away security for convenience, a bargain that rarely stays contained to "just development."

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-ssl-certificate-verification-failed-error)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [SSL Certificate Chain Incomplete Error — Fix (2026)](/claude-code-ssl-certificate-chain-incomplete-fix-2026/)
