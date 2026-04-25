---
layout: default
title: "How to Export Passwords from Chrome"
description: "Claude Code guide: learn the official methods and best practices for exporting your Chrome passwords securely. Includes command-line tools, encryption..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /export-passwords-chrome-safely/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
last_tested: "2026-04-22"
---

Chrome's built-in password manager stores credentials locally with encryption, but there are legitimate reasons to export them: migrating to a dedicated password manager, backing up your data, or auditing stored credentials. This guide covers the official export method, security considerations, and programmatic approaches for developers and power users.

## Official Chrome Password Export

Chrome provides a built-in way to export passwords through the browser settings. This method exports credentials in an unencrypted CSV file, which you'll need to handle carefully.

## Step-by-Step Export

1. Open Chrome and navigate to `chrome://settings/passwords`
2. Locate the "Passwords" section and toggle "Offer to save passwords" if not already enabled
3. Click the three-dot menu next to "Saved Passwords"
4. Select "Export passwords"
5. Confirm by clicking "Export passwords" in the dialog
6. Choose your save location and file name

The exported file contains: URL, username, and password in plain text. The filename typically includes a timestamp like `Chrome Passwords-2026-03-15.csv`.

## What the CSV Looks Like

The exported file has a straightforward structure with four columns:

```
name,url,username,password
Google,https://accounts.google.com,user@gmail.com,hunter2
GitHub,https://github.com/login,devuser,mysecretpassword
```

Every row is plaintext. There is no encryption, no obfuscation, and no password hint. just the raw credentials. Anyone who opens this file sees everything. That is the fundamental tension in Chrome's export feature: it is easy to use, but the output requires careful handling.

## Export via Chrome Password Manager on the Web

If you use Chrome with a Google account, your passwords sync to your Google account and are accessible at `passwords.google.com`. This web interface also offers an export option, available under the settings menu in the top right. The output format is identical to the browser export. a plaintext CSV.

The web export is useful if Chrome itself is unavailable, such as on a shared machine where you cannot install software.

## Understanding Chrome's Encryption

When passwords are stored locally, Chrome encrypts them using OS-level keychain services:

- Windows: Data Protection API (DPAPI)
- macOS: Keychain Services
- Linux: libsecret

The exported CSV, however, contains plaintext passwords. This is the critical security gap, you're trading convenience for exposure during the export process.

Understanding what this means in practice: when Chrome reads passwords to display them in settings or autofill them on a page, it decrypts them in memory using the OS keychain, uses them, then discards the plaintext. The export function does the same decryption but writes the result to disk as plaintext. The security model that protects stored passwords does not extend to the export file.

On macOS, this means Chrome will prompt for your macOS login password or Touch ID before completing the export. Chrome needs to use the Keychain to decrypt the stored passwords. On Windows, DPAPI ties encryption to the current user account, so exports can only happen while logged in as that user. On Linux with libsecret, the behavior depends on your distribution's secret service implementation.

## Command-Line Export Methods

For automation and scripting, developers can interact with Chrome's data through several approaches.

## Reading Chrome's SQLite Database

Chrome stores passwords in a SQLite database. The location varies by OS:

```bash
macOS
~/Library/Application Support/Google/Chrome/Default/Login Data

Linux
~/.config/google-chrome/Default/Login Data

Windows
%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data
```

You can read the database directly with sqlite3:

```bash
sqlite3 "~/Library/Application Support/Google/Chrome/Default/Login Data" \
 "SELECT origin_url, username_value, password_value FROM logins"
```

The `password_value` field contains encrypted data that requires decryption using the operating system's keychain. This makes direct database extraction complex without additional tooling.

## Why Direct Database Access Is Complicated

The SQLite approach retrieves the `password_value` field, but that field stores a binary blob, not plaintext. On macOS, it is an AES-GCM encrypted value. The encryption key is stored in the macOS Keychain under the entry "Chrome Safe Storage." On Windows, the encryption key is stored in a `Local State` file next to the profile directory, but the key itself is encrypted with DPAPI and tied to the current user session.

This design means that even with direct file access, you cannot read passwords without going through the OS's key management layer. Scripts that claim to extract Chrome passwords directly almost always shell out to the OS keychain APIs rather than doing purely file-based work.

