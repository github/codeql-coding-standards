#include <signal.h>
static void catch_function(int p1) {}
void f1(void) {
  if (signal(SIGINT, catch_function) == SIG_ERR) { // NON_COMPLIANT
  }
  if (raise(SIGINT) != 0) { // NON_COMPLIANT
  }
  catch_function(1); // COMPLIANT
}
