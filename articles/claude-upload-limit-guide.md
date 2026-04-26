---
layout: default
title: "Claude Upload Limit (2026)"
description: "Complete breakdown of Claude upload limits across web, API, and CLI. File sizes, supported types, page limits, and workarounds for large files."
permalink: /claude-upload-limit-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Upload Limit: File Size and Types (2026)

Claude handles file uploads differently depending on whether you are using Claude.ai (web), the API, or Claude Code (CLI). Each interface has its own limits for file size, file count, and supported types. This reference covers every limit, every supported format, and every workaround for when you hit a ceiling.

## Claude.ai (Web Interface) Upload Limits

The Claude.ai web interface is where most people encounter upload limits first. Here are the current constraints.

### File Size Limits

- **Maximum file size per file:** 30 MB
- **Maximum files per message:** 5 files
- **Total upload size per message:** limited by the combined token count of all files

Files larger than 30 MB are rejected at upload with an error message. There is no way to override this in the web interface.

### Supported File Types

Claude.ai accepts these file formats:

**Documents:**
- PDF (`.pdf`) — up to 100 pages on Pro plan, varies by plan
- Plain text (`.txt`)
- CSV (`.csv`)
- Markdown (`.md`)
- Code files (`.py`, `.js`, `.ts`, `.html`, `.css`, `.json`, `.yaml`, `.xml`, `.sql`, `.sh`, `.rb`, `.go`, `.rs`, `.java`, `.c`, `.cpp`, `.h`, and more)

**Spreadsheets:**
- Excel (`.xlsx`, `.xls`)
- CSV (`.csv`)

**Images:**
- JPEG (`.jpg`, `.jpeg`)
- PNG (`.png`)
- GIF (`.gif`)
- WebP (`.webp`)

**Not supported in web upload:**
- Video files (`.mp4`, `.mov`, `.avi`)
- Audio files (`.mp3`, `.wav`) — unless using a plan with audio features
- Executable files (`.exe`, `.app`)
- Archive files (`.zip`, `.tar.gz`) — must extract first

### PDF Specific Limits

PDFs are tokenized based on their text content. A dense 50-page PDF can consume a significant portion of the context window.

- **Page limit:** varies by plan (Free, Pro, Team, Enterprise)
- **Image-heavy PDFs:** each page image is processed as a vision input, consuming more tokens
- **Scanned PDFs:** Claude can read scanned text via OCR, but quality depends on scan resolution

### Image Resolution Limits

Images are resized before processing to fit within Claude's vision input constraints:

- **Maximum resolution processed:** 1568 x 1568 pixels (images are downscaled if larger)
- **Minimum useful resolution:** approximately 200 x 200 pixels for readable text
- **Aspect ratio:** preserved during resizing
- **Token cost:** approximately 1,600 tokens for a typical image

High-resolution screenshots and photos work well. Very small images or images with tiny text may lose detail after resizing.

## Claude API Upload Limits

The API gives you more control but has its own constraints.

### Image Uploads via API

Images are sent as base64-encoded data within the message body:

```python
import anthropic
import base64

client = anthropic.Anthropic()

with open("screenshot.png", "rb") as f:
    image_data = base64.standard_b64encode(f.read()).decode("utf-8")

message = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",
                        "data": image_data,
                    },
                },
                {
                    "type": "text",
                    "text": "Describe this image."
                }
            ],
        }
    ],
)
```

**API image limits:**
- **Supported formats:** JPEG, PNG, GIF, WebP
- **Maximum image size:** 20 MB per image (base64-encoded)
- **Maximum images per request:** 20 images
- **Resolution:** same 1568 x 1568 processing limit applies

### PDF Uploads via API

PDFs are supported through the document content type:

```python
import anthropic
import base64

client = anthropic.Anthropic()

with open("report.pdf", "rb") as f:
    pdf_data = base64.standard_b64encode(f.read()).decode("utf-8")

message = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4096,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "document",
                    "source": {
                        "type": "base64",
                        "media_type": "application/pdf",
                        "data": pdf_data,
                    },
                },
                {
                    "type": "text",
                    "text": "Summarize this document."
                }
            ],
        }
    ],
)
```

**API PDF limits:**
- **Maximum file size:** 32 MB
- **Maximum pages:** 100 pages per document
- **Token consumption:** each page consumes tokens based on text density and images

### Token Limits — The Real Constraint

Regardless of file size, the total content of uploaded files must fit within the model's context window:

- **Claude Sonnet/Opus:** 200,000 token context window
- **Claude Haiku:** 200,000 token context window

A single dense PDF can easily consume 50,000+ tokens. Multiple large files will hit the context limit before they hit any file size limit.

## Claude Code (CLI) File Handling

Claude Code does not have traditional upload limits because it reads files directly from your local filesystem. This changes the constraints significantly.

### No Upload Limit — Disk Access

