// NOTICE: SOME OF THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.

#include <tuple>

int test_used(int x) { return x; } // COMPLIANT

void test_unused(int x) {} // NON_COMPLIANT

void test_unnamed(
    int) { // COMPLIANT - unnamed parameters are allowed to be unused
}

class A {
  int a(int x) { return x; }      // COMPLIANT
  void b(int x) {}                // NON_COMPLIANT
  void c(int) {}                  // COMPLIANT
  virtual void d(int x, int y) {} // virtual, not covered by this rule
};

void f(
    int i,                 // COMPLIANT
    int j,                 // COMPLIANT
    int k,                 // COMPLIANT
    [[maybe_unused]] int l // COMPLIANT: explicitly stated as [[maybe_unused]]
) {
  static_cast<void>(i); // COMPLIANT: explicitly ignored by static_cast to void
  (void)j;              // COMPLIANT: explicitly ignored by c-style cast to void
  std::ignore = k; // COMPLIANT: explicitly ignored by assignment to std::ignore
}

void test_lambda_expr() {
  auto lambda =
      [](int x, // COMPLIANT: used
         int y, // NON_COMPLIANT: unused without explicit notice
         [[maybe_unused]] int z, // COMPLIANT: stdattribute [[maybe_unused]]
         int w,                  // COMPLIANT: static_cast to void
         int u,                  // COMPLIANT: c-style cast to void
         int) {                  // COMPLIANT: unnamed parameter
        static_cast<void>(w);
        (void)u;
        return x;
      };
}

void test_no_def(int x); // COMPLIANT - no definition, so cannot be "unused"
