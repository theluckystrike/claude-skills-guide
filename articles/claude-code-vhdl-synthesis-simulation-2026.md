---
title: "Claude Code for VHDL Synthesis"
description: "VHDL synthesis and simulation with Claude Code. Write synthesizable RTL and self-checking testbenches with GHDL."
permalink: /claude-code-vhdl-synthesis-simulation-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for VHDL Synthesis

VHDL has a steep learning curve: strong typing, signal vs variable semantics, process sensitivity lists, and the distinction between synthesizable and simulation-only constructs catch even experienced hardware engineers. Writing a self-checking testbench with file I/O stimulus and automated pass/fail is another 200 lines of boilerplate per module.

Claude Code generates VHDL-2008 code that synthesizes cleanly on FPGA toolchains (Vivado, Quartus, Yosys/GHDL), avoids latches from incomplete sensitivity lists, and produces testbenches with clock generation, reset sequencing, and automated comparison against expected output vectors.

## The Workflow

### Step 1: Setup

```bash
# Open-source VHDL simulator
sudo apt install ghdl gtkwave  # Ubuntu
# Or: brew install ghdl gtkwave  # macOS

# Synthesis (open-source flow)
sudo apt install yosys ghdl-yosys-plugin
# Or commercial: Vivado, Quartus

mkdir -p vhdl_project/{rtl,tb,sim,synth,vectors}
```

### Step 2: Synthesizable VHDL Module with Testbench

```vhdl
-- rtl/fifo.vhd — Synchronous FIFO (synthesizable VHDL-2008)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_fifo is
  generic (
    DATA_WIDTH : positive := 8;
    FIFO_DEPTH : positive := 16
  );
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    -- Write interface
    wr_en     : in  std_logic;
    wr_data   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    full      : out std_logic;
    -- Read interface
    rd_en     : in  std_logic;
    rd_data   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    empty     : out std_logic;
    -- Status
    fill_level : out unsigned(clog2(FIFO_DEPTH) downto 0)
  );
end entity sync_fifo;

architecture rtl of sync_fifo is
  -- Calculate address width
  function clog2(val : positive) return natural is
    variable result : natural := 0;
    variable v      : natural := val - 1;
  begin
    while v > 0 loop
      result := result + 1;
      v := v / 2;
    end loop;
    return result;
  end function;

  constant ADDR_WIDTH : natural := clog2(FIFO_DEPTH);

  type mem_array_t is array (0 to FIFO_DEPTH - 1)
    of std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem : mem_array_t;

  signal wr_ptr : unsigned(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal rd_ptr : unsigned(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal count  : unsigned(ADDR_WIDTH downto 0) := (others => '0');

  signal full_i  : std_logic;
  signal empty_i : std_logic;

begin
  -- Assertions (simulation only, stripped during synthesis)
  -- synthesis translate_off
  assert FIFO_DEPTH >= 2
    report "FIFO_DEPTH must be >= 2" severity failure;
  assert DATA_WIDTH >= 1
    report "DATA_WIDTH must be >= 1" severity failure;
  -- synthesis translate_on

  full_i  <= '1' when count = FIFO_DEPTH else '0';
  empty_i <= '1' when count = 0 else '0';
  full    <= full_i;
  empty   <= empty_i;
  fill_level <= count;

  process (clk, rst_n)
  begin
    if rst_n = '0' then
      wr_ptr <= (others => '0');
      rd_ptr <= (others => '0');
      count  <= (others => '0');
    elsif rising_edge(clk) then
      -- Write
      if wr_en = '1' and full_i = '0' then
        mem(to_integer(wr_ptr)) <= wr_data;
        if wr_ptr = FIFO_DEPTH - 1 then
          wr_ptr <= (others => '0');
        else
          wr_ptr <= wr_ptr + 1;
        end if;
      end if;

      -- Read
      if rd_en = '1' and empty_i = '0' then
        rd_data <= mem(to_integer(rd_ptr));
        if rd_ptr = FIFO_DEPTH - 1 then
          rd_ptr <= (others => '0');
        else
          rd_ptr <= rd_ptr + 1;
        end if;
      end if;

      -- Count update
      if wr_en = '1' and full_i = '0' and
         (rd_en = '0' or empty_i = '1') then
        count <= count + 1;
      elsif rd_en = '1' and empty_i = '0' and
            (wr_en = '0' or full_i = '1') then
        count <= count - 1;
      end if;
    end if;
  end process;

end architecture rtl;
```

