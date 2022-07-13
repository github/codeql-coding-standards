#include "test.h"

extern int g2; // NON_COMPLIANT; should be declared in a header file.
unsigned short g1 = 0;
int g3 = g1 + g2;
extern int g4;   // NON_COMPLIANT[FALSE_NEGATIVE]; results in a different
                 // declaration due to a different type
using Bar = int; // COMPLIANT; this is a type alias, not a declaration.