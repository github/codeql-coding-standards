#define NEGATIVE(x) -(x)
#define WIDTH(x) (sizeof(x) * 8)

void test() {
  unsigned int a = 0;

  // test operand to >>
  a = a >> 0;              // COMPLIANT
  a = a >> 1;              // COMPLIANT
  a = a >> (WIDTH(a) - 1); // COMPLIANT

  // test operand to <<
  a = a << 0;              // COMPLIANT
  a = a << 1;              // COMPLIANT
  a = a << (WIDTH(a) - 1); // COMPLIANT

  // test operand to <<=
  a <<= 0;              // COMPLIANT
  a <<= 1;              // COMPLIANT
  a <<= (WIDTH(a) - 1); // COMPLIANT

  // test operand to >>=
  a >>= 0;              // COMPLIANT
  a >>= 1;              // COMPLIANT
  a >>= (WIDTH(a) - 1); // COMPLIANT

  // test negative operand to >>
  a = a >> -1;          // NON_COMPLIANT
  a = a >> NEGATIVE(1); // NON_COMPLIANT

  // test negative operand to <<
  a = a << -1;          // NON_COMPLIANT
  a = a << NEGATIVE(1); // NON_COMPLIANT

  // test positive operand to >>
  a = a >> WIDTH(a);       // NON_COMPLIANT
  a = a >> (WIDTH(a) + 1); // NON_COMPLIANT

  // test positive operand to <<
  a = a << WIDTH(a);       // NON_COMPLIANT
  a = a << (WIDTH(a) + 1); // NON_COMPLIANT

  // test negative operand to >>=
  a >>= -1;          // NON_COMPLIANT
  a >>= NEGATIVE(1); // NON_COMPLIANT

  // test negative operand to <<=
  a <<= -1;          // NON_COMPLIANT
  a <<= NEGATIVE(1); // NON_COMPLIANT

  // test positive operand to >>=
  a >>= WIDTH(a);       // NON_COMPLIANT
  a >>= (WIDTH(a) + 1); // NON_COMPLIANT

  // test positive operand to <<=
  a <<= WIDTH(a);       // NON_COMPLIANT
  a <<= (WIDTH(a) + 1); // NON_COMPLIANT
}