Claude Code uses the Read tool to access files on disk. There is no 30 MB limit. There is no file count limit per message. Claude Code reads whatever you point it at.

```bash
# Claude Code can read any file on your system
claude "Read the file at /path/to/large-dataset.json and summarize it"
```

### Context Window Is the Real Limit

The constraint for Claude Code is the same 200,000-token context window. A 500 MB log file cannot be loaded into context all at once. However, Claude Code handles this intelligently:

- **Selective reading:** Claude Code reads specific line ranges rather than entire files
- **Chunked processing:** large files are read in sections
- **Grep-based search:** Claude Code can search files with regex before reading, pulling only relevant sections

### Large File Strategies in Claude Code

For codebases and data files that exceed the context window:

**Read specific sections:**
```
Read lines 1-100 of /path/to/large-file.log
```

**Search before reading:**
```
Search for "ERROR" in /path/to/large-file.log and show me the context
```

**Process in chunks:**
```
Read the first 500 lines of data.csv, then the next 500, and summarize patterns
```

This makes Claude Code the best option for working with large files. See the [Claude Code Playbook](/playbook/) for more strategies.

## Workarounds for Large Files

When you hit upload limits in Claude.ai or the API, these techniques help.

### Split Large PDFs

Break a PDF into smaller sections before uploading:

```bash
# Using pdftk (install with brew install pdftk-java)
pdftk large-report.pdf cat 1-50 output part1.pdf
pdftk large-report.pdf cat 51-100 output part2.pdf

# Using qpdf
qpdf --pages large-report.pdf 1-50 -- part1.pdf
qpdf --pages large-report.pdf 51-100 -- part2.pdf
```

Upload each part in a separate message, then ask Claude to synthesize.

### Extract Text from PDFs First

Converting a PDF to plain text reduces size dramatically and avoids page limits:

```bash
# Using pdftotext (install with brew install poppler)
pdftotext report.pdf report.txt

# Using Python
pip install PyPDF2
python3 -c "
import PyPDF2
reader = PyPDF2.PdfReader('report.pdf')
text = '\n'.join(page.extract_text() for page in reader.pages)
with open('report.txt', 'w') as f:
    f.write(text)
"
```

The resulting `.txt` file is usually 10-100x smaller than the PDF.

---

