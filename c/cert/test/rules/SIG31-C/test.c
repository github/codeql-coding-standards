#include <signal.h>
#include <stdlib.h>
#include <string.h>

char *err_msg;
void handler(int signum) {
  strcpy(err_msg, "SIGINT encountered."); // NON_COMPLIANT
}

void f1(void) {
  signal(SIGINT, handler);
  // ...
}

volatile sig_atomic_t e_flag1 = 0;
void handler2(int signum) {
  e_flag1 = 1; // COMPLIANT
}

void f2(void) {
  signal(SIGINT, handler2);
  // ...
}

#include <stdatomic.h>

atomic_int e_flag3 = ATOMIC_VAR_INIT(0);
void handler3(int signum) {
  e_flag3 = 1; // COMPLIANT
}

void f3(void) {
  if (!atomic_is_lock_free(&e_flag3)) {
    // ...
  }

  if (signal(SIGINT, handler3) == SIG_ERR) {
    // ...
  }
}
