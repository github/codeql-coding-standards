void test_sizeof(void) {
  int l1 = 0;
  int l2 = sizeof(l1);   // COMPLIANT
  int l3 = sizeof(l1++); // NON_COMPLIANT
  int l4 =
      sizeof(int[++l1]); // COMPLIANT - see ISO/IEC 9899:201x 6.5.3.4 point 2
  int l5 = sizeof(
      int[++l1 % 1 + 1]); // NON_COMPLIANT[FALSE_NEGATIVE] - we cannot determine
                          // for all cases whether the size of the VLA is
                          // affected requiring the evaluation of the operand.
}

void test_alignof(void) {
  int l1 = 0;
  int l2 = _Alignof(++l1);      // NON_COMPLIANT
  int l3 = _Alignof(int[++l1]); // NON_COMPLIANT[FALSE_NEGATIVE]
  l1++;
  int l4 = _Alignof(int[l1]); // COMPLIANT
}

void test_generic(void) {
  int l1 = 0;

  int l2 = _Generic(++l1, int : 1, double : 2, long double : 3,
                    default : 0); // NON_COMPLIANT[FALSE_NEGATIVE]
}