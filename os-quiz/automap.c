#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>
#include <signal.h>
#include <execinfo.h>

#define AUTOMAP_COOKIE (0xc908ac34)
#define AUTOMAP(x) {(automap.cookie=AUTOMAP_COOKIE); sigsetjmp(automap.jump, 1);}; x; (automap.cookie=0);
// #define AUTOMAP(x) {probe_begin("automap"); (automap.cookie=AUTOMAP_COOKIE); sigsetjmp(automap.jump, 1);}; probe_begin("access"); x; probe_end(); (automap.cookie=0); {probe_end();};
// define AUTOMAP(x) x;

typedef void (*do_func_t)(void);

struct {
    int cookie;
    off_t addr;
    sigjmp_buf jump;
    do_func_t do_func;
} automap;

void print_trace(void) {
    void *array[10];
    char **strings;
    int size, i;

    size = backtrace (array, 10);
    strings = backtrace_symbols (array, size);
    if (strings != NULL) {
        printf ("Obtained %d stack frames.\n", size);
        for (i = 0; i < size; i++)
            printf ("%s\n", strings[i]);
    }
    free (strings);
}

void automap_handler(int sig, siginfo_t *info, void *context) {
    if (sig == SIGSEGV) {
        if (automap.cookie == AUTOMAP_COOKIE) {
            automap.addr = (off_t)info->si_addr;
            // NOTE: calling this function in a signal handler is usually not a good idea!
            //       But we only use AUTOMAP while accessing pointer values and are not calling abritary functions.
            //       So, it might be okay??? At least, it works at the moment.
            automap.do_func();
            siglongjmp(automap.jump, 1);
        } else {
            printf("%llX\n", (off_t)info->si_addr);
            print_trace();
            signal(SIGSEGV, SIG_DFL);
            raise(SIGSEGV);
        }
    }
}

void automap_init(do_func_t do_func) {
    struct sigaction sa;
    sa.sa_sigaction = automap_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO | SA_RESTART;
    automap.do_func = do_func;

    if (sigaction(SIGSEGV, &sa, NULL) == -1) {
        perror("sigaction");
        exit(1);
    }
}

void main(void) {
    automap_init(NULL);
    AUTOMAP(auto texts = state->global->se->texts);
}
