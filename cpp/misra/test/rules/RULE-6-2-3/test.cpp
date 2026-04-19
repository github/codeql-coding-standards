#include <cstdint>

inline int16_t global_redefined = 0;  // NON_COMPLIANT[False negative]
inline int16_t global_unique = 0;     // COMPLIANT
inline int16_t global_redeclared = 0; // COMPLIANT
inline void func_redefined() {}       // NON_COMPLIANT
inline void func_unique() {}          // COMPLIANT
inline void func_redeclared() {}      // COMPLIANT

// Violates our implementation of 6.2.1, but legal in our implementation
// of 6.2.3
int16_t global_noninline = 0;       // COMPLIANT
int func_noninline() { return 42; } // COMPLIANT

#include "template.h"
#include "compliant_specialization.h"
#include "noncompliant_specialization.h"
