#include <float.h>
#include <stdlib.h>
void f2();
void f1() {
  char l1[5] = "abcde";
  float l2 = atof(l1);      // NON_COMLIANT
  int l3 = atoi(l1);        // NON_COMPLIANT
  long l4 = atol(l1);       // NON_COMPLIANT
  long long l5 = atoll(l1); // NON_COMPLIANT
  f2();                     // COMPLIANT
}
