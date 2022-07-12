#if defined(X) // COMPLIANT
#endif
#if defined(X) // COMPLIANT
#endif
#if defined X // COMPLIANT
#endif

#if defined X > Y   // NON_COMPLIANT
#elif defined X < Y // NON_COMPLIANT
#endif

#if test
#if defined(X > Y)   // NON_COMPLIANT
#elif defined(X < Y) // NON_COMPLIANT
#endif
#endif

#define BADDEF defined
#define USES BADDEF
#define WRAPUSES USES
#define DBLWRAPUSES USES
#if DBLWRAPUSES(X) // NON_COMPLIANT
#endif

#define BADDEFTWO(X) defined(X)
#if BADDEFTWO(X) // NON_COMPLIANT
#endif

// clang-format off
#if defined (X) || (defined(_Y_)) // COMPLIANT
// clang-format on
#endif

#if defined(X) || defined _Y_ + X && defined(Y) // NON_COMPLIANT
#endif