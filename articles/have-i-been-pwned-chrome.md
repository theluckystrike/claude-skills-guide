---
layout: default
title: "Have I Been Pwned Chrome: A Developer and Power User Guide"
description: "Learn how to check if your credentials have been exposed in data breaches using Have I Been Pwned. Explore browser extensions, API integration, and automated monitoring strategies."
date: 2026-03-15
author: theluckystrike
permalink: /have-i-been-pwned-chrome/
---

# Have I Been Pwned Chrome: A Developer and Power User Guide

Have I Been Pwned (HIBP) remains the most comprehensive resource for checking whether your email addresses or passwords have appeared in known data breaches. Created by security researcher Troy Hunt, this free service aggregates breach data from thousands of incidents and provides multiple ways to query its database. For developers and power users, integrating HIBP into your workflow goes beyond the basic website check.

## Using the Official Have I Been Pwned Website

The simplest entry point is visiting [haveibeenpwned.com](https://haveibeenpwned.com). Enter your email address, and the service returns all breaches where that email appears. Each breach entry includes the date, the affected service, and what data types were exposed (email, password, phone number, physical address, etc.).

For Chrome users, the official "Have I Been Pwned" extension provides continuous protection. After installing it from the Chrome Web Store, the extension monitors your browsing and alerts you when you visit a site that has suffered a breach. This real-time notification system helps you make informed decisions about creating new accounts or logging into potentially compromised services.

## The Have I Been Pwned API for Developers

For programmatic access, HIBP offers a well-documented REST API. The API requires an API key, which you can obtain by subscribing to the service. Here's how to check an email address programmatically:

```bash
curl -H "hibp-api-key: YOUR_API_KEY" \
  "https://haveibeenpwned.com/api/v3/breachedaccount/user@example.com"
```

The API returns a JSON array of breach objects. Each object contains the breach name, title, domain, breach date, and a description of what was exposed. Handle this data carefully—it's breach data, meaning you're working with compromised credentials that should never be stored or misused.

### Checking Passwords Securely

Password checking via the API uses a k-anonymity model that never sends your actual password over the network. The process works like this:

```python
import hashlib
import requests

def check_password(password):
    sha1_hash = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
    prefix = sha1_hash[:5]
    suffix = sha1_hash[5:]
    
    response = requests.get(
        f"https://api.pwnedpasswords.com/range/{prefix}"
    )
    
    hashes = (line.split(':') for line in response.text.splitlines())
    
    for h, count in hashes:
        if h == suffix:
            return int(count)
    return 0

# Usage
count = check_password("your-test-password")
if count > 0:
    print(f"Password found in {count} breaches!")
else:
    print("Password not found in known breaches.")
```

This implementation sends only the first five characters of the SHA-1 hash to the API. The server returns all hashes matching that prefix, and your local code performs the suffix comparison. This design ensures your password never leaves your machine in any form.

## Integrating HIBP into Your Applications

For developers building authentication systems or password managers, integrating HIBP provides an additional security layer. Consider these practical approaches:

**Registration Validation**: When users create accounts, validate their proposed passwords against the HIBP database. Reject passwords that appear in significant numbers of breaches:

```javascript
async function validatePassword(password) {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hashBuffer = await crypto.subtle.digest('SHA-1', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('').toUpperCase();
  
  const prefix = hashHex.substring(0, 5);
  const suffix = hashHex.substring(5);
  
  const response = await fetch(`https://api.pwnedpasswords.com/range/${prefix}`);
  const text = await response.text();
  
  const match = text.split('\n').find(line => line.startsWith(suffix));
  
  if (match) {
    const count = parseInt(match.split(':')[1], 10);
    return { safe: false, count };
  }
  return { safe: true, count: 0 };
}
```

**Automated Breach Monitoring**: Set up periodic checks for critical email addresses. Use cron jobs or scheduled tasks to query the API and alert users when new breaches occur:

```python
import smtplib
from email.mime.text import MIMEText
import schedule
import time

def check_breaches(email):
    import requests
    response = requests.get(
        f"https://haveibeenpwned.com/api/v3/breach/{email}",
        headers={"hibp-api-key": "YOUR_API_KEY"}
    )
    return response.json() if response.status_code == 200 else []

def send_alert(email, breaches):
    msg = MIMEText(f"New breaches detected for {email}: {breaches}")
    # Configure your SMTP settings here
    with smtplib.SMTP('smtp.example.com', 587) as server:
        server.sendmail("alerts@example.com", email, msg.as_string())

def daily_check():
    for email in monitored_emails:
        breaches = check_breaches(email)
        if breaches:
            send_alert(email, breaches)

schedule.every().day.at("09:00").do(daily_check)

while True:
    schedule.run_pending()
    time.sleep(60)
```

## Chrome Extension Alternatives and Extensions

Beyond the official HIBP extension, several Chrome extensions provide similar functionality with additional features:

**1Password Watchtower**: If you use 1Password as your password manager, the built-in Watchtower feature automatically checks your stored credentials against HIBP. It flags compromised passwords and weak credentials across your vault.

**Bitwarden Breach Report**: Bitwarden users benefit from automatic breach monitoring. The password manager compares your vault against known breaches and notifies you of exposed credentials.

**Chrome Password Manager Integration**: Google's built-in password manager includes breach detection through Google Password Manager. While not as comprehensive as HIBP, it provides baseline protection for casual users.

For power users managing multiple identities or conducting security research, consider running local copies of breach databases. Several projects provide downloadable breach datasets for offline analysis, though handling this data requires strict security practices.

## Best Practices for Ongoing Protection

Beyond checking whether you've been pwned, establish habits that minimize your exposure:

- Enable two-factor authentication wherever available, especially on accounts linked to your primary email
- Use unique passwords for each service, managed through a reputable password manager
- Monitor alias email addresses for services you no longer use
- Regularly audit connected applications and remove unnecessary permissions
- Consider using email forwarding aliases to identify which services leak or sell your data

The HIBP API and Chrome extensions provide robust tools for staying informed about credential exposure. By integrating these checks into your development workflow and personal security practices, you reduce the risk of account compromise through credential stuffing and targeted attacks that rely on reused passwords.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
