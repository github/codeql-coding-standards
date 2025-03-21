/**
 * Cases where the macro itself is always compliant or non compliant:
 */
// COMPLIANT
#define M1(X) _Generic((X), int : 1, unsigned int : 2)
// COMPLIANT
#define M2(X) _Generic((X), int : 1, unsigned int : 2, default : 0)
// COMPLIANT
#define M3(X) _Generic((X), default : 0, int : 1, unsigned int : 2)
// NON-COMPLIANT
#define M4(X) _Generic((X), int : 1, default : 0, unsigned int : 2)

/**
 * Macros that are compliant or not based on use:
 */
// NON-COMPLIANT: because every use is non compliant
#define M5(...) _Generic(0, __VA_ARGS__, default : 0, int : 1)
// COMPLIANT: because some uses are compliant
#define M6(...) _Generic(0, __VA_ARGS__, int : 1)

void f1() {
  M1(0); // COMPLIANT
  M2(0); // COMPLIANT
  M3(0); // COMPLIANT
  M4(0); // COMPLIANT: the macro invocation is compliant, the macro definition
         // is not.

  // COMPLIANT: all invocations of M5 are non compliant so the macro is reported
  // instead.
  M5(unsigned int : 1);
  M5(unsigned int : 1, long : 2);

  // Some invocations of M6() will be compliant, so we'll report the issue at
  // each invocation.
  M6(default : 0);           // COMPLIANT
  M6(default : 0, long : 1); // COMPLIANT
  M6(long : 1, default : 0); // NON-COMPLIANT
}

/**
 * For completeness, non macro cases, though these are not likely and violate
 * RULE-23-1.
 */
void f2() {
  _Generic(0, int : 1, unsigned int : 2);              // COMPLIANT
  _Generic(0, int : 1, unsigned int : 2, default : 0); // COMPLIANT
  _Generic(0, default : 0, int : 1, unsigned int : 2); // COMPLIANT
  _Generic(0, int : 1, default : 0, unsigned int : 2); // NON-COMPLIANT
}