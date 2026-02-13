
int g0;            // COMPLIANT -- external linkage
static int sg0;    // NON_COMPLIANT -- internal linkage, but never used
const int cg0 = 0; // NON_COMPLIANT -- internal linkage, but never used, not in
                   // header
extern const int ecg0 = 0; // COMPLIANT -- external linkage
// tests compliant case of unused constant variable in header file
#include "test_header.hpp"

// Introduce anonymous namespace to define variables with internal linkage
namespace {
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

template <int t> struct C1 {
  int array[t]; // COMPLIANT
};

constexpr int g5 = 1; // COMPLIANT - used as template parameter

namespace ns1 {
constexpr int m1 = 1; // COMPLIANT - used a template parameter
}

void test_fp_reported_in_384() {
  struct C1<g5> l1;
  struct C1<ns1::m1> l2;

  l1.array[0] = 1;
  l2.array[0] = 1;
}
} // namespace