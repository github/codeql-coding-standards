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

int test_for_loop() {
  for (int i = 0; i < 10; i++) { // COMPLIANT[FALSE_POSITIVE] - not sure why i
                                 // gets reported by M0-1-1
    if (0) {                     // NON_COMPLIANT
      return 1;
    } else { // COMPLIANT
      return 2;
    }
  }
  return 1; // NON_COMPLIANT[FALSE_NEGATIVE] but a compiler warning is emitted
            // if omitted so maybe not?
}

int test_while_loop() {
  int i;
  while (0) { // NON_COMPLIANT
    i++;
  }
  return i;
}