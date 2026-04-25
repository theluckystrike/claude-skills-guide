---
layout: default
title: "Fix Claude Code Large File Crashes"
description: "Fix Claude Code crashes on large files with memory plugin tips, file splitting strategies, and .claudeignore configuration that actually works."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
last_tested: "2026-04-21"
permalink: /claude-code-crashes-on-large-files-how-to-fix/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-code, claude-skills]
geo_optimized: true
---

# Claude Code Crashes on Large Files: How to Fix

Claude Code (claude.ai) is a powerful AI assistant, but like any tool, it has boundaries. When working with massive files, log files, datasets, large codebases, you might encounter crashes or sluggish performance. This guide covers practical solutions to keep Claude running smoothly when handling large files.

## Understanding the Problem

Claude Code processes files by reading their contents into context. When a file exceeds reasonable limits, the system can become unresponsive or crash entirely. This commonly happens with:

- Log files exceeding 10MB
- Large JSON or CSV datasets
- Minified JavaScript bundles
- Single-file codebases with thousands of lines

The root cause is usually memory consumption or context window limitations. Each file Claude reads consumes a portion of the available context window, and when that limit is approached, performance degrades or processing fails.

What Is the Context Window and Why Does It Matter?

The context window is the total amount of text Claude can hold in "working memory" during a conversation. Every message you send, every file Claude reads, and every response Claude generates all count against this shared budget. Claude's context window is measured in tokens, roughly 0.75 words per token on average, so a 200,000-token window accommodates about 150,000 words of content.

When a large file is read into context, it crowds out room for your subsequent questions, Claude's reasoning, and its responses. As context fills, Claude may start forgetting earlier parts of the conversation or simply refuse to process more content. If reading the file itself requires more tokens than the window allows, Claude will fail before it even has a chance to respond.

Here is a rough token budget breakdown to illustrate how quickly a large file can dominate the context:

| File Type | Typical Size | Approximate Tokens | % of 200K Context |
|---|---|---|---|
| 1,000-line Python file | ~50KB | ~12,000 | 6% |
| 5,000-line JavaScript file | ~200KB | ~50,000 | 25% |
| 50MB log file | 50MB | ~12,000,000 | 6,000% (impossible) |
| 10MB CSV dataset | 10MB | ~2,500,000 | 1,250% (impossible) |
| Minified JS bundle | ~2MB | ~500,000 | 250% (will crash) |

The table makes the problem concrete: anything over a few hundred kilobytes starts creating real risk of degraded performance or an outright crash.

## Crash vs. Slow vs. Truncated: Diagnosing the Symptom

Not all large-file problems look the same. Understanding which symptom you are seeing helps you choose the right fix:

| Symptom | Likely Cause | Best First Fix |
|---|---|---|
| Complete crash / no response | File exceeds context ceiling | File splitting (Solution 1) |
| Very slow response | File is near context limit; model is under strain | Selective reading (Solution 3) |
| Response truncated mid-sentence | Output token limit hit while generating | Reduce file size fed in + ask for smaller outputs |
| "File too large" error message | Hard limit enforced by Claude Code CLI | Adjust maxFileSize config (Solution 2) |
| Garbled or hallucinated content | Context overflow; earlier content dropped | Pre-process to reduce size (Solution 6) |

## Solution 1: Use File Splitting

The most practical approach is breaking large files into smaller chunks. Instead of asking Claude to read an entire 50MB log file, split it first.

```bash
Split a large log file into 1000-line chunks
split -l 1000 application.log application_log_part_

Split a large CSV file by rows
head -1 large_dataset.csv > header.csv
tail -n +2 large_dataset.csv | split -l 5000 - dataset_part_
```

After splitting, process each chunk separately. This approach works well when analyzing logs with the [supermemory skill](/claude-supermemory-skill-persistent-context-explained/), which helps track insights across multiple file segments.

## Automated Splitting with Python

The bash `split` command works well for uniform files, but Python gives you more control when chunks need to be semantically meaningful, for example, splitting a large JSON array so each chunk is still valid JSON:

```python
import json
import math

def split_json_array(filepath, chunk_size=500, output_prefix="chunk_"):
 """Split a large JSON array file into smaller valid JSON files."""
 with open(filepath, 'r') as f:
 data = json.load(f)

 if not isinstance(data, list):
 raise ValueError("Expected a JSON array at the top level")

 total_chunks = math.ceil(len(data) / chunk_size)
 for i in range(total_chunks):
 chunk = data[i * chunk_size : (i + 1) * chunk_size]
 output_path = f"{output_prefix}{i:04d}.json"
 with open(output_path, 'w') as out:
 json.dump(chunk, out, indent=2)
 print(f"Wrote {len(chunk)} records to {output_path}")

Usage
split_json_array("large_dataset.json", chunk_size=500)
```

For log files, split on meaningful boundaries like timestamp boundaries rather than arbitrary line counts:

```python
from datetime import datetime, timedelta

def split_log_by_hour(filepath, output_dir="."):
 """Split a log file into per-hour files based on ISO timestamps."""
 current_hour = None
 current_file = None

 with open(filepath, 'r') as f:
 for line in f:
 # Assumes log format: 2026-03-14T15:23:01.000Z [LEVEL] message
 try:
 ts_str = line.split(' ')[0]
 dt = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))
 hour_key = dt.strftime("%Y%m%d_%H")
 except (ValueError, IndexError):
 # Line has no parseable timestamp; append to current file
 if current_file:
 current_file.write(line)
 continue

 if hour_key != current_hour:
 if current_file:
 current_file.close()
 current_hour = hour_key
 current_file = open(f"{output_dir}/log_{hour_key}.log", 'w')

 current_file.write(line)

 if current_file:
 current_file.close()
```

Hour-based log files are rarely larger than a few MB even for busy services, and they are much easier to correlate with deployment events or incidents.

## Solution 2: Adjust Context Settings

Claude Code supports several settings that control how it handles file content. In your configuration, you can set limits:

```json
{
 "maxFileSize": "5MB",
 "contextWindow": "200000",
 "streaming": true
}
```

Reducing the maximum file size forces Claude to request chunked reading, preventing crashes on oversized files.

## Where to Find Your Configuration File

The Claude Code CLI reads configuration from `~/.claude/settings.json` on macOS/Linux and `%APPDATA%\Claude\settings.json` on Windows. If the file does not exist, create it, Claude Code will pick it up on the next launch.

The full set of relevant configuration keys:

```json
{
 "maxFileSize": "5MB",
 "streaming": true,
 "env": {
 "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "8096",
 "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "0"
 }
}
```

Setting `streaming: true` is especially important for large files because it lets Claude begin returning output before the entire context is processed, reducing perceived latency and the likelihood of a timeout-triggered crash.

## Solution 3: Use Selective Reading

Instead of loading entire files, use partial reading techniques. Many programming tasks don't require the whole file.

```python
Python script to extract specific sections
def read_first_n_lines(filepath, n=100):
 with open(filepath, 'r') as f:
 for i, line in enumerate(f):
 if i >= n:
 break
 yield line
```

When working with PDF files using the pdf skill, request specific page ranges rather than the entire document. If you regularly hit size limits, review [context window optimization strategies](/claude-md-too-long-context-window-optimization/) to keep file processing lean. Similarly, when generating presentations with pptx, process slides individually for large decks.

## Targeted Reads Using Claude Code's Built-in Read Tool

Claude Code's Read tool accepts `offset` and `limit` parameters that let you read a file in windows without loading the whole thing. Instead of asking Claude to read a 5,000-line file, start with the first 200 lines to understand the structure, then read specific sections by line range:

```
Read /path/to/large_codebase.py with offset=1 limit=200 # First 200 lines
Read /path/to/large_codebase.py with offset=800 limit=100 # Lines 800-900
```

This pattern is particularly useful when you need to understand a large class definition buried in the middle of a file, you can navigate to the exact line range without loading surrounding content.

