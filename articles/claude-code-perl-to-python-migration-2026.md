---
layout: post
title: "Claude Code for Perl to Python (2026)"
description: "Migrate Perl scripts to Python with Claude Code. Automated translation, regex conversion, module mapping, and test generation workflow."
permalink: /claude-code-perl-to-python-migration-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Systematically migrate Perl scripts to Python using Claude Code for automated translation, preserving behavior with generated test suites. Covers regex conversion, CPAN-to-PyPI module mapping, and incremental migration strategy.

Expected time: 2-4 hours per 1000 lines of Perl
Prerequisites: Claude Code installed, Python 3.10+, existing Perl codebase, both perl and python interpreters available

## Setup

### 1. Create Migration Project Structure

```bash
mkdir -p perl-migration/{original,converted,tests,mappings}
cp -r /path/to/perl/scripts/* perl-migration/original/
cd perl-migration
```

### 2. Configure CLAUDE.md for Migration

```markdown
# CLAUDE.md

## Migration Rules
- Translate Perl idioms to Pythonic equivalents, not literal translations
- Perl hashes → Python dicts
- Perl arrays → Python lists
- Perl regex: convert /pattern/flags to re.compile(r'pattern', flags)
- Perl $_ → explicit variable names
- Perl `use strict; use warnings;` → Python type hints
- Always add type hints to function signatures
- Generate a requirements.txt for any PyPI packages needed
- Preserve all comments (translate if needed)
- File handling: open(my $fh, '<', $file) → with open(file) as fh:
- Error handling: eval { } → try/except with specific exceptions
- Output files go to ./converted/ directory
- Test files go to ./tests/ directory
```

### 3. Create Module Mapping Reference

```bash
cat > perl-migration/mappings/module-map.json << 'EOF'
{
  "LWP::UserAgent": "requests",
  "JSON": "json (stdlib)",
  "JSON::XS": "orjson",
  "DBI": "sqlalchemy or psycopg2",
  "DBD::Pg": "psycopg2",
  "DBD::mysql": "pymysql",
  "File::Find": "pathlib + os.walk",
  "File::Basename": "pathlib",
  "File::Path": "pathlib",
  "File::Slurp": "pathlib.read_text()",
  "Getopt::Long": "argparse",
  "POSIX": "os, sys, signal",
  "DateTime": "datetime",
  "Time::HiRes": "time.perf_counter()",
  "Carp": "logging + traceback",
  "Data::Dumper": "pprint",
  "Text::CSV": "csv (stdlib)",
  "XML::Simple": "xml.etree.ElementTree",
  "XML::LibXML": "lxml",
  "YAML": "pyyaml",
  "Moose": "dataclasses or pydantic",
  "Try::Tiny": "try/except",
  "List::Util": "functools, itertools",
  "Digest::MD5": "hashlib",
  "MIME::Base64": "base64",
  "Net::SMTP": "smtplib",
  "Socket": "socket"
}
EOF
```

## Usage Example

Migrate a Perl data processing script step by step:

Original Perl (`original/process_logs.pl`):

```perl
#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Find;
use JSON;
use POSIX qw(strftime);

my $dir = '/var/log';
my $pattern = '*.log';
my $output = 'report.json';
my $verbose = 0;

GetOptions(
    'dir=s'     => \$dir,
    'pattern=s' => \$pattern,
    'output=s'  => \$output,
    'verbose'   => \$verbose,
) or die "Invalid options\n";

my @files;
find(sub {
    push @files, $File::Find::name if /\Q$pattern\E$/;
}, $dir);

my %stats;
foreach my $file (@files) {
    open(my $fh, '<', $file) or do {
        warn "Cannot open $file: $!\n";
        next;
    };

    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^(\d{4}-\d{2}-\d{2})\s+(\w+)\s+(.+)$/) {
            my ($date, $level, $msg) = ($1, $2, $3);
            $stats{$level}++;
            $stats{by_date}{$date}{$level}++;

            if ($verbose && $level eq 'ERROR') {
                printf "[%s] %s: %s\n", $date, $file, $msg;
            }
        }
    }
    close($fh);
}

$stats{total_files} = scalar @files;
$stats{generated_at} = strftime("%Y-%m-%d %H:%M:%S", localtime);

my $json = JSON->new->pretty->encode(\%stats);
open(my $out, '>', $output) or die "Cannot write $output: $!\n";
print $out $json;
close($out);

print "Report written to $output\n";
print "Files processed: $stats{total_files}\n";
```

Claude Code produces this Python translation (`converted/process_logs.py`):

