extern int g1;   // ignored, declaration only
int g2;          // NON_COMPLIANT - only used once in test_gs()
int g3;          // ignored, never used
int g4;          // NON_COMPLIANT - used in `B` constructor
int g5;          // COMPLIANT - used twice in test_gs
volatile int g6; // ignore, volatile variable

#define m1()                                                                   \
  int mx1;                                                                     \
  int f2() { return mx1; }

m1(); // ignore dead code in macros

class GA {
public:
  int x;
};
class GB {
public:
  GB() { g4 = 10; }
};
class GC { // Not a POD type
public:
  virtual void f() {}
};

GA a1; // ignored, never used, and does not have a constructor call
GA a2; // NON_COMPLIANT - used only once
GB b;  // ignored - only used once, but has a constructor call
GC c;  // ignored - only used once, not a POD type

void test_gs() {
  g5;
  g5;
  g2 = 1;
  b;
  g6 = 1;
  a2.x = 0;
  c.f();
}

namespace N1 {
extern int x1;   // ignored, declaration only
int x2;          // NON_COMPLIANT - used only once in test_ns()
int x3;          // ignored, never used
int x4;          // NON_COMPLIANT - used in `B` constructor
int x5;          // COMPLIANT - used twice in test_ns()
int x6;          // NON_COMPLIANT - used only once outside `N1`, in
                 // `test_access_variable`
volatile int x7; // ignore, volatile variable

class N1A {
public:
  int x;
};
class N1B {
public:
  N1B() { x4 = 10; }
};
class N1C { // Not a POD type
public:
  virtual void f() {}
};

N1A a1; // ignored, never used, and does not have a constructor call
N1A a2; // NON_COMPLIANT - used only once
N1B b;  // ignored, only used once, but has a constructor call
N1C c;  // ignored - only used once, not a POD type

void test_ns() {
  x5;
  x5;
  x2 = 1;
  b;
  x7 = 1;
  a2.x = 0;
  c.f();
}

m1(); // ignore dead code in macros
} // namespace N1

int test_access_variable() { return N1::x6; }