extern int i;  // NON_COMPLIANT
extern int *a; // NON_COMPLIANT
extern "C" long
    b; // NON_COMPLIANT[FALSE_NEGATIVE] -- compiler does not extract c linkage
extern int c[1]; // COMPLIANT
extern int d{1}; // COMPLIANT

#include "test.h"
extern C<int[4]> x; // NON_COMPLIANT

extern A a1; // NON_COMPLIANT