int g1 = 0;        // NON_COMPLIANT
static int g2 = 1; // COMPLIANT; internal linkage

inline void f1() {} // COMPLIANT; inline functions are an exception

void f2() {} // NON_COMPLIANT