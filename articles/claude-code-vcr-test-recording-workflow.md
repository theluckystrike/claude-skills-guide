---
layout: default
title: "Claude Code VCR Test Recording Workflow"
description: "Learn how to implement VCR-style test recording in Claude Code for reproducible AI interactions. Capture, replay, and verify AI-driven test scenarios."
date: 2026-03-14
categories: [guides]
tags: [claude-code, testing, vcr, test-automation, reproducibility]
author: theluckystrike
reviewed: false
score: 0
permalink: /claude-code-vcr-test-recording-workflow/
---

# Claude Code VCR Test Recording Workflow

Reproducible testing is the backbone of reliable AI-assisted development. When working with Claude Code, you often need to capture complex interactions, API calls, and tool executions to create deterministic test suites. The VCR (Video Cassette Recorder) pattern—historically used for HTTP recording in Ruby—has found new life in AI development workflows. This guide shows you how to implement a VCR-style test recording workflow that captures and replays Claude Code interactions with precision.

## Understanding the VCR Pattern for AI Testing

The VCR pattern records interactions between your code and external services, then replays those recordings during subsequent test runs. For Claude Code, this means capturing the entire conversation context, tool invocations, and responses to create replayable test fixtures.

When you integrate the VCR pattern with Claude Code, you gain several advantages:

- **Deterministic tests** that produce consistent results across CI/CD pipelines
- **Offline development** without API dependencies or rate limits
- **Faster test execution** by skipping actual API calls
- **Debugging capability** to step through recorded interactions

## Setting Up Your Test Recording Infrastructure

Begin by creating a dedicated skill that handles recording and playback. The skill uses file system operations to store interaction logs in a structured format.

```python
import json
import os
from datetime import datetime
from pathlib import Path

class ClaudeVCR:
    def __init__(self, cassette_dir="cassettes"):
        self.cassette_dir = Path(cassette_dir)
        self.cassette_dir.mkdir(exist_ok=True)
        self.current_recording = None
    
    def record(self, session_id: str, interaction: dict):
        """Record a single interaction to the cassette."""
        cassette_file = self.cassette_dir / f"{session_id}.jsonl"
        
        with open(cassette_file, "a") as f:
            f.write(json.dumps({
                "timestamp": datetime.utcnow().isoformat(),
                "interaction": interaction
            }) + "\n")
    
    def playback(self, session_id: str):
        """Retrieve all recorded interactions for a session."""
        cassette_file = self.cassette_dir / f"{session_id}.jsonl"
        
        if not cassette_file.exists():
            raise FileNotFoundError(f"Cassette {session_id} not found")
        
        interactions = []
        with open(cassette_file, "r") as f:
            for line in f:
                interactions.append(json.loads(line))
        
        return interactions
```

This Python class provides the foundation for your VCR system. Store it in your project as `claude_vcr.py` and integrate it with your test framework.

## Creating a Recording Skill

You can encapsulate the recording logic in a Claude skill for easier access. The skill uses the `pdf` skill to generate test reports and the `tdd` skill to structure your test cases properly.

```yaml
---
name: vcr-test-helper
description: "Helper skill for recording and replaying Claude Code test interactions"
tools: [read_file, write_file, bash, glob]
---

# VCR Test Helper Skill

This skill manages test recordings for Claude Code interactions.

## Recording Mode

When you need to capture a new test session:

1. Initialize a recording session with a unique identifier
2. Execute your test scenario normally
3. Each tool call and response gets automatically captured
4. Close the session to finalize the recording

The session ID should follow your naming convention: `{feature}-{timestamp}`

## Playback Mode

To replay a recording:

1. Load the cassette by session ID
2. Validate the recording structure
3. Iterate through stored interactions
4. Compare actual results against recorded expectations

## Best Practices

- Use descriptive session IDs that indicate the test scenario
- Include assertions in your test framework to validate replay accuracy
-定期清理旧的录制文件以节省存储空间
```

## Implementing the Test Workflow

With your infrastructure in place, implement a practical testing workflow. This example demonstrates recording a file processing task.

