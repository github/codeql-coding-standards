#include "test.h"
#include "test1.h"

int g = 1; // COMPLIANT

extern int g1; // COMPLIANT

extern int g3; // NON_COMPLIANT