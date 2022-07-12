/** Test cases for `UnusedLocalVariable.ql` */

#define m1 int mx1 = 0;

int test_simple() {
  int x = 1; // COMPLIANT - used below
  int y = 2; // NON_COMPLIANT - never used
  m1         // we ignore unused variables in macros
      return x;
}

int test_const() {
  const int x = 1; // COMPLIANT - used below
  const int y = 2; // COMPLIANT[FALSE_POSITIVE] - used in array initialization,
                   // but the database does not contain sufficient information
                   // for this case
  int z[y];        // NON_COMPLIANT - never used
  return x;
}

template <class T> int f1() {
  int x = 1; // COMPLIANT - used in return value
  T t;       // NON_COMPLIANT - t is never used in any instantiation
             // Note: this gets reported twice, once for each instantiation
  return x;
}

class LA {};
class LB {};

void test_f1() {
  f1<LA>();
  f1<LB>();
}

int gc1 = 0;

class LC {
public:
  LC() { gc1++; }
};

void test_side_effect_init() {
  LA a; // NON_COMPLIANT - no constructor called
  LC c; // COMPLIANT - constructor called which is considered to potentially
        // have side effects
}