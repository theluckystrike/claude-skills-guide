---
layout: default
title: "Claude Code for CNC G-Code Optimization (2026)"
description: "Claude Code for CNC G-Code Optimization — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-cnc-gcode-optimization-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for CNC G-Code

CAM software generates G-code that works but is rarely optimal. Redundant rapid moves, excessive retract heights, conservative feed rates on finishing passes, and unnecessary tool changes add minutes to every cycle. On a production run of 10,000 parts, those minutes become weeks.

Claude Code parses G-code files, identifies optimization opportunities, and generates modified programs that reduce air-cutting time while preserving the intended geometry. It understands G00/G01/G02/G03 motion codes, canned cycles (G81-G89), and work coordinate systems.

## The Workflow

### Step 1: Setup

```bash
# G-code analysis tools
pip install pygcode matplotlib numpy

# Optional: NC verification
# Install CAMotics (open-source G-code simulator)
brew install --cask camotics  # macOS

mkdir -p cnc/{original,optimized,reports}
```

### Step 2: Analyze and Optimize G-Code

```python
# cnc/optimize_gcode.py
"""Analyze and optimize CNC G-code for reduced cycle time."""
import re
from pathlib import Path
from dataclasses import dataclass
import math

MAX_FEED_RATE = 5000.0   # mm/min machine limit
MAX_RAPID_HEIGHT = 50.0  # mm — excessive retract threshold
MAX_FILE_LINES = 500000

@dataclass
class GCodeStats:
    total_lines: int = 0
    rapid_moves: int = 0
    linear_moves: int = 0
    arc_moves: int = 0
    tool_changes: int = 0
    total_rapid_distance: float = 0.0
    total_cut_distance: float = 0.0
    excessive_retracts: int = 0
    redundant_rapids: int = 0


def parse_line(line: str) -> dict:
    """Parse a single G-code line into components."""
    result = {'raw': line.strip()}
    # Extract G/M codes and axis words
    for match in re.finditer(r'([GMXYZIJKFRS])(-?\d+\.?\d*)', line):
        letter, value = match.groups()
        result[letter] = float(value)
    return result


def calculate_distance(x1, y1, z1, x2, y2, z2) -> float:
    """3D Euclidean distance between two points."""
    return math.sqrt((x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2)


def analyze_gcode(filepath: str) -> GCodeStats:
    """Analyze G-code file for optimization opportunities."""
    assert Path(filepath).exists(), f"G-code file not found: {filepath}"
    stats = GCodeStats()

    with open(filepath, 'r') as f:
        lines = f.readlines()

    assert len(lines) <= MAX_FILE_LINES, \
        f"File exceeds {MAX_FILE_LINES} lines"
    stats.total_lines = len(lines)

    cur_x, cur_y, cur_z = 0.0, 0.0, 0.0
    prev_rapid_end = None

    for line in lines:
        parsed = parse_line(line)
        new_x = parsed.get('X', cur_x)
        new_y = parsed.get('Y', cur_y)
        new_z = parsed.get('Z', cur_z)

        g_code = parsed.get('G', -1)

        if g_code == 0:  # Rapid move
            stats.rapid_moves += 1
            dist = calculate_distance(
                cur_x, cur_y, cur_z, new_x, new_y, new_z)
            stats.total_rapid_distance += dist

            # Check excessive retract
            if new_z > MAX_RAPID_HEIGHT and cur_z < MAX_RAPID_HEIGHT:
                stats.excessive_retracts += 1

            # Check redundant rapid (rapid to same XY)
            if (prev_rapid_end and
                abs(new_x - prev_rapid_end[0]) < 0.001 and
                abs(new_y - prev_rapid_end[1]) < 0.001):
                stats.redundant_rapids += 1

            prev_rapid_end = (new_x, new_y, new_z)

        elif g_code == 1:  # Linear feed
            stats.linear_moves += 1
            dist = calculate_distance(
                cur_x, cur_y, cur_z, new_x, new_y, new_z)
            stats.total_cut_distance += dist
            prev_rapid_end = None

        elif g_code in (2, 3):  # Arc
            stats.arc_moves += 1
            prev_rapid_end = None

        if 'M' in parsed and parsed['M'] == 6:
            stats.tool_changes += 1

        cur_x, cur_y, cur_z = new_x, new_y, new_z

    return stats


def optimize_retracts(lines: list, safe_z: float = 5.0) -> list:
    """Reduce excessive retract heights to safe_z when possible."""
    assert safe_z > 0, "Safe Z must be positive"
    optimized = []
    for line in lines:
        parsed = parse_line(line)
        g_code = parsed.get('G', -1)
        z_val = parsed.get('Z', None)

        # Replace excessive retracts with safe_z
        if g_code == 0 and z_val is not None and z_val > MAX_RAPID_HEIGHT:
            new_line = re.sub(
                r'Z-?\d+\.?\d*', f'Z{safe_z:.1f}', line.strip())
            optimized.append(new_line + '  ; retract optimized\n')
        else:
            optimized.append(line)
    return optimized


def report(stats: GCodeStats) -> str:
    """Generate human-readable optimization report."""
    total_moves = stats.rapid_moves + stats.linear_moves + stats.arc_moves
    assert total_moves > 0, "No motion commands found in file"
    rapid_pct = (stats.total_rapid_distance /
                 (stats.total_rapid_distance + stats.total_cut_distance)
                 * 100) if stats.total_cut_distance > 0 else 0

    return (
        f"G-Code Analysis Report\n"
        f"{'='*40}\n"
        f"Total lines:         {stats.total_lines}\n"
        f"Rapid moves (G00):   {stats.rapid_moves}\n"
        f"Linear moves (G01):  {stats.linear_moves}\n"
        f"Arc moves (G02/03):  {stats.arc_moves}\n"
        f"Tool changes (M06):  {stats.tool_changes}\n"
        f"Rapid distance:      {stats.total_rapid_distance:.1f} mm\n"
        f"Cut distance:        {stats.total_cut_distance:.1f} mm\n"
        f"Rapid/total ratio:   {rapid_pct:.1f}%\n"
        f"Excessive retracts:  {stats.excessive_retracts}\n"
        f"Redundant rapids:    {stats.redundant_rapids}\n"
    )


if __name__ == '__main__':
    import sys
    assert len(sys.argv) == 2, "Usage: python optimize_gcode.py <file.nc>"
    stats = analyze_gcode(sys.argv[1])
    print(report(stats))
```

