# Natively Multimodal Tubelet Stack

Zero-Python sovereign pipeline. All source files licensed under **AGPLv3** (see [LICENSE](LICENSE)).

## Planes

**Verification plane** (geometry only — no metal):
- **ATS first** (`ats/tubelet_geometry.dats`) — dependent indices for dimensionality conservation, positional injectivity, and stochasticity. Type-checked before anything else.
- Agda (`agda/TubeletProjection.agda`) — dependent-type proofs of tensor dimensions, positional injectivity, and softmax stochasticity.
- Lean 4 + Lake (`lean/`) — same invariants as closed theorems (zero `sorry`).

**Execution plane** (host + metal):
- Zero-copy C (`c/nvme_mmap.c`) — POSIX `mmap` of NVMe frames.
- CUDA kernels (`cuda/tubelet_kernel.cu`) — `cudaHostRegister` / UVA, C-ABI `launch_tubelet_projection`.
- C# host (`csharp/Program.cs` + `NativeMetal.cs`) — raw `IntPtr` FFI, hard gate in CI.
- Dylan host (`dylan/host.dylan`) and topology extractor (`tools/TopologyParser.dylan`).

## Proof-Before-Compile

CI (`.github/workflows/sovereign-proof-chain.yml`) enforces:

1. ATS file present and non-empty (verification plane first)
2. Agda / Lean (attempted)
3. Only then C mmap → CUDA → C# hard build

## Build

```bash
# ATS (when patscc is available)
patscc -tcats ats/tubelet_geometry.dats

# Lean lemmas
cd lean && lake build

# Shared CUDA library (C-ABI)
nvcc -Xcompiler -fPIC -shared -o tubelet_kernel.so cuda/tubelet_kernel.cu

# Zero-copy layer
gcc -shared -fPIC -o nvme_mmap.so c/nvme_mmap.c

# C# host
cd csharp && dotnet build MultimodalHost.csproj -c Release
```

ATS/Agda/Lean prove the geometry. The C# bridge passes raw mmap pointers. CUDA pins them with `cudaHostRegister` and executes on the SMs with zero intermediate copies.
