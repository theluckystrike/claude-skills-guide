---
layout: default
title: "How to Use Claude Batch API"
description: "Use the Claude batch API with Claude Code skills for efficient bulk processing. Reduce costs and automate repetitive tasks at scale."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, batch-processing, automation, workflow]
reviewed: true
score: 9
permalink: /claude-code-batch-processing-with-skills-guide/
geo_optimized: true
---

# Claude Code Batch Processing with Skills Guide

Claude Code skills transform how developers handle repetitive tasks. Instead of processing files one at a time, you can chain skills together to handle batch operations across entire directories. This guide shows you how to build efficient batch processing workflows using Claude skills. For multi-agent approaches to parallel workloads, see [fan-out fan-in pattern with Claude Code subagents](/fan-out-fan-in-pattern-claude-code-subagents/).

## How Batch Processing Works with Skills

Skills in Claude Code are Markdown files containing specialized instructions. When you invoke a skill, Claude loads its context and applies that expertise to your current task. For batch processing, you combine skill invocation with shell commands or scripting to iterate over multiple files.

The key is understanding that skills don't execute loops themselves. they guide Claude's behavior while you provide the iteration mechanism through bash or scripts. This separation keeps your workflows flexible and debuggable.

Think of it like a chef and a kitchen assistant. The skill is the chef's expertise. knowledge of technique, what good output looks like, what mistakes to avoid. The shell script is the assistant who hands files to the chef one at a time. Neither can do the other's job well, but together they produce consistent, high-quality results at scale.

This architecture also makes debugging straightforward. When a batch job produces unexpected output for a specific file, you can reproduce the failure by running the claude invocation for just that file in isolation, without the loop. You see exactly what Claude received as input and can trace the issue without rerunning the entire batch.

## Setting Up Batch Processing

Create a working directory for your batch operations:

```
~/batch-projects/
 process/
 input/
 output/
 scripts/
```

Initialize your Claude session with the skills you need. For example, if processing design files, load the frontend-design skill alongside your processing script:

```
/frontend-design
```

Before running any batch job, it's worth writing a dry-run mode into your scripts. A dry-run lists what will be processed without actually calling Claude. This catches path errors, missing files, and glob pattern mistakes before you burn API credits or overwrite output files.

```bash
#!/bin/bash
Add --dry-run flag support to any batch script
DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true

for file in ./input/*.md; do
 if $DRY_RUN; then
 echo "[DRY RUN] Would process: $file"
 else
 # actual processing here
 echo "Processing: $file"
 fi
done
```

Running `./batch-process.sh --dry-run` before the real job catches 90% of configuration mistakes with zero cost.

## Processing Multiple Files with Skill Chains

The most common batch pattern involves iterating through files and applying skill-guided transformations. Here's a practical example processing markdown files for a documentation site:

```bash
#!/bin/bash
batch-process-docs.sh

INPUT_DIR="./docs"
OUTPUT_DIR="./processed"
mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.md; do
 filename=$(basename "$file")
 echo "Processing: $filename"

 # Use claude to process each file with skill guidance
 claude -p "Apply the documentation skill to improve this markdown file.
- Fix heading hierarchy
- Add appropriate code block language tags
- Ensure links are properly formatted

$(cat "$file")" > "$OUTPUT_DIR/$filename"
done
```

This script uses Claude in headless mode (`-p` flag) to process each file. The documentation improvement happens through skill guidance, not manual editing.

One important detail: the `$(cat "$file")` approach works for small files but becomes unwieldy for large ones. For files over 50 KB, pass the file path and instruct Claude to read it directly:

```bash
claude -p "Apply the documentation skill to improve the markdown file at $file.
- Fix heading hierarchy
- Add appropriate code block language tags
- Ensure links are properly formatted
Read the file contents yourself and write the improved version."
```

This avoids shell argument length limits and keeps the prompt readable.

## PDF Batch Processing Example

The pdf skill handles batch document operations efficiently. Process multiple PDFs for extraction or conversion:

```bash
#!/bin/bash
batch-extract-pdf.sh

PDF_DIR="./invoices"
OUTPUT_DIR="./extracted"
mkdir -p "$OUTPUT_DIR"

for pdf in "$PDF_DIR"/*.pdf; do
 filename=$(basename "$pdf" .pdf)

 claude -p "Using the pdf skill, extract all text content from this invoice: $pdf
Return the data as JSON with keys: invoice_number, date, total, line_items."

done > "$OUTPUT_DIR/all_invoices.json"
```

