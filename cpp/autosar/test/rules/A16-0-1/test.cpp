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

#ifdef OBJECTLIKE_MACRO_NO // COMPLIANT
int x0 = 0;                // not present
#elif OBJECTLIKE_MACRO > 0 // NON_COMPLIANT
int x0 = 1; // present
#endif                     // COMPLIANT

#ifdef OBJECTLIKE_MACRO     // NON_COMPLIANT
int x1 = 0;                 // present
#elif OBJECTLIKE_MACRO > -1 // NON_COMPLIANT[FALSE_NEGATIVE] - known due to
                            // database not containing elements
int x1 = 1; // not present
#endif                      // COMPLIANT

// case 1 - first present only
#ifdef MACRO_ENABLED_NON_1 // COMPLIANT
#include <string>          //present
#elif MACRO_ENABLED_OTHER  // NON_COMPLIANT[FALSE_NEGATIVE]
int x = 1;  // not present
#endif

// case 2 - second present only
#ifdef MACRO_ENABLED_NON    // COMPLIANT
#include <string>           //not present
#elif MACRO_ENABLED_OTHER_1 // NON_COMPLIANT
int x = 1;  // present
#endif

// case 3 - neither present
#ifdef MACRO_ENABLED_NON  // COMPLIANT
#include <string>         //not present
#elif MACRO_ENABLED_OTHER // NON_COMPLIANT[FALSE_NEGATIVE]
int x = 1;  // not present
#endif

// case 4 - both look present but the second still not bc the condition is not
// required to be evaluated
#ifdef MACRO_ENABLED_NON_1  // COMPLIANT
#include <string>           //present
#elif MACRO_ENABLED_OTHER_1 // NON_COMPLIANT[FALSE_NEGATIVE]
int x = 1;  // not present
#endif