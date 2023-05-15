#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/time.h>

void read_seq(int fd, int devnull_fd) {
    char buf[4 * 1024];
    size_t bytes_read = 0;
    int c = 0;
    while((bytes_read = read(fd, buf, sizeof(buf))) > 0) {
        write(devnull_fd, buf, bytes_read);
        c += bytes_read;
    }

    // printf("READ: %d\n", c);
}

void read_random(int fd, int devnull_fd) {
    off_t size = lseek(fd, 0, SEEK_END);

    size_t bytes_read = 0;
    char buf[4 * 1024];
    int c = 0;

    while(c < size) {
        off_t curr = rand() % (size - sizeof(buf));
        lseek(fd, curr, SEEK_SET);

        bytes_read = read(fd, buf, sizeof(buf));
        write(devnull_fd, buf, bytes_read);
        c += bytes_read;
    }

    // printf("READ: %d\n", c);
}

void read_backwards(int fd, int devnull_fd) {
    off_t size = lseek(fd, 0, SEEK_END);
    off_t curr = size;

    size_t bytes_read = 0;
    char buf[4 * 1024];
    int c = 0;

    bool end = false;
    while(end == false) {
        curr -= sizeof(buf);

        int to_read = sizeof(buf);
        if(curr <= 0) {
            to_read = -curr;
            curr = 0;
            end = true;
        }
        lseek(fd, curr, SEEK_SET);

        bytes_read = read(fd, buf, to_read);
        write(devnull_fd, buf, bytes_read);
        c += bytes_read;
    }

    // printf("READ: %d\n", c);
}

int main(int argc, char **argv) {
    if(argc < 4) {
        printf("usage: %s [advice_{normal,seq,random,willneed,dontneed}] [read_{seq,random,backwards}] [file]\n", argv[0]);
        exit(1);
    }

    int advice;
    if(strcmp(argv[1], "advice_seq") == 0) {
        advice = POSIX_FADV_SEQUENTIAL;
    } else if(strcmp(argv[1], "advice_random") == 0) {
        advice = POSIX_FADV_RANDOM;
    } else if(strcmp(argv[1], "advice_willneed") == 0) {
        advice = POSIX_FADV_WILLNEED;
    } else if(strcmp(argv[1], "advice_dontneed") == 0) {
        advice = POSIX_FADV_DONTNEED;
    } else if(strcmp(argv[1], "advice_normal") == 0) {
        advice = POSIX_FADV_NORMAL;
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
    if(posix_fadvise(fd, 0, size, advice) < 0) {
        printf("giving advice failed: %s\n", strerror(errno));
        exit(4);
    }
    lseek(fd, 0, SEEK_SET);

    int devnull_fd = open("/dev/null", O_WRONLY);

    // give kernel time to fulfill the advice:
    // sleep(10);

    struct timeval before, after;
    gettimeofday(&before, NULL);

    if(strcmp(argv[2], "read_seq") == 0) {
        read_seq(fd, devnull_fd);
    } else if(strcmp(argv[2], "read_random") == 0) {
        srand(42);
        read_random(fd, devnull_fd);
    } else if(strcmp(argv[2], "read_backwards") == 0) {
        read_backwards(fd, devnull_fd);
    } else {
        printf("unknown read mode: %s\n", argv[2]);
        exit(5);
    }
    gettimeofday(&after, NULL);
    double seconds = (after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec) / 1e6;

    printf("%s\t%s\t%.2fs\n", argv[2], argv[1], seconds);
    close(fd);
}
