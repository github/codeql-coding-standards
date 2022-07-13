#include <limits>

void test() {
  float f; // NON_COMPLIANT

  double d;       // COMPLIANT
  long double ld; // COMPLIANT
}