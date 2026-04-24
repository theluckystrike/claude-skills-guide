---
title: "Claude Code Notebook Kernel Not Found"
permalink: /claude-code-notebook-kernel-not-found-fix-2026/
description: "Install ipykernel in the active environment to fix kernel not found. Register the kernel with Jupyter so notebook cells can execute properly."
last_tested: "2026-04-21"
render_with_liquid: false
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
