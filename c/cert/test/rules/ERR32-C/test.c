#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>

typedef void (*pfv)(int);

void handler1(int signum) {
  pfv old_handler = signal(signum, SIG_DFL);
  if (old_handler == SIG_ERR) {
    perror(""); // NON_COMPLIANT
  }
}

void handler2a(int signum) {
  pfv old_handler = signal(signum, SIG_DFL);
  if (old_handler != SIG_ERR) {
    perror(""); // COMPLIANT
  } else {
    abort(); // COMPLIANT
  }
}

void handler2b(int signum) {
  pfv old_handler = signal(signum, SIG_DFL);
  if (old_handler != SIG_ERR) {
    perror(""); // COMPLIANT
  } else {
    perror(""); // NON_COMPLIANT
    abort();
  }
}

void handler3(int signum) { pfv old_handler = signal(signum, SIG_DFL); }

void handler4(int signum) {
  pfv old_handler = signal(signum, SIG_DFL);
  if (old_handler == SIG_ERR) {
    _Exit(0);
  }
}

void handler5(int signum) {
  pfv old_handler = signal(signum, SIG_DFL);
  if (old_handler != SIG_ERR) {
    perror(""); // COMPLIANT
  } else {
    perror(""); // NON_COMPLIANT
  }
}

int main(void) {
  pfv old_handler = signal(SIGINT, handler1);
  if (old_handler == SIG_ERR) {
    perror(""); // NON_COMPLIANT
  }

  old_handler = signal(SIGINT, handler2a);
  if (old_handler == SIG_ERR) {
    perror(""); // COMPLIANT
  }

  old_handler = signal(SIGINT, handler2b);

  old_handler = signal(SIGINT, handler3);

  old_handler = signal(SIGINT, handler4);

  old_handler = signal(SIGINT, handler5);

  FILE *fp = fopen("something", "r");
  if (fp == NULL) {
    perror("Error: "); // NON_COMPLIANT
  }
}
