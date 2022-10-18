#define MACRO(OP, L, R) ((L)OP(R))
#define MACRO2(L, R) (L + R)
#define MACRO3(L, R) (L " " R " " L)
#define MACRO4(L)                                                              \
  (L" "                                                                        \
   "suffix")
#define MACRO5(L, LR) (LR + 1)
#define MACRO6(X, LR) (LR + 1)

const char a1[MACRO2(1, 1) + 6]; // COMPLIANT

void f() {
  int i = MACRO(+, 1, 1); // COMPLIANT

  int i2 = MACRO2(7, 10); // COMPLIANT

  static int i3 = MACRO2(1, 1); // COMPLIANT

  char *i4 = MACRO3("prefix", "suffix"); // NON_COMPLIANT

  char *i5 = MACRO4("prefix"); // COMPLIANT

  int i6 = MACRO5(1, 1); // COMPLIANT

  int i7 = MACRO6(1, 1); // COMPLIANT
}