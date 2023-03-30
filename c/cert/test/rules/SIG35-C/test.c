#include <errno.h>
#include <limits.h>
#include <signal.h>
#include <stdlib.h>

volatile sig_atomic_t eflag;

void sighandle(int s) { // NON_COMPLIANT
  eflag = 1;
}

int f1(int argc, char *argv[]) {
  signal(SIGFPE, sighandle);

  return 0;
}

void sighandle2(int s) { // COMPLIANT
  eflag = 1;
  abort();
}

int f2(int argc, char *argv[]) {
  signal(SIGFPE, sighandle2);
  return 0;
}
