#include <stdlib.h>
#include <stdio.h>

void f() {
    int d;
    printf("stack d: %p\n", &d);
}

void stack(int depth) {
    if (depth <= 0) {
        return;
    }
    int a;
    printf("depth=%02d: a=%p\n", depth, &a);
    stack(depth-1);
}


int main(void) {
    stack(10);
    int a;
    int b;
    int c;
    int *x = malloc(sizeof(int));
    int *y = malloc(sizeof(int));
    int *z = malloc(sizeof(int));

    printf("stack a: %p\n", &a);
    printf("stack b: %p\n", &b);
    printf("stack c: %p\n", &c);
    f();

    printf("\n");

    printf("heap x: %p\n", x);
    printf("heap y: %p\n", y);
    printf("heap z: %p\n", z);

    printf("diff: %.2f GB", (&a - x) / 1024. / 1024. / 1024.);
    return 0;
}
