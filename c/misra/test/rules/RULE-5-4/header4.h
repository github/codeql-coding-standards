#define MULTIPLE_INCLUDE // NON_COMPLIANT

// This case is triggered from root2.c
// because PROTECTED isn't defined in
// that case
#ifndef PROTECTED
#define PROTECTED // COMPLIANT - checked by guard
#endif

// Always enabled, so conflicts in root1.c case
#ifdef MULTIPLE_INCLUDE
#define NOT_PROTECTED 1 // NON_COMPLIANT
#endif
