#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

char *info = NULL;

void log_local_unsafe(void) { fputs(info, stderr); }

void handler1(int signum) {
  log_local_unsafe(); // NON_COMPLIANT
  free(info);         // NON_COMPLIANT
  info = NULL;
}

int f1(void) {
  if (signal(SIGINT, handler1) == SIG_ERR) {
    //...
  }

  log_local_unsafe();

  return 0;
}

volatile sig_atomic_t eflag = 0;

void handler2(int signum) { eflag = 1; }

int f2(void) {
  if (signal(SIGINT, handler2) == SIG_ERR) {
    // ...
  }

  while (!eflag) {
    log_local_unsafe();
  }

  return 0;
}

#include <setjmp.h>

static jmp_buf env;

void handler3(int signum) {
  longjmp(env, 1); // NON_COMPLIANT
}

int f3(void) {
  if (signal(SIGINT, handler3) == SIG_ERR) {
    // ...
  }
  log_local_unsafe();

  return 0;
}

int f4(void) {
  if (signal(SIGINT, handler2) == SIG_ERR) {
    // ...
  }

  while (!eflag) {

    log_local_unsafe();
  }

  return 0;
}

void term_handler(int signum) { // SIGTERM handler
}

void int_handler(int signum) {
  // SIGINT handler
  if (raise(SIGTERM) != 0) { // NON_COMPLIANT
    // ...
  }
  if (raise(SIGINT) != 0) { // COMPLIANT
    // ...
  }
  if (raise(signum) != 0) { // COMPLIANT
    // ...
  }
}

int f5(void) {
  if (signal(SIGTERM, term_handler) == SIG_ERR) {
    // ...
  }
  if (signal(SIGINT, int_handler) == SIG_ERR) {
    // ...
  }

  if (raise(SIGINT) != 0) {
    // ...
  }

  return EXIT_SUCCESS;
}

void int_handler6(int signum) {

  term_handler(SIGTERM); // COMPLIANT
}

int f6(void) {
  if (signal(SIGTERM, term_handler) == SIG_ERR) {
    // ...
  }
  if (signal(SIGINT, int_handler6) == SIG_ERR) {
    // ...
  }

  if (raise(SIGINT) != 0) {
    // ...
  }

  return EXIT_SUCCESS;
}
