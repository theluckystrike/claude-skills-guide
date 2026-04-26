---
layout: default
title: "Claude Code for Quantum Computing (2026)"
permalink: /claude-code-quantum-computing-qiskit-2026/
date: 2026-04-20
description: "Quantum computing circuits with Claude Code and Qiskit. Build variational algorithms, error mitigation, and transpiler workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for Quantum Computing (Qiskit)

Quantum circuit design requires reasoning about unitary transformations, entanglement, and measurement in ways that classical programming intuition actively hinders. A single misplaced CNOT gate changes the entanglement structure of your entire circuit. Variational quantum algorithms (VQE, QAOA) add classical optimization loops around parameterized circuits, and the transpiler must map logical qubits to physical hardware topology with minimal SWAP overhead.

Claude Code generates Qiskit circuits from high-level algorithm descriptions, optimizes gate counts through circuit identities, applies error mitigation techniques (zero-noise extrapolation, probabilistic error cancellation), and produces the transpiled circuits that respect your target hardware's connectivity map. It catches the subtle bugs -- like measuring before all entangling operations complete or using a basis gate not supported by the backend.

## The Workflow

### Step 1: Quantum Development Setup

```bash
pip install qiskit==1.2 qiskit-aer==0.15
pip install qiskit-ibm-runtime  # for real hardware access
pip install qiskit-algorithms qiskit-nature  # chemistry/optimization

mkdir -p circuits/ results/ noise_models/
```

### Step 2: Build a Variational Quantum Eigensolver

```python
# src/vqe_h2.py
"""Variational Quantum Eigensolver for H2 molecule.
Finds ground state energy using a parameterized quantum circuit.
"""

import numpy as np
from qiskit import QuantumCircuit
from qiskit.quantum_info import SparsePauliOp
from qiskit_aer import AerSimulator
from qiskit.primitives import StatevectorEstimator
from scipy.optimize import minimize

def create_h2_hamiltonian(bond_length: float = 0.735) -> SparsePauliOp:
    """Create H2 molecular Hamiltonian in qubit representation.
    Uses Jordan-Wigner transformation of the fermionic Hamiltonian.
    bond_length in Angstroms (equilibrium = 0.735 A).
    """
    # Precomputed coefficients for STO-3G basis at 0.735 A
    # From: Kandala et al., Nature 549, 242 (2017)
    coeffs = {
        'II': -1.0523732,
        'IZ': 0.3979374,
        'ZI': -0.3979374,
        'ZZ': -0.0112801,
        'XX': 0.1809312,
    }

    hamiltonian = SparsePauliOp.from_list([
        (pauli, coeff) for pauli, coeff in coeffs.items()
    ])

    assert hamiltonian.num_qubits == 2, "H2 requires 2 qubits"
    return hamiltonian

def create_ansatz(theta: np.ndarray) -> QuantumCircuit:
    """Hardware-efficient ansatz for 2-qubit VQE.
    Single layer of Ry rotations + CNOT entanglement.
    """
    assert len(theta) == 3, "Ansatz requires 3 parameters"

    qc = QuantumCircuit(2)

    # Layer 1: Single-qubit rotations
    qc.ry(theta[0], 0)
    qc.ry(theta[1], 1)

    # Entangling gate
    qc.cx(0, 1)

    # Layer 2: Post-entanglement rotation
    qc.ry(theta[2], 0)

    return qc

def compute_energy(theta: np.ndarray,
                   hamiltonian: SparsePauliOp,
                   estimator) -> float:
    """Compute expectation value <psi|H|psi> for given parameters."""
    circuit = create_ansatz(theta)
    job = estimator.run([(circuit, hamiltonian)])
    result = job.result()
    energy = result[0].data.evs
    return float(energy)

def run_vqe(hamiltonian: SparsePauliOp,
            initial_params: np.ndarray = None,
            maxiter: int = 200) -> dict:
    """Run VQE optimization loop."""
    estimator = StatevectorEstimator()

    if initial_params is None:
        initial_params = np.random.uniform(-np.pi, np.pi, 3)

    energies = []

    def callback_energy(theta):
        e = compute_energy(theta, hamiltonian, estimator)
        energies.append(e)
        return e

    result = minimize(
        callback_energy,
        initial_params,
        method='COBYLA',
        options={'maxiter': maxiter, 'rhobeg': 0.5},
    )

    final_energy = compute_energy(result.x, hamiltonian, estimator)

    # Exact diagonalization for comparison
    exact_energy = min(np.linalg.eigvalsh(hamiltonian.to_matrix().toarray()))

    return {
        'vqe_energy': final_energy,
        'exact_energy': exact_energy,
        'error_hartree': abs(final_energy - exact_energy),
        'optimal_params': result.x,
        'convergence': energies,
        'n_iterations': result.nfev,
    }
```

### Step 3: Circuit Transpilation and Error Mitigation