Attempting to copy and query the database while Chrome is running can also trigger SQLite locking errors, since Chrome holds a write lock on the database. Copy the file first:

```bash
cp ~/Library/Application\ Support/Google/Chrome/Default/Login\ Data /tmp/chrome_login_data.db
sqlite3 /tmp/chrome_login_data.db "SELECT origin_url, username_value FROM logins"
```

This at least lets you see URLs and usernames without decryption. The passwords remain encrypted binary blobs.

## Secure Export Workflow

Follow these practices to minimize security risks when exporting Chrome passwords:

1. Work in an Air-Gapped Environment

Perform exports on a clean system without network connectivity. This prevents credential interception during the export process.

2. Use Ephemeral Filesystems

Mount a tmpfs partition for temporary storage:

```bash
Linux
sudo mount -t tmpfs -o size=100M tmpfs /mnt/secure

Work in /mnt/secure directory
Unmount after use
sudo umount /mnt/secure
```

On macOS, you can create an encrypted disk image using Disk Utility or the command line:

```bash
Create an encrypted sparse disk image
hdiutil create -size 50m -encryption AES-256 -type SPARSE \
 -volname "SecureExport" -fs HFS+ ~/Desktop/secure_export.dmg

Mount it
hdiutil attach ~/Desktop/secure_export.dmg

Export Chrome passwords to /Volumes/SecureExport/
When done, unmount
hdiutil detach /Volumes/SecureExport
```

This approach gives you an encrypted container that requires a password to mount. The exported CSV exists only within that encrypted space while you work with it.

3. Encrypt Immediately After Export

Apply strong encryption to the CSV immediately:

```bash
Using GPG for symmetric encryption
gpg --symmetric --cipher-algo AES256 Chrome-Passwords-2026-03-15.csv

This creates Chrome-Passwords-2026-03-15.csv.gpg
Delete the original plaintext file
rm Chrome-Passwords-2026-03-15.csv
```

To decrypt later when you need access:

```bash
gpg --decrypt Chrome-Passwords-2026-03-15.csv.gpg > Chrome-Passwords-decrypted.csv
Process the CSV, then delete it
shred -u -z Chrome-Passwords-decrypted.csv
```

4. Verify File Deletion

Overwrite deleted files to prevent recovery:

```bash
Overwrite file before deletion
shred -u -z Chrome-Passwords-2026-03-15.csv
```

On macOS, `shred` is not available by default, but you can install it via Homebrew (`brew install coreutils`) or use the built-in `srm` command if available on older macOS versions. On modern macOS with SSDs, secure deletion is complicated by wear-leveling. the filesystem may keep older blocks alive for SSD health even after "deletion." Using an encrypted disk image (as described above) is more reliable because you can simply destroy the encryption key by securely deleting the sparse image itself.

5. Keep the Window of Exposure Short

The most effective security practice is minimizing time-to-import. Export the CSV, immediately import it into your password manager of choice, verify the import is complete, then delete the export file. The entire process should take under five minutes. Do not let the plaintext CSV sit on your desktop while you get distracted.

## Importing to Password Managers

Most password managers accept CSV imports. Here are the expected formats:

## Bitwarden Format

```csv
name,login_uri,login_username,login_password,login_notes
,Github,user@example.com,supersecretpassword,Migrated from Chrome
```

## 1Password Format

```csv
title,location,username,password,url,notes
GitHub,github.com,user@example.com,supersecretpassword,https://github.com,Work account
```

## CSV Header Requirements

Different managers require different headers. Common variants include:

| Manager | Headers |
|---------|---------|
| Bitwarden | name, login_uri, login_username, login_password |
| LastPass | url, username, password, extra, name, grouping, favicon |
| 1Password | title, location, username, password, url, notes |
| KeePass | Account, Login Name, Password, URL, Notes |

## Converting Chrome's Export Format

Chrome's export uses `name,url,username,password` as headers. Most password managers expect different header names, so you will need to either rename the headers manually in a text editor or use a script to reformat before importing.

A simple header conversion with Python:

