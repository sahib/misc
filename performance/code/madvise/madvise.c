#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/time.h>

const int chunk_size = 4 * 1024;

void read_seq(void *m, off_t size, int devnull_fd) {
    off_t c = 0;
    for(off_t idx = 0; idx < size; idx += chunk_size) {
        off_t b = chunk_size;
        if(idx + chunk_size > size) {
            b = size - idx;
        }
        c += write(devnull_fd, m+idx, b);
    }

    // printf("WRITE %d\n", c);
}

void read_random(void *m, off_t size, int devnull_fd) {
    off_t c = 0;
    for(off_t idx = 0; idx < size; idx += chunk_size) {
        off_t off = rand() % (size - chunk_size);
        c += write(devnull_fd, m+off, chunk_size);
    }

    // printf("WRITE: %d\n", c);
}

void read_backwards(void *m, off_t size, int devnull_fd) {
    int c = 0;
    for(off_t idx = size; idx >= 0; idx -= chunk_size) {
        off_t b = chunk_size;
        if(idx <= 0) {
            b -= idx;
        }
        c += write(devnull_fd, m+idx, b);
    }

    // printf("WRITE: %d\n", c);
}

int main(int argc, char **argv) {
    if(argc < 4) {
        printf("usage: %s [advice_{normal,seq,random,willneed,dontneed}] [read_{seq,random,backwards}] [file]\n", argv[0]);
        exit(1);
    }

    int advice;
    if(strcmp(argv[1], "advice_seq") == 0) {
        advice = MADV_SEQUENTIAL;
    } else if(strcmp(argv[1], "advice_random") == 0) {
        advice = MADV_RANDOM;
    } else if(strcmp(argv[1], "advice_willneed") == 0) {
        advice = MADV_WILLNEED;
    } else if(strcmp(argv[1], "advice_dontneed") == 0) {
        advice = MADV_DONTNEED;
    } else if(strcmp(argv[1], "advice_normal") == 0) {
        advice = MADV_NORMAL;
    } else {
        printf("unknown advice: %s\n", argv[1]);
        exit(2);
    }

    int fd = open(argv[3], O_RDONLY);
    if(fd < 0) {
        printf("failed to open input file\n");
        exit(3);
    }

    off_t size = lseek(fd, 0, SEEK_END);
    void *m = mmap(NULL, size, PROT_READ, MAP_SHARED, fd, 0);

    if(madvise(m, size, advice) < 0) {
        printf("giving advice failed: %s\n", strerror(errno));
        exit(4);
    }

    // give kernel time to fulfill the advice:
    // sleep(10);

    int devnull_fd = open("/dev/null", O_WRONLY);

    struct timeval before, after;
    gettimeofday(&before, NULL);

    if(strcmp(argv[2], "read_seq") == 0) {
        read_seq(m, size, devnull_fd);
    } else if(strcmp(argv[2], "read_random") == 0) {
        srand(42);
        read_random(m, size, devnull_fd);
    } else if(strcmp(argv[2], "read_backwards") == 0) {
        read_backwards(m, size, devnull_fd);
    } else {
        printf("unknown read mode: %s\n", argv[2]);
        exit(5);
    }
    gettimeofday(&after, NULL);
    double seconds = (after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec) / 1e6;

    printf("%s\t%s\t%.3fs\n", argv[2], argv[1], seconds);
    close(fd);
}
