#define MACRO(OP, L, R) ((L)OP(R))   // COMPLIANT
#define MACRO2(L, R) (L + R)         // COMPLIANT
#define MACRO3(L, R) (L " " R " " L) // COMPLIANT
#define MACRO4(L)                                                              \
  (L" "                                                                        \
   "suffix")                   // NON_COMPLIANT
#define MACRO5(L, LR) (LR + 1) // COMPLIANT
#define MACRO6(X, LR) (LR + 1) // COMPLIANT
#define MACRO7(x, y) x##y      // COMPLIANT

const char a1[MACRO2(1, 1) + 6];

void f() {
  int i = MACRO(+, 1, 1);
  int i2 = MACRO2(7, 10);

  static int i3 = MACRO2(1, 1);

  char *i4 = MACRO3("prefix", "suffix");

  char *i5 = MACRO4("prefix");

  char *i6 = MACRO4(MACRO2(1, 1));

  int i7 = MACRO5(1, 1);

  int i8 = MACRO6(1, 1);

  char *i9 = MACRO7("prefix", "suffix");
}