## Extracting Relevant Sections with Ripgrep

Before handing a file to Claude, use `ripgrep` to extract only the sections you care about:

```bash
Get all function definitions in a Python file
rg "^def |^class " large_module.py

Get all TODO/FIXME comments
rg "TODO|FIXME|HACK" --line-number src/

Get lines matching a pattern with 5 lines of context
rg -C 5 "DatabaseError" application.log > errors_with_context.log
```

The resulting extracted file is typically 5–50x smaller than the original, fitting comfortably within the context window.

## Solution 4: Increase System Resources

Claude Code runs within your environment's memory constraints. If you're experiencing crashes:

1. Close other memory-intensive applications
2. Increase available RAM
3. Use a machine with more resources

For containerized environments, allocate more memory:

```yaml
docker-compose.yml
services:
 claude-code:
 mem_limit: 4g
 environment:
 - MAX_CONTEXT=200000
```

## Checking Memory Pressure Before Running Claude

On macOS, use the `memory_pressure` command to check available memory before starting a large-file session:

```bash
memory_pressure
Output: System-wide memory free percentage: 42%
```

On Linux, check available memory with `free`:

```bash
free -h
 total used free shared buff/cache available
Mem: 15Gi 9.2Gi 1.1Gi 512Mi 4.6Gi 5.8Gi
```

If the "available" column is under 2GB and you plan to process files larger than 1MB, close other applications first. Claude Code's Node.js runtime allocates heap memory aggressively, and running under memory pressure causes the OS to start swapping, which dramatically slows down or kills the process.

For long sessions processing many large files in sequence, restart Claude Code periodically to reclaim memory that was allocated for earlier files but not yet garbage-collected.

## Solution 5: Use Skill-Specific Optimizations

Different Claude skills handle large files in unique ways. Understanding these patterns helps prevent crashes:

## Using the xlsx Skill for Large Spreadsheets

The xlsx skill can process large Excel files efficiently by reading only necessary columns:

```python
import openpyxl

Load only specific columns to reduce memory
wb = openpyxl.load_workbook('large_dataset.xlsx', read_only=True)
ws = wb.active

Process data in chunks
for row in ws.iter_rows(min_row=1, max_row=1000, values_only=True):
 process(row)
```

For particularly large spreadsheets, the `read_only=True` flag is critical, without it, openpyxl loads the entire workbook into memory at once. In read-only mode it streams rows, keeping memory usage flat regardless of file size.

If you need to work with only specific columns, index them by header name to avoid loading irrelevant data:

```python
import openpyxl

def read_columns(filepath, column_names):
 """Read only specific columns from a large xlsx file."""
 wb = openpyxl.load_workbook(filepath, read_only=True)
 ws = wb.active

 # Find column indices from header row
 headers = [cell.value for cell in next(ws.iter_rows(min_row=1, max_row=1))]
 col_indices = {name: headers.index(name) for name in column_names if name in headers}

 results = []
 for row in ws.iter_rows(min_row=2, values_only=True):
 results.append({name: row[idx] for name, idx in col_indices.items()})

 wb.close()
 return results

Usage: only read the columns you need
data = read_columns("large_dataset.xlsx", ["customer_id", "amount", "date"])
```

## Using tdd for Code Analysis

When analyzing large codebases with the [tdd skill](/claude-tdd-skill-test-driven-development-workflow/), focus on specific modules rather than entire repositories. Break your analysis into targeted sessions:

```bash
Analyze specific directories
claude
claude
claude
```

A practical approach is to generate a file tree summary first, then let Claude identify which specific files to read for a given task, rather than reading everything upfront:

```bash
Generate a compact file tree (omit node_modules, .git, build dirs)
find . -type f -name "*.py" \
 | grep -v "__pycache__\|.git\|venv\|dist" \
 | sort > file_list.txt

Get line counts to identify large files
wc -l $(cat file_list.txt) | sort -rn | head -20
```

