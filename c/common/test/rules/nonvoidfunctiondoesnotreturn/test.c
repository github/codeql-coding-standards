// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C++ TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.
#include <stdlib.h>
int test_return_f1(int i) { // NON_COMPLIANT
  if (i > 100) {
    return i;
  }
}

int test_return_f2(int i) { // COMPLIANT
  if (i > 0) {
    return i;
  } else {
    return -i;
  }
}

int test_return_f3(int i) {} // NON_COMPLIANT

int test_return_f5(int i) { // NON_COMPLIANT
  if (i > 0) {
    return i;
  }
  if (i < 0) {
    return -i;
  }
}
