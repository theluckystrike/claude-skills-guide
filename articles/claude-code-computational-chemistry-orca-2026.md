---
layout: default
title: "Claude Code for Computational Chemistry (2026)"
description: "Claude Code for Computational Chemistry — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-computational-chemistry-orca-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for Computational Chemistry

Writing ORCA and Gaussian input files requires knowing which functional/basis set combinations are appropriate for your problem, how to set convergence criteria for tricky open-shell systems, and which keywords trigger implicit dependencies. A geometry optimization that should take 2 hours takes 200 hours because someone picked B3LYP/6-31G* for a transition metal complex where it is known to fail.

Claude Code generates ORCA input files with appropriate method selection based on system type, handles common pitfalls like basis set incompleteness errors for heavy elements, and parses output files to extract energies, geometries, and spectroscopic properties into structured data.

## The Workflow

### Step 1: Environment Setup

```bash
# ORCA is free for academic use — download from orcaforum.kofo.mpg.de
export ORCA_PATH=/opt/orca_5_0_4
export PATH=$ORCA_PATH:$PATH

# Python analysis tools
pip install cclib ase rdkit numpy matplotlib
# cclib parses output from ORCA, Gaussian, GAMESS, etc.

mkdir -p compchem/{inputs,outputs,analysis}
```

### Step 2: Generate ORCA Input Files

```python
# compchem/generate_orca_input.py
"""Generate ORCA input files for common computational chemistry tasks."""
from pathlib import Path
from dataclasses import dataclass

MAX_ATOMS = 500
MAX_ELECTRONS = 2000


@dataclass
class MolecularSystem:
    xyz_coords: str        # XYZ format geometry
    charge: int
    multiplicity: int
    n_atoms: int
    has_heavy_metals: bool  # elements beyond Kr


def parse_xyz(xyz_path: str) -> MolecularSystem:
    """Parse XYZ file and detect system characteristics."""
    assert Path(xyz_path).exists(), f"XYZ file not found: {xyz_path}"

    with open(xyz_path) as f:
        lines = f.readlines()

    n_atoms = int(lines[0].strip())
    assert 0 < n_atoms <= MAX_ATOMS, f"Atom count {n_atoms} out of range"

    heavy_elements = {"Ru", "Rh", "Pd", "Ag", "Os", "Ir", "Pt", "Au",
                      "Fe", "Co", "Ni", "Cu", "Zn", "Mo", "W", "Re"}
    has_heavy = False
    coords = []
    for line in lines[2:2+n_atoms]:
        parts = line.split()
        assert len(parts) >= 4, f"Malformed XYZ line: {line.strip()}"
        element = parts[0]
        if element in heavy_elements:
            has_heavy = True
        coords.append(line.strip())

    return MolecularSystem(
        xyz_coords="\n".join(coords),
        charge=0,
        multiplicity=1,
        n_atoms=n_atoms,
        has_heavy_metals=has_heavy,
    )


def select_method(system: MolecularSystem, task: str) -> dict:
    """Select appropriate DFT functional and basis set."""
    assert task in ("opt", "sp", "freq", "nmr", "td"), \
        f"Unknown task: {task}"

    if system.has_heavy_metals:
        # Use def2 basis with ECP for heavy elements
        method = {
            "functional": "PBE0",
            "basis": "def2-TZVP",
            "aux_basis": "def2/J",
            "dispersion": "D4",
            "relativistic": "ZORA",
            "notes": "Heavy metals detected — using ZORA relativistic correction",
        }
    elif system.n_atoms > 100:
        # Large organic: use RI approximation
        method = {
            "functional": "r2SCAN-3c",
            "basis": "",  # composite method includes basis
            "aux_basis": "",
            "dispersion": "",
            "relativistic": "",
            "notes": "Large system — using composite r2SCAN-3c for efficiency",
        }
    else:
        # Standard organic
        method = {
            "functional": "wB97X-D3",
            "basis": "def2-TZVPP",
            "aux_basis": "def2/J",
            "dispersion": "",  # included in functional
            "relativistic": "",
            "notes": "Standard organic system — range-separated hybrid",
        }

    return method


def generate_input(system: MolecularSystem, task: str,
                   output_path: str, n_cores: int = 8,
                   memory_mb: int = 4000) -> None:
    """Generate ORCA input file for specified task."""
    assert n_cores > 0 and n_cores <= 64, "Cores must be 1-64"
    assert memory_mb >= 1000, "Minimum 1000 MB memory"

    method = select_method(system, task)

    task_keywords = {
        "opt": "Opt TightOpt",
        "sp": "SP",
        "freq": "Opt Freq",
        "nmr": "NMR",
        "td": "TD-DFT",
    }

    keywords = [method["functional"]]
    if method["basis"]:
        keywords.append(method["basis"])
    if method["aux_basis"]:
        keywords.append(f"RIJCOSX {method['aux_basis']}")
    if method["dispersion"]:
        keywords.append(method["dispersion"])
    if method["relativistic"]:
        keywords.append(method["relativistic"])
    keywords.append(task_keywords[task])
    keywords.append("PrintBasis")

    with open(output_path, 'w') as f:
        f.write(f"# {method['notes']}\n")
        f.write(f"! {' '.join(keywords)}\n\n")
        f.write(f"%pal\n  nprocs {n_cores}\nend\n\n")
        f.write(f"%maxcore {memory_mb}\n\n")

        if task == "opt":
            f.write("%geom\n  MaxIter 200\nend\n\n")

        if task == "td":
            f.write("%tddft\n  NRoots 10\n  MaxDim 5\nend\n\n")

        f.write(f"* xyz {system.charge} {system.multiplicity}\n")
        f.write(system.xyz_coords + "\n")
        f.write("*\n")

    print(f"Wrote: {output_path}")
    print(f"Method: {method['notes']}")


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 3, \
        "Usage: python generate_orca_input.py <input.xyz> <task> [charge] [mult]"

    system = parse_xyz(sys.argv[1])
    task = sys.argv[2]
    if len(sys.argv) > 3:
        system.charge = int(sys.argv[3])
    if len(sys.argv) > 4:
        system.multiplicity = int(sys.argv[4])

    output = f"inputs/{Path(sys.argv[1]).stem}_{task}.inp"
    generate_input(system, task, output)
```

