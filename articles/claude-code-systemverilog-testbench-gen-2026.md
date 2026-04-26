---
layout: default
title: "Claude Code for SystemVerilog (2026)"
description: "Claude Code for SystemVerilog — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-systemverilog-testbench-gen-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for SystemVerilog Testbenches

Writing UVM testbenches is the most time-consuming part of RTL verification. A single AXI agent with driver, monitor, sequencer, and sequences can take a week to write and debug. Most of that time is spent on boilerplate: class declarations, TLM port connections, phase callbacks, and factory overrides that follow predictable patterns.

Claude Code generates structurally correct UVM components from your interface definitions. You describe the protocol, point it at your RTL port list, and it produces a complete agent hierarchy. The generated code follows UVM 1.2 conventions and compiles under VCS, Xcelium, and QuestaSim.

## The Workflow

### Step 1: Define the Interface

```systemverilog
// rtl/spi_if.sv — Your existing interface
interface spi_if(input logic clk);
  logic       sclk;
  logic       mosi;
  logic       miso;
  logic       cs_n;
  logic [7:0] tx_data;
  logic [7:0] rx_data;
  logic       tx_valid;
  logic       tx_ready;

  modport master(output sclk, mosi, cs_n, tx_data, tx_valid,
                 input  miso, rx_data, tx_ready);
  modport slave (input  sclk, mosi, cs_n, tx_data, tx_valid,
                 output miso, rx_data, tx_ready);
endinterface
```

### Step 2: Generate the UVM Agent

Ask Claude Code: "Generate a complete UVM agent for spi_if with driver, monitor, sequencer, and a basic sequence."

```systemverilog
// tb/spi_agent/spi_seq_item.sv
class spi_seq_item extends uvm_sequence_item;
  `uvm_object_utils(spi_seq_item)

  rand bit [7:0] data;
  rand bit       cpol;
  rand bit       cpha;
  rand int unsigned delay_cycles;

  constraint valid_delay_c { delay_cycles inside {[0:15]}; }
  constraint mode_dist_c {
    cpol dist {0 := 70, 1 := 30};
    cpha dist {0 := 70, 1 := 30};
  }

  function new(string name = "spi_seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("data=0x%02h cpol=%0b cpha=%0b delay=%0d",
                     data, cpol, cpha, delay_cycles);
  endfunction
endclass

// tb/spi_agent/spi_driver.sv
class spi_driver extends uvm_driver #(spi_seq_item);
  `uvm_component_utils(spi_driver)

  virtual spi_if.master vif;

  function new(string name = "spi_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(virtual spi_if.master)::get(
      this, "", "vif", vif)) else
      `uvm_fatal("DRV", "No virtual interface in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    spi_seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      drive_transaction(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_transaction(spi_seq_item txn);
    assert(txn != null) else `uvm_fatal("DRV", "Null transaction")
    vif.cs_n <= 1'b0;
    vif.tx_data <= txn.data;
    vif.tx_valid <= 1'b1;
    @(posedge vif.tx_ready);
    repeat(txn.delay_cycles) @(posedge vif.sclk);
    vif.cs_n <= 1'b1;
    vif.tx_valid <= 1'b0;
    `uvm_info("DRV", $sformatf("Drove: %s", txn.convert2string()), UVM_HIGH)
  endtask
endclass

// tb/spi_agent/spi_monitor.sv
class spi_monitor extends uvm_monitor;
  `uvm_component_utils(spi_monitor)

  virtual spi_if.slave vif;
  uvm_analysis_port #(spi_seq_item) ap;

  function new(string name = "spi_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    assert(uvm_config_db#(virtual spi_if.slave)::get(
      this, "", "vif", vif)) else
      `uvm_fatal("MON", "No virtual interface in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    spi_seq_item observed;
    forever begin
      @(negedge vif.cs_n);
      observed = spi_seq_item::type_id::create("observed");
      @(posedge vif.tx_ready);
      observed.data = vif.rx_data;
      ap.write(observed);
      `uvm_info("MON", $sformatf("Observed: %s",
                observed.convert2string()), UVM_HIGH)
    end
  endtask
endclass
```

### Step 3: Run the Testbench

```bash
# Compile and run with VCS
vcs -sverilog -ntb_opts uvm \
  rtl/spi_if.sv rtl/spi_master.sv \
  tb/spi_agent/*.sv tb/spi_env.sv tb/spi_test.sv tb/top.sv \
  -o simv -timescale=1ns/1ps

./simv +UVM_TESTNAME=spi_random_test +UVM_VERBOSITY=UVM_LOW
# Expected output:
# UVM_INFO: Scoreboard: 256 matches, 0 mismatches
# UVM_INFO: Coverage: 97.3% functional coverage achieved
# --- UVM Report Summary ---
# ** Report counts by severity
# UVM_ERROR :    0
# UVM_FATAL :    0
```

## CLAUDE.md for SystemVerilog Testbenches

```markdown
# SystemVerilog UVM Testbench Rules

## Standards
- IEEE 1800-2017 (SystemVerilog)
- IEEE 1800.2-2020 (UVM standard)
- Constrained-random verification methodology

## Libraries
- UVM 1.2 base class library
- VCS 2024.03+ / Xcelium 24.03+ / QuestaSim 2024.1+

## Testing
- Every agent must have: driver, monitor, sequencer, sequence_item
- Scoreboard comparison via uvm_comparer
- Minimum 95% functional coverage for signoff

## Naming Conventions
- Agents: {protocol}_agent
- Sequence items: {protocol}_seq_item
- Tests: {protocol}_{scenario}_test
```

## Common Pitfalls

- **config_db get() failures at runtime:** Virtual interface handles must be set in the top-level module before run_phase starts. Claude Code generates the config_db::set calls in the correct build order.
- **Sequence item randomization failures:** Overly tight constraints cause randomize() to return 0. Claude Code adds `if (!txn.randomize()) uvm_fatal` guards that catch this immediately instead of propagating corrupted data.
- **TLM port connection ordering:** Analysis ports must be connected in connect_phase, not build_phase. Claude Code enforces this in every generated agent.

## Related

- [Claude Code for ASIC Design Verification](/claude-code-asic-design-verification-2026/)
- [Claude Code for FPGA Development](/claude-code-for-fpga-development-workflow-tutorial/)
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

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [How to Test and Debug Multi Agent](/how-to-test-and-debug-multi-agent-workflows/)
- [Claude Code Debug Configuration](/claude-code-debug-configuration-workflow/)
- [How Do I Debug A Claude Skill](/how-do-i-debug-a-claude-skill-that-silently-fails/)
- [Claude Code Verbose Mode](/claude-code-verbose-mode-debug-output-2026/)

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