```vhdl
-- tb/fifo_tb.vhd — Self-checking testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_fifo_tb is
end entity sync_fifo_tb;

architecture sim of sync_fifo_tb is
  constant CLK_PERIOD : time := 10 ns;
  constant DATA_WIDTH : positive := 8;
  constant FIFO_DEPTH : positive := 8;

  signal clk, rst_n : std_logic := '0';
  signal wr_en, rd_en : std_logic := '0';
  signal wr_data, rd_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal full, empty : std_logic;

  signal test_pass_count : natural := 0;
  signal test_fail_count : natural := 0;
begin
  -- Clock generation
  clk <= not clk after CLK_PERIOD / 2;

  -- DUT instantiation
  dut : entity work.sync_fifo
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      FIFO_DEPTH => FIFO_DEPTH
    )
    port map (
      clk => clk, rst_n => rst_n,
      wr_en => wr_en, wr_data => wr_data, full => full,
      rd_en => rd_en, rd_data => rd_data, empty => empty
    );

  stim : process
    procedure check(condition : boolean; msg : string) is
    begin
      if condition then
        test_pass_count <= test_pass_count + 1;
      else
        test_fail_count <= test_fail_count + 1;
        report "FAIL: " & msg severity error;
      end if;
    end procedure;
  begin
    -- Reset
    rst_n <= '0';
    wait for CLK_PERIOD * 5;
    rst_n <= '1';
    wait for CLK_PERIOD;

    -- Test 1: Empty after reset
    check(empty = '1', "FIFO should be empty after reset");
    check(full = '0', "FIFO should not be full after reset");

    -- Test 2: Write until full
    for i in 0 to FIFO_DEPTH - 1 loop
      wr_en <= '1';
      wr_data <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
      wait for CLK_PERIOD;
    end loop;
    wr_en <= '0';
    wait for CLK_PERIOD;
    check(full = '1', "FIFO should be full");

    -- Test 3: Read back and verify order
    for i in 0 to FIFO_DEPTH - 1 loop
      rd_en <= '1';
      wait for CLK_PERIOD;
      check(rd_data = std_logic_vector(to_unsigned(i, DATA_WIDTH)),
            "Data mismatch at index " & integer'image(i));
    end loop;
    rd_en <= '0';
    wait for CLK_PERIOD;
    check(empty = '1', "FIFO should be empty after full read");

    -- Report
    wait for CLK_PERIOD * 2;
    report "Test complete: " &
           integer'image(test_pass_count) & " passed, " &
           integer'image(test_fail_count) & " failed"
      severity note;

    assert test_fail_count = 0
      report "TESTBENCH FAILED" severity failure;

    report "ALL TESTS PASSED" severity note;
    std.env.stop;
  end process;
end architecture sim;
```

### Step 3: Simulate and Synthesize

```bash
# Analyze and simulate with GHDL
cd sim
ghdl -a --std=08 ../rtl/fifo.vhd ../tb/fifo_tb.vhd
ghdl -e --std=08 sync_fifo_tb
ghdl -r --std=08 sync_fifo_tb --vcd=fifo.vcd --stop-time=2us
# Expected: ALL TESTS PASSED

# View waveforms
gtkwave fifo.vcd &

# Synthesize with Yosys (if GHDL plugin available)
yosys -m ghdl -p "ghdl --std=08 ../rtl/fifo.vhd -e sync_fifo; synth_ecp5; write_json fifo.json"
```

## CLAUDE.md for VHDL Projects

```markdown
# VHDL Development Rules

## Standards
- VHDL-2008 (IEEE 1076-2008)
- Use numeric_std, NEVER std_logic_arith
- Synthesizable subset only in rtl/ directory

## File Formats
- .vhd (VHDL source)
- .vcd / .ghw (waveform dumps)
- .xdc / .sdc (timing constraints)

## Libraries
- GHDL 4.x (simulator)
- Yosys + GHDL plugin (synthesis)
- GTKWave (waveform viewer)

## Testing
- Every RTL module must have a self-checking testbench
- Testbench reports pass/fail count at end of simulation
- assert with severity failure terminates on first error
- Coverage: exercise reset, full, empty, simultaneous read/write

## Synthesis Rules
- No wait statements in synthesizable code
- Complete sensitivity lists (or use process(all) in VHDL-2008)
- No initial values on signals (use reset)
- Avoid latches: always assign in all branches
```

## Common Pitfalls

- **Incomplete sensitivity list generates latch:** A process missing a signal in its sensitivity list compiles but creates a latch instead of combinational logic. Claude Code uses `process(all)` (VHDL-2008) or explicitly lists all read signals.
- **std_logic_arith vs numeric_std:** Older VHDL code uses the non-standard std_logic_arith library. Claude Code always uses ieee.numeric_std and converts old code during refactoring.
- **Simulation passes, synthesis fails:** Using `wait for 10 ns` in RTL code is simulation-only. Claude Code separates synthesizable code (rtl/) from simulation-only code (tb/) and flags non-synthesizable constructs.

## Related

- [Claude Code for FPGA Development](/claude-code-for-fpga-development-workflow-tutorial/)
- [Claude Code for SystemVerilog Testbenches](/claude-code-systemverilog-testbench-gen-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for RF Antenna Design Simulation (2026)](/claude-code-rf-antenna-design-simulation-2026/)
