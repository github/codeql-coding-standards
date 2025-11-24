#pragma GCC diagnostic warning "-Wformat" // NON-COMPLIANT
#define TODO(X) _Pragma("TODO: " #X)      // NON-COMPLIANT
void not_Pragma();
#define NOT_PRAGMA not_Pragma() // COMPLIANT
