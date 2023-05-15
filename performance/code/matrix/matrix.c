#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

int matrix_sum_row_traversal(int *m, int X, int Y) {
    int sum = 0;
    for(int y = 0; y < Y; y++) {
        for(int x = 0; x < X; x++) {
            if(x != y) {
                sum += m[y * X + x];
            }
        }
    }

    return sum;
}

int matrix_sum_col_traversal(int *m, int X, int Y) {
    int sum = 0;
    for(int x = 0; x < X; x++) {
        for(int y = 0; y < Y; y++) {
            if(x != y) {
                sum += m[y * X + x];
            }
        }
    }

    return sum;
}

void benchmark(int (*fn)(int *, int, int), const char *name) {
    int X = 20000;
    int Y = 20000;
    int *m = malloc(X * Y * sizeof(int));
    for(int i = 0; i < X*Y; i++) {
        m[i] = i;
    }

    clock_t t = clock();
    fn(m, X, Y);

    t = clock() - t;
    double time_taken = ((double)t)/CLOCKS_PER_SEC;
    printf("%s: %fs\n", name, time_taken);
    free(m);
}

int main(int argc, char **argv) {
    benchmark(matrix_sum_row_traversal, "row");
    benchmark(matrix_sum_col_traversal, "col");
    return EXIT_SUCCESS;
}
