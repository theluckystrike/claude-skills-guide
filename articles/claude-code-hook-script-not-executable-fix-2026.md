---
title: "Claude Code Hook Script Not Executable — Fix (2026)"
permalink: /claude-code-hook-script-not-executable-fix-2026/
description: "Run chmod +x on hook script to fix not-executable permission error. Ensure valid shebang line and Unix line endings are present in the file."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Hook failed: /path/to/hook.sh is not executable
```

## The Fix

```bash
# Make the hook script executable
chmod +x /path/to/hook.sh

# Verify the permission was set
ls -la /path/to/hook.sh
# Should show: -rwxr-xr-x
```

## Why This Works

Claude Code hooks invoke external scripts through the system shell. Unix systems require the executable bit set on any file invoked directly (as opposed to being passed as an argument to an interpreter). Without `+x`, the OS rejects execution at the syscall level before the script content is even read.

## If That Doesn't Work

```bash
# Ensure the script has a valid shebang line
head -1 /path/to/hook.sh
# Must be: #!/bin/bash or #!/usr/bin/env bash

# If missing, add it:
sed -i '1i#!/usr/bin/env bash' /path/to/hook.sh

# Also check the file doesn't have Windows line endings
file /path/to/hook.sh
# If it says "CRLF", fix with:
sed -i 's/\r$//' /path/to/hook.sh
```

Windows line endings cause the shebang to be read as `#!/bin/bash\r` which points to a nonexistent interpreter.

## Prevention

Add to your CLAUDE.md:
```
All hook scripts must have: (1) chmod +x applied, (2) a #!/usr/bin/env bash shebang on line 1, (3) Unix line endings (LF not CRLF). Verify with `file script.sh` before registering as a hook.
```
