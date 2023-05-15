#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

void *memcpy_basic(void * restrict dst, const void * restrict src, size_t n) {
    char *srcp = (char *)src;
    char *dstp = (char *)dst;
    for(size_t i = 0; i < n; i++) {
        dstp[i] = srcp[i];
    }

    return dst;
}

void *memcpy_chunks(void *restrict dst, const void *restrict src, size_t n) {
    uint64_t *dst64 = (uint64_t*)dst;
    uint64_t *src64 = (uint64_t*)src;
    size_t n64 = n/sizeof(uint64_t);

    size_t i = 0;
    for(; i < n64; i++) {
        dst64[i] = src64[i];
    }

    uint8_t *dst8 = (uint8_t*)dst;
    uint8_t *src8 = (uint8_t*)src;
    for(i *= sizeof(uint64_t); i < n; i++) {
        dst8[i] = src8[i];
    }

    return dst;
}

void benchmark(char *dst, char *src, size_t n, void* (*memcpy)(void *restrict, const void *restrict, size_t), const char *name) {
    clock_t t = clock();
    for(int i = 0; i < 1000; i++) {
        memcpy(dst, src, n);
    }

    t = clock() - t;
    double time_taken = ((double)t)/CLOCKS_PER_SEC;
    printf("%s: %fs\n", name, time_taken);
}

int main(int argc, char **argv) {
    const int n = 4 * 1024 * 1024;
    char *src = malloc(n);
    char *dst = malloc(n);

    for(int i = 0; i < n; i++) {
        src[i] = i % 256;
        dst[i] = 0;
    }

    benchmark(dst, src, n, memcpy_basic, "basic");
    benchmark(dst, src, n, memcpy_chunks, "chunks");
    benchmark(dst, src, n, memcpy, "system");
    return EXIT_SUCCESS;
}
