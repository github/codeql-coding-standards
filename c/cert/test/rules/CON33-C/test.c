#include <threads.h>

// defined in <string.h> but we get absolute
// paths using the current alert so they are defined here.
// to prevent absolute paths from being generated.
char *strtok(char *__restrict, const char *__restrict);

void f1() {
  char str[] = "codeql";

  strtok(str, 'c'); // NON_COMPLIANT
}

int t1(void *param) {
  char str[] = "codeql";

  strtok(str, 'c'); // NON_COMPLIANT

  f1();

  return 0;
}

int main() {

  char str[] = "codeql";

  strtok(str, 'c'); // COMPLIANT
  thrd_t t;
  thrd_create(&t, t1, NULL);
}