```python
#!/usr/bin/env python3
"""Log file processor — migrated from process_logs.pl."""

import argparse
import json
import re
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List


def find_log_files(directory: Path, pattern: str) -> List[Path]:
    """Find all files matching the glob pattern recursively."""
    return sorted(directory.rglob(pattern))


def parse_log_line(line: str) -> tuple[str, str, str] | None:
    """Extract date, level, and message from a log line."""
    match = re.match(r'^(\d{4}-\d{2}-\d{2})\s+(\w+)\s+(.+)$', line)
    if match:
        return match.group(1), match.group(2), match.group(3)
    return None


def process_files(
    files: List[Path],
    verbose: bool = False
) -> Dict:
    """Process log files and collect statistics."""
    stats: Dict = defaultdict(int)
    by_date: Dict[str, Dict[str, int]] = defaultdict(lambda: defaultdict(int))

    for filepath in files:
        try:
            with open(filepath, encoding='utf-8', errors='replace') as fh:
                for line in fh:
                    parsed = parse_log_line(line.rstrip('\n'))
                    if parsed is None:
                        continue

                    date, level, msg = parsed
                    stats[level] += 1
                    by_date[date][level] += 1

                    if verbose and level == 'ERROR':
                        print(f"[{date}] {filepath}: {msg}")

        except OSError as e:
            print(f"Cannot open {filepath}: {e}", file=sys.stderr)
            continue

    return {
        'levels': dict(stats),
        'by_date': {k: dict(v) for k, v in by_date.items()},
        'total_files': len(files),
        'generated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description='Process log files')
    parser.add_argument('--dir', type=Path, default=Path('/var/log'))
    parser.add_argument('--pattern', default='*.log')
    parser.add_argument('--output', type=Path, default=Path('report.json'))
    parser.add_argument('--verbose', action='store_true')
    args = parser.parse_args()

    if not args.dir.is_dir():
        print(f"Error: {args.dir} is not a directory", file=sys.stderr)
        sys.exit(1)

    files = find_log_files(args.dir, args.pattern)
    stats = process_files(files, verbose=args.verbose)

    args.output.write_text(json.dumps(stats, indent=2))

    print(f"Report written to {args.output}")
    print(f"Files processed: {stats['total_files']}")


if __name__ == '__main__':
    main()
```

Then generate the test file:

```python
# tests/test_process_logs.py
"""Tests for migrated process_logs module."""

import json
import tempfile
from pathlib import Path

import pytest

from converted.process_logs import find_log_files, parse_log_line, process_files


class TestParseLogLine:
    def test_valid_line(self):
        result = parse_log_line("2026-04-21 ERROR Something broke")
        assert result == ("2026-04-21", "ERROR", "Something broke")

    def test_valid_info_line(self):
        result = parse_log_line("2026-01-15 INFO Server started on port 8080")
        assert result == ("2026-01-15", "INFO", "Server started on port 8080")

    def test_invalid_line(self):
        assert parse_log_line("not a valid log line") is None

    def test_empty_line(self):
        assert parse_log_line("") is None


class TestFindLogFiles:
    def test_finds_log_files(self, tmp_path):
        (tmp_path / "app.log").write_text("test")
        (tmp_path / "error.log").write_text("test")
        (tmp_path / "readme.txt").write_text("test")

        results = find_log_files(tmp_path, "*.log")
        assert len(results) == 2

    def test_recursive_search(self, tmp_path):
        subdir = tmp_path / "subdir"
        subdir.mkdir()
        (subdir / "nested.log").write_text("test")

        results = find_log_files(tmp_path, "*.log")
        assert len(results) == 1


class TestProcessFiles:
    def test_counts_levels(self, tmp_path):
        log_content = "2026-04-21 ERROR fail\n2026-04-21 INFO ok\n2026-04-21 ERROR again\n"
        log_file = tmp_path / "test.log"
        log_file.write_text(log_content)

        stats = process_files([log_file])
        assert stats['levels']['ERROR'] == 2
        assert stats['levels']['INFO'] == 1
        assert stats['total_files'] == 1
```

Run validation:

```bash
# Run both and compare output
perl original/process_logs.pl --dir ./test-data --output /tmp/perl-out.json
python converted/process_logs.py --dir ./test-data --output /tmp/python-out.json

# Compare results
diff <(jq -S . /tmp/perl-out.json) <(jq -S . /tmp/python-out.json)
```

## Common Issues

- **Perl regex features not in Python:** Perl's `/e` flag (evaluate replacement) has no direct Python equivalent. Use `re.sub` with a lambda: `re.sub(pattern, lambda m: eval_replacement(m), text)`.
- **Perl autovivification behavior:** In Perl, `$hash{a}{b}++` creates intermediate keys automatically. In Python, use `defaultdict(lambda: defaultdict(int))` or check existence explicitly.
- **Different string handling:** Perl interpolates variables in double-quoted strings (`"Hello $name"`). Python requires f-strings (`f"Hello {name}"`). Claude Code handles this conversion automatically.

## Why This Matters

Perl codebases are increasingly difficult to maintain and hire for. Automated migration with Claude Code converts a 6-month manual rewrite into a 2-week project with generated tests proving behavioral equivalence.

## Related Guides

- [Using Claude Code to Learn New Programming Languages](/using-claude-code-to-learn-new-programming-languages/)
- [Best Way to Get Claude Code to Explain Existing Code](/best-way-to-get-claude-code-to-explain-existing-code/)
- [Claude Code for Test Driven Development Workflow](/claude-code-for-test-driven-development-workflow-tutorial/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.



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

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
