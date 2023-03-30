#include <signal.h>

void handler1(int signum) {
  if (signal(signum, handler1) == SIG_ERR) // NON_COMPLIANT
  {
    //...
  }
}

void f1(void) {
  if (signal(SIGUSR1, handler1) == SIG_ERR) {
    // ...
  }
}

void handler2(int signum) {
  if (signal(SIGUSR1, handler2) == SIG_ERR) // NON_COMPLIANT
  {
    //...
  }
}

void f2(void) {
  if (signal(SIGUSR1, handler2) == SIG_ERR) {
    // ...
  }
}