Hand this summary to Claude and ask it to identify the 3-5 files most relevant to the bug or feature you are working on. Reading targeted files instead of the whole codebase reduces context usage by 80-95% in a typical project.

## Using canvas-design for Large Assets

The canvas-design skill handles image assets differently. For large design files, work with optimized versions:

```javascript
// Use responsive image loading
const optimizedSrc = originalSrc.replace(/\.(png|jpg)$/, '_optimized.$1');
```

Before passing large images to Claude for analysis, pre-scale them to the minimum resolution needed for the task. A 6000x4000 pixel photograph exported at original resolution is unnecessary for visual analysis; a 1200x800 version conveys the same structural information in a fraction of the file size:

```bash
macOS: resize using sips (built-in)
sips -Z 1200 large_image.png --out preview_image.png

Linux / cross-platform: resize using ImageMagick
convert large_image.png -resize 1200x preview_image.png

Batch resize all PNG files in a directory
for f in *.png; do
 convert "$f" -resize 1200x "preview_${f}"
done
```

## Solution 6: Implement Pre-processing Pipelines

Create preprocessing scripts that extract relevant information before sending files to Claude:

```bash
#!/bin/bash
preprocess-logs.sh

Extract only ERROR and WARNING lines
grep -E "ERROR|WARN" large_logfile.log > filtered_errors.log

Extract last 1000 lines
tail -n 1000 large_logfile.log > recent_logfile.log

Extract lines matching pattern
grep "specific_pattern" large_codebase.js > matched_lines.js
```

This filtering reduces file size while preserving the information you need.

## A More Complete Pre-processing Pipeline

For production log analysis workflows, a multi-stage pipeline is more solid than a single grep command:

```bash
#!/bin/bash
full_preprocess.sh. prepare large log files for Claude analysis

SOURCE_LOG="$1"
OUTPUT_DIR="${2:-/tmp/claude_prep}"
MAX_LINES=2000

if [[ -z "$SOURCE_LOG" ]]; then
 echo "Usage: $0 <source_log> [output_dir]"
 exit 1
fi

mkdir -p "$OUTPUT_DIR"

Stage 1: Extract errors and warnings with context
echo "Stage 1: Extracting errors..."
grep -n -E "ERROR|FATAL|CRITICAL|WARN" "$SOURCE_LOG" \
 | head -n "$MAX_LINES" \
 > "$OUTPUT_DIR/errors.log"
echo " -> $(wc -l < "$OUTPUT_DIR/errors.log") error lines"

Stage 2: Extract unique stack trace signatures
echo "Stage 2: Extracting stack trace patterns..."
grep -E "^\s+at |Exception|Traceback" "$SOURCE_LOG" \
 | sort -u \
 | head -n 200 \
 > "$OUTPUT_DIR/stack_traces.log"
echo " -> $(wc -l < "$OUTPUT_DIR/stack_traces.log") unique stack frames"

Stage 3: Get a statistical summary
echo "Stage 3: Building summary..."
{
 echo "=== Log File Summary ==="
 echo "Source: $SOURCE_LOG"
 echo "Total lines: $(wc -l < "$SOURCE_LOG")"
 echo "File size: $(du -sh "$SOURCE_LOG" | cut -f1)"
 echo ""
 echo "=== Error Level Counts ==="
 grep -oE "ERROR|FATAL|CRITICAL|WARN|INFO|DEBUG" "$SOURCE_LOG" \
 | sort | uniq -c | sort -rn
 echo ""
 echo "=== First and Last Timestamps ==="
 head -1 "$SOURCE_LOG"
 tail -1 "$SOURCE_LOG"
} > "$OUTPUT_DIR/summary.txt"

echo ""
echo "Pre-processing complete. Files in $OUTPUT_DIR:"
ls -lh "$OUTPUT_DIR"
echo ""
echo "Feed summary.txt to Claude first, then errors.log for targeted analysis."
```

Running this script on a 200MB log file typically produces a `summary.txt` under 2KB and an `errors.log` under 100KB, both trivially small for Claude's context window.