This extracts structured data from multiple invoices in one run. The pdf skill understands document structure and applies consistent extraction logic across files.

However, piping all output to a single file the way this script does concatenates raw JSON objects without separators, which produces invalid JSON. A better approach writes one file per invoice, then merges them:

```bash
#!/bin/bash
batch-extract-pdf-fixed.sh

PDF_DIR="./invoices"
OUTPUT_DIR="./extracted"
mkdir -p "$OUTPUT_DIR"

for pdf in "$PDF_DIR"/*.pdf; do
 filename=$(basename "$pdf" .pdf)
 output_file="$OUTPUT_DIR/${filename}.json"

 # Skip already-processed files
 if [[ -f "$output_file" ]]; then
 echo "Already done: $filename, skipping"
 continue
 fi

 echo "Extracting: $filename"
 claude -p "Using the pdf skill, extract all text content from this invoice: $pdf
Return ONLY valid JSON with keys: invoice_number, date, total, line_items.
No markdown, no explanation, just the JSON object." > "$output_file"
done

Merge all JSON files into an array
echo "[" > "$OUTPUT_DIR/all_invoices.json"
first=true
for f in "$OUTPUT_DIR"/*.json; do
 [[ "$f" == "$OUTPUT_DIR/all_invoices.json" ]] && continue
 $first || echo "," >> "$OUTPUT_DIR/all_invoices.json"
 cat "$f" >> "$OUTPUT_DIR/all_invoices.json"
 first=false
done
echo "]" >> "$OUTPUT_DIR/all_invoices.json"
echo "Merged all invoices into all_invoices.json"
```

The skip logic (`if [[ -f "$output_file" ]]`) is valuable for large batch jobs that may need to be interrupted and resumed without reprocessing completed files.

## Code Transformation with Multiple Skills

Combine skills for complex batch transformations. This example uses the tdd skill together with a refactoring prompt:

```bash
#!/bin/bash
batch-add-tests.sh

SRC_DIR="./src"
TEST_DIR="./tests"
mkdir -p "$TEST_DIR"

for file in "$SRC_DIR"/*.js; do
 filename=$(basename "$file" .js)
 test_file="$TEST_DIR/${filename}.test.js"

 echo "Adding tests to: $file"

 claude -p "Apply the tdd skill to generate unit tests for this file, then
ensure the implementation passes all tests and follows clean code principles.
File: $file

$(cat "$file")

Write only the test file content, no explanation." > "$test_file"
done
```

The tdd skill generates appropriate test cases while the refactoring guidance ensures the implementation meets quality standards. Running both in the prompt produces tested, clean code.

For TypeScript codebases, extend this pattern to also generate type declarations:

```bash
#!/bin/bash
batch-add-types.sh

SRC_DIR="./src"

for file in "$SRC_DIR"/*.js; do
 filename=$(basename "$file" .js)
 ts_file="${SRC_DIR}/${filename}.ts"

 echo "Adding types to: $file"

 claude -p "Convert this JavaScript file to TypeScript.
Add proper type annotations to all function parameters, return types, and variables.
Preserve all existing logic exactly. change only the types, not the behavior.

$(cat "$file")

Output only the TypeScript source, no explanation." > "$ts_file"
done
```

Running the type-generation pass before the test-generation pass means your tdd invocations work with typed files, which produces more accurate test signatures.

## Automating Documentation Generation

The docs skill paired with batch scripts automates documentation across codebases:

```bash
#!/bin/bash
generate-docs.sh

COMPONENTS=(
 "Button"
 "Modal"
 "Dropdown"
 "DatePicker"
)

for component in "${COMPONENTS[@]}"; do
 claude -p "Generate component documentation for this file.
Include: props table, usage examples, and type signatures.

$(cat "./components/$component.js")"
done > "./docs/components.md"
```

This processes multiple component files and aggregates the documentation into a single file.

For larger projects, generating a table of contents entry alongside each component's documentation makes the output immediately usable:

```bash
#!/bin/bash
generate-full-docs.sh

COMPONENTS_DIR="./components"
DOCS_FILE="./docs/components.md"
TOC_FILE="./docs/toc.md"

echo "# Component Documentation" > "$DOCS_FILE"
echo "# Table of Contents" > "$TOC_FILE"

for file in "$COMPONENTS_DIR"/*.js; do
 component=$(basename "$file" .js)
 anchor=$(echo "$component" | tr '[:upper:]' '[:lower:]')

 echo "- [$component](#$anchor)" >> "$TOC_FILE"

 echo "" >> "$DOCS_FILE"
 echo "---" >> "$DOCS_FILE"

 claude -p "Generate documentation for this React component.
Format:
1. One-sentence description
2. Props table (prop | type | default | description)
3. Two usage examples
4. Any important notes about behavior

$(cat "$file")" >> "$DOCS_FILE"
done

Prepend TOC to the docs file
cat "$TOC_FILE" "$DOCS_FILE" > "$DOCS_FILE.tmp" && mv "$DOCS_FILE.tmp" "$DOCS_FILE"
echo "Documentation generated: $DOCS_FILE"
```

