void f(); // COMPLIANT

void f1() {}        // NON_COMPLIANT
inline void f2() {} // COMPLIANT

template <typename T> void f3(T){}; // COMPLIANT - implicitly inline

int i;             // NON_COMPLIANT
extern int i1 = 1; // NON_COMPLIANT

constexpr auto i2{1}; // COMPLIANT - not external linkage

struct S {
  int i;                         // COMPLIANT - no linkage
  inline static const int i1{1}; // COMPLIANT - inline
};

class C {
  static int m(); // COMPLIANT
  int m1();       // COMPLIANT
};

int C::m() {}  // NON_COMPLIANT
int C::m1() {} // NON_COMPLIANT