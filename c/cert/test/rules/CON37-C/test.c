#include <signal.h>
#include <stddef.h>
#include <threads.h>

int f(void *param) { return 0; }

int main(void) {
  signal(SIGUSR1, NULL); // NON_COMPLIANT
  thrd_t t;
  thrd_create(&t, f, NULL);

  return 0;
}