The result is a single-file component reference that's ready to publish without manual assembly.

## Memory-Augmented Batch Processing

The [supermemory skill enhances batch processing](/claude-supermemory-skill-persistent-context-explained/) by maintaining context across iterations. When processing related files, this prevents redundant work:

```
/supermemory Remember: processing all API endpoint files in ./src/api/ for documentation generation
```

The skill tracks what has been processed and what still needs attention, making large batch jobs more efficient.

Memory augmentation becomes particularly valuable when batch jobs span multiple Claude sessions. If you stop a batch job midway and resume it the next day, the supermemory skill can recall which files were already processed, what patterns appeared frequently, and which edge cases needed special handling. Without this, you either reprocess everything or maintain a separate tracking file.

## Progress Tracking for Long Batch Jobs

For batch jobs with hundreds of files, progress visibility matters. A simple progress tracker adds minimal overhead:

```bash
#!/bin/bash
batch-with-progress.sh

FILES=(./input/*.md)
TOTAL=${#FILES[@]}
DONE=0
FAILED=0
START_TIME=$(date +%s)

for file in "${FILES[@]}"; do
 DONE=$((DONE + 1))
 ELAPSED=$(( $(date +%s) - START_TIME ))
 ETA=$(( ELAPSED * TOTAL / DONE - ELAPSED ))

 printf "\r[%d/%d] ETA: %ds | Processing: %-40s" \
 "$DONE" "$TOTAL" "$ETA" "$(basename "$file")"

 if ! claude -p "Process this file: $(cat "$file")" > "output/$(basename "$file")" 2>/dev/null; then
 FAILED=$((FAILED + 1))
 echo "$(basename "$file")" >> failed.log
 fi
done

echo ""
echo "Done. $DONE processed, $FAILED failed."
[[ $FAILED -gt 0 ]] && echo "Failed files logged in failed.log"
```

The ETA calculation gives you a realistic sense of when to come back, which is useful for overnight runs where you want to know if the job will finish before your morning standup.

## Performance Optimization Tips

Batch processing with skills runs faster when you optimize the workflow:

Parallel processing: Use GNU parallel or xargs for concurrent operations:

```bash
ls *.json | xargs -P 4 -I {} bash process-one.sh {}
```

With `xargs -P 4`, four Claude invocations run simultaneously. The optimal parallelism depends on your API rate limits. if you're on a plan that allows 10 requests per minute, running 4 concurrent workers with a modest file count may finish faster than running 1 at a time but still stay under limits.

Reduce skill reloads: Group similar files together to minimize context switching between different skills. If your batch job processes both JavaScript and Python files, process all the JavaScript files first (under one skill context) then all the Python files, rather than alternating between them.

Pre-filter files: Use find or glob patterns to process only relevant files:

```bash
find . -name "*.ts" -newer last-run.txt -exec process.sh {} \;
```

The `-newer last-run.txt` flag processes only files modified after your last run. Combine this with `touch last-run.txt` at the end of each successful batch run to make incremental processing automatic.

Checkpoint frequently: For long-running batches, write a checkpoint file after every N files:

```bash
CHECKPOINT_FILE="./batch-checkpoint.txt"
CHECKPOINT_INTERVAL=10
PROCESSED=0

for file in ./input/*.md; do
 # ... process file ...
 PROCESSED=$((PROCESSED + 1))

 if (( PROCESSED % CHECKPOINT_INTERVAL == 0 )); then
 echo "$file" > "$CHECKPOINT_FILE"
 echo "Checkpoint saved at: $file"
 fi
done
```

On resume, read the checkpoint to skip already-processed files:

```bash
RESUME_FROM=""
[[ -f "$CHECKPOINT_FILE" ]] && RESUME_FROM=$(cat "$CHECKPOINT_FILE")
SKIP=true

for file in ./input/*.md; do
 if [[ -n "$RESUME_FROM" ]] && $SKIP; then
 [[ "$file" == "$RESUME_FROM" ]] && SKIP=false
 continue
 fi
 # ... process file ...
done
```

