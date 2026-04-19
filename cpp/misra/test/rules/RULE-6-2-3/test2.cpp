#include <cstdint>

inline int16_t global_redefined = 0;     // NON_COMPLIANT[False negative]
extern inline int16_t global_redeclared; // COMPLIANT
inline void func_redefined() {}          // NON_COMPLIANT -- flagged in test.cpp
inline void func_redeclared();           // COMPLIANT

// Violates our implementation of 6.2.1, but legal in our implementation
// of 6.2.3
int16_t global_noninline = 0;       // COMPLIANT
int func_noninline() { return 42; } // COMPLIANT