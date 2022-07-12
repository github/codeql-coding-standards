void f();                  // COMPLIANT
extern void f1() {}        // COMPLIANT
static inline void f2() {} // COMPLIANT

template <typename T> void f3(T) { int i; } // COMPLIANT

template <typename T> void f5(T) { int i; } // COMPLIANT

template <> void f5<int>(int t) { int i; } // NON_COMPLIANT

void f4() {} // NON_COMPLIANT

int g;                       // NON_COMPLIANT
extern int g1;               // COMPLIANT
constexpr static int g2 = 1; // COMPLIANT

namespace n1 {
constexpr static int l = 1; // COMPLIANT
const static int l1 = 1;    // COMPLIANT
static int l2;              // COMPLIANT
static void f5() {}         // COMPLIANT
} // namespace n1

class A {};

static void f6(int a, A a1) { f3(a1); } // COMPLIANT