### Step 3: Run and Parse Results

```bash
# Generate input
python3 compchem/generate_orca_input.py molecule.xyz opt

# Run ORCA
$ORCA_PATH/orca inputs/molecule_opt.inp > outputs/molecule_opt.out 2>&1

# Parse results with cclib
python3 -c "
import cclib
data = cclib.io.ccread('outputs/molecule_opt.out')
print(f'Final energy: {data.scfenergies[-1]:.6f} eV')
print(f'Converged: {data.optdone}')
print(f'N iterations: {len(data.scfenergies)}')
# Expected: optdone=True, energy converged to <0.001 eV change
"
```

## CLAUDE.md for Computational Chemistry

```markdown
# Computational Chemistry Rules

## Standards
- ORCA 5.0+ input syntax
- IUPAC nomenclature for compounds
- SI units in output (convert from Hartree where needed)

## File Formats
- .xyz (Cartesian coordinates)
- .inp (ORCA input)
- .out (ORCA output)
- .gbw (ORCA wavefunction)
- .cif (crystallographic)

## Libraries
- cclib 1.8+ (output parsing)
- ASE 3.22+ (Atomic Simulation Environment)
- RDKit 2024+ (cheminformatics)
- Open Babel 3.1+ (format conversion)

## Testing
- Verify SCF convergence (energy change < 1e-8 Eh)
- Check geometry optimization convergence (gradients < threshold)
- Frequency calculations must have zero imaginary frequencies for minima
- Compare against published benchmarks for known systems

## Method Selection
- Organic molecules < 100 atoms: wB97X-D3/def2-TZVPP
- Large organics > 100 atoms: r2SCAN-3c
- Transition metals: PBE0-D4/def2-TZVP + ZORA
- Excited states: TD-DFT with range-separated functional
```

## Common Pitfalls

- **Basis set superposition error (BSSE):** Interaction energies without counterpoise correction are systematically too favorable. Claude Code adds the BSSE keyword for all binding energy calculations.
- **Wrong multiplicity for transition metals:** An Fe(II) complex can be low-spin (singlet) or high-spin (quintet). Claude Code flags transition metal systems and prompts you to specify the spin state explicitly.
- **SCF convergence failure:** Default DIIS sometimes fails for open-shell or highly charged systems. Claude Code switches to SOSCF or adds level shifting when it detects convergence stalling in the output.



**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Molecular Dynamics](/claude-code-molecular-dynamics-gromacs-2026/)
- [Claude Code for Computational Biology](/claude-skills-for-computational-biology-bioinformatics/)
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
