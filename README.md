# Natively Multimodal Tubelet Stack

Zero-Python sovereign pipeline. All source files licensed under **AGPLv3** (see [LICENSE](LICENSE)).

## Planes

- **Verification**: Agda (`agda/TubeletProjection.agda`) — dependent-type proofs of tensor dimensions (`totalElements`), positional injectivity, and softmax stochasticity. Freehand, Builtin only.
- **Lemmas**: Lean 4 + Lake (`lean/`) — same invariants as closed theorems (zero `sorry`, no Mathlib). `lake build`.
- **Host / multi-agent orchestration**: Dylan (`dylan/host.dylan`) and C# (`csharp/Program.cs` + full `NativeMetal.cs` FFI).
- **Metal**: Full zero-copy CUDA kernels (`cuda/tubelet_kernel.cu`) using `cudaHostRegister` / UVA so the RTX streams mmap'd pages directly. C-ABI exports `launch_tubelet_projection`.
- **Zero-copy ingestion**: C (`c/nvme_mmap.c`) maps NVMe frames via POSIX `mmap`; C# passes the raw `IntPtr`.
- **Topology extraction**: Dylan (`tools/TopologyParser.dylan`) reads GGUF metadata and emits Lean/Agda constants.

## Proof-Before-Compile

The CI workflow `.github/workflows/sovereign-proof-chain.yml` enforces Agda → Lean → CUDA/C#.

## Build

```bash
# Lean lemmas
cd lean && lake build

# Shared CUDA library (C-ABI)
nvcc -Xcompiler -fPIC -shared -o tubelet_kernel.so cuda/tubelet_kernel.cu

# Zero-copy layer
gcc -shared -fPIC -o nvme_mmap.so c/nvme_mmap.c

# C# host
cd csharp && dotnet build MultimodalHost.csproj -c Release
```

Agda/Lean prove the geometry. The C# bridge passes raw mmap pointers. CUDA pins them with `cudaHostRegister` and executes on the SMs with zero intermediate copies.
