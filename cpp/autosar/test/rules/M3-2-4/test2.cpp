int g1 = 1;        // NON_COMPLIANT
static int g2 = 1; // COMPLIANT; internal linkage

namespace ns1 {
const int m1 = 0;        // COMPLIANT; internal linkage
extern const int m2 = 0; // NON_COMPLIANT
} // namespace ns1

template <typename T> class C1 {}; // COMPLIANT; templates are an exception
inline void f1() {} // COMPLIANT; inline functions are an exception

void f2() {} // NON_COMPLIANT