## Error Handling in Batch Jobs

Always implement proper error handling:

```bash
#!/bin/bash

LOG_FILE="batch-errors.log"
SUCCESS=0
FAILURE=0

for file in ./*.md; do
 OUTPUT="processed/$file"
 if claude -p "Process this file: $(cat "$file")" > "$OUTPUT" 2>&1; then
 echo "Success: $file"
 SUCCESS=$((SUCCESS + 1))
 else
 echo "Failed: $file" | tee -a "$LOG_FILE"
 FAILURE=$((FAILURE + 1))
 # Optionally remove partial output
 rm -f "$OUTPUT"
 fi
done

echo "Batch complete: $SUCCESS succeeded, $FAILURE failed"
[[ $FAILURE -gt 0 ]] && echo "See $LOG_FILE for details" && exit 1
exit 0
```

Review errors.log after completion to identify files requiring manual attention.

Beyond logging, consider categorizing failures. Some failures are transient (rate limit hit, network timeout) and will succeed if retried. Others are structural (malformed input file, unsupported format) and need manual intervention. A retry loop handles the first category automatically:

```bash
#!/bin/bash
process-with-retry.sh

MAX_RETRIES=3
file="$1"
output="$2"

for attempt in $(seq 1 $MAX_RETRIES); do
 if claude -p "Process: $(cat "$file")" > "$output"; then
 echo "Success on attempt $attempt: $file"
 exit 0
 fi
 echo "Attempt $attempt failed for $file, retrying in 5s..."
 sleep 5
done

echo "PERMANENT FAILURE after $MAX_RETRIES attempts: $file" >> permanent-failures.log
exit 1
```

Call this script from your outer loop instead of calling claude directly. It absorbs transient failures transparently and only escalates genuinely broken files.

## Real-World Use Cases

Batch processing with skills excels in several scenarios:

- Legacy code modernization: Process hundreds of files to add TypeScript types using the tdd skill with type-checking prompts
- Content migration: Transform CMS exports using docs and formatting skills
- Test coverage expansion: Apply tdd skill across entire codebases
- Design system updates: Batch update component props with frontend-design guidance

A few additional scenarios worth highlighting for developer teams:

API contract generation: Given a directory of controller files, generate OpenAPI spec entries for each endpoint. Skills trained on API documentation formats produce consistent, accurate specs that align with the actual implementation rather than drifting out of sync.

Commit message standardization: For repos with inconsistent commit history, batch-process git log output through a skill that rewrites messages to follow Conventional Commits format. Useful before publishing an open-source project or generating changelogs.

Localization string extraction: Scan source files for hardcoded UI strings, extract them with their context, and generate the initial entries for a localization file. A skill that understands your UI framework produces better extraction than a naive regex approach.

Security audit triage: Pass source files through a skill trained on OWASP patterns to flag potential vulnerabilities for human review. This doesn't replace a proper security audit, but it catches common patterns quickly across large codebases.

## Conclusion

Claude Code skills combined with shell scripting create powerful batch processing capabilities. Start with simple single-skill workflows, then combine multiple skills for complex transformations. The key is separating iteration logic (bash) from transformation expertise (skills). this keeps your pipelines maintainable and scalable.

Invest time in dry-run modes, progress tracking, and retry logic early. These patterns add maybe 20 lines to your script but eliminate the frustration of discovering a batch job failed silently halfway through. With solid infrastructure around the Claude invocation, batch processing scales from a handful of files to thousands without changing your core approach.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-batch-processing-with-skills-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code Agent Pipeline: Sequential vs Parallel Execution](/claude-code-agent-pipeline-sequential-vs-parallel/). Understand when to run batch jobs sequentially versus in parallel for maximum throughput
- [Rate Limit Management for Claude Code Skill-Intensive Workflows](/rate-limit-management-claude-code-skill-intensive-workflows/). Avoid hitting API rate limits when running large batch processing jobs
- [Fan-Out Fan-In Pattern with Claude Code Subagents](/fan-out-fan-in-pattern-claude-code-subagents/). Distribute batch workloads across multiple subagents and collect results
- [Claude Skills Hub](/workflows/). Explore automation workflows and batch processing patterns with Claude Code
- [Claude Code Skills for Insurance Claims Processing](/claude-code-skills-for-insurance-claims-processing/)
- [Claude Skills for Medical Records Processing — Automate CPT Code Mapping, FHIR Validation, and Clini](/claude-skills-for-medical-records-processing/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


