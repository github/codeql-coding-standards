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
