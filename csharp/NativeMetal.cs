// NativeMetal.cs — Strict C-ABI / P/Invoke bridge from C# host to CUDA/PTX and mmap.
// No Python. Zero intermediate wrappers.
//
// Copyright (C) 2026 AHMAD ALI PARR
// Licensed under the GNU Affero General Public License v3.0 or later.
// See LICENSE for the full text.

using System;
using System.Runtime.InteropServices;

namespace Multimodal.Abstraction
{
    public static class NativeMetal
    {
        // Bind to the compiled CUDA shared object / PTX launcher
        [DllImport("tubelet_kernel", CallingConvention = CallingConvention.Cdecl)]
        public static extern int LaunchTubeletProjection(
            IntPtr videoTensorPtr,
            int T, int H, int W, int C,
            int patchSize, int d_model,
            IntPtr outputSequencePtr);

        // Bind to the zero-copy mmap layer
        [DllImport("nvme_mmap", CallingConvention = CallingConvention.Cdecl)]
        public static extern int LaunchMmap(
            string path,
            out IntPtr ptr,
            out ulong size);

        [DllImport("nvme_mmap", CallingConvention = CallingConvention.Cdecl)]
        public static extern void nvme_mmap_close(IntPtr ptr, ulong size);
    }
}
