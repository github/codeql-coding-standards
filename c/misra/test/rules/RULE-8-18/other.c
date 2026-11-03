// semmle-extractor-options:--clang -std=c11 -nostdinc
int cross_tu_object = 0; // COMPLIANT

#define INITIALIZE_CONDITIONAL
#include "conditional.h"