```python
import pytest
from claude_vcr import ClaudeVCR

vcr = ClaudeVCR(cassette_dir="tests/cassettes")

def test_file_processing_workflow():
    """Test recording for file processing workflow."""
    session_id = "file-processing-001"
    
    # Start recording
    vcr.start_recording(session_id)
    
    # Simulate Claude Code interaction
    interaction = {
        "prompt": "Process all CSV files in the data directory",
        "tools_called": [
            {"name": "glob", "pattern": "data/*.csv"},
            {"name": "read_file", "path": "data/users.csv"},
            {"name": "bash", "command": "python process.py"}
        ],
        "response": "Processed 150 records from 3 files"
    }
    
    vcr.record(session_id, interaction)
    
    # Playback for verification
    recordings = vcr.playback(session_id)
    
    assert len(recordings) == 1
    assert recordings[0]["interaction"]["tools_called"][0]["pattern"] == "data/*.csv"
```

## Advanced: Conditional Recording Modes

For more sophisticated testing, implement different recording modes that control when to record, replay, or use live calls.

```python
from enum import Enum

class RecordingMode(Enum):
    RECORD = "record"      # Always record new interactions
    PLAYBACK = "playback"  # Always use recorded interactions
    LIVE = "live"          # Always use live API calls
    NEW_episode = "new_episode"  # Record if no cassette exists

class SmartVCR(ClaudeVCR):
    def __init__(self, cassette_dir="cassettes", mode=RecordingMode.LIVE):
        super().__init__(cassette_dir)
        self.mode = mode
    
    def execute(self, session_id: str, interaction: dict):
        cassette_exists = (self.cassette_dir / f"{session_id}.jsonl").exists()
        
        if self.mode == RecordingMode.RECORD or \
           (self.mode == RecordingMode.NEW_episode and not cassette_exists):
            self.record(session_id, interaction)
            return {"mode": "recorded", "data": interaction}
        
        elif self.mode == RecordingMode.PLAYBACK or \
             (self.mode == RecordingMode.NEW_episode and cassette_exists):
            return {"mode": "playback", "data": self.playback(session_id)}
        
        else:  # LIVE mode
            return {"mode": "live", "data": interaction}
```

This approach integrates seamlessly with CI/CD pipelines. You can record new tests in development, switch to playback mode in CI, and use live mode for integration testing.

## Integrating with Claude Skills

The VCR workflow pairs well with other Claude skills. Use the `supermemory` skill to store test metadata and retrieval patterns. When debugging, invoke the `frontend-design` skill to visualize test coverage metrics.

For documentation generation, the `pdf` skill can export test reports from your cassettes. The `tdd` skill provides complementary guidance for structuring test-driven development workflows alongside your recording strategy.

## Managing Cassettes Effectively

Organize your cassettes using a clear directory structure:

```
tests/
└── cassettes/
    ├── api/
    │   ├── user-fetch-001.jsonl
    │   └── user-update-001.jsonl
    ├── file-processing/
    │   ├── csv-001.jsonl
    │   └── json-001.jsonl
    └── integration/
        └── full-workflow-001.jsonl
```

Implement cassette versioning by including a schema version in each recording:

```python
def record(self, session_id: str, interaction: dict):
    cassette_file = self.cassette_dir / f"{session_id}.jsonl"
    
    with open(cassette_file, "a") as f:
        f.write(json.dumps({
            "version": "1.0",
            "claude_version": "1.0.23",
            "timestamp": datetime.utcnow().isoformat(),
            "interaction": interaction
        }) + "\n")
```

## Conclusion

The VCR test recording workflow transforms Claude Code development from unpredictable to deterministic. By capturing interactions as reusable cassettes, you build a test suite that runs consistently without API dependencies or network constraints. Start with simple session recordings, then expand to conditional modes and cassette versioning as your testing needs mature.

The pattern works particularly well for regression testing, CI/CD pipelines, and debugging complex multi-step workflows. Combine it with skills like `tdd` for structured test development, `supermemory` for knowledge management, and `pdf` for generating comprehensive test reports.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
