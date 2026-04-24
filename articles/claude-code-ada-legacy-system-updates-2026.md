---
title: "Claude Code for Ada Legacy System"
permalink: /claude-code-ada-legacy-system-updates-2026/
description: "Maintain and update Ada legacy systems with Claude Code. Modernize Ada 83/95 code to Ada 2022 standards for defense and avionics."
last_tested: "2026-04-22"
domain: "defense systems"
render_with_liquid: false
---

## Why Claude Code for Ada Legacy Systems

Ada remains the language of choice for safety-critical defense systems, avionics, air traffic control, and railway signaling. Millions of lines of Ada 83 and Ada 95 code run in production systems governed by DO-178C, MIL-STD-498, and other certification standards. These systems require ongoing maintenance, but the pool of Ada developers is shrinking and most tooling predates modern IDE support. Updating Ada 83 code to leverage Ada 2012/2022 features like contract-based programming and parallel constructs requires deep language knowledge.

Claude Code understands Ada's strong typing system, tasking model, generic packages, and the specific patterns required by real-time embedded systems. It can modernize legacy Ada code while maintaining the deterministic behavior and WCET (Worst Case Execution Time) properties that certification demands.

## The Workflow

### Step 1: Set Up the Ada Build Environment

```bash
# Install GNAT (GCC Ada compiler) via Alire package manager
curl -L https://github.com/alire-project/alire/releases/latest/download/alr-linux.zip -o alr.zip
unzip alr.zip && sudo mv bin/alr /usr/local/bin/

# Or on macOS
brew install gprbuild gnat

# Initialize project and add dependencies
mkdir -p ~/ada-project && cd ~/ada-project
alr init --bin my_system
alr with aunit       # Unit testing framework
alr with spark2014   # Formal verification subset

# Build and verify
alr build
```

### Step 2: Modernize Ada 83 to Ada 2012 with Contracts

Original Ada 83 code with manual precondition checks:

```ada
-- Ada 83 style: manual validation, no contracts
package body Navigation is

   procedure Calculate_Heading
     (Current_Lat  : in  Float;
      Current_Lon  : in  Float;
      Target_Lat   : in  Float;
      Target_Lon   : in  Float;
      Heading      : out Float;
      Status       : out Status_Type)
   is
      Delta_Lat : Float;
      Delta_Lon : Float;
   begin
      -- Manual precondition checks (Ada 83 pattern)
      if Current_Lat < -90.0 or Current_Lat > 90.0 then
         Status := Invalid_Latitude;
         Heading := 0.0;
         return;
      end if;
      if Current_Lon < -180.0 or Current_Lon > 180.0 then
         Status := Invalid_Longitude;
         Heading := 0.0;
         return;
      end if;

      Delta_Lat := Target_Lat - Current_Lat;
      Delta_Lon := Target_Lon - Current_Lon;
      Heading := Arctan(Delta_Lon, Delta_Lat) * 180.0 / Pi;
      if Heading < 0.0 then
         Heading := Heading + 360.0;
      end if;
      Status := OK;
   end Calculate_Heading;

end Navigation;
```

Claude Code modernizes to Ada 2012 with contracts and SPARK aspects:

```ada
-- Ada 2012/2022: contract-based, SPARK-provable
package Navigation
  with SPARK_Mode => On
is
   subtype Latitude  is Float range -90.0 .. 90.0;
   subtype Longitude is Float range -180.0 .. 180.0;
   subtype Heading   is Float range 0.0 .. 360.0;

   procedure Calculate_Heading
     (Current_Lat  : in  Latitude;
      Current_Lon  : in  Longitude;
      Target_Lat   : in  Latitude;
      Target_Lon   : in  Longitude;
      Result       : out Heading)
     with
       Global  => null,
       Depends => (Result => (Current_Lat, Current_Lon,
                              Target_Lat, Target_Lon)),
       Post    => Result in Heading;

end Navigation;

package body Navigation
  with SPARK_Mode => On
is
   procedure Calculate_Heading
     (Current_Lat  : in  Latitude;
      Current_Lon  : in  Longitude;
      Target_Lat   : in  Latitude;
      Target_Lon   : in  Longitude;
      Result       : out Heading)
   is
      Delta_Lat : constant Float := Float(Target_Lat) - Float(Current_Lat);
      Delta_Lon : constant Float := Float(Target_Lon) - Float(Current_Lon);
      Raw       : Float;
   begin
      Raw := Arctan(Delta_Lon, Delta_Lat) * 180.0 / Pi;
      if Raw < 0.0 then
         Raw := Raw + 360.0;
      end if;
      Result := Heading(Raw);
   end Calculate_Heading;

end Navigation;
```

