#if defined M1 // COMPLIANT
#endif
#if defined(M1) // COMPLIANT
#endif
#if defined(M1) // COMPLIANT
#endif
#if defined M1 && defined M2 // COMPLIANT
#endif
#if defined(M1) && defined(M2) // COMPLIANT
#endif
#if defined // NON-COMPLIANT
#endif
#if defined(M1) && defined // NON-COMPLIANT
#endif
#if defined && defined(M1) // NON-COMPLIANT
#endif
// Compliant, there are no keywords in the context of the preprocessor, only
// identifiers. Therefore, 'new' is a valid identifier.
#if defined new // COMPLIANT
#endif
#if defined(new) // COMPLIANT
#endif

// These cases don't compile in default tests, but may on other compilers
// #if defined 1 // NON-COMPLIANT
// #endif
// #if defined ( 1 ) // NON-COMPLIANT
// #endif
// #if defined + // NON-COMPLIANT
// #endif
// #if defined ( + ) // NON-COMPLIANT
// #endif

#define M1 defined
#define M2 1 + 2 + defined + 3
#define M3 M2
#define M4 1 + 2 + 3
#define M5 M4
#if M1 // NON-COMPLIANT
#endif
#if M2 // NON-COMPLIANT
#endif
#if M3 // NON-COMPLIANT
#endif
#if M4 // COMPLIANT
#endif
#if M5 // COMPLIANT
#endif
