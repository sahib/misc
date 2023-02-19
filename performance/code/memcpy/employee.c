#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

// try varying this from 8 to 256!
#define NAME_SIZE 256

void increase_income_oop(void) {
    typedef struct {
        char name[NAME_SIZE];
        double income;
    } Employee;

    Employee employee[200];
    for(int i = 0; i < 200; i++) {
        employee[i].income = 1;
        strcpy(employee[i].name, "Herbert");
    }

    for(int t = 0; t < 10000; t++) {
        for(int i = 0; i < 200; i++) {
            employee[i].income *= 1.5f;
        }
    }
}

void increase_income_dop(void) {
    char employeeName[200][NAME_SIZE];
    double employeeIncome[200];

    for(int i = 0; i < 200; i++) {
        employeeIncome[i] = 1;
        strcpy(employeeName[i], "Herbert");
    }

    for(int t = 0; t < 10000; t++) {
        for(int i = 0; i < 200; i++) {
            employeeIncome[i] *= 1.5f;
        }
    }
}

void benchmark(void (*fn)(void), const char *name) {
    clock_t t = clock();
    for(int i = 0; i < 1000; i++) {
        fn();
    }

    t = clock() - t;
    double time_taken = ((double)t)/CLOCKS_PER_SEC;
    printf("%s: %fs\n", name, time_taken);
}

int main(int argc, char **argv) {
    benchmark(increase_income_oop, "oop");
    benchmark(increase_income_dop, "dop");
    return EXIT_SUCCESS;
}
