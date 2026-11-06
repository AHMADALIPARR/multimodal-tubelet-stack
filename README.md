# Natively Multimodal Tubelet Stack

Zero-Python sovereign pipeline.

## Planes

- **Verification**: Agda (`agda/TubeletProjection.agda`) — dependent-type invariants, freehand, no external imports.
- **Lemmas**: Lean 4 + Lake (`lean/`) — same invariants as theorems, zero `sorry`.
- **Host / orchestration**: Dylan (`dylan/`).
- **Metal kernels**: CUDA / CUDA-Q style (`cuda/`) lowering tubelets and attention to PTX.
- **Abstraction + training CLI**: C# (`csharp/`) — renders visuals and drives the pipeline.

## Build

```bash
# Lean
cd lean && lake build

# C# CLI
dotnet run --project csharp -- --render

# CUDA (requires nvcc / CUDA-Q toolchain)
nvcc -o tubelet cuda/tubelet_kernel.cu
```

No Python. No external package imports in the formal layers.
