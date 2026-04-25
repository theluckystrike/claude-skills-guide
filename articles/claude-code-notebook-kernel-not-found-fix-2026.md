---
title: "Notebook Kernel Not Found — Fix"
permalink: /claude-code-notebook-kernel-not-found-fix-2026/
description: "Claude Code troubleshooting: install ipykernel in the active environment to fix kernel not found. Register the kernel with Jupyter so notebook cells..."
last_tested: "2026-04-21"
---

## The Error

```
Notebook kernel not found. Cannot execute cell.
```

## The Fix

```bash
# Install ipykernel in your current Python environment
pip install ipykernel

# Register the kernel so Jupyter can find it
python -m ipykernel install --user --name myenv --display-name "Python (myenv)"
```

## Why This Works

Claude Code's NotebookEdit tool requires a matching Jupyter kernel to execute cells. The kernel specification maps a name (stored in the notebook metadata) to an actual Python environment. When the kernel name in the `.ipynb` file references an environment that is not registered on the current machine, execution fails. Installing and registering ipykernel creates that mapping.

## If That Doesn't Work

```bash
# Check what kernels are available
jupyter kernelspec list

# Update the notebook metadata to use an existing kernel
python -c "
import json
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)
nb['metadata']['kernelspec']['name'] = 'python3'
nb['metadata']['kernelspec']['display_name'] = 'Python 3'
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
"
```

This rewrites the notebook to reference the default `python3` kernel that most Jupyter installations provide.

## Prevention

Add to your CLAUDE.md:
```
Before editing Jupyter notebooks, verify the kernel exists with `jupyter kernelspec list`. Use the standard 'python3' kernel name in notebook metadata for portability across environments.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `KernelNotFoundError: kernel 'python3' not found`
- `jupyter.kernelspec.NoSuchKernel`
- `Error starting kernel: Connection refused`
- `SyntaxError: Unexpected token in JSON at position 0`
- `JSON.parse: unexpected character at line 1 column 1`

## Frequently Asked Questions

### Which Jupyter kernels does Claude Code support?

Claude Code supports any Jupyter kernel registered on the system. The most common is `python3`, but R, Julia, and custom kernels also work. Run `jupyter kernelspec list` to see all available kernels.

### Why does the kernel mismatch between my venv and notebook?

Notebooks store the kernel name in their metadata. If you created the notebook in one virtual environment but opened it in another, the kernel name may not exist. Either re-register the kernel with `python -m ipykernel install --user --name myenv` or update the notebook metadata.

### Can Claude Code create notebooks?

Yes. Claude Code can create new `.ipynb` files and edit existing cells using the NotebookEdit tool. It can also execute cells and read their output for iterative data analysis workflows.

### Why does JSON parsing fail on API responses?

JSON parse failures on API responses typically indicate a network issue where an intermediate proxy returned an HTML error page instead of JSON. Check the raw response by enabling debug logging with `CLAUDE_LOG_LEVEL=debug` to see the actual content received.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
