#include <vector>
void f1();
void f2(int x);
void f3(int x, int y);
struct S1 {
  int x;
} g1, *g2;
int g3;

void f4() {
#define M1(X) X
  // No critical operators:
  M1(1);        // COMPLIANT
  M1((1));      // COMPLIANT
  M1("foo");    // COMPLIANT
  M1(("foo"));  // COMPLIANT
  M1(f1());     // COMPLIANT
  M1((f1));     // COMPLIANT
  M1(*"foo");   // COMPLIANT
  M1(!1);       // COMPLIANT
  M1(+1);       // COMPLIANT
  M1(-1);       // COMPLIANT
  M1("foo"[1]); // COMPLIANT
  M1(&"foo");   // COMPLIANT
  M1(g1.x);     // COMPLIANT
  M1(g2->x);    // COMPLIANT
  M1(g1.x++);   // COMPLIANT
  M1(++g1.x);   // COMPLIANT
  M1(g1.x--);   // COMPLIANT
  M1(--g1.x);   // COMPLIANT
  // M1(1, 1); -- not interpreted as a comma operator
  M1((1, 1));  // COMPLIANT
  M1(throw 1); // COMPLIANT

  // Level 13 operators:
  M1(1 * 1);   // NON-COMPLIANT
  M1((1 * 1)); // COMPLIANT
  M1(1 / 1);   // NON-COMPLIANT
  M1((1 / 1)); // COMPLIANT
  M1(1 % 1);   // NON-COMPLIANT
  M1((1 % 1)); // COMPLIANT
  // Level 12 operators:
  M1(1 + 1);   // NON-COMPLIANT
  M1((1 + 1)); // COMPLIANT
  M1(1 - 1);   // NON-COMPLIANT
  M1((1 - 1)); // COMPLIANT
  // Level 11 operators:
  M1(1 << 1);   // NON-COMPLIANT
  M1((1 << 1)); // COMPLIANT
  M1(1 >> 1);   // NON-COMPLIANT
  M1((1 >> 1)); // COMPLIANT
  // Level 10 operators:
  M1(1 < 1);    // NON-COMPLIANT
  M1((1 < 1));  // COMPLIANT
  M1(1 > 1);    // NON-COMPLIANT
  M1((1 > 1));  // COMPLIANT
  M1(1 <= 1);   // NON-COMPLIANT
  M1((1 <= 1)); // COMPLIANT
  M1(1 >= 1);   // NON-COMPLIANT
  M1((1 >= 1)); // COMPLIANT
  // Level 9 operators:
  M1(1 == 1);   // NON-COMPLIANT
  M1((1 == 1)); // COMPLIANT
  M1(1 != 1);   // NON-COMPLIANT
  M1((1 != 1)); // COMPLIANT
  // Level 8 operators:
  M1(1 & 1);   // NON-COMPLIANT
  M1((1 & 1)); // COMPLIANT
  // Level 7 operators:
  M1(1 ^ 1);   // NON-COMPLIANT
  M1((1 ^ 1)); // COMPLIANT
  // Level 6 operators:
  M1(1 | 1);   // NON-COMPLIANT
  M1((1 | 1)); // COMPLIANT
  // Level 5 operators:
  M1(1 && 1);   // NON-COMPLIANT
  M1((1 && 1)); // COMPLIANT
  // Level 4 operators:
  M1(1 || 1);   // NON-COMPLIANT
  M1((1 || 1)); // COMPLIANT
  // Level 3 operators:
  M1(1 ? 1 : 1);   // NON-COMPLIANT
  M1((1 ? 1 : 1)); // COMPLIANT
  // Level 2 operators:
  M1(g3 = 1);     // NON-COMPLIANT
  M1((g3 = 1));   // COMPLIANT
  M1(g3 += 1);    // NON-COMPLIANT
  M1((g3 += 1));  // COMPLIANT
  M1(g3 -= 1);    // NON-COMPLIANT
  M1((g3 -= 1));  // COMPLIANT
  M1(g3 *= 1);    // NON-COMPLIANT
  M1((g3 *= 1));  // COMPLIANT
  M1(g3 /= 1);    // NON-COMPLIANT
  M1((g3 /= 1));  // COMPLIANT
  M1(g3 %= 1);    // NON-COMPLIANT
  M1((g3 %= 1));  // COMPLIANT
  M1(g3 <<= 1);   // NON-COMPLIANT
  M1((g3 <<= 1)); // COMPLIANT
  M1(g3 >>= 1);   // NON-COMPLIANT
  M1((g3 >>= 1)); // COMPLIANT
  M1(g3 &= 1);    // NON-COMPLIANT
  M1((g3 &= 1));  // COMPLIANT
  M1(g3 ^= 1);    // NON-COMPLIANT
  M1((g3 ^= 1));  // COMPLIANT
  M1(g3 |= 1);    // NON-COMPLIANT
  M1((g3 |= 1));  // COMPLIANT
  // Level 1 and below are not critical operators, tested above.

// Precedence-protected macro:
#define M2(X) (X)
  M2(1 * 1);     // COMPLIANT
  M2(1 + 1);     // COMPLIANT
  M2(1 - 1);     // COMPLIANT
  M2(1 << 1);    // COMPLIANT
  M2(1 >> 1);    // COMPLIANT
  M2(1 < 1);     // COMPLIANT
  M2(1 > 1);     // COMPLIANT
  M2(1 <= 1);    // COMPLIANT
  M2(1 >= 1);    // COMPLIANT
  M2(1 == 1);    // COMPLIANT
  M2(1 != 1);    // COMPLIANT
  M2(1 & 1);     // COMPLIANT
  M2(1 ^ 1);     // COMPLIANT
  M2(1 | 1);     // COMPLIANT
  M2(1 && 1);    // COMPLIANT
  M2(1 || 1);    // COMPLIANT
  M2(1 ? 1 : 1); // COMPLIANT

// Macro that uses the # operator:
#define M3(X) #X
  M3(1 * 1);     // COMPLIANT
  M3(1 == 1);    // COMPLIANT
  M3(1 ? 1 : 1); // COMPLIANT

// Multi-argument macro:
#define M4(PROTECTED, UNPROTECTED) (PROTECTED), UNPROTECTED
  M4(1 * 1, 1); // COMPLIANT
  M4(1, 1 * 1); // NON-COMPLIANT

// Macro passed into a macro:
#define M5() 1 * 1
  M1(M5());   // NON-COMPLIANT
  M1((M5())); // COMPLIANT

  // Macro with function call:
  M1(f2(1 * 1)); // COMPLIANT

  // Macro with a string literal:
  M1("1 * 1"); // COMPLIANT

  // Macro with lots of silly parentheses:
  M1(1 * (1));     // NON-COMPLIANT
  M1((1) * 1);     // NON-COMPLIANT
  M1((1) * (1));   // NON-COMPLIANT
  M1((1 * 1) * 1); // NON-COMPLIANT
  M1(1 * (1 * 1)); // NON-COMPLIANT
  M1(((1 * 1)));   // COMPLIANT
  M1(((1) * (1))); // COMPLIANT

// Macros with unbalanced parenthesis:
#define OP_PAREN (
#define CL_PAREN )
  M1(OP_PAREN 1 * 1)
  CL_PAREN; // COMPLIANT -- by rule description, not top level operator.
  OP_PAREN M1(1 CL_PAREN * 1); // NON-COMPLIANT[False negative] -- by rule
                               // description, top level operator.

// Macro expanding to a variable declaration:
#define M6(NAME, INIT) int NAME = INIT;
  M6(l1, 1 * 1);   // NON-COMPLIANT
  M6(l2, (1 * 1)); // COMPLIANT

// Macro expanding to a type:
#define M7(TYPE, NAME, INIT) TYPE NAME INIT;
  M7(int, l3, );                                  // COMPLIANT
  M7(std::vector<int>, l4, );                     // COMPLIANT
  M7(int, l5, = 0);                               // COMPLIANT
  M7(int, l6, = 1 * 1);                           // NON-COMPLIANT
  M7(std::vector<int>, l7, = std::vector<int>()); // COMPLIANT
}

