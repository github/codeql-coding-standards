#include <exception>
#include <functional>
#include <memory>

// COMPLIANT - normal exception handling
void f1() {
  try {
  } catch (const std::exception &) {
  }
}

bool f2() { return std::uncaught_exception(); } // NON_COMPLIANT

struct IsZero {
  typedef int argument_type;
  bool operator()(int x) const { return x == 0; }
};

struct NotEqual {
  typedef int first_argument_type;
  typedef int second_argument_type;
  bool operator()(int x, int y) const { return x != y; }
};

std::unary_negate<IsZero> g1;  // NON_COMPLIANT
std::binary_negate<NotEqual> g2; // NON_COMPLIANT

void f3() {
  std::unary_negate<IsZero> l1;    // NON_COMPLIANT
  std::binary_negate<NotEqual> l2; // NON_COMPLIANT
  std::function<bool(int)> l3;     // COMPLIANT
}

void f4() {
  std::shared_ptr<int> p1;
  p1.unique();                 // NON_COMPLIANT
  p1.use_count();              // COMPLIANT
  (void)p1.unique();           // NON_COMPLIANT
  bool b = p1.unique();        // NON_COMPLIANT
}

void f5(std::shared_ptr<int> p1) {
  p1.unique(); // NON_COMPLIANT
}

#include <ccomplex> // NON_COMPLIANT
#include <cstdalign> // NON_COMPLIANT
#include <cstdbool> // NON_COMPLIANT
#include <ctgmath> // NON_COMPLIANT
#include <complex> // COMPLIANT
#include <stdalign.h> // COMPLIANT
#include <stdbool.h> // COMPLIANT
#include <tgmath.h> // COMPLIANT