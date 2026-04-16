#include <string>

int g; // COMPLIANT

class A {
public:
  int m1;
};

void f(int p) {        // COMPLIANT - not applicable to parameters
  int i;               // NON_COMPLIANT
  int i1 = 0;          // COMPLIANT
  int i2[10] = {1, 0}; // COMPLIANT
  int i3[10];          // COMPLIANT
  A a;                 // COMPLIANT - default initialized
  A a1;
  a1.m1 = 1;            // COMPLIANT
  int *i4 = new int;    // NON_COMPLIANT
  int *i5 = new int(1); // COMPLIANT
  int *p4;              // NON_COMPLIANT
  p4 = new int;
  std::string s; // COMPLIANT
}

void test_non_default_init() {
  static int sl; // COMPLIANT - static variables are zero initialized
  thread_local int
      tl;          // COMPLIANT - thread local variables are zero initialized
  static int *slp; // COMPLIANT - static variables are zero initialized
  thread_local int
      *tlp; // COMPLIANT - thread local variables are zero initialized
  _Atomic int
      ai; // COMPLIANT - atomics are special and not covered by this rule
}

namespace {
int i; // COMPLIANT
}