*This configuration is one of 200 production-ready templates in [The Claude Code Playbook](https://zovo.one/pricing). Permission configs, model selection rules, MCP setups — all tested and ready to copy.*

### Compress Images Before Upload

Reduce image file size while preserving enough quality for Claude's vision:

```bash
# Using ImageMagick
convert large-image.png -resize 1568x1568\> -quality 85 compressed.jpg

# Using sips on macOS
sips --resampleWidth 1568 large-image.png --out compressed.png
```

Since Claude downscales images to 1568 x 1568 anyway, pre-resizing wastes no quality and reduces upload time.

### Use Claude Code Instead of Web UI

For large codebases, switch from Claude.ai to Claude Code:

```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Navigate to your project and start
cd /path/to/large-project
claude
```

Claude Code reads from disk with no upload size limit. It searches and reads selectively, making it far more effective for large projects than uploading files through the web interface. See the [getting started guide](/claude-code-for-beginners-complete-getting-started-2026/) for initial setup.

### Chunk CSV and Excel Files

For large datasets, extract the relevant subset:

```bash
# First 1000 rows of a CSV
head -1001 large-data.csv > sample.csv

# Specific columns only
cut -d',' -f1,3,7 large-data.csv > subset.csv
```

Upload the subset and describe the full schema so Claude understands the complete structure.

## Upload Limits Comparison Table

| Feature | Claude.ai Web | Claude API | Claude Code CLI |
|---------|--------------|------------|-----------------|
| Max file size | 30 MB | 32 MB (PDF), 20 MB (image) | No limit (reads from disk) |
| Files per message | 5 | 20 images | No limit |
| PDF pages | Plan-dependent | 100 | No page limit |
| Image formats | JPEG, PNG, GIF, WebP | JPEG, PNG, GIF, WebP | All (reads bytes) |
| Document formats | PDF, TXT, CSV, XLSX, code | PDF, TXT (via text block) | All (reads text) |
| Context window | 200K tokens | 200K tokens | 200K tokens |
| Video/Audio | No | No | No native processing |

## Frequently Asked Questions

### Can I upload ZIP files to Claude?

Not directly. Claude.ai and the API do not process archive files. Extract the contents first and upload individual files. In Claude Code, you can ask it to run `unzip` or `tar` commands and then read the extracted files.

### What happens if I upload a file larger than 30 MB on Claude.ai?

The upload is rejected with an error before the file is sent. You will need to reduce the file size or switch to Claude Code.

### Does Claude count uploaded files against my usage limits?

Yes. File content is tokenized and counts toward your plan's token usage, the same as typed text. Large files consume proportionally more tokens.

### Can I upload multiple PDFs and ask Claude to compare them?

Yes, up to 5 files per message on Claude.ai. Upload both PDFs in the same message and ask for a comparison. On the API, include both as document content blocks in a single request.

### Why does my PDF upload fail even though it is under 30 MB?

The PDF may exceed the page limit for your plan, or the combined token count of the PDF plus your message may exceed the context window. Try extracting text first or splitting the PDF into sections.

### Is there a way to increase the upload limit?

Not on Claude.ai. The API has slightly higher limits (32 MB for PDFs). For truly large files, Claude Code is the recommended approach since it reads directly from your filesystem with no upload ceiling.

### Can Claude Code process video or audio files?

No. Neither Claude Code nor the API natively processes video or audio files. You would need to extract frames from video or transcribe audio before sending content to Claude.

### Is there a way to increase the 30 MB upload limit on Claude.ai?

No. The limit is fixed for the web interface. The API has slightly higher limits (32 MB for PDFs). For truly large files, Claude Code reads directly from your filesystem with no upload size limit.

### How many tokens does a typical image consume?

A typical image consumes approximately 1,600 tokens. High-resolution images that are downscaled to 1568x1568 pixels consume roughly the same amount regardless of original resolution.

### Can I upload multiple file types in the same message on Claude.ai?

Yes, you can mix file types in a single message, up to 5 files total. For example, you can upload a PDF and two images in the same message.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [The Claude Code Playbook](/playbook/) — comprehensive workflow reference
- [Claude Code Best Practices](/claude-code-claude-md-best-practices/) — optimize your setup
- [Claude Code Getting Started](/claude-code-for-beginners-complete-getting-started-2026/) — initial CLI setup
- [Claude Temperature Settings Guide](/claude-temperature-settings-guide/) — control output behavior
- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — reduce token consumption
- [Claude Code Configuration Hierarchy](/claude-code-configuration-hierarchy-explained-2026/) — understand settings precedence
- [Claude Code Security Best Practices](/claude-code-security-best-practices-2026/) — secure your workflow
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — extend capabilities with external tools
- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Large uploads affect token costs
- [save Claude Code conversations](/claude-code-save-conversation-guide/) — Save conversations with uploaded files

{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Can I upload ZIP files to Claude?", "acceptedAnswer": {"@type": "Answer", "text": "Not directly. Claude.ai and the API do not process archive files. Extract the contents first and upload individual files. In Claude Code, you can ask it to run unzip or tar commands."}},
    {"@type": "Question", "name": "What happens if I upload a file larger than 30 MB on Claude.ai?", "acceptedAnswer": {"@type": "Answer", "text": "The upload is rejected with an error before the file is sent. You will need to reduce the file size or switch to Claude Code."}},
    {"@type": "Question", "name": "Does Claude count uploaded files against my usage limits?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. File content is tokenized and counts toward your plan's token usage, the same as typed text. Large files consume proportionally more tokens."}},
    {"@type": "Question", "name": "Can I upload multiple PDFs and ask Claude to compare them?", "acceptedAnswer": {"@type": "Answer", "text": "Yes, up to 5 files per message on Claude.ai. Upload both PDFs in the same message and ask for a comparison."}},
    {"@type": "Question", "name": "Why does my PDF upload fail even though it is under 30 MB?", "acceptedAnswer": {"@type": "Answer", "text": "The PDF may exceed the page limit for your plan, or the combined token count of the PDF plus your message may exceed the context window."}},
    {"@type": "Question", "name": "Is there a way to increase the upload limit?", "acceptedAnswer": {"@type": "Answer", "text": "Not on Claude.ai. The API has slightly higher limits (32 MB for PDFs). For truly large files, Claude Code reads directly from your filesystem with no upload ceiling."}},
    {"@type": "Question", "name": "Can Claude Code process video or audio files?", "acceptedAnswer": {"@type": "Answer", "text": "No. Neither Claude Code nor the API natively processes video or audio files. You would need to extract frames from video or transcribe audio before sending content to Claude."}},
    {"@type": "Question", "name": "Is there a way to increase the 30 MB upload limit on Claude.ai?", "acceptedAnswer": {"@type": "Answer", "text": "No. The limit is fixed for the web interface. The API has slightly higher limits. For truly large files, Claude Code reads directly from your filesystem with no upload size limit."}},
    {"@type": "Question", "name": "How many tokens does a typical image consume?", "acceptedAnswer": {"@type": "Answer", "text": "A typical image consumes approximately 1,600 tokens. High-resolution images that are downscaled to 1568x1568 pixels consume roughly the same amount regardless of original resolution."}},
    {"@type": "Question", "name": "Can I upload multiple file types in the same message on Claude.ai?", "acceptedAnswer": {"@type": "Answer", "text": "Yes, you can mix file types in a single message, up to 5 files total. For example, you can upload a PDF and two images in the same message."}}
  ]
}
</script>

{% endraw %}