## Solution 7: Use External Tools for Initial Processing

Before involving Claude, use dedicated tools for heavy lifting:

- Log analysis: Use `awk`, `sed`, or `grep` for filtering
- Data extraction: Use `jq` for JSON processing
- Code formatting: Use `prettier` or `eslint` to make code readable
- Image optimization: Use `imagemin` or `sharp` for images

The docx skill can help you document these workflows for team consistency.

## Practical jq Recipes for Large JSON Files

`jq` is indispensable for reducing large JSON files before passing them to Claude. Here are the most useful patterns:

```bash
Count items in a large JSON array without loading it all
jq 'length' large_array.json

Extract only specific fields from each object in an array
jq '[.[] | {id: .id, name: .name, status: .status}]' large_array.json > slim.json

Filter array to objects matching a condition
jq '[.[] | select(.status == "error")]' events.json > errors.json

Get a sample of 50 records from the beginning
jq '.[0:50]' large_array.json > sample.json

Get distinct values of a field (useful for understanding a dataset)
jq '[.[].category] | unique | sort' large_array.json

Summarize nested numeric fields
jq '{
 total: length,
 avg_amount: ([.[].amount] | add / length),
 max_amount: ([.[].amount] | max),
 min_amount: ([.[].amount] | min)
}' transactions.json
```

Run the summary jq command first to understand the shape and scale of your data. Then extract only the records and fields Claude needs for the specific task.

## Using awk for Structured Log Reduction

`awk` is faster than Python for line-oriented log processing and handles files of any size because it streams line-by-line:

```bash
Extract lines where response time exceeds 2000ms (field 8 in nginx log format)
awk '$8 > 2000 {print}' access.log > slow_requests.log

Summarize HTTP status codes
awk '{counts[$9]++} END {for (code in counts) print code, counts[code]}' \
 access.log | sort -k2 -rn

Extract a specific time window
awk '/2026-03-14T14:00/,/2026-03-14T15:00/' app.log > incident_window.log
```

The time-window extraction (`awk '/pattern1/,/pattern2/'`) is particularly useful for isolating the logs from a specific incident without needing to know exact line numbers.

## Solution 8: Monitor and Set Alerts

Implement monitoring to catch large file issues before they cause crashes:

```javascript
// Check file size before processing
const fs = require('fs');
const MAX_SIZE = 10 * 1024 * 1024; // 10MB

function safeRead(filepath) {
 const stats = fs.statSync(filepath);
 if (stats.size > MAX_SIZE) {
 throw new Error(`File too large: ${stats.size} bytes`);
 }
 return fs.readFileSync(filepath);
}
```

## A More Solid File Safety Wrapper

The basic check above throws an error on large files but does not offer an alternative. A more useful wrapper auto-splits the file and returns the first safe chunk with a warning:

```javascript
const fs = require('fs');
const readline = require('readline');

const SAFE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB hard limit
const WARN_SIZE_BYTES = 2 * 1024 * 1024; // 2MB soft warning
const MAX_LINES_PER_CHUNK = 2000;

async function safeReadForClaude(filepath) {
 const stats = fs.statSync(filepath);

 if (stats.size <= WARN_SIZE_BYTES) {
 // Small enough to read directly
 return { content: fs.readFileSync(filepath, 'utf8'), truncated: false };
 }

 if (stats.size > SAFE_SIZE_BYTES) {
 console.warn(
 `[safeReadForClaude] ${filepath} is ${(stats.size / 1024 / 1024).toFixed(1)}MB ` +
 `, reading first ${MAX_LINES_PER_CHUNK} lines only`
 );
 }

 // Stream first N lines
 const lines = [];
 const rl = readline.createInterface({
 input: fs.createReadStream(filepath),
 crlfDelay: Infinity
 });

 for await (const line of rl) {
 lines.push(line);
 if (lines.length >= MAX_LINES_PER_CHUNK) {
 rl.close();
 break;
 }
 }

 return {
 content: lines.join('\n'),
 truncated: true,
 originalSizeBytes: stats.size,
 linesReturned: lines.length
 };
}

// Usage
const result = await safeReadForClaude('/var/log/app.log');
if (result.truncated) {
 console.log(`Warning: file truncated. Showing ${result.linesReturned} of ${
 Math.round(result.originalSizeBytes / 1024)
 }KB`);
}
```

