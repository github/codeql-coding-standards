void f1(int *x);
void f2(int x);

// Template function which forwards to a pointer function
template <typename F, typename X> void f3(F f, X x) { f1(x); }

#define NULL 0

struct ClassA {
  int *x;
};

#define CLASSA_INIT                                                            \
  { nullptr }

void test_nullptr() {
  int *l1 = 0;       // NON_COMPLIANT - 0 converted to a pointer type
  f1(0);             // NON_COMPLIANT - 0 converted to a pointer type
  int *l2 = nullptr; // COMPLIANT - use of nullptr
  f1(nullptr);       // COMPLIANT - use of nullptr
  f2(0);           // COMPLIANT - use of 0 literal with no conversion to pointer
  int l3 = 0;      // COMPLIANT - use of 0 literal with no conversion to pointer
  f3(f1, nullptr); // COMPLIANT - use of nullptr
  f1(NULL); // COMPLIANT - use of NULL macro is compliant according to this rule
            // only
  ClassA a = CLASSA_INIT; // COMPLIANT
}