### Step 3: Modernize Tasking with Ada 2012 Interfaces

```ada
-- Ada 2012: replace Ada 83 task entries with synchronized interfaces
package Sensor_Interface is

   type Sensor_Reader is task interface;

   procedure Read_Value
     (Self  : in out Sensor_Reader;
      Value : out Float) is abstract;

   procedure Calibrate
     (Self   : in out Sensor_Reader;
      Offset : in Float) is abstract;

   -- Concrete implementation for temperature sensor
   task type Temperature_Sensor is
      new Sensor_Reader with
      entry Read_Value (Value : out Float);
      entry Calibrate (Offset : in Float);
   end Temperature_Sensor;

end Sensor_Interface;
```

### Step 4: Verify with SPARK Formal Proof

```bash
# Run SPARK prover to verify absence of runtime errors
gnatprove -P my_system.gpr --level=2 --mode=prove

# Run AUnit tests
alr run -- --test

# Check WCET analysis (for DO-178C Level A)
gnatstack -P my_system.gpr

# Build for target platform
gprbuild -P my_system.gpr --target=arm-eabi --RTS=ravenscar-sfp
```

## CLAUDE.md for Ada Legacy Systems

```markdown
# Ada Legacy System Maintenance Standards

## Domain Rules
- All new code must be SPARK-compatible where possible (SPARK_Mode => On)
- Use Ada 2012+ subtypes with range constraints instead of manual validation
- Use Pre/Post contracts instead of manual precondition checks
- All tasking must use Ravenscar profile for real-time systems
- No dynamic memory allocation (Storage_Error must be impossible)
- No recursion (bounded stack depth required by DO-178C)

## File Patterns
- *.ads (package specifications), *.adb (package bodies)
- *.gpr (GNAT project files)
- test/*.adb (AUnit test packages)

## Common Commands
- alr build
- gnatprove -P project.gpr --level=2 --mode=prove
- gprbuild -P project.gpr -Xmode=release
- gnatstack -P project.gpr
- gnatcheck -P project.gpr -rules -from=coding_standards.rules
- alr run -- --test
- gnatpp -P project.gpr  (pretty printer)
- gnatmetric -P project.gpr  (code metrics)
```

## Common Pitfalls in Ada Legacy System Updates

- **Ravenscar profile violations:** Ada 83 code often uses unrestricted tasking (select-or-accept, task abort) that violates the Ravenscar profile required for DO-178C Level A. Claude Code refactors these into protected objects with priority ceiling protocol.

- **Implicit numeric conversions:** Ada 83 allowed some implicit float-to-integer conversions that Ada 2012 rejects. Claude Code adds explicit type conversions and range checks to maintain type safety.

- **Generic package instantiation placement:** Moving Ada 83 generics to Ada 2012 can trigger elaboration order issues. Claude Code adds proper `pragma Elaborate_All` or uses Ada 2012's aspect-based elaboration control.

## Related

- [Claude Code for COBOL to Java Migration](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for Mainframe REXX Modernization](/claude-code-mainframe-rexx-modernization-2026/)
- [Claude Code for MUMPS Healthcare Modernization](/claude-code-mumps-healthcare-modernization-2026/)
- [Help Claude Code Work With Legacy Code (2026)](/claude-code-cant-handle-legacy-code-fix-2026/)
