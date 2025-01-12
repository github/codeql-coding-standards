#ifdef FOO
#include "header1.h"
#else
#include "header2.h"
#endif

#ifdef FOO
#define A_MACRO 1 // COMPLIANT
#else
#define A_MACRO 2 // COMPLIANT
#endif