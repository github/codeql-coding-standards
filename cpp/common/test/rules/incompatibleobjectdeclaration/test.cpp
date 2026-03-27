short i;                // NON_COMPLIANT
int a[] = {1, 2, 3, 4}; // NON_COMPLIANT
long b; // NON_COMPLIANT[FALSE_NEGATIVE] -- compiler does not extract c linkage
extern int c[]; // COMPLIANT
extern int d;   // COMPLIANT