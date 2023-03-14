#include <stdlib.h>

#define EXIT(x) exit(x)
#define ABORT abort()
#define SYSTEM(x) system(x)
#define MULTIPLY(l1, l2) (l1 * l2)

void f1();
void f2() {
  exit(0);        // NON_COMPLIANT
  system("ls");   // NON_COMPLIANT
  abort();        // NON_COMPLIANT
  f1();           // COMPLIANT
  EXIT(0);        // NON_COMPLIANT - twice, one for function and one for macro
  ABORT;          // NON_COMPLIANT - twice, one for function and one for macro
  SYSTEM("ls");   // NON_COMPLIANT - twice, one for function and one for macro
  MULTIPLY(1, 2); // COMPLIANT
}
