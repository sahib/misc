#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

volatile sig_atomic_t gOff = 1;
static void handler(int sig, siginfo_t *si, void *_) {
  gOff = 0;
  printf("Got SIGSEGV at address: 0x%lx %d\n",(long) si->si_addr, gOff);
}

int main(void) {
  struct sigaction sa;
  sa.sa_flags = SA_SIGINFO;
  sigemptyset(&sa.sa_mask);
  sa.sa_sigaction = handler;
  if(sigaction(SIGSEGV, &sa, NULL) == -1) {
    printf("signal register failed\n");
    return EXIT_FAILURE;
  }

  printf("OFF %d\n", gOff);
  char array[1] = {'\0'};
  if(gOff) {
    printf("trying to trigger sigsegv\n");
    array[10000*gOff] = '\0';
    // raise(SIGSEGV);
  }
  printf("OFF %d\n", gOff);

  printf("survived!\n");
  return 0;
}