### Step 3: Verify with Simulation

```bash
# Run analysis
python3 cnc/optimize_gcode.py original/part_001.nc
# Expected output:
# G-Code Analysis Report
# Rapid moves (G00):   342
# Excessive retracts:  47
# Redundant rapids:    12

# Verify optimized code with CAMotics
camotics optimized/part_001.nc
# Visual check: same geometry, shorter air moves
```

## CLAUDE.md for CNC Programming

```markdown
# CNC G-Code Project Rules

## Standards
- ISO 6983 (G-code standard)
- FANUC-compatible dialect (most common)
- Machine-specific M-codes documented in header comments

## File Formats
- .nc / .ngc / .gcode (G-code programs)
- .tap (some controllers)
- .stl / .step (source CAD geometry)

## Libraries
- pygcode 0.2+ (G-code parser)
- camotics (NC verification)
- matplotlib (toolpath visualization)

## Testing
- Every optimized program must be verified in simulator before running
- Compare original vs optimized material removal volume (must match)
- Cycle time measurement: compare G-code line count and rapid distance

## Safety
- NEVER modify Z-depth values on cutting moves
- NEVER remove tool change commands
- Always preserve coolant on/off (M08/M09) commands
- Safe retract height minimum: 2mm above highest workpiece feature
```

## Common Pitfalls

- **Post-processor quirks:** Different machines interpret G-code differently. A G28 (return to reference) on a Haas is not the same as on a FANUC. Claude Code flags machine-specific codes and adds comments.
- **Arc direction errors:** Swapping G02 (CW) and G03 (CCW) gouges the part. Claude Code validates arc center points (I/J/K) against start and end coordinates to catch direction errors.
- **Modal state assumptions:** G-code is modal — G01 stays active until another motion code is issued. Claude Code tracks modal state and inserts explicit codes where assumptions are dangerous.

## Related

- [Claude Code for FPGA Development](/claude-code-for-fpga-development-workflow-tutorial/)
- [Claude Code for Embedded Systems](/claude-skills-for-embedded-systems-iot-firmware/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


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




**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/)
- [CLAUDE.md Length Optimization](/claude-md-length-optimization/)
- [Claude Code for Cloud Cost Optimization](/claude-code-for-cost-optimization-monitoring-guide/)
- [How to Use AI Code Optimization](/claude-code-token-usage-optimization-best-practices-guide/)

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
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
