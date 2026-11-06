# Natively Multimodal Tubelet Stack

Zero-Python sovereign pipeline. All source files licensed under **AGPLv3** (see [LICENSE](LICENSE)).

## Planes

- **Verification**: Agda (`agda/TubeletProjection.agda`) — dependent-type proofs of tensor dimensions (`totalElements`), positional injectivity, and softmax stochasticity. Freehand, Builtin only.
- **Lemmas**: Lean 4 + Lake (`lean/`) — same invariants as closed theorems (zero `sorry`, no Mathlib). `lake build`.
- **Host / multi-agent orchestration**: Dylan (`dylan/host.dylan`) and C# (`csharp/Program.cs` + `NativeMetal.cs`).
- **Metal**: CUDA-Q style kernels (`cuda/tubelet_kernel.cu`) that lower the proven attention matrix and tubelets directly toward PTX.
- **Zero-copy ingestion**: C (`c/nvme_mmap.c`) maps NVMe frames via POSIX `mmap` so the C# host passes raw pointers to CUDA.
- **Topology extraction**: Dylan (`tools/TopologyParser.dylan`) reads GGUF metadata and emits `lean/Constants.lean` / `agda/Topology.agda` so proofs are parameterized by the concrete model.

## Proof-Before-Compile

The CI workflow `.github/workflows/sovereign-proof-chain.yml` enforces:

1. Agda type-check
2. Lean `lake build`
3. Only then CUDA `nvcc` and C# build

If the algebraic geometry fails, the metal never compiles.

## Build

```bash
# Lean lemmas
cd lean && lake build

# C# multi-agent CLI + visual render
dotnet run --project csharp -- --render

# CUDA-Q / nvcc kernels
nvcc -o tubelet cuda/tubelet_kernel.cu

# Zero-copy layer
gcc -shared -fPIC -o nvme_mmap.so c/nvme_mmap.c
```

Agda/Lean prove the geometry. Dylan or C# orchestrates the agents. CUDA-Q compiles the actual attention matrix. The CI gate makes the proof a prerequisite for the binary.
