# Natively Multimodal Tubelet Stack

Zero-Python sovereign pipeline. All source files licensed under **AGPLv3** (see [LICENSE](LICENSE)).

## Planes

- **Verification**: Agda (`agda/TubeletProjection.agda`) — dependent-type proofs of tensor dimensions (`totalElements`), positional injectivity, and softmax stochasticity. Freehand, Builtin only.
- **Lemmas**: Lean 4 + Lake (`lean/`) — same invariants as closed theorems (zero `sorry`, no Mathlib). `lake build`.
- **Host / multi-agent orchestration**: Dylan (`dylan/host.dylan`) and C# (`csharp/Program.cs`).
- **Metal**: CUDA-Q style kernels (`cuda/tubelet_kernel.cu`) that lower the proven attention matrix and tubelets directly toward PTX.

## Build

```bash
# Lean lemmas
cd lean && lake build

# C# multi-agent CLI + visual render
dotnet run --project csharp -- --render

# CUDA-Q / nvcc kernels
nvcc -o tubelet cuda/tubelet_kernel.cu
```

Agda/Lean prove the geometry. Dylan or C# orchestrates the agents. CUDA-Q compiles the actual attention matrix.
