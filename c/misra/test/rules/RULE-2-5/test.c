#include "test.h"
#define MACRO1 1 // COMPLIANT
#define MACRO2 2 // COMPLIANT
#define MACRO3 3 // NON_COMPLIANT

#undef MACRO1

// This case is not captured by the query
#define MACRO1 1 // NON_COMPLIANT[FALSE_NEGATIVE]

#undef HEADER_MACRO1

void test() {
  MACRO2;
  HEADER_MACRO2;
}