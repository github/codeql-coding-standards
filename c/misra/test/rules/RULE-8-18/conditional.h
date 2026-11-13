#ifdef INITIALIZE_CONDITIONAL
int conditional_after = 1; // COMPLIANT
#else
int conditional_after;      // NON_COMPLIANT
#endif

#ifndef INITIALIZE_CONDITIONAL
int conditional_before; // NON_COMPLIANT
#else
int conditional_before = 1; // COMPLIANT
#endif
