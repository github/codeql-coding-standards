#define MACRO(X, Y) (X * Y)        // NON_COMPLIANT
#define MACROTWO(X, Y) ((X) * (Y)) // COMPLIANT
#define MACROTHREE(X) a##X *(X)    // COMPLIANT
#define MACROFOUR(X, Y) (X).Y      // COMPLIANT[FALSE_POSITIVE]

#define MACROFIVE(Y) MACROSIX(Y) // COMPLIANT
#define MACROSIX(X) ((X) + 1)    // COMPLIANT