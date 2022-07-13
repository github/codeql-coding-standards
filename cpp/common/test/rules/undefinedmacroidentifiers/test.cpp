#define MACROONE 0

#if NOTDEF // NON_COMPLIANT
#endif

#ifdef NOTDEF // COMPLIANT
#endif

#ifndef NOTDEF // COMPLIANT
#endif

#if MACROONE   // COMPLIANT
#elif MACROONE // COMPLIANT
#endif

#if defined(MACROONE) // COMPLIANT
#endif

#if defined NOTDEF // COMPLIANT
#endif

#if defined(MACROONE) // COMPLIANT
#endif

#if defined(MACROONE) || NOTDEF // NON_COMPLIANT
#endif

// clang-format off
#if defined (MACROONE) || NOTDEF // NON_COMPLIANT
#endif
// clang-format on

#define MACROTWO 0

#if MACROTWO // COMPLIANT
#endif
#undef MACROTWO

#if MACROTWO // NON_COMPLIANT
#endif

#define MACROTWO 0
#if MACROTWO // COMPLIANT
#endif

#if 1 + 1 > 3 // COMPLIANT
#endif

#if defined MACROTHREE && (defined(MACROONE))
#if MACROONE // COMPLIANT
#endif
#endif