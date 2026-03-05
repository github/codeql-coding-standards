#define QSTRING "string"
#define DOTH .h
#define STRING_PATH "string.h"
#include "string.h"  // COMPLIANT
#include <iostream>  // COMPLIANT
#include STRING_PATH // NON-COMPLIANT
// clang-format off
#include "string" ".h" // NON-COMPLIANT[False negative]
// clang-format on
#include QSTRING DOTH // NON-COMPLIANT

// Invalid directives:
// #include string.h // NON-COMPLIANT
// #include // NON-COMPLIANT
// #include 1 + 1 // NON-COMPLIANT