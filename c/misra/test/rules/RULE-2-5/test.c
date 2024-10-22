#include "test.h"
#define MACRO1 1 // COMPLIANT
#define MACRO2 2 // COMPLIANT
#define MACRO3 3 // NON_COMPLIANT

#undef MACRO1

// This case is not captured by the query
#define MACRO1 1 // NON_COMPLIANT[FALSE_NEGATIVE]

#undef HEADER_MACRO1

void test() {
  MACRO2;
  HEADER_MACRO2;
}

#define CHECKED_MACRO_1 // COMPLIANT - used in branch
#define CHECKED_MACRO_2 // COMPLIANT - used in branch
#define CHECKED_MACRO_3 // COMPLIANT - used in branch

#ifdef CHECKED_MACRO_1
#endif

#ifndef CHECKED_MACRO_2
#endif

#if defined(CHECKED_MACRO_3)
#endif

// In the case above, the extractor will identify macro accesses with each use
// of the macro. In the case above, the extractor does not tie them together,
// but the standard considers this acceptable usage. Notably, this type of
// pattern occurs for header guards.

#ifdef CHECKED_MACRO_BEFORE_1
#endif

#ifndef CHECKED_MACRO_BEFORE_2
#endif

#if defined(CHECKED_MACRO_BEFORE_3)
#endif

#define CHECKED_MACRO_BEFORE_1 // COMPLIANT - used in branch
#define CHECKED_MACRO_BEFORE_2 // COMPLIANT - used in branch
#define CHECKED_MACRO_BEFORE_3 // COMPLIANT - used in branch