---
title: "mTLS Client Certificate Error — Fix (2026)"
permalink: /claude-code-mtls-client-cert-error-fix-2026/
description: "Fix mTLS client certificate required error. Configure Node.js with client cert and key for mutual TLS authentication."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: SSL routines:ssl3_read_bytes:tlsv13 alert certificate required
  code: 'ERR_SSL_TLSV13_ALERT_CERTIFICATE_REQUIRED'
  The server requires a client certificate for mutual TLS authentication.
```

This error occurs when the API server or a network device requires mutual TLS (mTLS) authentication — the client must present a certificate, not just validate the server's.

## The Fix

1. Configure Node.js with your client certificate:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca.pem
export NODE_TLS_CLIENT_CERT=/path/to/client.pem
export NODE_TLS_CLIENT_KEY=/path/to/client-key.pem
```

2. If using the Python SDK with mTLS:

```python
import httpx
import anthropic

http_client = httpx.Client(
    cert=("/path/to/client.pem", "/path/to/client-key.pem"),
    verify="/path/to/ca.pem"
)
client = anthropic.Anthropic(http_client=http_client)
```

3. For the Node.js SDK:

```javascript
const https = require('https');
const fs = require('fs');
const agent = new https.Agent({
  cert: fs.readFileSync('/path/to/client.pem'),
  key: fs.readFileSync('/path/to/client-key.pem'),
  ca: fs.readFileSync('/path/to/ca.pem')
});
```

4. Verify the mTLS connection:

```bash
curl --cert /path/to/client.pem --key /path/to/client-key.pem \
  https://api.anthropic.com/v1/messages -v 2>&1 | grep "SSL"
```

## Why This Happens

Mutual TLS requires both the server and client to present certificates during the TLS handshake. Some corporate environments enforce mTLS as a zero-trust security measure. The Anthropic API itself does not require mTLS, but a corporate API gateway or proxy in front of it may. Without the client certificate, the server rejects the connection during the handshake.

## If That Doesn't Work

- Check if the client cert is in the correct format:

```bash
openssl x509 -in /path/to/client.pem -noout -text | head -15
```

- Verify the key matches the cert:

```bash
openssl x509 -noout -modulus -in client.pem | md5
openssl rsa -noout -modulus -in client-key.pem | md5
# Both should output the same hash
```

- If the cert is in PKCS12 format, convert it:

```bash
openssl pkcs12 -in client.p12 -out client.pem -clcerts -nokeys
openssl pkcs12 -in client.p12 -out client-key.pem -nocerts -nodes
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# mTLS Configuration
- Client cert and key paths must be configured for corporate mTLS proxies.
- Store cert files outside the repo. Reference by absolute path.
- Verify cert/key pair match before configuring: openssl x509 -modulus vs openssl rsa -modulus.
```
