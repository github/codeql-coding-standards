void f1(int *x);
void f2(int x);
void f3(char *x);
// Template function which forwards to a pointer function
template <typename F, typename X> void f3(F f, X x) { f1(x); }

#define NULL 0

void test_nullptr() {
  int *l1 = 0;       // NON_COMPLIANT - 0 converted to a pointer type
  f1(0);             // NON_COMPLIANT - 0 converted to a pointer type
  int *l2 = nullptr; // COMPLIANT - use of nullptr
  f1(nullptr);       // COMPLIANT - use of nullptr
  f2(0);           // COMPLIANT - use of 0 literal with no conversion to pointer
  int l3 = 0;      // COMPLIANT - use of 0 literal with no conversion to pointer
  f3(f1, nullptr); // COMPLIANT - use of nullptr
  f1(NULL);        // NON_COMPLIANT - use of NULL macro
  f1('\0');        // NON_COMPLIANT - use of octal escape 0
  f3("0");         // COMPLIANT - "0" is not a literal zero
}