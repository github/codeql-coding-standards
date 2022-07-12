extern int g1; // ignored, declaration only
int g2;        // COMPLIANT - used in test_gs()
int g3;        // NON_COMPLIANT - never used
int g4;        // COMPLIANT - used in `B` constructor

#define m1()                                                                   \
  int mx1;                                                                     \
  int f2() { return mx1; }

m1(); // ignore dead code in macros

class GA {};
class GB {
public:
  GB() { g4 = 10; }
};

GA a; // NON_COMPLIANT - never used, and does not have a constructor call
GB b; // COMPLIANT - has a constructor call

void test_gs() { g2 = 1; }

namespace N1 {
extern int x1; // ignored, declaration only
int x2;        // COMPLIANT - used in test_gs()
int x3;        // NON_COMPLIANT - never used
int x4;        // COMPLIANT - used in `B` constructor
int x5;        // COMPLIANT - used outside `N1`, in `test_access_variable`

class N1A {};
class N1B {
public:
  N1B() { x4 = 10; }
};

N1A a; // NON_COMPLIANT - never used, and does not have a constructor call
N1B b; // COMPLIANT - has a constructor call

void test_ns() { x2 = 1; }

m1(); // ignore dead code in macros
} // namespace N1

int test_access_variable() { return N1::x5; }