/*
 * nvme_mmap.c — Zero-copy POSIX mmap persistence layer for video tensors.
 * Maps raw frames directly from NVMe into a contiguous block for CUDA.
 * C# host passes the pointer; no GC involvement.
 *
 * Copyright (C) 2026 AHMAD ALI PARR
 * Licensed under the GNU Affero General Public License v3.0 or later.
 * See LICENSE for the full text.
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>

/*
 * Maps a file (e.g. decoded frame dump or raw tensor) into process memory.
 * Returns pointer to the mapped region and the size via out-param.
 * Caller is responsible for munmap.
 */
int nvme_mmap_open(const char *path, void **out_ptr, size_t *out_size)
{
    int fd = open(path, O_RDONLY);
    if (fd < 0) return -1;

    struct stat st;
    if (fstat(fd, &st) < 0) {
        close(fd);
        return -1;
    }

    void *ptr = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);

    if (ptr == MAP_FAILED) return -1;

    *out_ptr = ptr;
    *out_size = (size_t)st.st_size;
    return 0;
}

void nvme_mmap_close(void *ptr, size_t size)
{
    if (ptr && size) munmap(ptr, size);
}

/* Export for P/Invoke */
__attribute__((visibility("default")))
int LaunchMmap(const char *path, void **ptr, size_t *sz)
{
    return nvme_mmap_open(path, ptr, sz);
}
