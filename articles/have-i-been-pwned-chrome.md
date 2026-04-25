---
layout: default
title: "Have I Been Pwned Chrome Extension"
description: "Claude Code extension tip: learn how to check if your credentials have been exposed in data breaches using Have I Been Pwned. Explore browser..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /have-i-been-pwned-chrome/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
geo_optimized: true
---
Have I Been Pwned (HIBP) remains the most comprehensive resource for checking whether your email addresses or passwords have appeared in known data breaches. Created by security researcher Troy Hunt, this free service aggregates breach data from thousands of incidents and provides multiple ways to query its database. For developers and power users, integrating HIBP into your workflow goes beyond the basic website check.

## Using the Official Have I Been Pwned Website

The simplest entry point is visiting [haveibeenpwned.com](https://haveibeenpwned.com). Enter your email address, and the service returns all breaches where that email appears. Each breach entry includes the date, the affected service, and what data types were exposed (email, password, phone number, physical address, etc.).

For Chrome users, the official "Have I Been Pwned" extension provides continuous protection. After installing it from the Chrome Web Store, the extension monitors your browsing and alerts you when you visit a site that has suffered a breach. This real-time notification system helps you make informed decisions about creating new accounts or logging into compromised services.

## The Have I Been Pwned API for Developers

For programmatic access, HIBP offers a well-documented REST API. The API requires an API key, which you can obtain by subscribing to the service. Here's how to check an email address programmatically:

```bash
curl -H "hibp-api-key: YOUR_API_KEY" \
 "https://haveibeenpwned.com/api/v3/breachedaccount/user@example.com"
```

The API returns a JSON array of breach objects. Each object contains the breach name, title, domain, breach date, and a description of what was exposed. Handle this data carefully, it's breach data, meaning you're working with compromised credentials that should never be stored or misused.

## Batch Checking Multiple Emails

If you need to check multiple email addresses, a Python script provides flexibility for bulk workflows:

```python
import requests
import os

def check_email_breaches(email, api_key):
 url = f"https://haveibeenpwned.com/api/v3/breachedaccount/{email}"
 headers = {"hibp-api-key": api_key}
 response = requests.get(url, headers=headers)

 if response.status_code == 200:
 breaches = response.json()
 print(f"{email} found in {len(breaches)} breach(es):")
 for breach in breaches:
 print(f" - {breach['Name']} ({breach['BreachDate']})")
 elif response.status_code == 404:
 print(f"{email} not found in any known breaches")
 else:
 print(f"Error checking {email}: {response.status_code}")

if __name__ == "__main__":
 email = os.environ.get("CHECK_EMAIL")
 api_key = os.environ.get("HIBP_API_KEY")
 if email and api_key:
 check_email_breaches(email, api_key)
```

Save this as `check_breaches.py`, set your environment variables, and run it with `python check_breaches.py`. This pattern extends easily to read emails from a file or database for bulk checking.

## Checking Passwords Securely

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

Usage
count = check_password("your-test-password")
if count > 0:
 print(f"Password found in {count} breaches!")
else:
 print("Password not found in known breaches.")
```

This implementation sends only the first five characters of the SHA-1 hash to the API. The server returns all hashes matching that prefix, and your local code performs the suffix comparison. This design ensures your password never leaves your machine in any form.

## Integrating HIBP into Your Applications

For developers building authentication systems or password managers, integrating HIBP provides an additional security layer. Consider these practical approaches:

Registration Validation: When users create accounts, validate their proposed passwords against the HIBP database. Reject passwords that appear in significant numbers of breaches:

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

Automated Breach Monitoring: Set up periodic checks for critical email addresses. Use cron jobs or scheduled tasks to query the API and alert users when new breaches occur:

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

## Quick Checks with Chrome DevTools

For on-the-fly verification without leaving the browser, Chrome DevTools provides a handy shortcut. Open the console on any page and run a fetch directly:

```javascript
async function checkBreach(email) {
 const response = await fetch(
 `https://haveibeenpwned.com/api/v3/breachedaccount/${encodeURIComponent(email)}`,
 { headers: { 'hibp-api-key': 'YOUR_KEY' } }
 );
 const data = await response.json();
 console.log(data);
}
checkBreach('your@email.com');
```

This is useful for quick, one-off checks during development or security audits without needing a dedicated script.

## Chrome Extension Alternatives and Extensions

Beyond the official HIBP extension, several Chrome extensions provide similar functionality with additional features:

1Password Watchtower: If you use 1Password as your password manager, the built-in Watchtower feature automatically checks your stored credentials against HIBP. It flags compromised passwords and weak credentials across your vault.

Bitwarden Breach Report: Bitwarden users benefit from automatic breach monitoring. The password manager compares your vault against known breaches and notifies you of exposed credentials.

Chrome Password Manager Integration: Google's built-in password manager includes breach detection through Google Password Manager. While not as comprehensive as HIBP, it provides baseline protection for casual users.

For power users managing multiple identities or conducting security research, consider running local copies of breach databases. Several projects provide downloadable breach datasets for offline analysis, though handling this data requires strict security practices.

## Scheduling Automated Breach Checks

For continuous monitoring without a full application stack, a simple cron job is sufficient. Schedule the Python batch script to run daily:

```bash
0 8 * * * /usr/bin/python3 /path/to/check_breaches.py >> /var/log/breach_check.log 2>&1
```

This runs at 8 AM every day and logs results. Extend the script to send notifications via email, Slack, or a webhook when new breaches are detected.

## What to Do If Your Email Is Breached

When breach checking reveals exposed addresses, act immediately:

1. Change passwords for all affected accounts
2. Enable two-factor authentication wherever available
3. Review the breach details to understand what other data was exposed (passwords, phone numbers, physical addresses)
4. Use a password manager to generate unique, strong passwords for each account going forward
5. Monitor for phishing attempts that may weaponize information from the breach

## API Security Considerations

When building breach-checking workflows, follow these guardrails:

- Protect your API keys. store them in environment variables or a secrets manager, never hardcoded in source files
- Respect rate limits. the HIBP free tier has per-day request caps; plan bulk checks accordingly
- Only check addresses you own or have explicit permission to query. checking third-party emails without consent raises ethical and legal concerns
- Never store breach data beyond its immediate use. breach datasets contain compromised credentials and should not be persisted

## Best Practices for Ongoing Protection

Beyond checking whether you've been pwned, establish habits that minimize your exposure:

- Enable two-factor authentication wherever available, especially on accounts linked to your primary email
- Use unique passwords for each service, managed through a reputable password manager
- Monitor alias email addresses for services you no longer use
- Regularly audit connected applications and remove unnecessary permissions
- Consider using email forwarding aliases to identify which services leak or sell your data

The HIBP API and Chrome extensions provide solid tools for staying informed about credential exposure. By integrating these checks into your development workflow and personal security practices, you reduce the risk of account compromise through credential stuffing and targeted attacks that rely on reused passwords.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=have-i-been-pwned-chrome)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Calendar Chrome Extensions for Developers and Power.](/calendar-chrome-extension-best/)
- [Manifest V3 Privacy: What Developers and Power Users.](/manifest-v3-privacy/)
- [AI Autocomplete Chrome Extension: A Developer's Guide](/ai-autocomplete-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


