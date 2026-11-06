// NativeMetal.cs — Full C-ABI / P/Invoke bridge.
// Zero-copy from POSIX mmap pointer to CUDA via cudaHostRegister.
// Geometry checked against Agda invariants before the metal drop.
//
// Copyright (C) 2026 AHMAD ALI PARR
// Licensed under the GNU Affero General Public License v3.0 or later.
// See LICENSE for the full text.

using System;
using System.Runtime.InteropServices;

namespace Multimodal.Abstraction
{
    public static unsafe class NativeMetal
    {
        private const string CudaLibrary = "tubelet_kernel";

        [DllImport(CudaLibrary, CallingConvention = CallingConvention.Cdecl,
                   EntryPoint = "launch_tubelet_projection")]
        private static extern int LaunchTubeletProjectionInternal(
            IntPtr hostVideoTensor,
            IntPtr hostOutputSequence,
            int T, int H, int W, int C,
            int t_patch, int p_patch,
            int d_model);

        [DllImport("nvme_mmap", CallingConvention = CallingConvention.Cdecl)]
        public static extern int LaunchMmap(string path, out IntPtr ptr, out ulong size);

        [DllImport("nvme_mmap", CallingConvention = CallingConvention.Cdecl)]
        public static extern void nvme_mmap_close(IntPtr ptr, ulong size);

        /// <summary>
        /// Sovereign entry point. Verifies topology then drops into metal.
        /// </summary>
        public static void ProjectTubelets(
            IntPtr mmapVideoTensorPtr,
            float[] outputSequence,
            int T, int H, int W, int channels,
            int temporalSlice, int spatialSlice,
            int d_model)
        {
            int totalTubelets = (T / temporalSlice) * (H / spatialSlice) * (W / spatialSlice);
            int expectedLength = totalTubelets * d_model;

            if (outputSequence.Length != expectedLength)
                throw new InvalidOperationException(
                    $"Topology violation: expected {expectedLength}, got {outputSequence.Length}");

            fixed (float* pOutput = outputSequence)
            {
                int status = LaunchTubeletProjectionInternal(
                    mmapVideoTensorPtr,
                    (IntPtr)pOutput,
                    T, H, W, channels,
                    temporalSlice, spatialSlice,
                    d_model);

                if (status != 0)
                    throw new Exception($"CUDA launch failed with status {status}");
            }
        }

        /// <summary>
        /// Convenience wrapper that also opens the mmap.
        /// </summary>
        public static void ProjectFromFile(
            string holoPath,
            float[] outputSequence,
            int T, int H, int W, int C,
            int t, int p, int d_model)
        {
            if (LaunchMmap(holoPath, out IntPtr ptr, out ulong size) != 0)
                throw new Exception("mmap failed");

            try
            {
                ProjectTubelets(ptr, outputSequence, T, H, W, C, t, p, d_model);
            }
            finally
            {
                nvme_mmap_close(ptr, size);
            }
        }
    }
}
