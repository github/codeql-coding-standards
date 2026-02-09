int f1(int p1);
int f2(int p1, int p2);

// COMPLIANT -- standard correct cases:
#define M1(X) _Generic((X), int : f1, default : f1)(X)
#define M2(X) _Generic((X), int : f1(X), default : f1(X))

// NON-COMPLIANT -- standard incorrect cases:
#define M3(X) _Generic((X), int : f1(X), default : 0)
#define M4(X) (X) + _Generic((X), int : f1(X), default : f1(X))
#define M5(X) _Generic((X), int : f1(X), default : f1(X)) + (X)
#define M6(X) _Generic((X), int : f1((X) + (X)), default : f1(X))

// Compliant by exception
// COMPLIANT
#define M7(X) _Generic((X), int : 1, default : 0)
// NON-COMPLIANT[FALSE NEGATIVE] -- Without an expansion, we can't tell if this
// macro has only constant expressions or not.
#define M8(X) _Generic((X), int : f1(1))
// NON-COMPLIANT -- If the macro is expanded we can detect constant expressions
#define M9(X) _Generic((X), int : f1)
// NON-COMPLIANT -- If the macro is expanded we can detect constant expressions
#define M10(X) _Generic((X), int : f1(1))
void f3() {
  M9(1);
  M10(1);
}

// COMPLIANT -- multiple uses in the controlling expression is OK:
#define M11(X) _Generic((X) + (X), int : f1(X), default : f1(X))
// NON-COMPLIANT -- the rule should still be enforced otherwise:
#define M12(X) _Generic((X) + (X), int : f1(X), default : 1)
#define M13(X) _Generic((X) + (X), int : f1(X), default : f1(X)) + (X)

// COMPLIANT -- the argument is not used in the controlling expression:
#define M14(X) _Generic(1, int : f1((X) + (X)), default : f1(X))
#define M15(X) _Generic(1, int : f1(X), default : f1(X)) + (X)

// Test cases with more than one argument:
// COMPLIANT -- Y is not used in the controlling expression:
#define M16(X, Y) _Generic((X), int : f2((X), (Y)), default : f2((X), 1))
// NON-COMPLIANT -- Y is used in the controlling expression
#define M17(X, Y) _Generic((X) + (Y), int : f2((X), (Y)), default : f2((X), 1))
// COMPLIANT -- Y is used in the controlling expression correctly
#define M18(X, Y)                                                              \
  _Generic((X) + (Y), int : f2((X), (Y)), default : f2((X), (Y)))

// Test unevaluated contexts:
// COMPLIANT -- sizeof is not evaluated:
#define M19(X) _Generic((X), int[sizeof(X)] : f1, default : f1)(X)
#define M20(X) _Generic((X), int : f1(sizeof(X)), default : f1)(X)
#define M21(X) _Generic((X), int : f1(X), default : f1(X)) + sizeof(X)
// NON-COMPLIANT[FALSE NEGATIVE] -- sizeof plus evaluated context
#define M22(X) _Generic((X), int : f1(sizeof(X) + X), default : f1(X))(X)
// NON-COMPLIANT[FALSE NEGATIVE] -- array type sizes may be evaluated
#define M23(X) _Generic((X), int[X] : f1, default : f1)(X)
// COMPLIANT -- alignof, typeof are not evaluated:
#define M24(X) _Generic((X), int[X] : f1, default : f1)(X)

// Nested macros:
#define ONCE(X) (X)
#define TWICE(X) (X) + (X)
#define IGNORE(X) (1)
#define IGNORE_2ND(X, Y) (X)
// COMPLIANT
#define M25(X) _Generic((X), int: ONCE(f1(X)), default: ONCE(f1(X))
// COMPLIANT[FALSE POSITIVE]
#define M26(X) _Generic((X), int : IGNORE_2ND(X, X), default : IGNORE_2ND(X, X))
#define M27(X) _Generic((X), int : f1(IGNORE(X)), default : f1(IGNORE(X)))(X)
// NON-COMPLIANT[FASE NEGATIVE]
#define M28(X) _Generic((X), int : f1(IGNORE(X)), default : f1(IGNORE(X)))
#define M29(X) _Generic((X), int : TWICE(f1(X)), default : TWICE(f1(X)))