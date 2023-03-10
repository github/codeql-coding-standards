#include <setjmp.h>

void f1() {
  jmp_buf env; // COMPLIANT - Assumption of features outlined in rule is
               // functions only.
  int i;
  i = setjmp(env); // NON_COMPLIANT
  longjmp(env, 2); // NON_COMPLIANT
}
