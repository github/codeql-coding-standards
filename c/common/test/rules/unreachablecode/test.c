// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C++ TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.

void test_switch(int p1) {
  int l1 = 0;
  switch (p1) {
    l1 = p1; // NON_COMPLIANT[FALSE_NEGATIVE]
  case 1:
    break;
  default:
    break;
  }
}

int test_after_return() {
  return 0;
  int l1 = 0; // NON_COMPLIANT - function has returned by this point
}

int test_constant_condition() {
  if (0) { // NON_COMPLIANT
    return 1;
  } else { // COMPLIANT
    return 2;
  }
}