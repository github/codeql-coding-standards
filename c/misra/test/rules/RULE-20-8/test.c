#define false 0
#define true 1
#define extra 17
#define falseAlsoOk false + 1
#define tricky (1)

#if false // COMPLIANT
#endif

#if falseAlsoOk // COMPLIANT[FALSE_POSITIVE]
#endif

#if true // COMPLIANT
#endif

#if tricky // COMPLIANT
#endif

#if extra == 1 // COMPLIANT
#endif

#if defined(extra) // COMPLIANT
#endif

#if defined(extra) && defined(notdefinedmacro) // COMPLIANT
#endif

#if defined(extra) && 17 // COMPLIANT
#endif

#if extra > 1 // COMPLIANT
#endif

#if 17 // NON_COMPLIANT
#endif

#if extra // NON_COMPLIANT
#endif

#if extra + 1 // NON_COMPLIANT[FALSE_NEGATIVE]
#endif

#if false + 1 // COMPLIANT
#endif

#if undefinedmacro // COMPLIANT
#endif

#if false // COMPLIANT
#if 17    // COMPLIANT - not evaluated
#endif
#endif

#if !1 // COMPLIANT
#endif

#if !2 // COMPLIANT
#endif

#if !(2 + 2) // COMPLIANT
#endif

#if 2 + 2 // NON_COMPLIANT
#endif

#if !!2 + !!2 // NON_COMPLIANT
#endif

#if !0 + !0 // NON_COMPLIANT
#endif

#if (1 + 1 + 1) // NON_COMPLIANT
#endif

#if !(1 + 1 + 1) // COMPLIANT
#endif
