
#define GOOD_MACRO_WITH_ARG(X) ((X)*X##_scale) // COMPLIANT
#define MACRO 1
#define BAD_MACRO_WITH_ARG(x) (x) + wow##x        // NON_COMPLIANT
#define BAD_MACRO_WITH_ARG_TWO(x, y) (x) + wow##x // NON_COMPLIANT
#define MACROONE(x) #x                            // COMPLIANT
#define MACROTWO(x) x *x                          // COMPLIANT
#define MACROTHREE(x) "##\"\"'" + (x)             // COMPLIANT
#define FOO(x) #x MACROONE(x) // COMPLIANT - no further arg expansion

void f() {

  int x;
  int x_scale;
  int y;
  int wowMACRO = 0;

  y = GOOD_MACRO_WITH_ARG(x);
  wowMACRO = BAD_MACRO_WITH_ARG(MACRO);
  wowMACRO = BAD_MACRO_WITH_ARG_TWO(MACRO, 1);
  char s[] = MACROONE(MACRO);
  y = MACROTWO(MACRO);
  MACROTHREE(MACRO);
  FOO(x);
}