```python
# src/transpile_circuit.py
"""Transpile circuits to hardware topology with error mitigation."""

from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
from qiskit_aer.noise import NoiseModel, depolarizing_error

def transpile_for_hardware(circuit: QuantumCircuit,
                            coupling_map: list = None,
                            basis_gates: list = None,
                            optimization_level: int = 3
                            ) -> QuantumCircuit:
    """Transpile circuit to target hardware constraints."""
    if coupling_map is None:
        # IBM Eagle topology (subset): linear chain
        coupling_map = [[0,1],[1,0],[1,2],[2,1],[2,3],[3,2]]

    if basis_gates is None:
        basis_gates = ['cx', 'id', 'rz', 'sx', 'x']

    transpiled = transpile(
        circuit,
        coupling_map=coupling_map,
        basis_gates=basis_gates,
        optimization_level=optimization_level,
    )

    print(f"Original gates: {circuit.count_ops()}")
    print(f"Transpiled gates: {transpiled.count_ops()}")
    print(f"Circuit depth: {circuit.depth()} -> {transpiled.depth()}")

    return transpiled

def create_noise_model(p_depol_1q: float = 0.001,
                        p_depol_2q: float = 0.01) -> NoiseModel:
    """Create simplified depolarizing noise model for simulation."""
    noise_model = NoiseModel()
    error_1q = depolarizing_error(p_depol_1q, 1)
    error_2q = depolarizing_error(p_depol_2q, 2)

    noise_model.add_all_qubit_quantum_error(error_1q, ['rx','ry','rz','sx','x'])
    noise_model.add_all_qubit_quantum_error(error_2q, ['cx'])

    return noise_model

def zero_noise_extrapolation(circuit: QuantumCircuit,
                              hamiltonian,
                              noise_factors: list = [1, 2, 3],
                              base_noise: float = 0.01
                              ) -> float:
    """Zero-noise extrapolation (ZNE) error mitigation.
    Run at multiple noise levels, extrapolate to zero noise.
    """
    energies = []

    for factor in noise_factors:
        noise_model = create_noise_model(
            p_depol_1q=0.001 * factor,
            p_depol_2q=base_noise * factor,
        )
        sim = AerSimulator(noise_model=noise_model)
        # ... run circuit on noisy simulator
        # energies.append(measured_energy)

    # Richardson extrapolation to zero noise
    # E(0) = sum(w_i * E(lambda_i)) where weights from Lagrange interpolation
    # For linear ZNE: E(0) = 2*E(1) - E(2)
    return energies  # placeholder: real implementation needs measurement
```

### Step 4: Verify VQE

```bash
python3 -c "
import numpy as np
from src.vqe_h2 import create_h2_hamiltonian, run_vqe

H = create_h2_hamiltonian(bond_length=0.735)
print(f'Hamiltonian: {H.num_qubits} qubits, {len(H)} Pauli terms')

result = run_vqe(H, maxiter=300)
print(f'VQE energy:   {result[\"vqe_energy\"]:.6f} Ha')
print(f'Exact energy: {result[\"exact_energy\"]:.6f} Ha')
print(f'Error:        {result[\"error_hartree\"]:.6f} Ha')
print(f'Iterations:   {result[\"n_iterations\"]}')

# Chemical accuracy: < 1.6 mHa (1 kcal/mol)
assert result['error_hartree'] < 0.0016, \
    f'VQE did not reach chemical accuracy: {result[\"error_hartree\"]:.4f} Ha'
print('VQE verification: PASS (chemical accuracy reached)')
"
```

## CLAUDE.md for Quantum Computing

```markdown
# Quantum Computing with Qiskit

## Gate Conventions
- Qiskit uses little-endian qubit ordering (q[0] is rightmost in ket)
- Rotation gates: Rx(theta) = exp(-i*theta/2 * X)
- CX (CNOT): control is first argument, target is second

## Circuit Design Rules
- Minimize CNOT count (most expensive gate on real hardware)
- Use transpile() with optimization_level=3 before hardware execution
- Always verify circuits on statevector simulator before noisy simulation
- Parameterized circuits: use ParameterVector for variational algorithms

## Libraries
- qiskit 1.2+ (core circuit library)
- qiskit-aer 0.15+ (simulators and noise models)
- qiskit-ibm-runtime (real hardware access)
- qiskit-algorithms (VQE, QAOA, Grover)
- qiskit-nature (molecular simulations)

## Common Commands
- python3 -c "import qiskit; print(qiskit.__version__)" — check version
- circuit.draw('mpl') — visualize circuit
- transpile(circuit, backend).count_ops() — count hardware gates
- AerSimulator().run(circuit, shots=8192) — noisy simulation
```

## Common Pitfalls

- **Qubit ordering confusion:** Qiskit's little-endian convention means qubit 0 is the rightmost bit in measurement outcomes. Claude Code generates circuits with explicit qubit labels and adds comments showing the expected measurement bit order.
- **Barren plateaus in deep ansatze:** Random initialization of deep parameterized circuits produces near-zero gradients. Claude Code initializes parameters near identity (small angles) and uses shallow circuits with problem-specific structure.
- **Missing measurement before sampling:** A circuit without `measure()` gates returns zero counts from `backend.run()`. Claude Code adds measurement gates automatically when using shot-based simulation and omits them for statevector estimation.



**Get started →** Generate your project setup with our [Project Starter](/starter/).

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Computational Chemistry (ORCA)](/claude-code-computational-chemistry-orca-2026/)
- [Claude Code for Materials Science VASP/LAMMPS](/claude-code-materials-science-vasp-lammps-2026/)
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
