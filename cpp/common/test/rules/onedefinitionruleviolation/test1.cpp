#include "test.h"

namespace ns1 {
constexpr int S1::S2::m1; // COMPLIANT; defines m1 in scope S1
}

enum E1 { // COMPLIANT
  M1,
  M2,
  M3
};

struct S1 { // COMPLIANT
  int m1;
  char *m2;
};

inline void
f1(){}; // COMPLIANT; exemption listed in N3797 [basic.def.odr] point 6.

extern void f2();
inline void f3() { f2(); } // NON_COMPLIANT[FALSE_NEGATIVE]

template <typename T>
class T1 { // COMPLIANT; exemption listed in N3797 [basic.def.odr] point 6.
};

template <typename T>
class T2 { // NON_COMPLIANT[FALSE_NEGATIVE]; differs from definition in
           // test2.cpp
public:
  T2() {}
  int f1(int i = 0) { return i + 1; }
};

template <typename T> void f2(T p1){}; // NON_COMPLIANT[FALSE_NEGATIVE]

struct S2 { // NON_COMPLIANT[FALSE_NEGATIVE]
  int f1;
};