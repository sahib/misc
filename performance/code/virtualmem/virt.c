#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>

int main(void) {
    // allocate 1G of virtual memory:
    char *big = malloc(1024 * 1024 * 1024);
    while(true) {
        // convert 1M to residual memory at a time:
        for(int i = 0; i < 1024 * 1024; i++) {
            *big++ = i;
        }
        sleep(1);
        printf(".\n");
    }

    free(big);
}