```python
import csv
import sys

Map Chrome headers to Bitwarden headers
CHROME_TO_BITWARDEN = {
 'name': 'name',
 'url': 'login_uri',
 'username': 'login_username',
 'password': 'login_password',
}

def convert_chrome_to_bitwarden(input_file, output_file):
 with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
 reader = csv.DictReader(infile)
 fieldnames = [CHROME_TO_BITWARDEN[f] for f in reader.fieldnames]
 writer = csv.DictWriter(outfile, fieldnames=fieldnames)
 writer.writeheader()
 for row in reader:
 writer.writerow({CHROME_TO_BITWARDEN[k]: v for k, v in row.items()})

convert_chrome_to_bitwarden('chrome_export.csv', 'bitwarden_import.csv')
```

Run this conversion on a secure system and delete both files promptly after the import completes.

## Verifying Import Completeness

Before deleting your Chrome export, verify the import worked correctly:

1. Count rows in the CSV (minus the header line)
2. Compare against the item count shown in your password manager after import
3. Spot-check five to ten credentials by looking up specific sites in the new manager and verifying the credentials are present and correct
4. Test autofill on two or three sites to confirm the imported credentials actually work

Only delete the export CSV after you are confident the import is complete and the credentials are accessible.

## Automating Exports with Python

For recurring exports or batch processing, use Python with the `keyring` library:

```python
import csv
import os
import sqlite3
from keyring import get_password

def get_chrome_passwords():
 db_path = os.path.expanduser(
 "~/Library/Application Support/Google/Chrome/Default/Login Data"
 )

 # Copy database (Chrome locks the original)
 temp_db = "/tmp/chrome_passwords.db"
 import shutil
 shutil.copy2(db_path, temp_db)

 conn = sqlite3.connect(temp_db)
 cursor = conn.cursor()

 # Note: Passwords are encrypted in the DB
 # This requires additional decryption logic
 cursor.execute(
 "SELECT origin_url, username_value, password_value FROM logins"
 )

 passwords = cursor.fetchall()
 conn.close()
 os.remove(temp_db)

 return passwords

Export to CSV
def export_to_csv(passwords, output_file):
 with open(output_file, 'w', newline='') as f:
 writer = csv.writer(f)
 writer.writerow(['URL', 'Username', 'Password'])
 for row in passwords:
 writer.writerow([row[0], row[1], '[Encrypted]'])

export_to_csv(get_chrome_passwords(), 'chrome_passwords.csv')
```

The actual decryption requires accessing the system's keychain, which adds complexity. For production automation, consider using existing libraries like `chrome-password-decryptor`.

## A More Complete macOS Decryption Approach

On macOS, the decryption key for Chrome passwords is stored in the Keychain. Retrieving it and decrypting passwords programmatically looks like this:

```python
import os
import sqlite3
import shutil
import subprocess
import base64
from Crypto.Cipher import AES

def get_chrome_safe_storage_key():
 """Retrieve the Chrome Safe Storage key from macOS Keychain."""
 result = subprocess.run(
 ['security', 'find-generic-password', '-wa', 'Chrome Safe Storage'],
 capture_output=True, text=True
 )
 return result.stdout.strip().encode()

def decrypt_chrome_password(encrypted_value, key):
 """Decrypt a Chrome password on macOS."""
 # Chrome uses AES-128-CBC with a 16-byte key derived from the keychain password
 # Salt is 'saltysalt', iterations=1003, key length=16
 from hashlib import pbkdf2_hmac
 derived_key = pbkdf2_hmac('sha1', key, b'saltysalt', 1003, dklen=16)

 # Remove the 'v10' prefix that Chrome adds
 iv = b' ' * 16
 encrypted_value = encrypted_value[3:] # Strip 'v10' prefix

 cipher = AES.new(derived_key, AES.MODE_CBC, iv)
 decrypted = cipher.decrypt(encrypted_value)

 # Remove PKCS7 padding
 padding_length = decrypted[-1]
 return decrypted[:-padding_length].decode('utf-8')
```

This requires the `pycryptodome` package (`pip install pycryptodome`) and only works on macOS. Windows has a different key retrieval path using DPAPI. In practice, unless you have a specific automation requirement, the built-in Chrome export is simpler and less error-prone.

## Security Considerations

## Risks of CSV Exports

