#include <assert.h>

#define MACRO(OP, L, R) ((L)OP(R))                      // COMPLIANT
#define MACRO2(L, R) (L + R)                            // COMPLIANT
#define MACRO3(L, R) (L " " R " " L)                    // COMPLIANT
#define MACRO4(x) (x + 1)                               // NON_COMPLIANT
#define MACRO5(L, LR) (LR + 1)                          // COMPLIANT
#define MACRO6(x) printf_custom("output = %d", test##x) // COMPLIANT
#define MACRO7(x) #x                                    // COMPLIANT
#define MACRO8(x) "NOP"                                 // COMPLIANT
#define MACRO9() printf_custom("output = %d", 7)        // NON_COMPLIANT
#define MACRO10(x)                                      // COMPLIANT
#define MY_ASSERT(X) assert(X) // NON_COMPLIANT[FALSE_NEGATIVE]

const char a1[MACRO2(1, 1) + 6];
extern printf_custom();
int test1;

void f() {
  int i = MACRO(+, 1, 1);
  int i2 = MACRO2(7, 10);

  static int i3 = MACRO2(1, 1);

  char *i4 = MACRO3("prefix", "suffix");

  int i5 = MACRO4(1);

  int i6 = MACRO4(MACRO2(1, 1));

  int i7 = MACRO5(1, 1);

  MACRO6(1);

  char *i10 = MACRO7("prefix");

  asm(MACRO8(1));

  MY_ASSERT(1);
}