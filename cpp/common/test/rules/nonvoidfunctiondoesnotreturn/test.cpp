// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.
#include <cstdlib>
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

int test_return_f4(int i) { // COMPLIANT

  if (i > 0 && i < 10) {
    throw "Valid";
  }
  return i;
}

int test_return_f5(int i) { // NON_COMPLIANT
  if (i > 0) {
    return i;
  }
  if (i < 0) {
    return -i;
  }
}

int test_return_f6(int i) { // COMPLIANT
  throw "Valid";
}

int test_return_f7(int i) { // NON_COMPLIANT[FALSE_NEGATIVE]
  if (i > 0) {
    std::abort();
  }
  return 0;
}

int test_return_f8(int i) { std::abort(); } // NON_COMPLIANT[FALSE_NEGATIVE]

int test_trycatch_f1(int i) { // NON_COMPLIANT
  try {
    return 42;
  } catch (int i) {
  }
}
int test_trycatch_f2(int i) { // COMLIANT
  try {
    if (i > 0) {
      i = i + 100;
    }
    return i;
  } catch (int i) {
    return i;
  }
}