1. Plaintext Storage: Exported passwords are readable by anyone with file access
2. Unencrypted Transfer: Moving the file across networks exposes credentials
3. Backup Exposure: Cloud backups may contain unencrypted exports
4. Malware Target: Password files are high-value targets for malware

## Mitigation Strategies

- Always encrypt exports immediately after creation
- Use strong, unique passwords for encryption (consider a password generator)
- Delete exports from temp directories promptly
- Never store exports in cloud-synced folders
- Consider splitting exports into smaller batches to limit exposure

## Understanding Your Threat Model

The right security precautions depend on what you are actually worried about. Most people exporting Chrome passwords are doing a one-time migration to a dedicated password manager. For this use case, the biggest risks are:

- Accidentally syncing the CSV to cloud storage (Dropbox, iCloud, Google Drive)
- Leaving the CSV on a shared machine
- Sending the CSV via email or messaging apps to yourself

For typical users, the practical guidance is: export the file, move it somewhere not cloud-synced, import it, verify, delete immediately. The elaborate air-gapped environment setup described earlier is appropriate for security-sensitive contexts. corporate credential migrations, high-value personal accounts, or environments where you have reason to believe your network is monitored.

For developers building tooling that handles exported password files, the bar is higher. If you are writing a migration script that reads the CSV, it should never write decrypted passwords to additional files, should handle the data only in memory, and should log nothing that could contain credentials.

## When to Use Dedicated Password Managers

Chrome's built-in manager lacks features that developers and security-conscious users require:

- No Encryption Verification: Cannot audit encryption strength
- Limited 2FA Integration: No support for hardware security keys
- No Security Alerts: Cannot warn about compromised passwords
- No Secure Sharing: Cannot share credentials safely with team members
- Platform Lock-in: Difficult migration to other platforms

Dedicated managers like Bitwarden, 1Password, or KeePass offer better security postures, including zero-knowledge architecture, breach monitoring, and secure sharing features.

## Comparing Options After Migration

| Feature | Chrome | Bitwarden | 1Password | KeePass |
|---------|--------|-----------|-----------|---------|
| Cost | Free | Free/Premium | Paid | Free |
| Zero-knowledge | No | Yes | Yes | Yes (local) |
| Breach monitoring | Basic | Yes | Yes | Via plugins |
| Browser integration | Native | Extension | Extension | Extension |
| Mobile apps | Yes | Yes | Yes | Third-party |
| Team sharing | No | Yes (Teams) | Yes (Teams) | Via sync services |
| Offline access | Yes | Paid tier | Yes | Yes (local) |
| Open source | No | Yes | No | Yes |
| Hardware key 2FA | No | Premium | Yes | Via plugins |

For most developers, Bitwarden strikes the best balance: open source, self-hostable, cross-platform, and free for individuals with paid tiers for teams. 1Password has a better user experience but requires a subscription. KeePass is the right choice if you want complete local control and are comfortable managing your own sync.

## After the Migration

Once you have imported your passwords into a dedicated manager:

1. Disable Chrome's password manager to prevent new credentials from accumulating there: navigate to `chrome://settings/autofill/passwords` and turn off "Offer to save passwords" and "Auto Sign-in"
2. Configure your new password manager's browser extension to handle autofill
3. Change passwords for high-value accounts (banking, email, work systems) immediately after migration. the export process itself is a good reminder to rotate important credentials
4. Enable two-factor authentication on your password manager account if you have not already

The goal is to make Chrome's password manager irrelevant going forward, not just to perform a one-time export.

## Conclusion

Exporting passwords from Chrome is straightforward through the built-in feature, but handling the exported data requires careful security practices. For developers automating credential management, Python scripts can streamline the process. though you'll need to handle Chrome's encryption properly. Always encrypt exports immediately, work in secure environments, and consider migrating to dedicated password managers for improved long-term security.

The plaintext CSV is the weakest link. Every minute it exists unencrypted on a writable filesystem is a minute it is copied, synced, or read by something it should not be. Treat the export workflow as a race: get in, import, verify, delete.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=export-passwords-chrome-safely)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Export Highlights Notes: A Practical Guide](/chrome-extension-export-highlights-notes/)
- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)
- [AI Color Picker Chrome Extension: A Developer's Guide](/ai-color-picker-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