Integrate this wrapper into any tooling or scripts that pass files to Claude Code, and you will eliminate the most common category of unexpected crashes.

## Prevention Strategies

The best fix is prevention. Establish these practices:

1. Set file size limits in your Claude configuration
2. Use version control to track large asset files separately
3. Compress archives before processing
4. Document file handling procedures for your team
5. Test with sample data before processing production files

## Team-Wide File Handling Standards

If you are setting up Claude Code for a development team, document the file handling conventions in your project's `CLAUDE.md` (the project instructions file Claude reads automatically). Here is a template section:

```markdown
Working with Large Files

Before asking Claude to read any file, check its size:
- Under 200KB: safe to read directly
- 200KB–2MB: consider selective reading (specific line ranges or sections)
- Over 2MB: always pre-process first using the scripts in ./scripts/claude_prep/

Pre-processing scripts available
- `scripts/claude_prep/split_logs.sh <logfile>`. splits into hourly chunks
- `scripts/claude_prep/extract_errors.sh <logfile>`. extracts ERROR/WARN lines
- `scripts/claude_prep/slim_json.sh <jsonfile> <fields...>`. extracts specific fields

Files that are always too large to read directly
- `data/production_export_*.json`. use slim_json.sh first
- `logs/app-*.log`. use extract_errors.sh first
- `dist/bundle.min.js`. never feed minified bundles to Claude; use source maps instead
```

Documenting this in `CLAUDE.md` means Claude itself can reference these guidelines when helping teammates who are unfamiliar with the project's file sizes.

## When All Else Fails

If Claude continues crashing on large files:

- Restart the Claude session to clear memory
- Check for corrupted files that might cause parsing issues
- Verify your Claude Code installation is up to date
- Consider using the CLI version with more memory allocation

## Advanced Debugging Checklist

When the above tips still do not resolve the crashes, work through this checklist:

1. Verify the file is not corrupted. A truncated JSON file or a log file with null bytes can cause the parser to loop indefinitely rather than failing cleanly. Run `file your_file.log` to check file type detection and `wc -c your_file.log` to confirm the reported size matches expectations.

2. Check for encoding issues. Files with mixed encodings (UTF-8 plus Windows-1252 special characters) can cause read failures. Convert to clean UTF-8 first: `iconv -f ISO-8859-1 -t UTF-8 input.csv > output.csv`

3. Try the `--max-tokens` flag when invoking Claude Code from the CLI to reduce the output budget and leave more room in the total context for the file content.

4. Check Claude Code version. Run `claude --version` and compare to the latest release. File handling improvements are shipped frequently.

5. Use `--verbose` flag to see exactly where in the processing pipeline the crash occurs. This helps distinguish between a file-read failure, a context overflow, and a network timeout.

```bash
Run with verbose output to diagnose where the failure occurs
claude --verbose "analyze this log file" < filtered_errors.log
```

For teams, document your file handling patterns so everyone understands the limitations and best practices.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-crashes-on-large-files-how-to-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code Slow Response: How to Fix Latency Issues](/claude-code-slow-response-how-to-fix-latency-issues/). Companion guide covering latency and performance problems beyond just file-size crashes
- [Claude MD Too Long: Context Window Optimization](/claude-md-too-long-context-window-optimization/). Reduce the context footprint that causes file processing to fail
- [Claude SuperMemory Skill: Persistent Context Explained](/claude-supermemory-skill-persistent-context-explained/). Track insights across chunked file sessions without losing context between runs
- [Claude Skills Troubleshooting Hub](/troubleshooting-hub/). All troubleshooting guides for Claude Code performance and stability issues

Built by theluckystrike. More at [zovo.one](https://zovo.one)


