#define NULL 0

void f1(int x);
void f2(int *x);

void test_null_as_integer() {
  10 + NULL;      // NON_COMPLIANT
  int l1 = NULL;  // NON_COMPLIANT
  f1(NULL);       // NON_COMPLIANT
  int *l2 = NULL; // COMPLIANT - for M4-10-1, but non compliant with A4-10-1
  f2(NULL);       // COMPLIANT - for M4-10-1, but non compliant with A4-10-1
}