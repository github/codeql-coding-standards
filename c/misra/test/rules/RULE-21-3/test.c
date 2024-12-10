// Note: A subset of these cases are also tested in c/misra/test/rules/RULE-1-5
// via a MemoryAllocDeallocFunctionsOfStdlibhUsed.qlref and .expected file in
// that directory. Changes to these tests may require updating the test code or
// expectations in that directory as well.

#include <stdio.h>
#include <stdlib.h>
void f2();
void f1() {
  int *p1, *p2;
  int l1;

  p1 = (int *)malloc(l1 * sizeof(int)); // NON_COMPLIANT
  p2 = (int *)calloc(l1, sizeof(int));  // NON_COMPLIANT
  p2 = realloc(p2, l1 * sizeof(int));   // NON_COMPLIANT
  free(p1);                             // NON_COMPLIANT
  free(p2);                             // NON_COMPLIANT
  f2();                                 // COMPLIANT
}
