---
layout: default
title: "How to Export Passwords from Chrome Safely: A Developer's Guide"
description: "Learn the official methods and best practices for exporting your Chrome passwords securely. Includes command-line tools, encryption details, and automation workflows."
date: 2026-03-15
author: theluckystrike
permalink: /export-passwords-chrome-safely/
---

Chrome's built-in password manager stores credentials locally with encryption, but there are legitimate reasons to export them: migrating to a dedicated password manager, backing up your data, or auditing stored credentials. This guide covers the official export method, security considerations, and programmatic approaches for developers and power users.

## Official Chrome Password Export

Chrome provides a built-in way to export passwords through the browser settings. This method exports credentials in an unencrypted CSV file, which you'll need to handle carefully.

### Step-by-Step Export

1. Open Chrome and navigate to `chrome://settings/passwords`
2. Locate the "Passwords" section and toggle "Offer to save passwords" if not already enabled
3. Click the three-dot menu next to "Saved Passwords"
4. Select "Export passwords"
5. Confirm by clicking "Export passwords" in the dialog
6. Choose your save location and file name

The exported file contains: URL, username, and password in plain text. The filename typically includes a timestamp like `Chrome Passwords-2026-03-15.csv`.

## Understanding Chrome's Encryption

When passwords are stored locally, Chrome encrypts them using OS-level keychain services:

- **Windows**: Data Protection API (DPAPI)
- **macOS**: Keychain Services
- **Linux**: libsecret

The exported CSV, however, contains plaintext passwords. This is the critical security gap—you're trading convenience for exposure during the export process.

## Command-Line Export Methods

For automation and scripting, developers can interact with Chrome's data through several approaches.

### Reading Chrome's SQLite Database

Chrome stores passwords in a SQLite database. The location varies by OS:

```bash
# macOS
~/Library/Application Support/Google/Chrome/Default/Login Data

# Linux
~/.config/google-chrome/Default/Login Data

# Windows
%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data
```

You can read the database directly with sqlite3:

```bash
sqlite3 "~/Library/Application Support/Google/Chrome/Default/Login Data" \
  "SELECT origin_url, username_value, password_value FROM logins"
```

The `password_value` field contains encrypted data that requires decryption using the operating system's keychain. This makes direct database extraction complex without additional tooling.

## Secure Export Workflow

Follow these practices to minimize security risks when exporting Chrome passwords:

### 1. Work in an Air-Gapped Environment

Perform exports on a clean system without network connectivity. This prevents credential interception during the export process.

### 2. Use Ephemeral Filesystems

Mount a tmpfs partition for temporary storage:

```bash
# Linux
sudo mount -t tmpfs -o size=100M tmpfs /mnt/secure

# Work in /mnt/secure directory
# Unmount after use
sudo umount /mnt/secure
```

### 3. Encrypt Immediately After Export

Apply strong encryption to the CSV immediately:

```bash
# Using GPG for symmetric encryption
gpg --symmetric --cipher-algo AES256 Chrome-Passwords-2026-03-15.csv

# This creates Chrome-Passwords-2026-03-15.csv.gpg
# Delete the original plaintext file
rm Chrome-Passwords-2026-03-15.csv
```

### 4. Verify File Deletion

Overwrite deleted files to prevent recovery:

```bash
# Overwrite file before deletion
shred -u -z Chrome-Passwords-2026-03-15.csv
```

## Importing to Password Managers

Most password managers accept CSV imports. Here are the expected formats:

### Bitwarden Format

```csv
name,login_uri,login_username,login_password,login_notes
,Github,user@example.com,supersecretpassword,Migrated from Chrome
```

### 1Password Format

```csv
title,location,username,password,url,notes
GitHub,github.com,user@example.com,supersecretpassword,https://github.com,Work account
```

### CSV Header Requirements

Different managers require different headers. Common variants include:

| Manager | Headers |
|---------|---------|
| Bitwarden | name, login_uri, login_username, login_password |
| LastPass | url, username, password, extra, name, grouping, favicon |
| 1Password | title, location, username, password, url, notes |
| KeePass | Account, Login Name, Password, URL, Notes |

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

# Export to CSV
def export_to_csv(passwords, output_file):
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['URL', 'Username', 'Password'])
        for row in passwords:
            writer.writerow([row[0], row[1], '[Encrypted]'])

export_to_csv(get_chrome_passwords(), 'chrome_passwords.csv')
```

The actual decryption requires accessing the system's keychain, which adds complexity. For production automation, consider using existing libraries like `chrome-password-decryptor`.

## Security Considerations

### Risks of CSV Exports

1. **Plaintext Storage**: Exported passwords are readable by anyone with file access
2. **Unencrypted Transfer**: Moving the file across networks exposes credentials
3. **Backup Exposure**: Cloud backups may contain unencrypted exports
4. **Malware Target**: Password files are high-value targets for malware

### Mitigation Strategies

- Always encrypt exports immediately after creation
- Use strong, unique passwords for encryption (consider a password generator)
- Delete exports from temp directories promptly
- Never store exports in cloud-synced folders
- Consider splitting exports into smaller batches to limit exposure

## When to Use Dedicated Password Managers

Chrome's built-in manager lacks features that developers and security-conscious users require:

- **No Encryption Verification**: Cannot audit encryption strength
- **Limited 2FA Integration**: No support for hardware security keys
- **No Security Alerts**: Cannot warn about compromised passwords
- **No Secure Sharing**: Cannot share credentials safely with team members
- **Platform Lock-in**: Difficult migration to other platforms

Dedicated managers like Bitwarden, 1Password, or KeePass offer better security postures, including zero-knowledge architecture, breach monitoring, and secure sharing features.

## Conclusion

Exporting passwords from Chrome is straightforward through the built-in feature, but handling the exported data requires careful security practices. For developers automating credential management, Python scripts can streamline the process—though you'll need to handle Chrome's encryption properly. Always encrypt exports immediately, work in secure environments, and consider migrating to dedicated password managers for improved long-term security.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
