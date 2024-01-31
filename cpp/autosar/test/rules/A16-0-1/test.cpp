#include <string> //COMPLIANT

#pragma gcc testingpragma // COMPLIANT - exception - already reported by A16-7-1

#ifndef TESTHEADER // NON_COMPLIANT
int g;
#endif

#define OBJECTLIKE_MACRO 1            // NON_COMPLIANT
#define FUNCTIONLIKE_MACRO(X) X + 1   // NON_COMPLIANT
#define FUNCTIONLIKE_MACROTWO() 1 + 1 // NON_COMPLIANT

#ifndef TESTHEADER // COMPLIANT
#define TESTHEADER // COMPLIANT
#endif

#ifndef TESTHEADER // COMPLIANT
#include <string>  //COMPLIANT
#endif             // COMPLIANT

#ifdef MACRO_ENABLED // COMPLIANT
#include <string>    // COMPLIANT
#else                // COMPLIANT
#include <string>    // COMPLIANT
#endif               // COMPLIANT

#ifdef MACRO_ENABLED_NON  // COMPLIANT
#include <string>         // COMPLIANT
#elif MACRO_ENABLED_OTHER // COMPLIANT
#include <string>         // COMPLIANT
#endif                    // COMPLIANT

#ifdef OBJECTLIKE_MACRO_NO // NON_COMPLIANT
int x = 0;                 // not present
#elif OBJECTLIKE_MACRO > 0 // NON_COMPLIANT
int x = 1;  // present
#endif                     // COMPLIANT

#ifdef OBJECTLIKE_MACRO // NON_COMPLIANT
int x1 = 0;             // present
#elif OBJECTLIKE_MACRO >                                                       \
    -1 // COMPLIANT - by technicality of conditional compilation
int x1 = 1; // not present
#endif // COMPLIANT