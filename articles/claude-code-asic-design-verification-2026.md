---
title: "Claude Code for ASIC Design"
description: "ASIC design verification workflow with Claude Code. Generate UVM testbenches and coverage models faster."
permalink: /claude-code-asic-design-verification-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for ASIC Design Verification

ASIC verification consumes 60-70% of total chip development time. Engineers spend weeks writing UVM testbenches, building coverage models, and tracking down corner-case bugs in RTL that only appear after millions of simulation cycles. The verification gap keeps growing as designs hit billions of gates.

Claude Code understands SystemVerilog, UVM class hierarchies, and constrained-random methodology well enough to scaffold testbench components, generate functional coverage bins, and help trace assertion failures back through the design hierarchy. This does not replace your verification plan, but it cuts the boilerplate that eats your schedule.

## The Workflow

### Step 1: Project Setup

```bash
# Typical ASIC verification environment
pip install cocotb cocotb-bus cocotb-coverage
# Or use commercial: Synopsys VCS, Cadence Xcelium, Siemens QuestaSim
# Ensure simulator is on PATH
which vcs xrun vsim 2>/dev/null || echo "Using cocotb for open-source flow"

# Project structure
mkdir -p rtl tb/uvm_env tb/sequences tb/tests sim coverage
```

### Step 2: Generate a UVM Testbench Skeleton

Claude Code can produce UVM components that follow your team's class naming and port conventions. Here is the kind of environment scaffold it generates:

```systemverilog
// tb/uvm_env/axi_scoreboard.sv
// Generated with Claude Code assistance
class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)

  uvm_tlm_analysis_fifo #(axi_transaction) expected_fifo;
  uvm_tlm_analysis_fifo #(axi_transaction) actual_fifo;

  int unsigned match_count;
  int unsigned mismatch_count;

  function new(string name = "axi_scoreboard", uvm_component parent);
    super.new(name, parent);
    assert(name.len() > 0) else `uvm_fatal("SCB", "Empty scoreboard name")
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    expected_fifo = new("expected_fifo", this);
    actual_fifo   = new("actual_fifo", this);
    assert(expected_fifo != null) else `uvm_fatal("SCB", "FIFO alloc failed")
  endfunction

  task run_phase(uvm_phase phase);
    axi_transaction exp_txn, act_txn;
    forever begin
      expected_fifo.get(exp_txn);
      actual_fifo.get(act_txn);
      if (exp_txn.compare(act_txn)) begin
        match_count++;
        `uvm_info("SCB", $sformatf("Match #%0d: addr=0x%08h",
                  match_count, exp_txn.addr), UVM_MEDIUM)
      end else begin
        mismatch_count++;
        `uvm_error("SCB", $sformatf("Mismatch #%0d at addr=0x%08h",
                   mismatch_count, exp_txn.addr))
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info("SCB", $sformatf("Results: %0d matches, %0d mismatches",
              match_count, mismatch_count), UVM_LOW)
    assert(mismatch_count == 0) else
      `uvm_fatal("SCB", "Verification FAILED: mismatches detected")
  endfunction
endclass
```

### Step 3: Build Functional Coverage

Coverage closure is where schedules slip. Claude Code generates covergroups tied to your verification plan:

```systemverilog
// tb/uvm_env/axi_coverage.sv
class axi_coverage extends uvm_subscriber #(axi_transaction);
  `uvm_component_utils(axi_coverage)

  covergroup axi_cg with function sample(axi_transaction txn);
    burst_type_cp: coverpoint txn.burst_type {
      bins fixed  = {FIXED};
      bins incr   = {INCR};
      bins wrap   = {WRAP};
    }
    burst_len_cp: coverpoint txn.burst_len {
      bins short_burst  = {[0:3]};
      bins medium_burst = {[4:15]};
      bins max_burst    = {[16:255]};
    }
    addr_align_cp: coverpoint txn.addr[3:0] {
      bins aligned   = {4'h0};
      bins unaligned = {[4'h1:4'hF]};
    }
    // Cross coverage catches interactions
    burst_x_align: cross burst_type_cp, addr_align_cp;
  endgroup

  function new(string name = "axi_coverage", uvm_component parent);
    super.new(name, parent);
    axi_cg = new();
  endfunction

  function void write(axi_transaction t);
    axi_cg.sample(t);
  endfunction
endclass
```

### Step 4: Run Simulation and Check Coverage

```bash
# Using Synopsys VCS
vcs -sverilog -ntb_opts uvm -f filelist.f -o simv
./simv +UVM_TESTNAME=axi_random_test +UVM_VERBOSITY=UVM_MEDIUM
# Check coverage
urg -dir simv.vdb -report coverage_report
# Expected: functional coverage > 95%, zero UVM_ERROR

# Or using cocotb (open-source)
cd sim && make SIM=verilator TOPLEVEL=axi_top MODULE=test_axi_basic
```

## CLAUDE.md for ASIC Verification

```markdown
# ASIC Verification Project Rules

## Standards
- UVM 1.2 methodology (IEEE 1800.2-2020)
- SystemVerilog IEEE 1800-2017
- All assertions use immediate assert with `uvm_fatal on failure

## File Formats
- .sv for SystemVerilog RTL and testbench
- .svh for UVM class headers
- .f for file lists
- .ucdb / .vdb for coverage databases

## Libraries
- UVM 1.2 base classes
- cocotb 1.9+ (open-source alternative)
- cocotb-coverage 1.2+
- pyuvm 2.9+ (Python UVM)

## Testing
- Constrained-random with directed sequences for corner cases
- Coverage-driven: must hit 95% functional coverage before tapeout
- Regression suite runs nightly on compute farm

## Naming
- Classes: snake_case with _env, _agent, _drv, _mon, _scb suffixes
- Signals: lowercase with underscore separators
- Parameters: UPPER_CASE
```

## Common Pitfalls

- **Missing cross coverage:** Engineers write individual coverpoints but skip crosses. Claude Code can audit your covergroups and suggest missing cross bins that your verification plan requires.
- **Scoreboard ordering bugs:** Out-of-order transactions break naive FIFO scoreboards. Ask Claude Code to generate a scoreboard with associative-array lookup by transaction ID instead of sequential matching.
- **UVM phase misuse:** Putting blocking code in build_phase or connect_phase causes simulation hangs. Claude Code flags phase violations when reviewing testbench code.

## Related

- [Claude Code for FPGA Development](/claude-code-for-fpga-development-workflow-tutorial/)
- [Claude Code Skills for VHDL](/claude-code-skills-for-hardware-description-language-vhdl/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