// Macro expanding to a function declaration -- We cannot confidently analyze
// this case.
#define M8(NAME, BODY)                                                         \
  void NAME() { BODY * 2; }
M8(f5, 2 + 2) // NON-COMPLIANT[False negative]

// Macro expanding to a class declaration -- We cannot confidently analyze this
// case.
#define M9(NAME, BODY)                                                         \
  class NAME {                                                                 \
    int x = BODY * 2;                                                          \
  };
M9(C1, 2 + 2) // NON-COMPLIANT[False negative]

// A macro containing every critical operator:
#define M10(X)                                                                 \
  (1 + 1, 1 - 1, 1 * 1, 1 / 1, 1 % 1, 1 << 1, 1 >> 1, 1 < 1, 1 > 1, 1 <= 1,    \
   1 >= 1, 1 == 1, 1 != 1, 1 & 1, 1 ^ 1, 1 | 1, g3 = 1, g3 += 1, g3 -= 1,      \
   g3 *= 1, g3 /= 1, g3 %= 1, g3 <<= 1, g3 >>= 1, g3 &= 1, g3 ^= 1, g3 |= 1,   \
   1 && 1, 1 || 1, 1 ? 1 : 1, X)

void f6() {
  // No critical operators in macro arguments, handled correctly:
  M10(1);     // COMPLIANT -- we can tell no operators are in the macro argument
  M10(g2->x); // COMPLIANT -- we can tell this isn't a lt operator
  M10(g3++);  // COMPLIANT -- we can tell this isn't a binary + operator
  M10(g3--);  // COMPLIANT -- we can tell this isn't a binary - operator
  M10("1 * 1");    // COMPLIANT -- we can tell this is in a string literal
  M10("*"[0] * 1); // NON-COMPLIANT[False negative] --- falsely suppressed

  // Guess that operators are unary based on the first character:
  M10(*"foo"); // COMPLIANT
  M10(&"foo"); // COMPLIANT
  M10(-1);     // COMPLIANT
  M10(+1);     // COMPLIANT

  // No critical operators in macro arguments, handled incorrectly:
  // These falsely look to us like the critical operators are in the macro
  // arguments, but they are not.

  // Compliant, we know the operators are parenthesized and cannot be
  // responsible for the critical operators generated by the macro.
  M10((1 * 1));  // COMPLIANT
  M10((1 - 1));  // COMPLIANT
  M10((1 == 1)); // COMPLIANT

  // Remaining known false positive cases
  M10("foo"[1 + 1]); // NON-COMPLIANT -- by rule description, this is a top
                     // level operator. We also don't handle parsing matching
                     // brackets like this currently. But in practice, this is
                     // not a top level operator.

#define M11(X, Y) f3(X, Y)
  M11(1 * 1, 1); // NON-COMPLIANT by rule, but not a dangerous case.

#define M12(X, Y) (X) + (Y)
#define M13(X, Y) M12(X, Y)
  M13(1 * 1,
      1); // NON-COMPLIANT -- the rule text suggests that this is non
          // compliant, though an argument could be made the other way.
          // Regardless, this case is diffucult for us to detect.
#define M14(X) M1(X *X)
  M14(1); // NON-COMPLIANT[False negative] -- The definition of M13 is
          // non-compliant, but we don't detect the generated elements.

  // Trickier case of # operator to handle. In this case, we do not produce a
  // string literal, which ordinarily is cause to suppress an alert.
#define M15(X, Y) X
#define M16(X) M15((X), #X)
  M16(1 * 1); // COMPLIANT -- all expansions of X are precedence protected.
#define M17(X) M15(X, #X)
  M17(1 *
      1); // NON-COMPLIANT -- not all expansions of X are precedence protected.

  // Spaces should not fool our analysis:
  /* clang-format off */
#define M18(X) ( X )
  M18(1 * 1);     // COMPLIANT
#define M19(X) M15(( X ), # X)
  M16(1 * 1); // COMPLIANT -- all expansions of X are precedence protected.
  /* clang-format on */
}