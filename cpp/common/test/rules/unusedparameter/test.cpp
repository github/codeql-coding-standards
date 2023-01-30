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
   int i,
   int j,
   int k,
   [[maybe_unused]]
   int l                   // NON_COMPILANT: maybe_unused parameters should also be considered unused
 ) {
    static_cast<void>(i);  // NON_COMPILANT: static_cast to void should also be considered unused
    (void)j;               // NON_COMPILANT: C-style void casts should also be considered unused
    std::ignore = k;       // NON_COMPILANT: Assignment to std::ignore should also be considered unused
 }

void test_no_def(int x); // COMPLIANT - no definition, so cannot be "unused"